resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  special = false
}
resource "aws_s3_bucket" "s3_static_bucket" {
  bucket        = "${var.project}-${var.environment}-static-bucket-${random_string.s3_unique_key.result}"
  force_destroy = true
}
 
resource "aws_s3_bucket_versioning" "s3_static_bucket_versioning" {
  bucket = aws_s3_bucket.s3_static_bucket.bucket
 
  versioning_configuration {
    status = "Disabled"
  }
}
 
resource "aws_s3_bucket_public_access_block" "s3_static_bucket" {
  bucket                  = aws_s3_bucket.s3_static_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

 
data "aws_iam_policy_document" "s3_static_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_static_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [var.user_arn]
    }
  }
}
 
resource "aws_s3_bucket_policy" "s3_static_bucket" {
  bucket = aws_s3_bucket.s3_static_bucket.id
  policy = data.aws_iam_policy_document.s3_static_bucket.json
  depends_on = [
    aws_s3_bucket_public_access_block.s3_static_bucket,
    aws_s3_bucket_versioning.s3_static_bucket_versioning
  ]
}
