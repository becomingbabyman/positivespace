class User < ActiveRecord::Base
	include Gravtastic

	include Tire::Model::Search
	include Tire::Model::Callbacks
	index_name ES_INDEX_NAME
	tire do
		settings :index => {
			:number_of_shards => (ENV["ELASTIC_SEARCH_SHARDS"] || 1).to_i,
			:number_of_replicas => (ENV["ELASTIC_SEARCH_REPLICAS"] || 1).to_i,
			:analysis => {
				:filter => {
					:autocomplete_ngram  => {
						"type"     => "ngram",
						"min_gram" => 2,
						"max_gram" => 16 }
				},
				:analyzer => {
					:autocomplete => {
						"type"         => "custom",
						"tokenizer"    => "standard",
						"filter"       => [ "standard", "lowercase", "stop", "kstem", "autocomplete_ngram" ] }
				}
			}
		} do
			mapping do
				indexes :id,            type: 'integer', index:    :not_analyzed
				indexes :slug,          type: 'string',  analyzer: 'keyword'
				indexes :state,         type: 'string',  analyzer: 'keyword'
				indexes :name,          type: 'string',  index_analyzer: 'autocomplete',  search_analyzer: 'snowball'
				indexes :body,          type: 'string',  index_analyzer: 'autocomplete',  search_analyzer: 'snowball' #, :boost => 2.0
				indexes :username,      type: 'string',  index_analyzer: 'autocomplete',  search_analyzer: 'snowball'
				indexes :location,      type: 'string',  index_analyzer: 'autocomplete',  search_analyzer: 'snowball'
				indexes :personal_url,  type: 'string',  index_analyzer: 'autocomplete',  search_analyzer: 'snowball'
				indexes :gender,  		type: 'string',  analyzer: 'keyword'
				indexes :locale,  		type: 'string',  analyzer: 'keyword'
				indexes :timezone,		type: 'string',  analyzer: 'keyword'
				indexes :update_at,     type: 'date'
				indexes :created_at,    type: 'date'
				indexes :avatar_thumb_url, type: 'string', index:  :not_analyzed
				indexes :personal_url_root, type: 'string', index:  :not_analyzed
			end
		end
	end


	state_machine :initial => :unendorsed do
		event :endorse do
			transition :unendorsed => :endorsed
		end
		after_transition on: :endorse, do: :after_endorse

		# event :publish do
		#   transition [:endorsed, :unpublished] => :published
		# end
		# # after_transition on: :complete, do: :after_publish

		# event :unpublish do
		#   transition [:published] => :unpublished
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
		tire.search(load: false, page: params[:page], per_page: params[:per]) do
			query do
				match [:name, :username, :body, :location, :personal_url], params[:q]
				# TODO: try to set default_operator, maybe it can't be set on a match
				# default_operator: "AND"
			end
			# filter :not => { :term => { :state => :unendorsed } }
		end
	end

	self.include_root_in_json = false
	def to_indexed_json
		{
			id: id,
			slug: slug,
			state: state,
			name: name,
			body: body,
			username: username,
			location: location,
			personal_url: personal_url,
			gender: gender,
			locale: locale,
			timezone: timezone,
			update_at: updated_at,
			created_at: created_at,
			avatar_thumb_url: avatar.try(:image).try(:thumb).try(:url),
			personal_url_root: personal_url_root,
		}.to_json
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

	def slug
		super || username || id.to_s
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

	# params: {days_ago: integer, days_range: integer, metrics: string(comma separated metrics list), intervals: integer}
	def metrics params
		response = {}
		end_time = Chronic.parse("#{params[:days_ago].to_i} days ago at 0:00")
		start_time = end_time - params[:days_range].to_i.days
		intervals = params[:intervals].to_i
		metrics = params[:metrics].split(',').map{|s| s.strip()}

		# lets not go too crazy just yet
		if intervals < 60
			if metrics.include? 'views'
				query = lambda {|range| impressions.where(created_at: range).count}
				response[:views] = metrics_for_range query, start_time, end_time, intervals
			end
			if metrics.include? 'responses'
				query = lambda {|range| recieved_conversations.where(created_at: range).count}
				response[:responses] = metrics_for_range query, start_time, end_time, intervals
			end
			if metrics.include? 'initiations'
				query = lambda {|range| sent_conversations.where(created_at: range).count}
				response[:initiations] = metrics_for_range query, start_time, end_time, intervals
			end
		end

		response
	end

	# query: lambda that accepts a date range in the form of starttime..endtime
	# start_time: time
	# end_time: time
	# intervals: integer
	def metrics_for_range query, start_time, end_time, intervals
		response = []
		interval = (end_time.to_i - start_time.to_i) / intervals
		current_time = start_time
		(0..intervals-1).each do |i|
			next_time = current_time + interval
			response[i] = query.call(current_time..next_time)
			current_time = next_time
		end
		response
	end

	def personal_url_root
		if url = personal_url
			url = url.split("//")[1] if url.split("//").length > 1
			url = url.split("/")[0] if url.split("/").length > 1
			url = url.split("?")[0] if url.split("?").length > 1
			url = url.split("#")[0] if url.split("#").length > 1
		end
		url
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
	#   invitation = Invitation.find_by_id(self.invitation_id)
	#   unless invitation and invitation.legit?(self.invitation_code)
	#       errors.add(:invitation, "must be valid")
	#   end
	# end

	# def use_invitation

	#   self.invitation.mark_as_used if self.invitation

	#   # SendWelcomeEmailWorker.perform_in(2.seconds, self.id)
	#   # FirstForwardableInvitationWorker.perform_at(Chronic.parse("2 days from now at 6:23pm"), self.id)
	# end
end
