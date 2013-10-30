S3DirectUpload.config do |c|
  c.access_key_id = CONFIG["s3_id"]
  c.secret_access_key = CONFIG["s3_secret"]
  c.bucket = CONFIG["s3_bucket"]
end