data "aws_vpc" "example" {
  id = local.vpc_id
}

data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.example.id]
  }

  filter {
    name   = "tag:Name"
    values = ["database*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.example.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

data "aws_security_groups" "app1_lb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.example.id]
  }

  filter {
    name   = "group-name"
    values = ["serverless-2-app1-lb-${local.suffix}"]
  }

  tags = {
    Name  = "serverless-2-app1-lb-${local.suffix}"
  }
}
