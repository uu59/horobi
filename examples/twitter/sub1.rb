#!/usr/bin/env ruby
# -- coding: utf-8


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "horobi"
require "json"

Horobi::Sub.listen do |msg|
  begin
    tw = JSON.parse(msg)
    puts tw["user"]["screen_name"] + ": " + tw["text"]
  rescue
    next
  end
end
