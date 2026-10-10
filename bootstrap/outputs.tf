output "state_bucket_name" {
  description = "Nome do bucket de state. Use no seu backend.hcl."
  value = aws_s3_bucket.state.bucket
}