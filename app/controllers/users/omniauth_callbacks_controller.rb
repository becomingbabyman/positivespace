class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	# respond_to :json

	def facebook
		@user = User.find_for_facebook(env["omniauth.auth"].extra.raw_info, current_user, session[:invitation_id], session[:invitation_code])

		flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"

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

	def passthru
		render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
	end

end
