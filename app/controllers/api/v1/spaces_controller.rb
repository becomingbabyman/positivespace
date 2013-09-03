class Api::V1::SpacesController < InheritedResources::Base
	respond_to :json
	actions :show

	impressionist actions: [:show]
end
