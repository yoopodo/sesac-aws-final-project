# 1. 필수 변경
# 2. 선택 사항

#---------------------------------------필수!!-------------------------------------------------#

variable "user_number" {
  description = "유저 id를 입력하세요"
  type        = number
  default     = 524297582387
}

variable "DNS_name" {
  description = "도메인 이름"
  type = string
  default = "jhyoo.shop"
}

variable "region" {
  description = "리전을 입력하세요"
  type        = string
  default     = "ap-northeast-2"
}

variable "imagerepo" {
  description = "리전에 맞는 레지스트리를 입력하세요" 
#     https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/add-ons-images.html
  type        = string
  default     = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
}



#-------------------------------------------선택-----------------------------------------------#


#--------------EKS 설정---------------------#

variable "desired_size" {
  description = "기본 eks 클러스터 갯수"
  type        = number
  default     = 2
}
variable "max_size" {
  description = "최소 eks 클러스터 갯수"
  type        = number
  default     = 2
}
variable "min_size" {
  description = "최대 eks 클러스터 갯수"
  type        = number
  default     = 2
}

#------------------------고정-------------------------------#

variable "cluster-name" {
  description = "클러스터이름"
  type        = string
  default     = "EKS-cluster01"
}
variable "vpc_range" {
  description = "vpc범위"
  type        = string
  default     = "10.0.0.0/16"
}


#--------------maria db 설정----------------------#

variable "cpu" {
  description = "CPU 설정을 입력하세요"
  type        = string
  default     = "db.t2.micro"
}

variable "storage" {
  description = "스토리지 크기를 입력하세요"
  type        = number
  default     = 20
}


variable "passwd" {
  description = "패쓰워드를 입력하세요"
  type        = string
  default     = "It12345!"
}



