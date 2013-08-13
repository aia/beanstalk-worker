require 'beanstalk-client'

class BeanStalk::Worker
  attr_accessor :config, :log, :beanstalk, :stats
  
  def initialize(config = {})
    @config = BeanStalk::Worker::Config
    @config.merge!(config || {})
    @logger = BeanStalk::Worker::Log

    @logger.info("Logging started")
    
    @stats = {
      'received' => 0
    }
    
    initialize_beanstalk
  end
  
  def initialize_beanstalk
    @beanstalk = Beanstalk::Pool.new([
      BeanStalk::Worker::Config.beanstalk_uri
    ])
    
    @beanstalk.watch(@config[:beanstalk][:tube])
    @beanstalk.use(@config[:beanstalk][:tube])
    @beanstalk.ignore('default')
  end
  
  def start(received = -1)
    while (received == -1) || (@stats['received'] < received)
      begin
        job = @beanstalk.reserve
        
        @logger.debug("job #{job.inspect}")
        @logger.debug("job #{job.body.inspect}")
        
        @stats['received'] += 1
        
        job.delete if work(job)
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
