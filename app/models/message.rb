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
	after_create :parse_embed_url

	attr_accessible :body, :embed_url, :from_email, :state_event, :conversation_id
	attr_protected :none, as: :admin

	serialize :embed_data

	acts_as_mentioner
	belongs_to :to, :class_name => 'User'
	belongs_to :from, :class_name => 'User'
	belongs_to :conversation

	validates :body, presence: true#, length: {maximum: 250}
	validates :to_id, presence: true
	validates :from_id, presence: true
	validate :validate_not_to_self
	validate :validate_take_turns, on: :create
	validate :validate_not_ended, on: :create
	validate :validate_from_is_in_conversation
	validate :validate_length

	# default_scope :order => 'created_at asc'

	scope :draft, where(state: :draft)
	scope :sent, where(state: :sent)
	scope :replied, where(state: :replied)
	scope :in_progress, joins(:conversation).where("conversations.state = ?", :in_progress)
	scope :ended, joins(:conversation).where("conversations.state = ?", :ended)
	scope :with, lambda { |user_id| where("messages.from_id = ? OR messages.to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(messages.from_id = ? AND messages.to_id = ?) OR (messages.from_id = ? AND messages.to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("messages.id != ?", id) }
	scope :conversation_id, lambda { |id| where("messages.conversation_id = ?", id) }

	def self.total_seconds_to_edit
		0 # TODO: think about removing all of this out
	end

	def seconds_left_to_edit
		self.created_at + Message.total_seconds_to_edit - DateTime.now.utc
	end

	def editors
		[self.from]
	end

	def max_char_count
		base_char_count = 250
		if c = self.conversation
			c.messages.size * 50 + base_char_count
		else
			base_char_count
		end
	end

private

	def validate_not_to_self
		errors.add(:you, "can't send a message to yourself >_<") if self.from_id == self.to_id
	end

	def validate_take_turns
		errors.add(:you, "have to wait for a reply before sending another message") if m = self.conversation.last_message and m.from_id == self.from_id
	end

	def validate_not_ended
		errors.add(:you, "have already had a conversation with #{self.to.name} about this topic") if self.conversation.ended?
	end

	def validate_from_is_in_conversation
		errors.add(:you, "must be a member of this conversation to reply to it") unless self.from_id == self.conversation.from_id or self.from_id == self.conversation.to_id
	end

	def validate_length
		errors.add(:body, "is too long. #{self.max_char_count} characters max.") if self.body.size > self.max_char_count
	end

	def after_send
		self.conversation.last_message.reply if self.conversation.last_message
		append_message_to_conversation
		notify_recipient
	end

	def continue_conversation
		unless self.conversation
			c = Conversation.between(self.from_id, self.to_id).where(prompt: self.to.body).first
			c ||= Conversation.new(from_id: self.from_id, to_id: self.to_id, prompt: self.to.body)
			self.conversation = c
		end
	end

	def append_message_to_conversation
		c = self.conversation
		c.last_message_id = self.id
		c.last_message_from_id = self.from.id
		c.last_message_body = self.body
		c.save
	end

	def notify_recipient
		NotificationsMailer.delay.recieved_message(self.id) if self.to.settings[:notifications][:email][:every_new_message]
	end

	def parse_embed_url
		ParseMessageEmbedUrl.perform_in(2.seconds, self.id) unless self.embed_url.blank?
	end

	def after_reply
		# Do nothing yet
	end

end
