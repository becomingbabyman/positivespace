class Review < ActiveRecord::Base
	attr_accessible :explanation, :rating, :vote_event, :tweet
	attr_protected :none, as: :admin

	state_machine :vote, :initial => :pending do
		event :vote_up do
			transition :pending => :positive
		end
		# after_transition on: :endorse, do: :after_endorse

		event :vote_skip do
		  transition :pending => :neutral
		end
		# after_transition on: :complete, do: :after_publish

		event :vote_down do
		  transition :pending => :negative
		end
		# after_transition on: :complete, do: :after_unpublish
	end

	after_save do
		inc_conversation_magnetism if self.reviewable_type == "Conversation"
	end

	has_paper_trail
	belongs_to :reviewable, polymorphic: true, counter_cache: :reviews_count
	belongs_to :user, counter_cache: :reviewed_count
	has_many :magnetisms, :as => :attachable, :dependent => :destroy

	validates :reviewable_id, presence: true
	validates :reviewable_type, presence: true
	validates :user_id, presence: true, uniqueness: {scope: [:reviewable_id, :reviewable_type]}
	validates :rating, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}, allow_blank: true
	validates :tweet, length: 1..140, allow_blank: true

	scope :user_id, lambda { |id| where("reviews.user_id = ?", id) }


	def editors
		[self.user]
	end

	# You can only tweet once per review
	def tweet= msg
		if msg and !self.tweet
			if !(1..140).cover?(msg.size)
				# The validation will add the error msg
				write_attribute(:tweet, msg)
			elsif self.user.tweet(msg)
				# TODO: should this be an update_attribute? We want to make sure this gets saved because we only want to call self.user.tweet(msg) once.
				write_attribute(:tweet, msg)
			end
		end
	end

	def recipient
		case self.reviewable_type
		when 'Conversation'
			self.reviewable.partner(self.user)
		else
			User.new
		end
	end

private

	def inc_conversation_magnetism
		# If the conversation was positive
		if self.positive?
			# Find the person the reviewer was talking to
			partner = self.reviewable.partner(self.user)
			# Only reviewers with magnetism > 107 can increase the magnetism of other people.
			# Only conversations with > 3 messages are elligable for magnetism.
			if self.user.magnetism > 107 and self.reviewable.messages_count > 3
				# Give more on the first conversation to incentivise talking to strangers
				if Conversation.between(partner.id, self.user.id).order("created_at ASC").first == self.reviewable
					# Magnetism validations should keep duplicates from being created
					partner.magnetisms.where(inc: 5, reason: 'positive first conversation review', attachable_id: self.id, attachable_type: self.class.to_s).first_or_create
				else
					partner.magnetisms.where(inc: 2, reason: 'positive conversation review', attachable_id: self.id, attachable_type: self.class.to_s).first_or_create
				end
			end
		elsif self.negative?
			# Find the person the reviewer was talking to
			partner = (self.reviewable.from == self.user ? self.reviewable.to : self.reviewable.from)
			# Only reviewers with magnetism > 999 can decrease the magnetism of other people.
			if self.user.magnetism > 999
				partner.magnetisms.where(inc: -2, reason: 'negative conversation review', attachable_id: self.id, attachable_type: self.class.to_s).first_or_create
			end
		end
	end

end
