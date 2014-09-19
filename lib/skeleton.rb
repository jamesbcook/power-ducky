#!/usr/bin/env ruby

# Class that all modules will inheart from making it easier to create modules
class Skeleton
  class << self
    attr_accessor :title
  end

  def initialize
    setup
  end

  def setup; end

  def run; end

  def finish; end
end
