$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.dirname(__FILE__)

if RUBY_VERSION.gsub('.', '').to_i >= 190
  require 'simplecov'

  module SimpleCov::Configuration
    def clean_filters
      @filters = []
    end
  end

  SimpleCov.configure do
    clean_filters
    load_adapter 'test_frameworks'
  end

  ENV["COVERAGE"] && SimpleCov.start do
    add_filter "/.rvm/"
  end
end

require 'rspec'
require 'beanstalk-worker'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
