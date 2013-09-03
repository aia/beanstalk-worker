require 'beanstalk-client'

class BeanStalk::Worker
  attr_accessor :config, :log, :connection, :stats
  
  def initialize(config = {})
    @config = BeanStalk::Worker::Config
    if File.exists? @config[:config_file]
      if config[:environment]
        @config.from_file @config[:config_file], config[:environment]
      else
        @config.from_file @config[:config_file]
      end
    end
    @config.merge!(config || {})

    @logger = BeanStalk::Worker::Log
    @logger.reset!
    @logger.info("Logging started")
    
    @stats = {
      'received' => 0
    }
    
    initialize_beanstalk
  end
  
  def beanstalk
    if @connection.nil?
      @connection = Beanstalk::Pool.new([
        BeanStalk::Worker::Config.beanstalk_uri
      ])
      @logger.info("Connected to beanstalk")
    end
    @connection
  rescue
    @logger.error("Could not connect to beanstalk.")
    reconnect
  end
  
  def initialize_beanstalk    
    beanstalk.watch(@config[:beanstalk][:tube])
    beanstalk.use(@config[:beanstalk][:tube])
    beanstalk.ignore('default')
  rescue
    @logger.error("Could not connect to beanstalk.")
    reconnect
  end
  
  def reconnect
    @connection = nil
    @logger.error("Sleeping 30 seconds")
    sleep(30)
    @logger.error("Attempting to reconnect")
    start
  end
  
  def start(received = -1)
    while (received == -1) || (@stats['received'] < received)
      begin
        job = beanstalk.reserve
        
        @logger.debug("job #{job.inspect}")
        @logger.debug("job #{job.body.inspect}")
        
        @stats['received'] += 1
        
        job.delete if work(job)
      rescue Beanstalk::NotConnected => e
        @logger.error("Beanstalk disconnected")
        reconnect
      rescue Exception => e
        @logger.error("Caught exception #{e.to_s}")
        exit
      end
    end
  end
  
  def work(job)
    return true
  end
end
