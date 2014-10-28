#!/usr/bin/env ruby
require 'optparse'
options = {}
OptionParser.new do |opts|
  options[:version] = '2.0 - Power Ducky Rewrite'
  opts.on_tail('--help', 'Display this screen') do
    puts opts
    puts
    exit
  end

  opts.parse!
end

frame_work = __FILE__
frame_work = File.readlink(frame_work) while File.symlink?(frame_work)
APP_ROOT = File.dirname(frame_work)

$LOAD_PATH.unshift(File.join(APP_ROOT, 'lib'))
begin
  require 'guide'
  Dir.chdir(APP_ROOT) do
    Guide.new(options)
  end
end
