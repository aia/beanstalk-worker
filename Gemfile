source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem 'beanstalk-client'
gem "mixlib-log", "~> 1.6.0"
gem "mixlib-config", "~> 1.1.2"
gem "mixlib-log-json", "~> 0.0.1"
gem "yajl-ruby", "~> 1.1.0"
gem "activesupport", "~> 4.0.0"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", ">= 2.13.0"
  gem "yard", "> 0.8"
  gem "rdoc", "> 4.0"
  gem "cucumber", ">= 0"
  gem "bundler", "~> 1.3.5"
  gem "jeweler", "~> 1.8.4"
  gem "beanstalk-client-rspec", ">= 0"
  gem (RUBY_VERSION.gsub('.', '').to_i >= 190 ? "simplecov" : "rcov"), ">= 0"
end
