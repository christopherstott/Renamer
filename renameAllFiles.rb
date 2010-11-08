#!/usr/bin/env ruby
$: << File.dirname( __FILE__) 
require 'renamer'

####################################################################
#

if ARGV.count != 1
  puts "Must enter a directory to process"
  exit
end

directory = ARGV[0]

Dir[directory+'/**/*.*'].each do |f| 
  RenameAndMove(f)
end