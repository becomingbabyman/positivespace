class PagesController < ApplicationController

	def home
		render :layout => 'angular'
	end

	def robots
		if Rails.env.production?
			render :layout => false, :content_type => "text/plain"
		else
			render :text => "User-agent: *\nDisallow: /", :layout => false, :content_type => "text/plain"
		end
	end

end
