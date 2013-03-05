class User < ActiveRecord::Base

	after_validation    :validate_username_reserved
	before_create do
		# initialize_profile
		initialize_permissions
	end
	after_save do
		# sync_slug if username != profile.slug
		generate_username unless username?
		update_achievements
	end

	# Include default devise modules. Others available are:
	# :confirmable
	devise  :database_authenticatable, :registerable,
			:recoverable, :rememberable, :trackable, :validatable,
			:omniauthable, :lockable, :timeoutable, :token_authenticatable,
			:async, :authentication_keys => [:login]

	attr_accessor :login
	attr_accessible :username, :login, :email, :password, :password_confirmation, :remember_me
	attr_accessible :body, :location, :name, :personal_url, :positive_response, :negative_response
	attr_protected :none, as: :admin

	serialize :achievements


	has_many :sent_messages, :foreign_key => :from_id, :class_name => 'Message', :order => 'created_at desc'
	has_many :recieved_messages, :foreign_key => :to_id, :class_name => 'Message', :order => 'created_at desc'

	extend FriendlyId
	friendly_id :username

	validates :username, :uniqueness => {:case_sensitive => false}, :length => 3..30, :allow_blank => true, :if => Proc.new { |user| user.username != user.id.to_s }
	validate  :validate_username_format


	# Authenticate with email or username
	def self.find_first_by_auth_conditions(warden_conditions)
		conditions = warden_conditions.dup
		if login = conditions.delete(:login)
			where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		else
			where(conditions).first
		end
	end

	# Inherited resource needs this in the messages controller to find a user's messages
	# TODO: think about a cleaner solution
	# TODO: think about merging this with sent messages
	def messages
		self.recieved_messages
	end

	# Given facebook authentication data, find the user record
	# TODO: UNHACK: This is a whackasshack method
	# def self.find_for_facebook(fb_user, current_user=nil, invitation_id=nil, invitation_code=nil)
	#	if current_user
	#		current_user.update_attribute(:facebook_id, fb_user.id) if current_user.facebook_id != fb_user.id
	#		current_user.update_attribute(:username, fb_user.username) unless current_user.username
	#		current_user
	#	elsif user = User.find_by_facebook_id(fb_user.id)
	#		user
	#	elsif user = User.find_by_email(fb_user.try(:email).try(:downcase))
	#		user.update_attribute(:facebook_id, fb_user.id)
	#		user.update_attribute(:username, fb_user.username) unless user.username
	#		unless user.avatar
	#			# TODO: UNHACK: This is a whackasshack. I don't know how to store the model's attributes before processing the image in the uploader. This proccesses twice, the first time with no image.
	#			image = user.avatars.new
	#			image.update_attribute :remote_image_url, "https://graph.facebook.com/#{fb_user.id}/picture?type=large"
	#		end
	#		user
	#	else # Create a user.
	#		password = SecureRandom.hex(20)
	#		user = User.create({ email: fb_user.email.downcase, username: fb_user.username, first_name: fb_user.first_name, last_name: fb_user.last_name, password: password, password_confirmation: password, invitation_id: invitation_id, invitation_code: invitation_code })
	#		user.update_attribute(:facebook_id, fb_user.id)
	#		# TODO: UNHACK: This is a whackasshack. I don't know how to store the model's attributes before processing the image in the uploader. This proccesses twice, the first time with no image.
	#		image = user.avatars.new
	#		image.update_attribute :remote_image_url, "https://graph.facebook.com/#{fb_user.id}/picture?type=large"
	#		user
	#	end
	# end


	# Override destroy
	def destroy
		# Do nothing
	end

	def email_to_name
		email.split("@").first.split(/[\-\_\.]/).reduce{ |full_name, name| full_name = "#{full_name} #{name}" }.titleize rescue ""
	end

	def editors
		editors = [self]
		editors
	end

	def editor? model
		model.editors.include? self
	end

	def avatar
		# self.avatars.first
	end

	def avatar= image
		# self.avatars.new(image: image)
	end

private
	def validate_username_reserved
		if errors[:friendly_id].present?
			errors[:username] = "is reserved. Please choose something else."
			errors.messages.delete(:friendly_id)
		end
	end

	def generate_username
		self.update_attribute(:username, self.id.to_s)
	end

	def validate_username_format
		unless username =~ /^[a-zA-Z][a-zA-Z0-9-]*$/ or username == id.to_s
			errors.add(:username, "may only contain letters, numbers, and dashes")
		end
	end

	def initialize_permissions
		self.permissions = 2
	end

	def update_achievements
		# TODO: search for newly completed achievements and check them off
	end
end
