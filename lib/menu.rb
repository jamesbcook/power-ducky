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
# require 'readline'
# require_relative 'banners'
# include Banners
# module Menu
#   def main_menu
#     system('clear')
#     print_banner_color(main_banner)
#     if Process.uid != 0
#       print_info('Not Running as Root some payloads may not work properly')
#     end
#     print "
#     \n1) Fast Meterpreter \
#     \n2) Reverse Meterpreter \
#     \n3) Dump Domain and Local Hashes \
#     \n4) Dump Lsass Process \
#     \n5) Dump Wifi Passwords \
#     \n6) Wget Execute \
#     \n99) Exit\n"
#     Readline.readline('> ', true)
#   end
#   def fast_meterpreter_menu
#     system('clear')
#     print_banner_color(fast_meterpreter_banner)
#     puts 'This payload will grab a powershell script from a ruby webserver and execute it on the victims computer'
#     print "
#     \n1) SSL Admin with UAC \
#     \n2) SSL Admin with out UAC \
#     \n3) SSL Low Priv \
#     \n4) Admin with UAC \
#     \n5) Admin with out UAC \
#     \n6) Low Priv \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   def reverse_meterpreter_menu
#     system('clear')
#     print_banner_color(reverse_meterpreter_banner)
#     puts 'This payload will create a reverse meterpreter shell through powershell bypassing all AV'
#     print "
#     \n1) Admin with UAC \
#     \n2) Admin with out UAC \
#     \n3) Low Priv \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   def dump_hashes_menu
#     system('clear')
#     print_banner_color(dump_hash_banner)
#     puts 'This payload will dump Domain cached and Local Hashes and then push them to a listening server'
#     print "
#     \n1) SSL Admin with UAC \
#     \n2) SSL Admin with out UAC \
#     \n3) Admin with UAC \
#     \n4) Admin with out UAC \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   def dump_lsass_menu
#     system('clear')
#     print_banner_color(dump_lsass_banner)
#     puts 'This payload will dump the lsass process memory through powershell and then upload it to a listening server'
#     print "
#     \n1) SSL Admin with UAC \
#     \n2) SSL Admin with out UAC \
#     \n3) Admin with UAC \
#     \n4) Admin with out UAC \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   def dump_wifi_menu
#     system('clear')
#     print_banner_color(dump_wifi_banner)
#     puts 'This payload will dump available wifi profiles through powershell and then upload it to a listening server'
#     print "
#     \n1) SSL Admin with UAC \
#     \n2) SSL Admin with out UAC \
#     \n3) SSL Low Priv \
#     \n4) Admin with UAC \
#     \n5) Admin with out UAC \
#     \n6) Low Priv \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   def powershell_wget_menu
#     system('clear')
#     print_banner_color(powershell_wget_banner)
#     puts 'This payload will download and executable from a webserver and execute it on the system'
#     print "
#     \n1) Admin with UAC\
#     \n2) Admin with out UAC\
#     \n3) Low Priv  \
#     \n99) Main Menu\n"
#     Readline.readline('> ', true)
#   end
#   #def hex_to_bin_menu
#   #  system('clear')
#   #  print_banner_color(hex_to_bin_banner)
#   #  puts 'This payload will convert a binary to hex and then convert it back to a binary on the victim system and execute'
#   #  print "
#   #  \n1) Admin with UAC\
#   #  \n2) Admin with out UAC\
#   #  \n3) Low Priv  \
#   #  \n99) Main Menu\n"
#   #  Readline.readline('> ', true)
#   #end
#   def language_menu
#     puts "\nPlease select the appropriate keyboard layout!"
#     print "
#     \n1) us \
#     \n2) be \
#     \n3) it \
#     \n4) dk \
#     \n5) es \
#     \n6) uk \
#     \n7) sv \
#     \n8) ru \
#     \n9) pt \
#     \n10) de \
#     \n11) no \
#     \n12) fr\n"
#     Readline.readline('> ', true)
#   end
# end
