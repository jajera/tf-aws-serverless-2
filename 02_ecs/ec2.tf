data "aws_ami" "amzn2023" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "imagebuilder" {
  ami                         = data.aws_ami.amzn2023.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.imagebuilder.name
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.private.ids[0]

  vpc_security_group_ids = [
    data.aws_security_groups.ssh.ids[0]
  ]

  user_data = <<-EOF
              #!/bin/bash -xe
              hostnamectl set-hostname imagebuilder
              dnf update -y
              dnf install -y docker tree

              # configure docker
              systemctl start docker
              systemctl enable docker

              # optional
              usermod -aG docker ec2-user
              chmod 666 /var/run/docker.sock
              systemctl restart docker

              REPO_URL="${aws_ecr_repository.app1.repository_url}"
              S3_BUCKET="${aws_s3_bucket.app1.bucket}"
              AWS_REGION="${data.aws_region.current.name}"
              APP_NAME="app1"

              # download source
              mkdir -p ~/workspace
              aws s3 sync s3://$S3_BUCKET ~/workspace/
              cd ~/workspace/

              # build image
              docker buildx build -t $APP_NAME:latest .
              docker tag $APP_NAME:latest $REPO_URL:$APP_NAME-latest

              # upload image
              aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $REPO_URL
              docker push $REPO_URL:$APP_NAME-latest
              EOF

  tags = {
    Name = "ecr-image-upload-imagebuilder-${local.suffix}"
  }
}
