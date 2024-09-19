# S3 버킷 정의
resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_base_name}${var.bucket_suffix}"
}

# S3 CORS 설정 추가
resource "aws_s3_bucket_cors_configuration" "my_bucket_cors" {
  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]  # 필요한 경우 특정 도메인으로 제한 가능
    max_age_seconds = 3000
  }
}

# CloudFront Origin Access Identity (OAI) 정의
resource "aws_cloudfront_origin_access_identity" "my_origin_access_identity" {
  comment = "OAI for S3 bucket access via CloudFront"
}

# S3 버킷 정책 (OAI를 통해서만 접근 허용)
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.my_origin_access_identity.iam_arn
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

# CloudFront Distribution 정의
resource "aws_cloudfront_distribution" "my_distribution" {
  enabled             = true
  comment             = "My CloudFront Distribution"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.my_origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    min_ttl         = 0
    default_ttl     = 3600
    max_ttl         = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Outputs 설정
output "url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}

output "distribution_id" {
  value = aws_cloudfront_distribution.my_distribution.id
}
