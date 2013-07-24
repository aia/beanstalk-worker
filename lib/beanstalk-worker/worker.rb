require 'logger'
require 'beanstalk-client'

module BeanStalk
  class Worker
    attr_accessor :config, :log, :beanstalk, :stats
    
    def initialize(config = {}, logger = nil)
      @config = {
        'beanstalk' => {
          'server' => "127.0.0.1",
          'port' => "11300",
          'tube' => "worker1"
        }
      }
      
      @config['beanstalk'].merge!(config['beanstalk'] || {})
      
      initialize_logger unless logger
      
      @log = logger if logger
      
      @log.error("Logging started")
      
      @stats = {
        'received' => 0
      }
      
      initialize_beanstalk
    end
    
    def initialize_logger
      @config['log'] = {
        'file' => $stdout,
        'level' => 'INFO'
      }.merge(@config['log'] || {})

      log_initialize = [@config['log']['file']]
      log_initialize << @config['log']['shift_age'] if @config['log']['shift_age']
      log_initialize << @config['log']['shift_size'] if @config['log']['shift_size']

      begin
        @log = Logger.new(*log_initialize)
        @log.level = Logger.const_get(@config['log']['level'])
      rescue Exception => e
        @config['log'] = {
          'file' => $stdout,
          'level' => 'INFO'
        }
        @log = Logger.new(@config['log']['file'])
        @log.level = Logger.const_get(@config['log']['level'])
        @log.error("Caught a problem with log settings")
        @log.error("#{e.message}")
        @log.error("Setting log settings to defaults")
      end
    end
    
    def initialize_beanstalk
      @beanstalk = Beanstalk::Pool.new([
        [@config['beanstalk']['server'], @config['beanstalk']['port']].join(":")
      ])
      
      @beanstalk.watch(@config['beanstalk']['tube'])
      @beanstalk.use(@config['beanstalk']['tube'])
      @beanstalk.ignore('default')
    end
    
    def start(received = -1)
      while (received == -1) || (@stats['received'] < received)
        begin
          job = @beanstalk.reserve
          
          @log.info("job #{job.inspect}")
          @log.info("job #{job.body.inspect}")
          
          @stats['received'] += 1
          
          job.delete if work(job)
        rescue Exception => e
          @log.error("Caught exception #{e.to_s}")
          exit
        end
      end
    end
    
    def work(job)
      return true
    end
  end
end