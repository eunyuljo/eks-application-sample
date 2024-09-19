variable "target_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "bucket_base_name" {
  type    = string
  default = "eks-work-frontend-"
}

variable "bucket_suffix" {
  type    = string
  description = "버킷 이름의 접미사"
}

variable "stack_name" {
  type    = string
  default = "MyStack"
}
