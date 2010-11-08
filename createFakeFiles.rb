#!/usr/bin/ruby

# Need to give mention to thetvdb.com

# Required gems :
# gem install xml-simple

require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'cgi'

def CreateFile(filename)
  File.open(filename, 'w') {|f| f.write('h') }
end

def CreateDummyFiles
  dir =`pwd`
  if dir.index("FakeDownloaded") == nil
    puts "CREATING DUMMY EPISODES CAN ONLY BE RUN INSIDE A dir called Testing"
    exit
  end
  puts "Creating Dummy Episodes"
  `rm -r -f -d *`
  `mkdir 'Blackadder'`
  `mkdir 'Blackadder/1'`
  `mkdir 'Blackadder/Season 1'`
  `mkdir 'Blackadder/Season 2'`
  `mkdir 'Blackadder/s3'`
  `mkdir 'Blackadder/Season3'`
  `mkdir 'blackadder_s03'`
  `mkdir 'Blackadder/Series 4'`
  `mkdir 'Blackadder/Series4'`
  `mkdir 'Blackadder Season 4'`
  Dir::mkdir('Ocean\'s.11[2001]DvDrip[Eng]-aXXo')
  `mkdir 'Point Break.1991-DvDRiP[x]'`
  `mkdir 'Mr And Mrs Smith 2005 BRRip [A Release Lounge H264]'`
  `echo h > 'Blackadder/Blackadder 1x1.avi'`
  `echo h > 'Blackadder/1/Blackadder S01E02.avi'`
  `echo h > 'Blackadder/Season 1/Blackadder S01E03.avi'`
  `echo h > 'Blackadder/Blackadder S01-E04.avi'`
  `echo h > 'Blackadder/Blackadder 02x01.avi'`
  `echo h > 'Blackadder/Blackadder S02-E02.avi'`
  `echo h > 'Blackadder/Season 2/Blackadder S02E03.avi'`
  `echo h > 'Blackadder/Season 2/Blackadder S02E04.avi'`
  `echo h > 'Blackadder/Blackadder 205.avi'`
  `echo h > 'Blackadder/Blackadder 3x01.avi'`
  `echo h > 'Blackadder/s3/Blackadder S03E02.avi'`
  `echo h > 'blackadder_s03/Blackadder S03E03.avi'`
  `echo h > 'Blackadder/Blackadder S03E04.avi'`
  `echo h > 'Blackadder/Season3/Blackadder S03E05.avi'`
  `echo h > 'Blackadder/Series 4/Blackadder S04E01.avi'`
  `echo h > 'Blackadder/Series 4/Blackadder 02.avi'`
  `echo h > 'Blackadder/Series4/Blackadder 3.avi'`
  `echo h > 'Blackadder/Blackadder Season 4 Episode 4.avi'`
  `echo h > 'Blackadder Season 4/Blackadder Series 4 Ep 5.avi'`
  `echo h > 'Blackadder/Blackadder S05E01.avi'`
  `echo h > 'Blackadder/Blackadder S05E02.avi'`
  `echo h > 'Blackadder/Blackadder S05E03.avi'`
  `echo h > 'Blackadder/Blackadder S05E04.avi'`
  `echo h > 'Blackadder/Blackadder S05E05.avi'`
  `echo h > 'Blackadder/Blackadder S07E05.avi'`
  CreateFile('Ocean\'s.11[2001]DvDrip[Eng]-aXXo/Ocean\'s.11[2001]DvDrip[Eng]-aXXo.avi')
  CreateFile('Ocean\'s.11[2001]DvDrip[Eng]-aXXo/ocean\'s.11-aXXo.nfo')
  CreateFile('Ocean\'s.11[2001]DvDrip[Eng]-aXXo/IMPORTANT.Read carefully before enjoy this movie.txt')
  `echo h > 'Point Break.1991-DvDRiP[x]/Point Break.1991-DvDRiP[x].avi'`
  `echo h > 'Point Break.1991-DvDRiP[x]/xRiPp3d.txt'`
  `echo h > 'Mr And Mrs Smith 2005 BRRip [A Release Lounge H264]/Mr And Mrs Smith 2005 BRRip [A Release Lounge H264].mp4'`
end

CreateDummyFiles()