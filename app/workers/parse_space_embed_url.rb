require 'embedly'
class ParseSpaceEmbedUrl
	include Sidekiq::Worker
	# sidekiq_options queue: "high"
	# sidekiq_options retry: false

	def perform(space_id)
		space = Space.find(space_id)
		unless space.embed_url.blank?
			# TODO: move the key out of here
			embedly_api = Embedly::API.new :key => 'f42bdb4234f14b998f8f7bbe95d5acb3', :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; my@email.com)'
			obj = embedly_api.oembed :url => space.embed_url, autoplay: false, width: 400#, maxheight: 500 #, maxwidth: 278, frame: true, secure: true
			space.embed_data = obj[0].marshal_dump
			space.save!
		end
	end
end
