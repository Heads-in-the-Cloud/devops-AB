# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = [ "amazon" ]
#   filter {
#     name   = "name"
#     values = [ "amzn2-ami-hvm*" ]
#   }
# }

resource "aws_security_group" "ssh" {
  name        = "${var.project_id}-ssh"
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
    Name = "${var.project_id}-ssh"
  }
}

data "aws_iam_policy_document" "default" {
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

resource "aws_iam_role" "default" {
  name = "${var.project_id}-bastion"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role = aws_iam_role.default.name
  policy_arn = var.policy_arn
}

resource "aws_iam_instance_profile" "default" {
  name = "${var.project_id}-bastion"
  role = aws_iam_role.default.name
}

resource "aws_instance" "default" {
  vpc_security_group_ids = [ aws_security_group.ssh.id ]
  iam_instance_profile   = aws_iam_instance_profile.default.name
  instance_type  = var.instance_type
  subnet_id      = var.subnet_id
  ami            = "ami-0b3456eff9b6f87f1" # data.aws_ami.amazon_linux_2.id
  user_data      = var.user_data

  tags = {
    Name = "${var.project_id}-bastion"
  }
}
