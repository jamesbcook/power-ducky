power-ducky
===========

Power Shell Scripts for the Hak5 Ducky

```

        ____                             ____             __
       / __ \____ _      _____  _____   / __ \__  _______/ /____  __
      / /_/ / __ \ | /| / / _ \/ ___/  / / / / / / / ___/ //_/ / / /
     / ____/ /_/ / |/ |/ /  __/ /     / /_/ / /_/ / /__/ ,< / /_/ /
    /_/    \____/|__/|__/\___/_/     /_____/\__,_/\___/_/|_|\__, /
                                                           /____/
  
1) Fast Meterpreter      
2) Reverse Meterpreter       
3) Dump Domain and Local Hashes       
4) Dump Lsass Process       
5) Dump Wifi Passwords
6) Wget Execute       
99) Exit

```


All payloads are written in powershell so nothing should be caught by AV


####Fast Meterpreter

Stores the meterpreter script on a web sever, the ducky will then go grab the script using ssl and execute it on the victims machine.

####Reverse Meterpreter

Creates a reverse meterpreter shell through powershell injection

####Dump Domain and Local Hashes

Makes a copy of the sam and sys file, and then dumps those files through a tcp socket to a listening server.

####Dump Lsass Process

Dumps the lsass process through powershell, then reads the file and dumps it through a tcp socket to a listening server.

####Dump Wifi Passwords

Dumps all available wifi profiles, and then dumps each file through a tcp socket

####Wget Execute

Downloads a file and executes it on the victim's machine
