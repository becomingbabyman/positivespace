class PagesController < ApplicationController
	
	def robots
		if Rails.env.production?
			render :layout => false, :content_type => "text/plain"
		else
			render :text => "User-agent: *\nDisallow: /", :layout => false, :content_type => "text/plain"
		end
	end

	def me
		if current_user
			redirect_to edit_user_path(current_user)
		else
			redirect_to root_url
		end
	end

end