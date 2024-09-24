provider "aws" {
  region = "eu-west-3"
}

data "aws_vpc" "euw-3_vpc" {
  id = var.vpc-vpc-euw-3
}

# Create subnet space

resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = data.aws_vpc.euw-3_vpc.id
  cidr_block        = var.eu_subnets.subnet_a.cidr
  availability_zone = var.eu_subnets.subnet_a.az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = data.aws_vpc.euw-3_vpc.id
  cidr_block        = var.eu_subnets.subnet_b.cidr
  availability_zone = var.eu_subnets.subnet_b.az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-az2"
  }
}

data "aws_internet_gateway" "euw-3_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.euw-3_vpc.id]
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = data.aws_vpc.euw-3_vpc.id
  tags = {
    Name = "public-route-table"
  }
}

# Add a route to the Internet Gateway in the route table
resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.euw-3_igw.id
}

# Associate the Route Table with both public subnets
resource "aws_route_table_association" "public_route_association_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_association_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}


# Security

resource "aws_key_pair" "aws_key" {
  key_name = "aws-key" 
}


resource "aws_security_group" "aws_sg" {
  id = var.security_group_id
}

# Create the first EC2 instance (Node API) in subnet 1 (AZ 1)

resource "aws_instance" "node_api_instance" {
  ami           = var.ami.id
  instance_type = var.ami.instance_type

  key_name = aws_key_pair.aws_key.key_name

  vpc_security_group_ids = [aws_security_group.aws_sg.id]

  subnet_id  = aws_subnet.public_subnet_az1.id
  associate_public_ip_address = true  

  tags = {
    Name = "node-api-instance"
  }
}

# Create the second EC2 instance (Monitoring) in subnet 2 (AZ 2)
resource "aws_instance" "monitoring_instance" {
  ami           = var.ami.id
  instance_type = var.ami.instance_type

  key_name = aws_key_pair.aws_key.key_name

  vpc_security_group_ids = [aws_security_group.aws_sg.id]

  subnet_id  = aws_subnet.public_subnet_az2.id
  associate_public_ip_address = true 

  tags = {
    Name = "monitoring-instance"
  }
}

# Create the third EC2 instance (Delivery) in subnet 1 (AZ 1)
resource "aws_instance" "delivery_instance" {
  ami           = var.ami.id
  instance_type = var.ami.instance_type

  key_name = aws_key_pair.aws_key.key_name

  vpc_security_group_ids = [aws_security_group.aws_sg.id]

  subnet_id  = aws_subnet.public_subnet_az1.id
  associate_public_ip_address = true

  tags = {
    Name = "delivery-instance"
  }
}

# Create the fourth EC2 instance (Database) in subnet 2 (AZ 2)
resource "aws_instance" "database_instance" {
  ami           = var.ami.id
  instance_type = var.ami.instance_type

  key_name = aws_key_pair.aws_key.key_name

  vpc_security_group_ids = [aws_security_group.aws_sg.id]

  subnet_id  = aws_subnet.public_subnet_az2.id
  associate_public_ip_address = false  # No public IP for the database instance (for security)

  private_ip = var.db_private_ip

  tags = {
    Name = "database-instance"
  }

  # Attach additional volume for the database
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # Add a second EBS volume for database storage
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 10
    volume_type = "gp3"
  }
}
