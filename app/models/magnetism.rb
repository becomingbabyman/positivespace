class Magnetism < ActiveRecord::Base

	attr_accessor :callback
	attr_accessible :none
	attr_protected :none, as: :admin

	after_create do
		unless callback == :none
			inc_user_magnetism
		end
	end

	before_destroy do
		unless callback == :none
			dec_user_magnetism
		end
	end

	has_paper_trail
	belongs_to :user, counter_cache: true
	belongs_to :attachable, polymorphic: true

	validates :inc, presence: true
	validates :reason, presence: true
	validates :user_id, presence: true
	validates :attachable_id, allow_blank: true, uniqueness: {scope: [:attachable_type, :user_id, :reason]}

private

	def inc_user_magnetism
		self.user.update_attribute(:magnetism, self.user.magnetism + self.inc)
	end

	def dec_user_magnetism
		self.user.update_attribute(:magnetism, self.user.magnetism - self.inc)
	end
end
