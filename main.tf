resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = var.project_name
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = var.project_name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-Public-${local.azs[count.index]}"
    }

  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-Private-${local.azs[count.index]}"
    }

  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr_block[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-Database-${local.azs[count.index]}"
    }

  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-Public"
    },
    var.public_route_table_tags
  )
}

# Creating ElasticIP for NAT Gateway
resource "aws_eip" "eip" {
  domain   = "vpc"
  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    }
  )
}

# Creating NAT Gateway for Private and Database subnets
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.ngw_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-Private"
    },
    var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-Database"
    },
    var.database_route_table_tags
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_block)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr_block)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

# Grouping Database Subnets
# which you can see in AWS-->RDS-->Subnet groups
resource "aws_db_subnet_group" "default" {
  name       = "roboshop"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.db_subnet_group_tags
  )
}