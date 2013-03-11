CarrierWave.configure do |config|
  ## Comment to test heroku s3 image persistence
  config.storage = :fog

  config.fog_credentials = {
    :provider => 'AWS',
    :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
    :region => 'us-east-1'
  }
  config.fog_directory = "positivespace-#{Rails.env}"
  config.asset_host = ENV['FOG_HOST_SSL']
  # config.asset_host = Proc.new do |source, request=nil|
  #   if request and request.ssl?
  #     ENV['FOG_HOST_SSL']
  #   else
  #     "#{ENV['FOG_HOST']}".gsub("assets%d", "assets#{rand(0..3)}") # use the insecure but fast assets0-3 subdomains here
  #   end
  # end
  config.fog_public = true
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
end


module CarrierWave
  module RMagick

    # Rotates the image based on the EXIF Orientation
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient!
        img = yield(img) if block_given?
        img
      end
    end

    def quality(percentage)
      manipulate! do |img|
        img.write(current_path){ self.quality = percentage } unless img.quality == percentage
        img = yield(img) if block_given?
        img
      end
    end

  end
end
