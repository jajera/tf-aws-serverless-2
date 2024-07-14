data "aws_vpc" "example" {
  id = local.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}

data "aws_route_table" "private" {
  for_each = toset(data.aws_subnets.private.ids)

  subnet_id = each.value
}

data "aws_security_groups" "ssh" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.example.id]
  }

  filter {
    name   = "group-name"
    values = ["serverless-2-ssh-${local.suffix}"]
  }

  tags = {
    Name  = "serverless-2-ssh-${local.suffix}"
  }
}

resource "aws_security_group" "app1_endpoint" {
  name        = "serverless-2-app1-endpoint-${local.suffix}"
  vpc_id      = data.aws_vpc.example.id

  ingress {
    description = "allow https incoming traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "serverless-2-app1-endpoint-${local.suffix}"
  }
}

resource "aws_security_group" "app1_lb" {
  name        = "serverless-2-app1-lb-${local.suffix}"
  vpc_id      = data.aws_vpc.example.id

  ingress {
    description = "allow lb incoming traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "serverless-2-app1-lb-${local.suffix}"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = data.aws_vpc.example.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  
  security_group_ids  = [
    aws_security_group.app1_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name  = "serverless-2-private-ecr-${local.suffix}"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.example.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  
  security_group_ids  = [
    aws_security_group.app1_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name  = "serverless-2-private-ecr-api-${local.suffix}"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = data.aws_vpc.example.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  
  security_group_ids  = [
    aws_security_group.app1_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name  = "serverless-2-private-cw-${local.suffix}"
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = data.aws_vpc.example.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  
  security_group_ids  = [
    aws_security_group.app1_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name  = "serverless-2-private-sm-${local.suffix}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id              = data.aws_vpc.example.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name  = "serverless-2-private-s3-${local.suffix}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each = data.aws_route_table.private

  route_table_id  = each.value.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
