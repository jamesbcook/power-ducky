#!/usr/bin/env ruby
require 'menu'
require 'menus'

class Guide < Menu
  def initialize(options)
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
