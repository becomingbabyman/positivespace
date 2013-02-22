class Api::V1::Users::PasswordsController < Devise::PasswordsController
	respond_to :json

	prepend_before_filter :require_no_authentication
	# Render the #edit only if coming from a reset password email link
	append_before_filter :assert_reset_token_passed, :only => :edit

	# POST /resource/password
	def create
		self.resource = resource_class.send_reset_password_instructions(resource_params)

		if successfully_sent?(resource)
			respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
		else
			respond_with(resource)
		end
	end

end

