# 1. EKS cluster
# 2. EKS Node
# 3. 



#----------------------------EKS cluster-------------------------------#


resource "aws_eks_cluster" "EKS-cluster01" {
  name = var.cluster-name
  role_arn = aws_iam_role.clusterRole.arn
  version = "1.24"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_A_1.id,
      aws_subnet.private_subnet_B_1.id,
      aws_subnet.private_subnet_B_2.id
    ]
    security_group_ids = [aws_security_group.EKS-security-group.id]
    endpoint_public_access = true
    endpoint_private_access = true
  }

}
output "endpoint" {
  value = aws_eks_cluster.EKS-cluster01.endpoint 
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.EKS-cluster01.certificate_authority[0].data
}
#----------------------EKS Node ---------------------------------------#



resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.EKS-cluster01.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [
    aws_subnet.private_subnet_A_1.id,
    aws_subnet.private_subnet_B_1.id,
    aws_subnet.private_subnet_B_2.id,
  ]
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }
}
