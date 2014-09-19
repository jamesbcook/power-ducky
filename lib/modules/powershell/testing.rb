#!/usr/bin/env ruby
require 'skeleton'
class Test < Skeleton
  attr_reader :ducky
  self.title = 'Testing'
  
  def setup
    puts 'hello'
  end
end
