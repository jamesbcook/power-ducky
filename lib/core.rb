#!/usr/bin/env ruby
module MainCommands
	def print_error(text)
	  print "\e[31m[-]\e[0m #{text}"
	end 
  def print_info(text)
	  print "\e[34m[*]\e[0m #{text}"
  end 
  def print_success(text)
		print "\e[32m[+]\e[0m #{text}"
	end 
	def print_warning(text)
		print "\e[33m[!]\e[0m #{text}"
	end 
  def encoded_command(command)
		encoded_command = Base64.encode64(command.encode("utf-16le")).delete("\r\n")
	end
end
