#!/usr/bin/env ruby
# -- coding: utf-8

require "rubygems"
require "eventmachine"
require "twitter/json_stream"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "horobi"

EM.run do
  stream = Twitter::JSONStream.connect(
    :path    => "/1/statuses/filter.json?track=#{ARGV.first}",
    :auth    => "#{ENV["SCREEN_NAME"]}:#{ENV["PASSWORD"]}"
  )
  stream.each_item do |json|
    Horobi::Pub.send(json)
  end

  stream.on_error do |message|
    p message
    EM.stop
  end
end
