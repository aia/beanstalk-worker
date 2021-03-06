require 'mixlib/config'
require 'active_support/core_ext/hash'
require 'yajl'
require 'yaml'

# The configuration object for the gemindexer worker.
class BeanStalk::Worker
  module Config
    extend Mixlib::Config

    # Return the configuration itself upon inspection.
    def self.inspect
      configuration.inspect
    end

    class << self
      configuration = HashWithIndifferentAccess.new

      # Support merging via coercion to symbols.
      #
      # @param [ Hash ] hash The configuration hash to symbolize and merge.
      alias :base_merge! :merge!
      def merge!(hash)
        base_merge!(configuration.deep_merge(hash.deep_symbolize_keys))
      end
    end

    # Loads a given file and passes it to the appropriate parser.
    #
    # @raise [ IOError ] Any IO Exceptions that occur.
    #
    # @param [ String ] filename The filename to read.
    # @param [ Hash ] opts The options to send
    def self.from_file(filename, opts={})
      opts = { :parser => "yaml" }.merge(opts)
      send("from_file_#{opts[:parser]}".to_sym, filename,
        (opts[:environment] || self[:environment]))
    end

    # Loads a given ruby file and runs instance_eval against it
    # in the context of the current object.
    #
    # @raise [ IOError ] Any IO Exceptions that occur.
    #
    # @param [ String ] filename The file to read.
    def self.from_file_ruby(filename, *args)
      self.instance_eval(IO.read(filename), filename, 1)
    end

    # Loads a given yaml file and merges the current context
    # configuration with the updated hash.
    #
    # @raise [ IOError ] Any IO Exceptions that occur.
    # @raise [ Yajl::ParseError ] Raises Yajl Parsing error on improper json.
    #
    # @param [ String ] filename The file to read.
    # @param [ String ] environment The environment to use.
    def self.from_file_yaml(filename, environment)
      merge!(YAML.load_file(filename).deep_symbolize_keys[environment])
    end

    # Loads a given json file and merges the current context
    # configuration with the updated hash.
    #
    # @raise [ IOError ] Any IO Exceptions that occur.
    # @raise [ Yajl::ParseError ] Raises Yajl Parsing error on improper json.
    #
    # @param [ String ] filename The file to read.
    def self.from_file_json(filename, *args)
      self.from_stream_json(IO.read(filename))
    end

    # Loads a given json input and merges the current context
    # configuration with the updated hash.
    #
    # @raise [ IOError ] Any IO Exceptions that occur.
    # @raise [ Yajl::ParseError ] Raises Yajl Parsing error on improper json.
    #
    # @param [ String ] input The json configuration input.
    def self.from_stream_json(input, *args)
      parser = Yajl::Parser.new(:symbolize_keys => true)
      merge!(parser.parse(input))
    end

    # Helper method for generation the beanstalk uri
    #
    # @return [ String ] The beanstalk uri.
    def self.beanstalk_uri
      [self[:beanstalk][:server], self[:beanstalk][:port]].join(":")
    end

    # When you are using ActiveSupport, they monkey-patch 'daemonize' into
    # Kernel. So while this is basically identical to what method_missing
    # would do, we pull it up here and get a real method written so that
    # things get dispatched properly.
    config_attr_writer :daemonize do |v|
      configure do |c|
        c[:daemonize] = v
      end
    end

    # Enable debug
    debug false

    # Logging Settings
    log_level :warn
    log_location STDOUT
    log_formatter :json

    # Environment
    environment :development

    # Config file
    config_file "#{Dir.pwd}/beanstalk-worker.conf"

    # Beanstalk config
    beanstalk({
      :server => '127.0.0.1',
      :port => 11300,
      :tube => 'worker1'
    })

  end
end
