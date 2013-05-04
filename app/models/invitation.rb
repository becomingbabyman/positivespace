class Invitation < ActiveRecord::Base
	#########################
	# Callbacks & Misc method calls (e.g. devise for, acts_as_whatever )
	#########################
	after_initialize :generate_code, on: :create
	# after_create :email_code_to_user


	#########################
	# Setup attributes (reader, accessible, protected)
	#########################
	#attr_reader
	# attr_accessor :recipient_email, :recipient_name
	# attr_accessible :recipient_email, :recipient_name
	attr_protected :none, as: :admin


	#########################
	# Associations
	#########################
	is_impressionable :counter_cache => { :unique => true }
	belongs_to :user # Inviter
	has_many :users # Invitees


	#########################
	# Validations
	#########################
	validates :code, presence: true
	validate :max_use_count_gt_current, on: :create


	#########################
	# Scopes
	#########################
	#scope :red, where(:color => 'red')


	#########################
	# Public Class Methods ( def self.method_name )
	#########################

	#def self.my_method
	#
	#end


	#########################
	# Public Instance Methods ( def method_name )
	#########################

	# def share recipient_email, recipient_name = nil
	#	InvitationMailer.delay_for(5.seconds).share(self.id, recipient_email, recipient_name)
	#	self.increment(:share_count)
	#	self.save!
	# end

	def legit? input_code
		!self.used_up? and (self.code == input_code)
	end

	def used_up?
		self.current_use_count >= self.max_use_count
	end

	def expired?
		# TODO: MAYBE
	end

	def mark_as_used
		self.increment(:current_use_count)
		self.save!
	end

	def remaining_uses
		self.max_use_count - self.current_use_count
	end


	#########################
	# Protected Methods
	#########################
protected

	# Same as Public Instance Methods


	#########################
	# Private Methods
	#########################
private

	def generate_code
		self.code ||= SecureRandom.urlsafe_base64(13)
	end

	def max_use_count_gt_current
		self.errors.add(:max_use_count, "must be greater than current use count") if self.max_use_count <= self.current_use_count
	end

	# def email_code_to_user
	#	if self.user_id
	#		InvitationMailer.delay_for(5.seconds).forwardable_invitation_for_existing_user(self.id)
	#	else
	#		InvitationMailer.delay_for(5.seconds).invitation_for_new_user(self.id, self.recipient_email, self.recipient_name)
	#	end
	# end

end
