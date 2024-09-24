require "aws-sdk-s3"
require "net/http"

class S3Service
  def initialize
    @s3_resource = Aws::S3::Resource.new(
      region: Rails.application.credentials[:aws][:region]
      access_key_id: Rails.application.credentials[:aws][:access_key_id]
      secret_access_key: Rails.application.credentials[:aws][:secret_access_key]
    )
  end

  def get_presigned_url(bucket, object_key)
    begin
    bucket = @s3_resource.bucket(bucket)
    obj = bucket.object(object_key)
    url = obj.presigned_url(:put)
    URI(url)
    rescue Aws::Errors::ServiceError => e
      "Couldn't create presigned URL for #{bucket.name}:#{object_key}. Here's why: #{e.message}"
    end  
  end
end