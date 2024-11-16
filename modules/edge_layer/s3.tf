####################################### S3 Bucket Creation #######################################
# This section defines the creation of the S3 bucket that will be used for hosting 
# the frontend assets. The bucket name is defined by the provided prefix variable.

resource "aws_s3_bucket" "frontend_bucket" {
  bucket_prefix = var.s3_bucket_name # Unique bucket name prefix
}

####################################### Public Access Settings #######################################
# This section configures the public access settings for the S3 bucket. It allows public 
# access by modifying the Block Public Access settings, ensuring that the bucket can be accessed 
# publicly as needed.

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false # Allow public ACLs
  block_public_policy     = false # Allow public policies
  ignore_public_acls      = false # Ignore public ACLs if they exist
  restrict_public_buckets = false # Do not restrict public buckets
}

####################################### S3 Bucket Policy #######################################
# This section attaches a bucket policy to the S3 bucket, allowing public read access 
# to all objects. The policy grants permissions to the CloudFront service principal 
# to read objects from the bucket.

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id # Attach policy to the bucket

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "cloudfront.amazonaws.com"
      },
      "Action" : "s3:GetObject",
      "Resource" : "${aws_s3_bucket.frontend_bucket.arn}/*",
      "Condition" : {
        "StringEquals" : {
          "AWS:SourceArn" : "${aws_cloudfront_distribution.cdn.arn}"
        }
      }
    }
  })
}

####################################### Upload Index File #######################################
# This section uploads the index.html file to the S3 bucket. This file serves as the 
# main entry point for the website and is stored in the specified bucket.

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend_bucket.id # Reference the bucket id
  key          = "index.html"                     # File name (object key) in the bucket
  source       = "index.html"                     # Local path to the index file
  content_type = "text/html"                      # MIME type for the HTML file
}

####################################### Upload Error File (Commented) #######################################
# This section is intended to upload the error.html file to the S3 bucket. 
# It is currently commented out and can be enabled if needed for handling error responses.

# resource "aws_s3_object" "error" {
#   bucket       = aws_s3_bucket.frontend_bucket.id # Reference the bucket id
#   key          = "error.html"                     # File name for the error page
#   source       = "error.html"                     # Local path to the error file
#   content_type = "text/html"                      # MIME type for the error file
# }


