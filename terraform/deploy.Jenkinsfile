#!groovy
pipeline {
    agent any

    environment {
        environment = "dev"
        region      = "us-west-2"
        project_id  = "AB-utopia"

        s3_bucket        = PROJECT_ID.toLowerCase()
        vpc_cidr_block   = "10.0.0.0/16"
        subdomain_prefix = PROJECT_ID.toLowerCase()
        domain           = "hitwc.link"
    }

    stages {
        stage('Init & Plan') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            sh "terraform init -backend-config='bucket=$s3_bucket' -backend-config='region=$REGION'"
                            sh "terraform workspace select $ENV || terraform workspace new $ENV"
                            sh """
                                cat > terraform.tfvars << EOF
                                    region = "$REGION"
                                    s3_bucket = "$s3_bucket"
                                    name_prefix = "$PROJECT_ID"
                                    environment = "$ENV"
                                    vpc_cidr_block = "$vpc_cidr_block"
                                    num_availability_zones = "$num_availability_zones"
                                    subdomain_prefix = "$subdomain_prefix"
                                    domain = "$domain"
                                EOF
                            """
                            sh "terraform plan -input=false -out=tfplan"
                        }
                    }
                    sh "terraform show tfplan"
                }
            }
        }

        stage('Apply') {
            steps {
                dir("terraform") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh "terraform apply -input=false tfplan"
                        sh "terraform output -json > outputs.json"
                        sh "aws s3 cp file://outputs.json s3://$s3_bucket/env:/$ENV/tf_output_backup.json"
                    }
                }
            }
        }
    }
}
