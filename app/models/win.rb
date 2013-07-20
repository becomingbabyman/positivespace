class Win < ActiveRecord::Base
	attr_accessible :none
	attr_protected :none, as: :admin

	after_create :add_to_achievements_list
	before_destroy :remove_from_achievements_list

	belongs_to :user, counter_cache: :achievements_count
	belongs_to :achievement

	validates :user_id, presence: true
	validates :achievement_id, presence: true, uniqueness: { scope: :user_id }

private

	def add_to_achievements_list
		u = self.user
		n = self.achievement.name
		unless u.achievements_list.include?(n)
			u.achievements_list << n
			u.save
		end
	end

	def remove_from_achievements_list
		u = self.user
		n = self.achievement.name
		u.achievements_list.delete n
		u.save
	end

end
