# 1. Create the EKS 보안그룹
# 2. EKS Master서버 역할
# 3. EKS노드서버 역할
# 4. EFS 클라이언트 전송 중 암호화를 활성화, 루트 액세스 비활성화하는 IAM 정책 




# -----------------------------------Create the EKS 보안그룹-------------------------------#
resource "aws_security_group" "EKS-security-group" {
  name_prefix = "EKS-security-group"
  vpc_id      = aws_vpc.project_vpc.id

  # Inbound rule to allow all traffic
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------EKS Master서버 역할-----------------------------#

resource "aws_iam_role" "clusterRole" {
  name = "clusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "my_eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.clusterRole.name
}

#------------------EKS노드서버 역할--------------------------------#

resource "aws_iam_role" "node_group" {
  name = "Node-group"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "container_registry_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}


#----------------------mariadb 보안그룹------------------------------#

resource "aws_security_group" "mariadb" {
  name_prefix = "mariadb-security"
  vpc_id = aws_vpc.project_vpc.id

#개인 ip
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["58.120.204.126/32"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.EKS-security-group.id]
  }
# 모든 ip
/*   ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  */
}
