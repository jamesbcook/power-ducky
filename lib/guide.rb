#!/usr/bin/env ruby
require 'menu'
require 'menus'

class Guide < Menu
  def initialize(options)
    # TODO: menu optoins need to include:
    # msf path, text path
    Menu.opts = {}

    launch!
  end

  def launch!
    options = []
    options << 'PowerShell'
    pick('1')
  end

  def pick(choice)
    case choice
    when '1'
      @powershell ||= Powershell.new
      @powershell.launch!
    when '2'
      exit
    end
    self.launch!
  end
end
