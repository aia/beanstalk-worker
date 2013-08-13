$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'beanstalk-client-rspec'

describe "BeanStalk" do
  describe "Worker" do
    before(:each) do
      BeanStalk::Worker::Config[:log_location] = '/dev/null'
      BeanStalk::Worker::Log.init
      BeanStalk::Worker::Log.reset!
      
      @test_config = {
        :beanstalk => {
          :server => '10.10.10.10',
          :port => 11111,
          :tube => 'testqueue'
        }
      }
      
      @original_stdout = $stdout
      $stdout = File.new('/dev/null', 'w')
      
      stub_const("Beanstalk::Pool", Beanstalk::MockPool)
    end
    
    it "should initialize with configuration" do
      @worker = BeanStalk::Worker.new(@test_config)
      @worker.config[:beanstalk].should eql @test_config[:beanstalk]
    end
    
    it "should receive queued messages" do
      @worker = BeanStalk::Worker.new(@test_config)
      @worker.beanstalk.put("foo")
      job = @worker.beanstalk.reserve
      job.body.should eql "foo"
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
