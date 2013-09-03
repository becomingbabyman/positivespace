class EmbedsController < ApplicationController
	def space
		@space = Space.find(params[:id])
		render :layout => 'embed'
	end

	def user
		@user = User.find(params[:id])
		render :layout => 'embed'
	end
end