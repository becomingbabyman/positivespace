class Conversation < ActiveRecord::Base
	state_machine :initial => :in_progress do
		event :end do
			transition :in_progress => :ended
		end
	end

	attr_accessible :state_event
	attr_protected :none, as: :admin

	belongs_to :to, :class_name => 'User', :foreign_key => :to_id
	belongs_to :from, :class_name => 'User', :foreign_key => :from_id
	has_many :messages

	validates :to_id, presence: true
	validates :from_id, presence: true
	validates :prompt, presence: true

	default_scope :order => 'updated_at ASC'

	scope :in_progress, where(state: :in_progress)
	scope :ended, where(state: :ended)
	scope :with, lambda { |user_id| where("from_id = ? OR to_id = ?", user_id, user_id) }
	scope :between, lambda { |id1, id2| where("(from_id = ? AND to_id = ?) OR (from_id = ? AND to_id = ?)", id1, id2, id2, id1) }
	scope :is_not, lambda { |id| where("id != ?", id) }

	def editors
		[self.to]
	end

	def last_message
		Message.find_by_id(last_message_id)
	end

	def last_message_from
		User.find_by_id(last_message_from_id)
	end
end
