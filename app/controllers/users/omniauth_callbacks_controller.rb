class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	# respond_to :json

	def facebook
		@user = User.find_for_facebook(env["omniauth.auth"].extra.raw_info, current_user, session[:invitation_id], session[:invitation_code])

		# flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"

		if @user.persisted?
			# session.delete(:invitation_id)
			# session.delete(:invitation_code)

			sign_in @user, :event => :authentication
			# analytical.identify(@user.id, { name: @user.username } )

			# if DateTime.now.to_i - @user.created_at.to_i < 10.seconds
			#	# analytical.event 'Successful Facebook Registration', { username: @user.username }
			#	# analytical.event 'Successful Registration', { username: @user.username }
			# else
			#	# analytical.event 'Successful Facebook Login', { username: @user.username }
			#	# analytical.event 'Successful Login', { username: @user.username }
			# end
		end

		# respond_with @user
	end

	def twitter
		@user = User.find_for_twitter(request.env["omniauth.auth"].extra.raw_info, request.env["omniauth.auth"].extra.access_token, params, current_user, session[:invitation_id], session[:invitation_code])
		# render json: request.env["omniauth.auth"].to_json
		if @user and @user.persisted?
			sign_in @user, :event => :authentication
			redirect_to params[:redirect_uri] if params[:redirect_uri]
		else
			render json: {error: 'Twitter account not associated with any Positive Space account. Pleace sign up with Facebook or Email and then connect your Twitter account.'}, template: false, status: 400
		end
	end

	def linkedin
		@user = User.find_for_linkedin(request.env["omniauth.auth"], params, current_user, session[:invitation_id], session[:invitation_code])
		# render json: request.env["omniauth.auth"].to_json
		if @user and @user.persisted?
			sign_in @user, :event => :authentication
			redirect_to params[:redirect_uri] if params[:redirect_uri]
		else
			render json: {error: 'LinkedIn account not associated with any Positive Space account. Pleace sign up with Facebook or Email and then connect your LinkedIn account.'}, template: false, status: 400
		end
	end

	def github
		@user = User.find_for_github(request.env["omniauth.auth"], params, current_user, session[:invitation_id], session[:invitation_code])
		# render json: request.env["omniauth.auth"].to_json
		if @user and @user.persisted?
			sign_in @user, :event => :authentication
			redirect_to "/previous/url"
		else
			render json: {error: 'GitHub account not associated with any Positive Space account. Pleace sign up with Facebook or Email and then connect your GitHub account.'}, template: false, status: 400
		end
	end

	def passthru
		render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
	end

end
