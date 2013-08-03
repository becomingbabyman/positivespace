class Conversation < ActiveRecord::Base
	state_machine :initial => :in_progress do
		event :end do
			transition :in_progress => :ended
		end
	end

	attr_accessible :state_event
	attr_protected :none, as: :admin

	belongs_to :to, :class_name => 'User', counter_cache: :recieved_conversations_count
	belongs_to :from, :class_name => 'User', counter_cache: :sent_conversations_count
	belongs_to :last_message, :class_name => 'Message'
	belongs_to :last_message_from, :class_name => 'User'
	belongs_to :space, counter_cache: :conversations_count
	has_many :messages, :dependent => :destroy
	has_many :magnetisms, :as => :attachable
	has_many :reviews, :as => :reviewable

	validates :to_id, presence: true
	validates :from_id, presence: true

	# default_scope :order => 'updated_at ASC'

	scope :in_progress, where(state: 'in_progress')
	scope :ended, where(state: 'ended')
	scope :turn, lambda { |user_id| joins(:last_message).where("messages.to_id = ?", user_id) }
	scope :not_turn, lambda { |user_id| joins(:last_message).where("messages.from_id = ?", user_id) }
	scope :to, lambda { |user_id| where("conversations.to_id = ?", user_id) }
	scope :from, lambda { |user_id| where("conversations.from_id = ?", user_id) }
	scope :with, lambda { |user_id| where("conversations.from_id = ? OR conversations.to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(conversations.from_id = ? AND conversations.to_id = ?) OR (conversations.from_id = ? AND conversations.to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("conversations.id != ?", id) }

	def editors
		[self.to, self.from]
	end

	def members
		[self.to, self.from]
	end

	def relationship user
		rel = :none
		if members.include? user
			if in_progress?
				rel = :ready
				rel = :waiting if last_message_from_id == user.id
			else
				rel = :ended
			end
		end
		rel
	end
end
