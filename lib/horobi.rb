# coding: utf-8

require "logger"
require "optparse"
require "rubygems"
require "yaml"
require "zmq"

module Horobi
  attr_accessor :logger
  attr_reader :config
  @logger = Logger.new(nil)
  @closes = []

  def daemonize
    exit!(0) if fork
    Process.setsid
    exit!(0) if fork

    STDIN.reopen('/dev/null', 'r+')
    #STDOUT.reopen('/dev/null', 'a')
    #STDERR.reopen('/dev/null', 'a')
  end

  def close_hooks(&block)
    @closes << block
  end

  %w!INT TERM!.each{|sig|
    Signal.trap(sig) do
      @closes.each{|destruct|
        destruct.call
      }
    end
  }

  extend self
end

require "#{File.dirname(__FILE__)}/horobi/hub.rb"
require "#{File.dirname(__FILE__)}/horobi/sub.rb"
require "#{File.dirname(__FILE__)}/horobi/pub.rb"
