class User < ActiveRecord::Base

	after_validation    :validate_username_reserved
	before_create do
		# initialize_profile
		initialize_permissions      
	end
	after_save do   
		# sync_slug if username != profile.slug
		generate_username unless username?
	end

	# Include default devise modules. Others available are:
	# :confirmable
	devise  :database_authenticatable, :registerable,
			:recoverable, :rememberable, :trackable, :validatable,
			:omniauthable, :lockable, :timeoutable, :token_authenticatable


	attr_accessor :login
	attr_accessible :username, :login, :email, :password, :password_confirmation, :remember_me
	attr_protected :none, as: :admin

	
	extend FriendlyId
	friendly_id     :username


	validates :username, :uniqueness => {:case_sensitive => false}, :length => 1..20, :allow_blank => true, :if => Proc.new { |user| user.username != user.id.to_s }
	validate  :validate_username_format


	# Authenticate with email or username
	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		login = conditions.delete(:login)
		where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
	end

	# Given facebook authentication data, find the user record
	def self.find_for_facebook(fb_user, current_user=nil)
		if current_user
			current_user.update_attribute(:facebook_id, fb_user.id) if current_user.facebook_id != fb_user.id
			current_user
		elsif user = User.find_by_facebook_id(fb_user.id)
			user
		elsif user = User.find_by_email(fb_user.email.downcase)
			user.update_attribute(:facebook_id, fb_user.id)
			if user.profile.avatars.count == 0
				# TODO: UNHACK: This is a hack. I don't know how to store the model's attributes before processing the image in the uploader. This proccesses twice, the first time with no image. 
				image = user.profile.images.new({ image_type: 'avatar' })
				image.update_attributes({ remote_image_url: "https://graph.facebook.com/#{fb_user.id}/picture?type=large", image_type: 'avatar' })
			end
			user
		else # Create a user. This should never get persisted. The user should confirm the info and fb data should be synced on registration.
			user = User.new({ email: fb_user.email.downcase, facebook_id: fb_user.id, username: fb_user.username })
			user
		end
	end


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
		unless username =~ /^[a-zA-Z][a-zA-Z0-9_]*$/ or username == id.to_s
			errors.add(:username, "may only contain letters, numbers and underscores")
		end
	end

	def initialize_permissions
		self.permissions = 2 
	end

end
