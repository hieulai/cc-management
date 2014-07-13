source 'https://rubygems.org'

gem 'rails', '3.2.16'

group :test, :development do
  gem 'annotate'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass', '~> 2.3.1.0'
end

group :production do
  gem 'pg'
  gem 'unicorn'
end

# Frontend stuff
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'cocoon'
gem 'simple_form'
gem 'rails3-jquery-autocomplete'
gem 'select2-rails'
gem 'kaminari'

# Uploads
gem 'carrierwave'
gem 'fog'
gem 'unf'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'roo'
gem 'to_xls', '~> 1.0.0'

# Indexing
gem 'sunspot_rails', '~> 1.3.1'
gem 'sunspot_solr', '~> 1.3.1'
gem 'progress_bar'

# Authentication
gem 'devise'

#Monitoring
gem 'newrelic_rpm'
gem "bugsnag"

# Misc
gem "acts_as_paranoid"
gem 'delayed_job_active_record'
