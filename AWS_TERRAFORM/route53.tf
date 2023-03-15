# 1. DNS 생성
# 2. DNS 네임서버 출력
# 3. ACM 생성


#------------------------DNS 생성 --------------------------------#

resource "aws_route53_zone" "main" {
  name = var.DNS_name
}

#---------------------------------DNS resource name output------------------#

output "example_name_servers" {  
  value = aws_route53_zone.main.name_servers
}

#-------------Amazon Certificate Manager----------------

resource "aws_acm_certificate" "cert" {
  domain_name       = var.DNS_name
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}