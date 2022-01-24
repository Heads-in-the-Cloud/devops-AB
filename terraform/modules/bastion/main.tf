data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = [ "amazon" ]
  filter {
    name   = "name"
    values = [ "amzn2-ami-hvm*" ]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh-${var.project_id}"
  description = "Inbound to only 22 from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  tags = {
    Name = "ssh-${var.project_id}"
  }
}

data "aws_iam_policy_document" "bastion" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "bastion" {
  name = "bastion-${var.project_id}"
  assume_role_policy = data.aws_iam_policy_document.bastion.json
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role = aws_iam_role.bastion.name
  policy_arn = var.policy_arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion-${var.project_id}"
  role = aws_iam_role.bastion.name
}

resource "aws_key_pair" "bastion" {
  key_name = "bastion-${var.project_id}"
  public_key = var.public_ssh_key
}

resource "aws_instance" "bastion" {
  vpc_security_group_ids = [ aws_security_group.ssh.id ]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  instance_type = var.instance_type
  key_name      = aws_key_pair.bastion.key_name
  subnet_id     = var.subnet_id
  ami           = data.aws_ami.amazon_linux_2.id
  user_data     = var.user_data

  tags = {
    Name = "bastion-${var.project_id}"
  }
}
