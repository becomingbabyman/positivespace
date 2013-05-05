class Mention < ActiveRecord::Base
	acts_as_mention_store

	after_create :increment_counter_cache
	after_destroy :decrement_counter_cache

	def increment_counter_cache
		m = self.mentionable
		if m.has_attribute? :mentioners_count
			m.increment(:mentioners_count)
			m.save!
		end
	end

	def decrement_counter_cache
		m = self.mentionable
		if m.has_attribute? :mentioners_count
			m.decrement(:mentioners_count)
			m.save!
		end
	end
end
