class User < ActiveRecord::Base
	include Gravtastic

	include Tire::Model::Search
	include Tire::Model::Callbacks

	tire.settings   :number_of_shards => 1,
					:number_of_replicas => 1,
					:analysis => {
						:filter => {
							:url_ngram  => {
								"type"     => "nGram",
								"max_gram" => 5,
								"min_gram" => 3 }
						},
						:analyzer => {
							:url_analyzer => {
									"tokenizer"    => "lowercase",
									"filter"       => ["stop", "url_ngram"],
									"type"         => "custom" }
						}
					} do
		mapping do
			indexes :id,           :index    => :not_analyzed, type: :integer
			indexes :name,         :analyzer => 'snowball'
			indexes :body,         :analyzer => 'snowball'#, :boost => 2.0
			# indexes :content_size, :as       => 'content.size'
			indexes :username,     :analyzer => 'snowball'
			indexes :slug,         :analyzer => 'snowball'
			indexes :state,        :analyzer => 'keyword'
			indexes :location,     :analyzer => 'snowball'
			indexes :personal_url, :analyzer => 'url_analyzer'
			indexes :update_at,    :type => 'date'
			indexes :created_at,   :type => 'date'
		end
	end


	state_machine :initial => :unendorsed do
		event :endorse do
			transition :unendorsed => :endorsed
		end
		after_transition on: :endorse, do: :after_endorse

		# event :publish do
		#	transition [:endorsed, :unpublished] => :published
		# end
		# # after_transition on: :complete, do: :after_publish

		# event :unpublish do
		#	transition [:published] => :unpublished
		# end
		# # after_transition on: :complete, do: :after_unpublish
	end

	after_validation :validate_username_reserved
	before_create do
		# initialize_profile
		initialize_permissions
	end
	after_create :add_gravatar
	# TODO: BETA: REMOVE: don't auto endorse people on create
	after_create :endorse
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


	attr_accessor :login, :invitation_code, :socialable_type, :socialable_id, :socialable_action, :endorse_user, :endorse_user_id
	attr_accessible :username, :login, :email, :password, :password_confirmation, :remember_me
	attr_accessible :body, :location, :name, :personal_url, :socialable_type, :socialable_id, :socialable_action, :endorse_user #, :positive_response, :negative_response
	attr_protected :none, as: :admin

	serialize :achievements

	has_paper_trail
	extend FriendlyId
	friendly_id :username
	has_shortened_urls
	is_impressionable :counter_cache => { :unique => true }
	acts_as_follower
	acts_as_followable
	acts_as_liker
	acts_as_likeable
	acts_as_mentionable
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
	validate  :validate_can_endorse_user
	# validate  :validate_invitation, on: :create


	scope :unendorsed, where(state: :unendorsed)
	scope :endorsed, where(state: :endorsed)


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

	def self.search(params)
		# TODO: disable load true by caching errthang you need
		tire.search(load: true, page: params[:page], per_page: params[:per]) do
			query { string params[:q], default_operator: "AND" } if params[:q].present?
			# filter :not => { :term => { :state => :unendorsed } }
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

	def socialable_action= action
		m = self.socialable_type.classify.constantize.find_by_id(self.socialable_id)
		if m
			case action
			when 'like'
				self.like! m
			when 'unlike'
				self.unlike! m
			when 'follow'
				self.follow! m
			when 'unfollow'
				self.unfollow! m
			end
		end
	end

	def track_achievement achievement_name
		self.achievements[achievement_name]=true
		self.save
	end

	def endorse_user= uid
		# TODO: REFACTOR: call validate before
		self.endorse_user_id = uid
		if self.endorsed? and self.remaining_invitations_count > 0 and invitee = User.find_by_id(uid) and invitee.unendorsed?
			invite = self.invitations.create
			invitee.invitation_id = invite.id
			invitee.endorse
		end
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

	def validate_can_endorse_user
		unless self.endorse_user_id.nil?
			if self.endorsed? and self.remaining_invitations_count > 0 and invitee = User.find_by_id(self.endorse_user_id) and invitee.unendorsed?
				# win!
			else
				errors.add(:endorsement, "unsuccessful")
			end
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

	def after_endorse
		# The endorsed user can now endorse others
		self.update_attribute(:remaining_invitations_count, 3)
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
