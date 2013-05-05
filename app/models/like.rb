class Like < ActiveRecord::Base
	acts_as_like_store

	after_create :increment_counter_cache
	after_destroy :decrement_counter_cache

	def increment_counter_cache
		m = self.likeable
		if m.has_attribute? :likers_count
			m.increment(:likers_count)
			m.save!
		end
	end

	def decrement_counter_cache
		m = self.likeable
		if m.has_attribute? :likers_count
			m.decrement(:likers_count)
			m.save!
		end
	end
end
