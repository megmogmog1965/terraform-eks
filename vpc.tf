# VPCの設定
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# パブリックサブネットの設定
resource "aws_subnet" "eks_public_subnet" {
  count                   = 2  # 2つのパブリックサブネットを作成
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index}"
  }
}

# プライベートサブネットの設定
resource "aws_subnet" "eks_private_subnet" {
  count                   = 2  # 2つのプライベートサブネットを作成
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + 2)  # 異なるCIDRを設定
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "eks-private-subnet-${count.index}"
  }
}

# パブリックルートテーブルの設定
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

# プライベートルートテーブルの設定
resource "aws_route_table" "eks_private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-private-route-table"
  }
}

# パブリックルートテーブルのサブネット関連付け
resource "aws_route_table_association" "eks_public_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_route_table.id
}

# プライベートルートテーブルのサブネット関連付け
resource "aws_route_table_association" "eks_private_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
  route_table_id = aws_route_table.eks_private_route_table.id
}