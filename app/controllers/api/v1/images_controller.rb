class Api::V1::ImagesController < InheritedResources::Base

	respond_to :json
	actions  :create, :update, :destroy, :show

	before_filter :init_image, on: :create

	before_filter :authenticate_user!
	load_and_authorize_resource

	def create
		@image = Image.create( image: params[:image], image_type: params[:image_type], attachable_id: params[:attachable_id].to_i, attachable_type: params[:attachable_type] )
		respond_with @image
	end

private

	def init_image
		@image = Image.new( attachable_id: params[:attachable_id].to_i, attachable_type: params[:attachable_type] )
	end

end
