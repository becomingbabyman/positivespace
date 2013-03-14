source 'https://rubygems.org'
ruby '2.0.0'

# The Framework
gem 'rails', '3.2.11'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# The Database
gem 'pg'

# The Server
gem 'puma'

# The Worker & Friends
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'
gem 'sidekiq-failures'

# Memcached
gem 'memcachier'
gem 'dalli'

# Authentications & Permissions
gem 'devise'
gem 'devise-async'
gem 'omniauth', '~> 1.1.1'
gem 'omniauth-facebook', '1.4.0' # TODO: remove explicit version when CSRF bug is fixed http://stackoverflow.com/questions/11597130/omniauth-facebook-keeps-reporting-invalid-credentials
gem 'omniauth-openid'
gem 'cancan'

# Administration
gem 'rails_admin'

# Slugging
gem 'friendly_id', '~> 4.0.9'

# Versioning
gem 'paper_trail'

# Clean RESTful Controllers
gem 'inherited_resources'
# and Controller Scopes
gem 'has_scope'

# Time
gem 'chronic'

# API - JSON Serialization
gem 'rabl'
gem 'oj'

# Sync Assets to CDN
gem 'asset_sync'

# Uploads and Images
gem 'carrierwave'
gem 'rmagick'
gem 'fog'
gem 'gravtastic'

# Embedly API
gem 'embedly'

# Pagination
gem 'kaminari'

# UJS - JQuery
gem 'jquery-rails'

# Better Select Boxes
gem 'select2-rails'

# HAML View Templating
gem 'haml'

# Form Helpers
gem 'simple_form'

# Analytics
# gem 'newrelic_rpm'
# gem 'airbrake'
# Google Cookie Parser
gem 'ga_cookie_parser'

# Misc
gem 'html5-rails' # TODO: is this needed?
gem 'possessive'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'compass-h5bp'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end


group :development, :test, :sandbox do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
end


group :development, :test do
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'faraday'
end


group :development do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-remote'
  gem 'letter_opener'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'brakeman'
  gem 'foreman'
  # gem 'bullet'
  # gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  # gem 'growl'
  # gem 'ruby-debug19', :require => 'ruby-debug'  # NOTE: only use when needed
end


group :production, :staging do
  gem 'exception_notification'
  gem 'heroku-deflater'
end

