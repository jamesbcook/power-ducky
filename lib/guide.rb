#!/usr/bin/env ruby
require 'menu'
require 'menus'

class Guide < Menu
  def initialize(options)
    # TODO: menu optoins need to include:
    # msf path, text path
    Menu.opts = {}
    Menu.opts[:banner] = {
      host: Menu.opts[:server] || 'No Server started',
      ports: Menu.opts[:port] || 'No Ports used'
    }
    launch!
  end

  def launch!
    options = []
    options << 'Main Menu'
    options << '1) PowerShell'
    options << '2) CMD'
    main_menu(options, 'Exit')
    print 'Choice'
    begin
      pick(rgets(': ').strip)
    rescue SignalException
      exit
    end
  end

  def pick(choice)
    case choice
    when '1'
      @powershell ||= Powershell.new
      @powershell.launch!
    when '2'
      @cmd ||= CMD.new
      @cmd.launch!
    when '3'
      exit
    end
    self.launch!
  end
end
