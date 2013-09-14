#!/usr/bin/env ruby
require 'readline'
require_relative 'banners'
include Banners
module Menu
  def main_menu
    system('clear')
    puts main_banner
    print "
      \n1) Reverse Meterpreter \
      \n2) Dump Domain and Local Hashes \
      \n3) Dump Lsass Process \
      \n4) Wget Execute \
      \n99) Exit\n"
    Readline.readline('> ', true)
  end
  def reverse_meterpreter
    system('clear')
    puts reverse_meterpreter_banner
    puts 'This payload will create a reverse meterpreter shell through powershell bypassing all AV'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n3) Low Priv \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def dump_hashes
    system('clear')
    puts dump_hash_banner
    puts 'This payload will dump Domand cached and Local Hashes and then push them to a listening server'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def dump_lsass
    system('clear')
    puts dump_lsass_banner
    puts 'This payload will dump the lsass process memory through powershell and then upload it to a listening server'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def powershell_wget
    system('clear')
    puts powershell_wget_banner
    puts 'This payload will download and executable from a webserver and execute it on the system'
    print "
    \n1) Admin with UAC\
    \n2) Admin with out UAC\
    \n3) Low Priv\n"
    Readline.readline('> ', true)
  end
end