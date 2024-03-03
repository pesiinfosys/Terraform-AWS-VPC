variable "cidr_block" {
  
}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "common_tags" {
  default = {}
}

variable "vpc_tags" {
  default = {}
}

variable "project_name" {
  
}

variable "igw_tags" {
  default = {}
}

variable "public_subnet_cidr_block" {
    type = list
    validation {
      condition = length(var.public_subnet_cidr_block) == 2
      error_message = "Please provide 2 public subnet CIDRs"
    }
}

variable "private_subnet_cidr_block" {
    type = list
    validation {
      condition = length(var.private_subnet_cidr_block) == 2
      error_message = "Please provide 2 private subnet CIDRs"
    }
}

variable "database_subnet_cidr_block" {
    type = list
    validation {
      condition = length(var.database_subnet_cidr_block) == 2
      error_message = "Please provide 2 Database subnet CIDRs"
    }
}

variable "public_route_table_tags" {
  default = {}
}

variable "ngw_tags" {
  default = {}
}

variable "private_route_table_tags" {
  default = {}
}

variable "database_route_table_tags" {
  default = {}
}

variable "db_subnet_group_tags" {
  default = {}
}

variable "requester_vpc_id" {
  default = {} 
}

variable "is_peering_required" {
  default = false
}