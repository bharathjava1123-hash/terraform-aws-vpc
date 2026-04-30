variable "cidr_block" {
  type        = string
  
}

variable "project_name" {
  type        = string
  
}

variable "environment" {
  type        = string
  
}

variable "common_tags" {
 default = {}
  
}

variable "vpc_tags" {
    default = {}
}

variable "igw_tags" {
    default = {}
}
variable "nat_gateway_tags" {
  default     = {}
}
 variable "db_subnet_group_tags" {
   default     = {}
 }
 

variable "public_subnet_cidr_block" {
 type = list
    validation {
        condition = length(var.public_subnet_cidr_block) == 2
        error_message = "Please provide 2 valid public subnet CIDR"
    }  
}

variable "private_subnet_cidr_block" {
 type = list
    validation {
        condition = length(var.private_subnet_cidr_block) == 2
        error_message = "Please provide 2 valid public subnet CIDR"
    }  
}

variable "database_subnet_cidr_block" {
 type = list
    validation {
        condition = length(var.database_subnet_cidr_block) == 2
        error_message = "Please provide 2 valid public subnet CIDR"
    }  
}

variable "aws_subnet_tags" {
  default     = {}
}

variable "route_table_tags" {
  default     = {}
}

