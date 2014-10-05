#!/usr/bin/env ruby
require 'core'
require 'server_setup'
require 'ducky_setup'

# Class that all modules will inheart from making it easier to create modules
class Skeleton
  include Core::Commands
  include Core::Files
  class << self
    attr_accessor :title, :description
  end

  def initialize
    system('clear')
    puts self.class.title
    puts self.class.description
    @file_name = self.class.title.gsub(' ', '_')
    @ducky_writer = Ducky::Writer.new
    @server_setup = Server::Setup.new
    setup
    run
    finish
  end

  def setup; end

  def run; end

  def finish; end
end
