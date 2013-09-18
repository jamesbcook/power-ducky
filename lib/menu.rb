#!/usr/bin/env ruby
require 'readline'
require_relative 'banners'
include Banners
module Menu
  def main_menu
    system('clear')
    print_banner_color(main_banner)
    print "
      \n1) Reverse Meterpreter \
      \n2) Dump Domain and Local Hashes \
      \n3) Dump Lsass Process \
      \n4) Wget Execute \
      \n5) Hex to Bin \
      \n99) Exit\n"
    Readline.readline('> ', true)
  end
  def reverse_meterpreter_menu
    system('clear')
    print_banner_color(reverse_meterpreter_banner)
    puts 'This payload will create a reverse meterpreter shell through powershell bypassing all AV'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n3) Low Priv \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def dump_hashes_menu
    system('clear')
    print_banner_color(dump_hash_banner)
    puts 'This payload will dump Domain cached and Local Hashes and then push them to a listening server'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def dump_lsass_menu
    system('clear')
    print_banner_color(dump_lsass_banner)
    puts 'This payload will dump the lsass process memory through powershell and then upload it to a listening server'
    print "
    \n1) Admin with UAC \
    \n2) Admin with out UAC \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def powershell_wget_menu
    system('clear')
    print_banner_color(powershell_wget_banner)
    puts 'This payload will download and executable from a webserver and execute it on the system'
    print "
    \n1) Admin with UAC\
    \n2) Admin with out UAC\
    \n3) Low Priv  \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def hex_to_bin_menu
    system('clear')
    print_banner_color(hex_to_bin_banner)
    puts 'This payload will convert a binary to hex and then convert it back to a binary on the victim system and execute'
    print "
    \n1) Admin with UAC\
    \n2) Admin with out UAC\
    \n3) Low Priv  \
    \n99) Main Menu\n"
    Readline.readline('> ', true)
  end
  def language_menu
    puts "\nPlease select keyboard the appropriate keyboard layout!"
    print "
    \n1) us \
    \n2) be \
    \n3) it \
    \n4) dk \
    \n5) es \
    \n6) uk \
    \n7) sv \
    \n8) ru \
    \n9) pt \
    \n10) de \
    \n11) no \
    \n12) fr\n"
    Readline.readline('> ', true)
  end
end