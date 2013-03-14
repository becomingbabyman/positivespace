# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  include CarrierWave::MimeTypes
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if %w[development test].include? Rails.env
    storage :file
  else
    storage :fog
  end

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore.pluralize}/#{model.image_type.pluralize}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + ii[version_name, ".png"].compact.join('_'))

  #   "/assets/fallback/" + [version_name, "default.png"].compact.join('_')
  # end


  # process :convert => 'png' # This screws with animated gifs


  version :large do
    process :large_process
  end

  version :medium, :from_version => :large do
    process :medium_process
  end

  version :small, :from_version => :medium do
    process :small_process
  end

  version :big_thumb, :from_version => :medium do
    process :big_thumb_process
  end

  version :thumb, :from_version => :big_thumb do
    process :thumb_process
  end

  # process :tiny_thumb, :from_version => :thumb, :if => :is_user? do
  #   process :resize_to_fill => [30, 30]
  # end

  # TODO: cleanup these processes
  def large_process
    case [model.attachable_type, model.image_type]
    when ['User', 'avatar'] then
      resize_to_fill 1024, 683 # 3x2
    when ['User', 'inspiration'] then
      resize_to_fit 1024, 9999 # fixed width
    when ['Message', 'avatar'] then
      resize_to_fit 1024, 9999 # fixed width
    when ['Message', 'alternate'] then
      resize_to_fit 1024, 9999 # fixed width
    when ['Alternative', 'avatar'] then
      resize_to_fill 1024, 683 # 3x2
    else
      resize_to_fit 1024, 9999 # fixed width
    end
    # TODO: Test and implement this.
    # fix_exif_rotation
    quality 70
  end

  def medium_process
    case[model.attachable_type, model.image_type]
    when ['User', 'avatar'] then
      resize_to_fill 512, 341 # 3x2
    when ['User', 'inspiration'] then
      resize_to_fit 512, 9999 # fixed width
    when ['Message', 'avatar'] then
      resize_to_fit 512, 9999 # fixed width
    when ['Message', 'alternate'] then
      resize_to_fit 512, 9999 # fixed width
    when ['Alternative', 'avatar'] then
      resize_to_fill 512, 341 # 3x2
    else
      resize_to_fit 512, 9999 # fixed width
    end
    quality 70
  end

  def small_process
    case [model.attachable_type, model.image_type]
    when ['User', 'avatar'] then
      resize_to_fill 128, 85 # 3x2
    when ['User', 'inspiration'] then
      resize_to_fit 128, 9999 # fixed width
    when ['Message', 'avatar'] then
      resize_to_fit 128, 9999 # fixed width
    when ['Message', 'alternate'] then
      resize_to_fit 128, 9999 # fixed width
    when ['Alternative', 'avatar'] then
      resize_to_fill 128, 85 # 3x2
    else
      resize_to_fit 128, 9999 # fixed width
    end
    quality 70
  end

  def big_thumb_process
    case [model.attachable_type, model.image_type]
    when ['User', 'avatar'] then
      resize_to_fill 128, 128 # 3x2
    when ['User', 'inspiration'] then
      resize_to_fill 128, 128 # fixed width
    when ['Message', 'avatar'] then
      resize_to_fill 128, 128 # fixed width
    when ['Message', 'alternate'] then
      resize_to_fill 128, 128 # fixed width
    when ['Alternative', 'avatar'] then
      resize_to_fill 128, 128 # 3x2
    else
      resize_to_fill 128, 128 # fixed width
    end
    quality 100
  end

  def thumb_process
    case [model.attachable_type, model.image_type]
    when ['User', 'avatar'] then
      resize_to_fill 64, 64 # 1x1
    when ['User', 'inspiration'] then
      resize_to_fill 64, 64 # 1x1
    when ['Message', 'avatar'] then
      resize_to_fill 64, 64 # 1x1
    when ['Message', 'alternate'] then
      resize_to_fill 64, 64 # 1x1
    when ['Alternative', 'avatar'] then
      resize_to_fill 64, 64 # 1x1
    else
      resize_to_fill 64, 64 # 1x1
    end
    quality 100
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if original_filename
      if model && model.read_attribute(:image).present?
        model.read_attribute(:image)
      else
        @name ||= "#{secure_token}.#{file.extension}"
      end
    end
  end


protected

  def is_user?(picture)
    return model.attachable_type == "User"
  end

  def not_user?(picture)
    return !self.is_profile?(picture)
  end


private

  def secure_token
    ivar = "@#{mounted_as}_secure_token"
    token = model.instance_variable_get(ivar)
    token ||= model.instance_variable_set(ivar, SecureRandom.hex(8))
  end


end
