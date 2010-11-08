#!/usr/bin/env ruby
$: << File.dirname( __FILE__) 
require 'renamer'

####################################################################
#

if ARGV.count != 1
  puts "Must enter a file to process"
  exit
end

filename = ARGV[0]
RenameAndMove(filename)