$:.unshift File.dirname(__FILE__)

module BeanStalk
  class Worker
    VERSION = '0.1.4'
  end
end

require 'beanstalk-worker/version_class'
require 'beanstalk-worker/config'
require 'beanstalk-worker/logger'
require 'beanstalk-worker/worker'
