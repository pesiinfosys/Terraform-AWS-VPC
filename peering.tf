### VPC Peering with Default VPC
resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  # peer_owner_id = var.peer_owner_id
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = var.requester_vpc_id
  auto_accept   = true

  tags = merge(
    var.common_tags,
    {
      Name = "VPC Peering between default vpc and ${var.project_name} vpc"
    }
  )
}
# add route in default subnet
resource "aws_route" "default_subnet_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# add route in roboshop public subnet
resource "aws_route" "roboshop_public_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.default_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# add route in roboshop private subnet
resource "aws_route" "roboshop_private_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.default_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# add route in roboshop database subnet
resource "aws_route" "roboshop_database_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = var.default_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}