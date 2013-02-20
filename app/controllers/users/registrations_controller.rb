class Users::RegistrationsController < Devise::RegistrationsController
	
	respond_to :json, :html
	
	# GET /resource/sign_up
	# def new
	#	# @invitation = Invitation.find_by_id(session[:invitation_id])
	#	resource = build_resource({})
	#	# resource.email ||= @invitation.try(:invitation_request).try(:email)
	#	# flash[:notice] = "Create an account to redeem your invitation." if @invitation
	#	respond_with resource do |format|
	#		format.html { render layout: 'landing' }
	#	end
	# end

	# POST /resource
	def create
		# @invitation = Invitation.find_by_id(session[:invitation_id])
		build_resource

		# resource.invitation_id = session[:invitation_id]
		# resource.invitation_code = session[:invitation_code]
		
		# TODO: get this to work with angular
		# to track referral source
		# utmz = cookies["__utmz"]
		# data = GaCookieParser::GaCookieParser.new(:utmz => utmz)
		# resource.acq_source = data.utmz_hash[:utmcsr]
		# resource.acq_medium = data.utmz_hash[:utmcmd]

		if resource.save
			# session.delete(:invitation_id)
			# session.delete(:invitation_code)
			if resource.active_for_authentication?
				set_flash_message :notice, :signed_up if is_navigational_format?
				sign_in(resource_name, resource)
			else
				set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
				expire_session_data_after_sign_in!
			end
			# analytical.event 'Successful Email Registration', { username: resource.username }
			# analytical.event 'Successful Registration', { username: resource.username }
			respond_with resource, :location => after_inactive_sign_up_path_for(resource)
		else
			clean_up_passwords resource
			# analytical.event 'Failed Email Registration', { errors: resource.errors.to_json }
			# analytical.event 'Failed Registration', { errors: resource.errors.to_json }
			# flash[:error] = "invitation #{resource.errors.messages[:invitation].first}" if resource.errors.messages[:invitation]
			respond_with resource
		end
	end

end