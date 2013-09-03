class Space < ActiveRecord::Base

	state_machine :initial => :draft do
		event :publish do
			transition :draft => :published
		end
		# after_transition on: :publish, do: :after_publish
	end

	after_create :parse_embed_url

	attr_accessible :embed_data, :embed_url, :prompt, :state_event
	attr_protected :none, as: :admin

	serialize :embed_data

	acts_as_likeable
	is_impressionable :counter_cache => { :unique => true }
	belongs_to :user, counter_cache: :spaces_count
	has_many :conversations

	validates :prompt, presence: true, length: 1..250

private

	def parse_embed_url
		ParseSpaceEmbedUrl.perform_in(2.seconds, self.id) unless self.embed_url.blank?
	end

end
