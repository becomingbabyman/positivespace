class User < ActiveRecord::Base
	include Gravtastic

	state_machine :initial => :uninvited do
		event :invite do
			transition :uninvited => :invited
		end
		# after_transition on: :invite, do: :after_invite

		event :complete do
			transition :invited => :completed
		end
		# after_transition on: :complete, do: :after_complete
	end

	after_validation :validate_username_reserved
	before_create do
		# initialize_profile
		initialize_permissions
	end
	after_create :add_gravatar
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

	gravtastic :secure => false,
	            :filetype => :jpg,
	            :default => :identicon,
	            :size => 1024

	# Track views
	is_impressionable :counter_cache => { :unique => true }

	attr_accessor :login, :invitation_code
	attr_accessible :username, :login, :email, :password, :password_confirmation, :remember_me
	attr_accessible :body, :location, :name, :personal_url#, :positive_response, :negative_response
	attr_protected :none, as: :admin

	serialize :achievements

	extend FriendlyId
	friendly_id :username
	has_shortened_urls
	has_many :images, :as => :attachable
	has_many :avatars, :as => :attachable, :source => :images, :class_name => "Image", :conditions => {image_type: "avatar"}, :order => 'created_at desc'
	has_many :sent_messages, :foreign_key => :from_id, :class_name => 'Message', :order => 'created_at desc'
	has_many :recieved_messages, :foreign_key => :to_id, :class_name => 'Message', :order => 'created_at desc'
	has_many :sent_conversations, :foreign_key => :from_id, :class_name => 'Conversation', :order => 'created_at desc'
	has_many :recieved_conversations, :foreign_key => :to_id, :class_name => 'Conversation', :order => 'created_at desc'
	has_many :invitations
	belongs_to :invitation

	accepts_nested_attributes_for :images, :avatars

	validates :username, :uniqueness => {:case_sensitive => false}, :length => 3..18, :allow_blank => true, :if => Proc.new { |user| user.username != user.id.to_s }
	validates :body, length: 1..250, allow_blank: true
	validates :positive_response, length: 1..250, allow_blank: true
	validates :negative_response, length: 1..250, allow_blank: true
	validate  :validate_username_format
	# validate  :validate_invitation, on: :create


	# Authenticate with email or username
	def self.find_first_by_auth_conditions(warden_conditions)
		conditions = warden_conditions.dup
		if login = conditions.delete(:login)
			where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		else
			where(conditions).first
		end
	end

	# Given facebook authentication data, find the user record
	# TODO: UNHACK: This is a whackasshack method
	def self.find_for_facebook(fb_user, current_user=nil, invitation_id=nil, invitation_code=nil)
		if current_user
			current_user.update_attribute(:facebook_id, fb_user.id) if current_user.facebook_id != fb_user.id
			current_user
		elsif user = User.find_by_facebook_id(fb_user.id)
			user
		elsif user = User.find_by_email(fb_user.try(:email).try(:downcase))
			attrs = {}
			attrs[:name] = "#{fb_user.first_name} #{fb_user.last_name}" if !user.name or user.name == user.username
			attrs[:gender] = fb_user.gender unless user.gender
			attrs[:birthday] = fb_user.try(:birthday) unless user.birthday
			attrs[:locale] = fb_user.locale unless user.locale
			attrs[:timezone] = fb_user.timezone.to_i unless user.timezone
			attrs[:avatars_attributes] = [ { process_image_upload: true, remote_image_url: "https://graph.facebook.com/#{fb_user.id}/picture?type=large" } ] unless user.avatar
			user.update_attributes attrs
			user.update_attribute(:facebook_id, fb_user.id)
			user
		else # Create a user.
			password = SecureRandom.hex(20)
			user = User.create({ email: fb_user.email.downcase,
				name: "#{fb_user.first_name} #{fb_user.last_name}",
				gender: fb_user.gender,
				birthday: fb_user.try(:birthday),
				locale: fb_user.locale,
				timezone: fb_user.timezone.to_i,
				password: password,
				password_confirmation: password,
				avatars_attributes: [
					{ process_image_upload: true, remote_image_url: "https://graph.facebook.com/#{fb_user.id}/picture?type=large" }
				]
			})#, invitation_id: invitation_id, invitation_code: invitation_code })
			user.update_attribute(:facebook_id, fb_user.id)
			user
		end
	end


	# Override destroy
	def destroy
		# Do nothing
	end

	def name
		super || self.username
	end

	def first_name
		name.split(' ').first
	end

	def last_name
		n = name.split(' ')
		n.last if n.size > 1
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

	# Inherited resource needs this in the messages controller to find a user's messages
	# TODO: think about a cleaner solution
	# TODO: think about merging this with sent messages
	def messages
		Message.with(self.id)
	end

	def conversations
		Conversation.with(self.id)
	end

	def avatar
		self.avatars.first
	end

	def avatar= image
		self.avatars.new(image: image)
	end

	def track_achievement achievement_name
		self.achievements[achievement_name]=true
		self.save
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

	 # Adds a gravatar if no avatar exists
	def add_gravatar
		unless avatar
			avatars.create({ process_image_upload: true, remote_image_url: gravatar_url, user_id: id })
		end
	end

	# def validate_invitation
	#	invitation = Invitation.find_by_id(self.invitation_id)
	#	unless invitation and invitation.legit?(self.invitation_code)
	#		errors.add(:invitation, "must be valid")
	#	end
	# end

	# def use_invitation

	#	self.invitation.mark_as_used if self.invitation

	#	# SendWelcomeEmailWorker.perform_in(2.seconds, self.id)
	#	# FirstForwardableInvitationWorker.perform_at(Chronic.parse("2 days from now at 6:23pm"), self.id)
	# end
end
