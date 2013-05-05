class Follow < ActiveRecord::Base
	acts_as_follow_store

	after_create :increment_counter_cache
	after_destroy :decrement_counter_cache

	def increment_counter_cache
		m = self.followable
		if m.has_attribute? :followers_count
			m.increment(:followers_count)
			m.save!
		end
	end

	def decrement_counter_cache
		m = self.followable
		if m.has_attribute? :followers_count
			m.decrement(:followers_count)
			m.save!
		end
	end
end
