#!/usr/bin/env ruby
# -- coding: utf-8

require "rubygems"
require "json"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "horobi"

loop do
  Horobi::Pub.send({
    "user" => {
      "screen_name" => "fake",
    },
    "text" => "this is fake tweet!"
  }.to_json)
  sleep 1
end
