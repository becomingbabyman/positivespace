source 'https://rubygems.org'
ruby '1.9.3'

# The Framework
gem 'rails', '3.2.11'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# The Database
gem 'pg'

# The Server
gem 'puma'

# Authentications & Permissions
gem 'devise'
# gem 'devise-async'
# gem 'omniauth-facebook', '1.4.0' # TODO: remove explicit version when CSRF bug is fixed http://stackoverflow.com/questions/11597130/omniauth-facebook-keeps-reporting-invalid-credentials
# gem 'omniauth-openid'
gem 'cancan'

# Slugging
gem 'friendly_id', '~> 4.0.9'

# Clean RESTful Controllers 
gem 'inherited_resources'
# and Controller Scopes
gem 'has_scope'

# Time
gem 'chronic'

# API - JSON Serialization
gem 'rabl'
gem 'oj'

# UJS - JQuery
gem 'jquery-rails'

# HAML View Templating
gem 'haml-rails'

# Inline Coffeescript Compiler
gem 'coffee-filter'

# Form Helpers
gem 'simple_form'

# Misc
gem 'possessive' 


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # gem 'bootstrap-sass', '~> 2.1.0.0'
  gem 'coffee-rails', '~> 3.2.1'
  # gem 'compass-rails'
  # gem 'compass-h5bp'
  # gem 'haml_coffee_assets'
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
end


group :development do
  gem 'pry'
  gem 'heroku'
  gem 'letter_opener'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'brakeman'
  gem 'foreman'
  # gem 'growl'
  # gem 'ruby-debug19', :require => 'ruby-debug'  # NOTE: only use when needed
end


group :production, :staging do
  gem 'exception_notification'
end
