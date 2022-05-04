#create vpc
resource "aws_vpc" "mainvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MercuryVPC"
  }
}

#create igw and attach it to MercuryVPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "MercuryIGW"
  }
}

#create 1 frontend 1 backend subnet
#frontend
resource "aws_subnet" "pub-frontend" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "frontend_public_subnet"
  }
}

#backend
resource "aws_subnet" "pvt-backend" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.20.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "backend_private_subnet"
  }
}

#create elastic ip

resource "aws_eip" "lb" {
  tags = {
    Name = "MercuryEIP"
  }
}

#create nat
resource "aws_nat_gateway" "pubnat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.pub-frontend.id

  tags = {
    Name = "MercuryPublicNAT"
  }
}


#main public router table
resource "aws_default_route_table" "mercurypubtroute" {
  default_route_table_id = aws_vpc.mainvpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "MercuryPubRouteTable"
  }
} 

#public route table - add public subnet 
resource "aws_route_table_association" "mercurypubtroute" {
  subnet_id      = aws_subnet.pub-frontend.id
  route_table_id = aws_vpc.mainvpc.default_route_table_id
}

#create private route table - add nat
resource "aws_route_table" "mercurypvtroute" {
  vpc_id = aws_vpc.mainvpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.pubnat.id
  }

  tags = {
    Name = "MercuryPvtRouteTable"
  }

}

#private route table - add private subnet 
resource "aws_route_table_association" "routetablepvtsubnet" {
  subnet_id      = aws_subnet.pvt-backend.id
  route_table_id = aws_route_table.mercurypvtroute.id
}


#create 2 security group 1 public 1 private
#public
resource "aws_security_group" "allow_tls" {
  name        = "Public"
  description = "Allow 22 80 8080 443 inbound traffic"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "TLS from webservice "
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "Public -22 80 8080 443"
  }
}

#2 private 
resource "aws_security_group" "block_tls" {
  name        = "Private"
  description = "backend SG"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups = [aws_security_group.allow_tls.id]
    
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow_tls.id]
    
  }

  tags = {
    Name = "Private SG "
  }
}
