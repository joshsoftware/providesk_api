source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 6.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false
gem 'jwt'
gem 'mina'
gem 'mina-version_managers'
gem 'mina-sidekiq'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

#Use versionist for handling headers based api versioning
gem 'versionist'

# Use Serializers to generate JSON in an object-oriented and convention-driven manner.
gem 'active_model_serializers'

#Use aasm for state machine management
gem 'aasm', '~> 5.3'

# Use audited to log changes of models
gem 'audited', '~> 5.0'

# Use sidekiq for job scheduling
gem 'sidekiq','~> 6.5.8'
gem 'sidekiq-scheduler'

# Use cancan for authorization
# gem "cancan"
gem 'cancancan'

#use for aws
gem 'aws-sdk-s3', '~> 1.160'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  #rspec-rails is a testing framework for Rails
  gem 'rspec-rails', '~> 6.0.0.rc1'
  # factory_bot_rails provides integration between factory_bot and rails 4.2 or newer
  gem 'factory_bot_rails', '~> 6.2'

  # Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc.
  gem 'faker', '~> 2.23'
  gem 'rspec_api_documentation'

  #Use letter Opener to test the mailers
  gem 'letter_opener', '~> 1.8', '>= 1.8.1'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
