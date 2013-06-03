class PagesController < ApplicationController

	def home
		# TODO: LAUNCH: REMOVE: the redirect
		if current_user or session[:show_angular]
			render :layout => 'angular', :template => 'pages/home'
		else
			redirect_to "http://signup.positivespace.io"
		end
	end

	def wildcard
		session[:show_angular] = true
		render :layout => 'angular', :template => 'pages/home'
	end

	def robots
		if Rails.env.production?
			render :layout => false, :content_type => "text/plain"
		else
			render :text => "User-agent: *\nDisallow: /", :layout => false, :content_type => "text/plain"
		end
	end

end
