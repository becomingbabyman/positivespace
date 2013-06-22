class EmailsController < ApplicationController
	skip_before_filter :verify_authenticity_token

	before_filter :pick_params

	def message
		@email_params[:action] = :message
		@email = Email.create(@email_params)
		Email.delay.process @email.id

		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

protected

	def pick_params
		@email_params = Hash[pick(params, Email.accessible_attributes.to_a.map(&:dasherize)).map { |k, v| [k.to_s.underscore, v] }]
	end
end
