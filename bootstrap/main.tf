provider "aws" {
  region = var.aws_region


  default_tags {
    tags = {
      Project   = var.project
      Component = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}


#Usado para deixar o nome do bucket globalmente único sem hardcode do ID da conta.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Um "terraform destroy" acidental aqui apagaria o state de TODOS os ambientes.
  lifecycle {
    prevent_destroy = true
  }
}


# Versionamento: permite recuperar uma versão anterior do state se ele corromper.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}


# Criptografia em repouso: o state pode conter dados sensíveis.
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Bloqueia qualquer forma de acesso público ao bucket.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Criptografia em trânsito: recusa qualquer requisição que não use HTTPS.
data "aws_iam_policy_document" "state_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]


    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_tls_only.json

  # A policy só pode ser aplicada depois do public access block existir.
  depends_on = [aws_s3_bucket_public_access_block.state]
}
