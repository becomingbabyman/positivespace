require 'embedly'
class Message < ActiveRecord::Base

	state_machine :initial => :pending do
		event :continue do
			transition :pending => :continued
		end

		event :discontinue do
			transition :pending => :discontinued
		end
	end

	after_create :continue_current_conversation
	after_create :notify_recipient

	attr_accessible :body, :embed_url, :from_email
	attr_protected :none, as: :admin

	serialize :embed_data

	belongs_to :to, :class_name => 'User', :foreign_key => :to_id
	belongs_to :from, :class_name => 'User', :foreign_key => :from_id

	validates :body, presence: true, length: {maximum: 250}
	validates :to_id, presence: true
	validates :from_id, presence: true

	default_scope :order => 'created_at asc'

	scope :pending, where(state: :pending)
	scope :continued, where(state: :continued)
	scope :discontinued, where(state: :discontinued)
	scope :with, lambda { |user_id| where("from_id = ? OR to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(from_id = ? AND to_id = ?) OR (from_id = ? AND to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("id != ?", id) }

	def self.total_seconds_to_edit
		0 # TODO: think about removing all of this out
	end

	def seconds_left_to_edit
		self.created_at + Message.total_seconds_to_edit - DateTime.now.utc
	end

	# def embed_url= url
	#	# TODO: move the key out of the model
	#	unless url.blank?
	#		embedly_api = Embedly::API.new :key => 'TODO: Add a key', :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; my@email.com)'
	#		obj = embedly_api.oembed :url => url
	#		self.embed_data = obj[0].marshal_dump
	#	end
	#	super url
	# end

	def editors
		[self.from]
	end

private

	def continue_current_conversation
		Message.between(self.from_id, self.to_id).pending.is_not(self.id).each(&:continue)
	end

	def notify_recipient
		NotificationsMailer.delay.recieved_message(self.id)
	end

end
