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
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "s3_static_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_static_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
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



resource "aws_s3_bucket" "s3_deploy_bucket" {
  bucket        = "${var.project}-${var.environment}-deploy-bucket-${random_string.s3_unique_key.result}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "s3_deploy_bucket_versioning" {
  bucket = aws_s3_bucket.s3_deploy_bucket.bucket

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_deploy_bucket" {
  bucket                  = aws_s3_bucket.s3_deploy_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "s3_deploy_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_deploy_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.app_iam_role.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_deploy_bucket" {
  bucket = aws_s3_bucket.s3_deploy_bucket.id
  policy = data.aws_iam_policy_document.s3_deploy_bucket.json
  depends_on = [
    aws_s3_bucket_public_access_block.s3_deploy_bucket,
    aws_s3_bucket_versioning.s3_deploy_bucket_versioning
  ]
}
