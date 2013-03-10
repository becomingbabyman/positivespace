# config/initializers/setup_mail.rb
require "development_mail_interceptor"

if Rails.env.to_s == "development"
elsif ["test", "sandbox"].include?(Rails.env.to_s)
  ActionMailer::Base.raise_delivery_errors = true

  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "positivespace.io",
    :user_name            => "test-email-account1@positivespace.io",
    :password             => "TODO TODO TODO TODO",
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) # sends all mail to test-email-account1@positivespace.io

else

  ActionMailer::Base.smtp_settings = {
    :port =>           '587',
    :address =>        'smtp.mandrillapp.com',
    :user_name =>      ENV['MANDRILL_USERNAME'],
    :password =>       ENV['MANDRILL_APIKEY'],
    :domain =>         'positivespace.io',
    :authentication => :plain
  }
  ActionMailer::Base.delivery_method = :smtp

  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env == 'staging' # sends all mail to test-email-account1@positivespace.io
end

if Rails.env == "test"
  ActionMailer::Base.delivery_method = :test
end
