


#-----------------------maria db group 생성-----------------------#
resource "aws_db_subnet_group" "mariadb-public-group" {
  name        = "mariadb-subnet-group"
  description = "mariadb subnet group for RDS"

  subnet_ids = [
    aws_subnet.public_subnet_A.id,
    aws_subnet.public_subnet_B.id,
  ]
}



#-----------------------db 생성-----------------------------------#
resource "aws_db_instance" "mariadb" {
  identifier            = "admin"
  engine                = "mariadb"
  engine_version        = "10.4"
  instance_class        = var.cpu
  allocated_storage     = var.storage
  storage_type          = "gp2"
  publicly_accessible   = true
  db_subnet_group_name  = aws_db_subnet_group.mariadb-public-group.id
  vpc_security_group_ids = [aws_security_group.mariadb.id]
  username              = "admin"
  password              = var.passwd
  skip_final_snapshot       = true
}

