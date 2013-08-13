require 'net/http'

class PagesController < ApplicationController

	def home
		if current_user
			# render :layout => 'angular', :template => 'pages/wildcard'
			redirect_to "/#{current_user.slug}"
		else
			render :layout => 'angular', :template => 'pages/home'
		end
	end

	def wildcard
		session[:show_angular] = true

		if request.headers['X-PJAX']
			render :layout => false, :template => 'pages/wildcard'
		elsif request.env["HTTP_USER_AGENT"] and request.env["HTTP_USER_AGENT"].match(/\(.*https?:\/\/.*\)/)
			uri = URI("http://seo.positivespace.io#{request.path}")
			uri.query = URI.encode_www_form(params)
			req = Net::HTTP::Get.new(uri)
			req["x-forwarded-host"] = "www.positivespace.io"
			res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
			render text: res.body, layout: false, :content_type => "text/html"
		else
			render :layout => 'angular', :template => 'pages/wildcard'
		end
	end

	def robots
		if Rails.env.production?
			render :layout => false, :content_type => "text/plain"
		else
			render :text => "User-agent: *\nDisallow: /", :layout => false, :content_type => "text/plain"
		end
	end

	def iframe
		render :layout => false
	end

end
