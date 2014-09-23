#!/usr/bin/env ruby
require 'core'
require 'server_setup'
require 'ducky_setup'

# Class that all modules will inheart from making it easier to create modules
class Skeleton
  include Core::Commands
  class << self
    attr_accessor :title, :description
  end

  def initialize
    system('clear')
    puts self.class.title
    puts self.class.description
    setup
  end

  def setup; end

  def run; end

  def finish; end
end
