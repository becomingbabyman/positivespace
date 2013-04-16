class Conversation < ActiveRecord::Base
	state_machine :initial => :in_progress do
		event :end do
			transition :in_progress => :ended
		end
	end

	attr_accessible :state_event
	attr_protected :none, as: :admin

	belongs_to :to, :class_name => 'User'
	belongs_to :from, :class_name => 'User'
	belongs_to :last_message, :class_name => 'Message'
	belongs_to :last_message_from, :class_name => 'User'
	has_many :messages

	validates :to_id, presence: true
	validates :from_id, presence: true
	validates :prompt, presence: true

	default_scope :order => 'updated_at ASC'

	scope :in_progress, where(state: :in_progress)
	scope :ended, where(state: :ended)
	scope :turn, lambda { |user_id| joins(:last_message).where("messages.to_id = ?", user_id) }
	scope :not_turn, lambda { |user_id| joins(:last_message).where("messages.from_id = ?", user_id) }
	scope :with, lambda { |user_id| where("conversations.from_id = ? OR conversations.to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(conversations.from_id = ? AND conversations.to_id = ?) OR (conversations.from_id = ? AND conversations.to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("conversations.id != ?", id) }

	def editors
		[self.to, self.from]
	end
end
