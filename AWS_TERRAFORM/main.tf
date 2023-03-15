# 1. VPC 생성
# 2. EIP 생성(2개)
# 3. 서브넷 생성 ( 10.0.10.0/24    # 10.0.20.0/24    # 10.0.11.0/24      # 10.0.21.0/24      # 10.0.12.0/24      # 10.0.12.0/24)
#                 public_subnet_A # public_subnet_B # public_subnet_A_1 # public_subnet_A_2 # public_subnet_B_1 # public_subnet_B_2
# 4. NAT GW
# 5. Internet GW
# 6. Route 3개 ( Public Route / Private 1 / Private 2 )

# -------------------------------Create the VPC
resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project_vpc"
  }
}

# -------------------------------Create the two Elastic IPs
resource "aws_eip" "public_eip1" {
  vpc = true
  tags = {
    Name = "public_eip1"
  }
}
resource "aws_eip" "public_eip2" {
  vpc = true
  tags = {
    Name = "public_eip2"
  }
}


# Create the six subnets
resource "aws_subnet" "public_subnet_A" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Public-Subnet-at-zone-A"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/EKS-cluster01" = "owned"
  }
}

resource "aws_subnet" "public_subnet_B" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Public-Subnet-at-zone-B"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/EKS-cluster01" = "owned"
  }
}

resource "aws_subnet" "private_subnet_A_1" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Private-Subnet-at-zone-A-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/EKS-cluster01" = "owned"
  }
}

resource "aws_subnet" "private_subnet_A_2" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Private-Subnet-at-zone-A-2"
    "kubernetes.io/cluster/EKS-cluster01" = "shared"
  }
}

resource "aws_subnet" "private_subnet_B_1" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "Private-Subnet-at-zone-B-1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/EKS-cluster01" = "owned"
  }
}

resource "aws_subnet" "private_subnet_B_2" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "Private-Subnet-at-zone-B-2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/EKS-cluster01" = "owned"
  }
}

#--------------------------------Create the NAT Gateway 
resource "aws_nat_gateway" "nat_gateway_A" {
  allocation_id = aws_eip.public_eip1.id
  subnet_id     = aws_subnet.public_subnet_A.id

  tags = {
    Name = "nat-gateway-A"
  }
}

resource "aws_nat_gateway" "nat_gateway_B" {
  allocation_id = aws_eip.public_eip2.id
  subnet_id     = aws_subnet.public_subnet_B.id

  tags = {
    Name = "nat-gateway-B"
  }
}

#--------------------------------Create the Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

#Create the Routing Table

#----------------------Route1----------------------------#
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_A_association" {
  subnet_id      = aws_subnet.public_subnet_A.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_B_association" {
  subnet_id      = aws_subnet.public_subnet_B.id
  route_table_id = aws_route_table.public_route_table.id
}


#----------------------Private Route1----------------------------#
resource "aws_route_table" "private_route_table_A" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_A.id
  }
  tags = {
    Name = "private-route-table-A"
  }
}

# Add route to the NAT gateway for internet access
resource "aws_route_table_association" "private_subnet_A_1_association" {
  subnet_id      = aws_subnet.private_subnet_A_1.id
  route_table_id = aws_route_table.private_route_table_A.id
}
resource "aws_route_table_association" "private_subnet_A_2_association" {
  subnet_id      = aws_subnet.private_subnet_A_2.id
  route_table_id = aws_route_table.private_route_table_A.id
}
#----------------------Private Route2----------------------------#

resource "aws_route_table" "private_route_table_B" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.nat_gateway_B.id
  }

  tags = {
    Name = "private-route-table-B"
  }
}

resource "aws_route_table_association" "private_subnet_B_1_association" {
  subnet_id      = aws_subnet.private_subnet_B_1.id
  route_table_id = aws_route_table.private_route_table_B.id
}
resource "aws_route_table_association" "private_subnet_B_2_association" {
  subnet_id      = aws_subnet.private_subnet_B_2.id
  route_table_id = aws_route_table.private_route_table_B.id
}