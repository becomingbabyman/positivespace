module Shortener::ShortenerHelper
	def short_url(url, owner=nil)
		short_url = Shortener::ShortenedUrl.generate(url, owner)

		if Rails.env == 'production'
			short_url ? "http://pos.yt/#{short_url.unique_key}" : url
		else
			short_url ? url_for(:controller => :"shortener/shortened_urls", :action => :show, :id => short_url.unique_key, :only_path => false, subdomain: "s") : url
		end
	end
end
