class Win < ActiveRecord::Base
	attr_accessible :none
	attr_protected :none, as: :admin

	belongs_to :user, counter_cache: :achievements_count
	belongs_to :achievement

	validates :user_id, presence: true
	validates :achievement_id, presence: true, uniqueness: { scope: :user_id }
end
