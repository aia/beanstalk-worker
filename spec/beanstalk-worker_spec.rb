$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'beanstalk-client-rspec'
require 'pp'

describe "BeanStalk" do
  describe "Worker" do
    before(:each) do
      @default_config = {
        'beanstalk' => {
          'server' => "127.0.0.1",
          'port' => "11300",
          'tube' => "worker1"
        }
      }
      
      @test_config = {
        'beanstalk' => {
          'server' => '10.10.10.10',
          'port' => '11111',
          'tube' => 'testqueue'
        }
      }
      
      @original_stdout = $stdout
      $stdout = File.new('/dev/null', 'w')
      
      stub_const("Beanstalk::Pool", Beanstalk::MockPool)
    end
    
    it "should initialize with defaults" do
      @worker = BeanStalk::Worker.new
      
      @worker.config['beanstalk'].should eql @default_config['beanstalk']
    end
    
    it "should initialize with configuration" do
      @worker = BeanStalk::Worker.new(@test_config)
      
      @worker.config['beanstalk'].should eql @test_config['beanstalk']
    end
    
    it "should receive queued messages" do
      @worker = BeanStalk::Worker.new(@test_config)
      
      @worker.beanstalk.put("foo")
      
      job = @worker.beanstalk.reserve
      
      job.body.should eql "foo"
    end
    
    it "should log messages" do
      logger = mock Logger
      logger.should_receive(:error).with("Logging started")
      @worker = BeanStalk::Worker.new(@test_config, logger)
    end
    
    it "should start" do
      @worker = BeanStalk::Worker.new(@test_config)
      
      @worker.beanstalk.put("foo")
      
      @worker.start(1)
    end
    
    it "should start to receive several messages" do
      @worker = BeanStalk::Worker.new(@test_config)
      
      3.times { @worker.beanstalk.put("foo") }
      
      @worker.start(3)
      @worker.stats['received'].should eql 3
    end
    
    it "should start to receive no more the specified number of messages" do
      @worker = BeanStalk::Worker.new(@test_config)
      
      3.times { @worker.beanstalk.put("foo") }
      
      expect {
        @worker.start(4)
      }.to raise_exception
      
      @worker.stats['received'].should eql 3
    end
    
    it "should start to receive undefined number of messages" do
      @worker = BeanStalk::Worker.new(@test_config)

      3.times { @worker.beanstalk.put("foo") }
      
      expect {
        @worker.start(4)
      }.to raise_exception
      
      @worker.stats['received'].should eql 3
    end
  end
end