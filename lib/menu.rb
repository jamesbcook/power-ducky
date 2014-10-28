#!/usr/bin/env ruby
require 'core'
require 'guide'
class Menu
  include Core::Commands

  class << self
    attr_accessor :title, :path, :description, :opts
  end

  def initialize
    files = Dir.glob("#{File.dirname(__FILE__)}/#{self.class.path}/*.rb")
    load_modules(files).to_a
  end

  def load_modules(class_files)
    before = ObjectSpace.each_object(Class).to_a
    class_files.each { |file| require file }
    after = ObjectSpace.each_object(Class).to_a
    @modules = []
    (after - before).each do |mod|
      @modules << mod if mod.method_defined?(:ducky)
    end
  end

  def list_options(options)
    system('clear')
    options.each { |item| puts "#{item}" }
    puts
    choice = rgets('Choice: ')
    select_option(choice)
  end

  def select_option(selected_option)
    @modules[selected_option.to_i - 1].new
  end

  def launch!
    options = []
    options << self.class.title
    i = 1
    @modules.each { |mod| options << "#{i}) #{mod.title}" && i += 1 }
    list_options(options)
  end
end
