require 'cangaroo/engine'
require 'interactor'
require 'json-schema'
require 'httparty'

require 'cangaroo/logger'
require 'cangaroo/logger_helper'
require 'cangaroo/webhook/error'
require 'cangaroo/webhook/client'
require 'cangaroo/class_configuration'

module Cangaroo
  class << self
    attr_writer :logger

    def logger
      @logger ||= Cangaroo::Logger.instance
    end
  end
end
