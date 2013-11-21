CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider => 'AWS',
      :aws_access_key_id => ENV['S3_KEY'] || 'AKIAISCTRNITEBPNMKKA',
      :aws_secret_access_key => ENV['S3_SECRET'] || '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',
      :region => ENV['S3_REGION'] || 'us-east-1'
  }
  config.storage = :fog
  config.cache_dir = "#{Rails.root}/tmp/uploads"

  config.fog_directory = ENV['S3_BUCKET_NAME'] || 'construction-central'
  config.fog_public = false
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
end