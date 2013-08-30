class EmbedsController < ApplicationController
	def space
		@space = Space.find(params[:id])
		render :layout => 'embed', :template => 'embeds/space'
	end

	# def user
	# 	render :layout => 'embed', :template => 'embeds/user'
	# end
end