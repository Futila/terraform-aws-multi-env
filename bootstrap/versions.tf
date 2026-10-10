terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Sem bloco "backend": o bootstrap cria o bucket que guarda o state dos
  # outros ambientes, então o state DELE fica local (problema do ovo e da galinha).

}
