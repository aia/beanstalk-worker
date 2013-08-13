require 'logger'
require 'mixlib/log'
require 'mixlib/log/formatter'
require 'mixlib/log/jsonformatter'

# Beanstalk::Worker's internal logging facility.
# Standardized to provide a consistent log format.
module BeanStalk::Worker::Log
  class << self
    include Mixlib::Log

    # Use Mixlib::Log.init when you want to set up the logger manually.  Arguments to this method
    # get passed directly to Logger.new, so check out the documentation for the standard Logger class
    # to understand what to do here.
    #
    # If this method is called with no arguments, it will log to STDOUT at the :warn level.
    #
    # It also configures the Logger instance it creates to use the custom Mixlib::Log::Formatter class.
    def init(*opts)
      reset!
      @logger = logger_for(BeanStalk::Worker::Config[:log_location])
      if @logger.respond_to?(:formatter=)
        if BeanStalk::Worker::Config[:log_formatter].eql?(:json)
          @logger.formatter = Mixlib::Log::JSONFormatter.new()
        else
          @logger.formatter = Mixlib::Log::Formatter.new()
        end
      end
      @logger.level = Logger.const_get(
        BeanStalk::Worker::Config[:log_level].to_s.upcase)
      @logger
    end
  end

  # Monkeypatch Formatter to allow local show_time updates.
  class Formatter
    # Allow enabling and disabling of time with a singleton.
    def self.show_time=(*args)
      Mixlib::Log::Formatter.show_time = *args
    end
  end
end
