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

  def main_menu(options, back = 'Main Menu')
    banner
    options << "#{options.length}) #{back}"
    banner = []
    Menu.opts[:banner].each { |k, v| banner << "#{k}: #{v}" }

    # Determine if menu options or notes is longer
    iterations = options.length > banner.length ? options.length : banner.length

    # Print the menu while maintaining format regardless of whether either
    # column is longer than the other
    i = 0
    while i < iterations
      first, second = options[i], banner[i]
      line = ''
      # Blank string for nil to maintain formatting
      first ||= ''
      line << first.ljust(42)
      line << second.rjust(40) if second
      puts line
      i += 1
    end

    puts
  end

  def banner
    system('clear')
    puts '*' * 81
    puts '*' + ' ' * 34 + 'Power Ducky' + ' ' * 34 + '*'
    puts '*' * 81
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

  def select_option(selected_option)
    return if selected_option.to_i > @modules.length
    @modules[selected_option.to_i - 1].new
  end

  def launch!
    options = []
    options << self.class.title
    @modules.each_with_index do |mod, index|
      options << "#{index + 1}) #{mod.title}"
    end
    main_menu(options)
    select_option(rgets('Choice: '))
    rescue SignalException
      return
  end
end
