variable "aws_region" {
  description = "Região AWS onde o bucket de state será criado"
  type = string
  default = "us-east-1"
}

variable "project" {
  description = "Prefixo usado para nomear recursos"
  type = string
  default = "rs-iac"
}