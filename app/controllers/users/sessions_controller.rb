class Users::SessionsController < Devise::SessionsController
	prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
	prepend_before_filter :allow_params_authentication!, :only => :create
	prepend_before_filter { request.env["devise.skip_timeout"] = true }

	respond_to :json

	# # POST /resource/sign_in
	# def create

	#	self.resource = warden.authenticate!(auth_options)
	#	set_flash_message(:notice, :signed_in) if is_navigational_format?
	#	if sign_in(resource_name, resource)
	#		# analytical.event 'Successful Email Login', { username: current_user.username }
	#		# analytical.event 'Successful Login', { username: current_user.username }
	#	end
	#	respond_with resource, :location => after_sign_in_path_for(resource)

	# end

end

