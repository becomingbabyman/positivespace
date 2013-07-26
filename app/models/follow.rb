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
		t = self.follower
		if t.has_attribute? :follows_count
			t.increment(:follows_count)
			t.save!
		end
	end

	def decrement_counter_cache
		m = self.followable
		if m.has_attribute? :followers_count
			m.decrement(:followers_count)
			m.save!
		end
		t = self.follower
		if t.has_attribute? :follows_count
			t.decrement(:follows_count)
			t.save!
		end
	end
end
