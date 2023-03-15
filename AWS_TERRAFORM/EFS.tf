# 1. EFS 보안 그룹 생성
# 2. EFS 파일 시스템을 생성
# 3. mount



#-----------------------보안 그룹을 생성-----------------------------------------------#
resource "aws_security_group" "my_efs_security_group" {
  name_prefix = "MyEfsSecurityGroup"
  description = "My EFS security group"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#--------------인바운드 규칙을 생성
resource "aws_security_group_rule" "example" {
  type        = "ingress"
  security_group_id = aws_security_group.my_efs_security_group.id
  protocol    = "tcp"
  from_port   = 2049
  to_port     = 2049
  cidr_blocks = ["10.0.0.0/16"]
}

#-------------- EFS 파일 시스템을 생성-----------------------------------------------#

# EFS 파일 시스템 생성
resource "aws_efs_file_system" "efs_01" {
  creation_token = "efs-standard" # 생성 토큰 설정
  performance_mode = "generalPurpose" # 성능 모드: generalPurpose(범용 모드), maxIO(최대 IO 모드)
  encrypted = true # 암호화 사용 여부 설정
  tags = {
    Name = "efs-standard"
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
} 



#-------------------------------------mount!!----------------------------------------------#


resource "aws_efs_mount_target" "efs-mount-A" {
  file_system_id   = aws_efs_file_system.efs_01.id
  subnet_id        = aws_subnet.private_subnet_A_1.id
  security_groups  = [aws_security_group.my_efs_security_group.id]
}


resource "aws_efs_mount_target" "efs-mount-B" {
  file_system_id   = aws_efs_file_system.efs_01.id
  subnet_id        = aws_subnet.private_subnet_A_2.id
  security_groups  = [aws_security_group.my_efs_security_group.id]
}

