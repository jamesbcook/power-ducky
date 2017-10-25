power-ducky
===========

Power Shell Scripts for the Hak5 Ducky

```

*********************************************************************************
*                                  Power Ducky                                  *
*********************************************************************************
Main Menu                                                  host: No Server started
1) PowerShell                                                 ports: No Ports used
2) CMD                                    
3) Exit                                   

Choice: 

```


All payloads are written in powershell so nothing should be caught by AV


#### Meterpreter

Stores the meterpreter script on a web sever, the ducky will then go grab the script using ssl and execute it on the victims machine.  Or Localy reflectly load Metasploit.

#### Dump Lsass Process

Dumps the lsass process through powershell, then reads the file and dumps it through a tcp socket to a listening server.

#### Hash Dump

Module will save sys, sec and sam using reg.exe.  It will then ship thefiles over TCP to a listening server.

#### Dump Wifi Passwords

Dumps all available wifi profiles, and then dumps each file through a tcp socket

#### Wget Execute

Downloads a file and executes it on the victim's machine
