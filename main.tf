resource "aws_vpc" "main" {
  cidr_block   =  var.cidr_block

  tags = merge (
    var.common_tags,
    var.vpc_tags,
    {
    Name = local.resource_name
   }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags =merge(
    var.common_tags,
    var.igw_tags,
    {
    Name = local.resource_name
  }
  )
}

resource "aws_subnet" "public" {
 count = length(var.public_subnet_cidr_block)
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidr_block[count.index]
 availability_zone   = data.aws_availability_zones.available.names[count.index]
  tags = merge(
   var.common_tags,
    var.aws_subnet_tags,
    {
    Name = "${local.resource_name}-public-${data.aws_availability_zones.available.names[count.index]}"
  })
}

resource "aws_subnet" "private" {
 count = length(var.private_subnet_cidr_block)
 vpc_id     = aws_vpc.main.id
 cidr_block = var.private_subnet_cidr_block[count.index]
 availability_zone   = data.aws_availability_zones.available.names[count.index]
  tags = merge(
   var.common_tags,
    var.aws_subnet_tags,
    {
    Name = "${local.resource_name}-private-${data.aws_availability_zones.available.names[count.index]}"
  })
}

resource "aws_subnet" "database" {
 count = length(var.database_subnet_cidr_block)
 vpc_id     = aws_vpc.main.id
 cidr_block = var.database_subnet_cidr_block[count.index]
 availability_zone   = data.aws_availability_zones.available.names[count.index]
  tags = merge(
   var.common_tags,
    var.aws_subnet_tags,
    {
    Name = "${local.resource_name}-database-${data.aws_availability_zones.available.names[count.index]}"
  })
}

# DB Subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_eip" "lb" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
    Name =  local.resource_name
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.route_table_tags,
    {
    Name =  "${local.resource_name}-public"
  })
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.route_table_tags,
    {
    Name =  "${local.resource_name}-private"
  })
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.route_table_tags,
    {
    Name =  "${local.resource_name}-database"
  })
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =  aws_internet_gateway.main.id
}


resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.main.id
}


resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.main.id
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidr_block)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}