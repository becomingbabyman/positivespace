# An Image can belong to anything
class Image < ActiveRecord::Base
	require 'carrierwave/orm/activerecord'
	require 'file_size_validator'

	# include Rails.application.routes.url_helpers

	#########################
	# Callbacks & Misc method calls (e.g. devise for, acts_as_whatever )
	#########################


	#########################
	# Setup attributes (reader, accessible, protected)
	#########################
	#attr_reader
	attr_accessible :image, :remote_image_url, :image_type, :attachable, :attachable_id, :attachable_type, :name, :lat, :lon, :user_id, :process_image_upload
	attr_protected :none, as: :admin

	#########################
	# Associations
	#########################
	belongs_to :user # The uploader/owner
	belongs_to :attachable, :polymorphic => true # The thing the image relates to -- Profiles, Projects, etc
	mount_uploader :image, ImageUploader
	process_in_background :image


	#########################
	# Validations
	#########################
	# validates :user_id, :presence => true
	# validates :attachable_id, :presence => true
	validates :attachable_type, :presence => true
	validates :image_type, :presence => true
	validates   :image,
				:presence => true,
				:file_size => {
					:maximum => 5.megabytes.to_i,
					:message => "file size too big. Please select a file less than 5MB."
				}

	#########################
	# Scopes
	#########################
	#scope :red, where(:color => 'red')


	#########################
	# Public Class Methods ( def self.method_name )
	#########################


	#########################
	# Public Instance Methods ( def method_name )
	#########################


	#########################
	# Protected Methods
	#########################
	protected

	# Same as Public Instance Methods


	#########################
	# Private Methods
	#########################
	private

end
