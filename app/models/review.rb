class Review < ActiveRecord::Base
	attr_accessible :explanation, :rating, :vote
	attr_protected :none, as: :admin

	belongs_to :reviewable, polymorphic: true, counter_cache: :reviews_count
	belongs_to :user, counter_cache: :reviewed_count

	validates :reviewable_id, presence: true
	validates :reviewable_type, presence: true
	validates :user_id, presence: true, uniqueness: {scope: [:reviewable_id, :reviewable_type]}
	validates :rating, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}, allow_blank: true

	scope :user_id, lambda { |id| where("reviews.user_id = ?", id) }


	def editors
		[self.user]
	end
end
