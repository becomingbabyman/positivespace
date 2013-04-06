require 'embedly'
class Message < ActiveRecord::Base

	state_machine :initial => :draft do
		event :send do
			transition :draft => :sent
		end
		after_transition on: :send, do: :after_send

		event :reply do
			transition :sent => :replied
		end
		after_transition on: :reply, do: :after_reply
	end

	before_validation :continue_conversation, on: :create

	attr_accessible :body, :embed_url, :from_email, :state_event
	attr_protected :none, as: :admin

	serialize :embed_data

	belongs_to :to, :class_name => 'User', :foreign_key => :to_id
	belongs_to :from, :class_name => 'User', :foreign_key => :from_id
	belongs_to :conversation

	validates :body, presence: true, length: {maximum: 250}
	validates :to_id, presence: true
	validates :from_id, presence: true
	validate :validate_not_to_self
	validate :validate_take_turns, on: :create

	default_scope :order => 'created_at asc'

	scope :draft, where(state: :draft)
	scope :sent, where(state: :sent)
	scope :replied, where(state: :replied)
	scope :with, lambda { |user_id| where("from_id = ? OR to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(from_id = ? AND to_id = ?) OR (from_id = ? AND to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("id != ?", id) }
	scope :conversation_id, lambda { |id| where("conversation_id = ?", id) }

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

	def validate_not_to_self
		errors.add(:you, "cannot send a message to yourself") if self.from_id == self.to_id
	end

	def validate_take_turns
		errors.add(:you, "have to wait for a reply before sending another message") if m = self.conversation.messages.last and m.from_id == self.from_id
	end

	def after_send
		self.conversation.touch
		notify_recipient
	end

	def continue_conversation
		c = Conversation.between(self.from_id, self.to_id).in_progress.first
		c ||= Conversation.new(from_id: self.from_id, to_id: self.to_id, state: :in_progress)
		self.conversation = c
	end

	def notify_recipient
		NotificationsMailer.delay.recieved_message(self.id)
	end

	def after_reply
		# Do nothing yet
	end

end
