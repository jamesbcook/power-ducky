#!/usr/bin/env ruby
require 'readline'
require './lib/banners'
include Banners
module Menu
  def main_menu
		system('clear')
		print_main_banner
    print "
		  \n1) Reverse Meterpreter \
		  \n2) Dump Domain and Local Hashes \
		  \n3) Dump Lsass Process \
			\n99) Exit\n" 
		answer = Readline.readline('> ', true)
		return answer
	end
	def reverse_meterpreter
		system('clear')
		print_reverse_meterpreter_banner
		puts "This payload will create a reverse meterpreter shell through powershell bypassing all AV"
    print "
		\n1) Admin with UAC \
		\n2) Admin with out UAC \
		\n3) Low Priv \
		\n99) Main Menu\n"
		answer = Readline.readline('> ', true)
		return answer
	end
	def dump_hashes
		system('clear')
		print_dump_hash_banner
		puts "This payload will dump Domand cached and Local Hashes and then push them to a listening server"
    print "
		\n1) Admin with UAC \
		\n2) Admin with out UAC \
		\n99) Main Menu\n"
		answer = Readline.readline('> ', true)
		return answer
	end
	def dump_lsass
		system('clear')
		print_dump_lsass_banner
		puts "This payload will dump the lsass process memory through powershell and then upload it to a listening server"
    print "
		\n1) Admin with UAC \
		\n2) Admin with out UAC \
		\n99) Main Menu\n"
		answer = Readline.readline('> ', true)
		return answer
	end
end
