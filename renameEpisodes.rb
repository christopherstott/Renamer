#!/usr/bin/ruby

# Need to give mention to thetvdb.com

# Required gems :
# gem install xml-simple

require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'cgi'

$thetvdb_api_key = "89909344A1B56E06"

def ValidateInput
  puts "Validating Input"
  $directory = ARGV[0]
  
  if not File.exists? $directory
    puts "Directory does not exist"
    exit
  end
  
  if not File.directory? $directory
    puts "Input is not a directory"
    exit
  end
end

def CreateDummyEpisodes
  dir =`pwd`
  if dir.index "Testing" == nil
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
  `mkdir 'Blackadder/blackadder_s03'`
  `mkdir 'Blackadder/Series 4'`
  `mkdir 'Blackadder/Series4'`
  `mkdir 'Blackadder/Blackadder Season 4'`
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
  `echo h > 'Blackadder/blackadder_s03/Blackadder S03E03.avi'`
  `echo h > 'Blackadder/Blackadder S03E04.avi'`
  `echo h > 'Blackadder/Season3/Blackadder S03E05.avi'`
  `echo h > 'Blackadder/Series 4/Blackadder S04E01.avi'`
  `echo h > 'Blackadder/Series 4/Blackadder 02.avi'`
  `echo h > 'Blackadder/Series4/Blackadder 3.avi'`
  `echo h > 'Blackadder/Blackadder Season 4 Episode 4.avi'`
  `echo h > 'Blackadder/Blackadder Season 4/Blackadder Series 4 Ep 5.avi'`
  `echo h > 'Blackadder/Blackadder S05E01.avi'`
  `echo h > 'Blackadder/Blackadder S05E02.avi'`
  `echo h > 'Blackadder/Blackadder S05E03.avi'`
  `echo h > 'Blackadder/Blackadder S05E04.avi'`
  `echo h > 'Blackadder/Blackadder S05E05.avi'`
  `echo h > 'Blackadder/Blackadder S07E05.avi'`
end

def FindCurrentSeriesName
  $array = ARGV[0].split('/')
  return $array[$array.length-1]
end

# Startup
#CreateDummyEpisodes()
ValidateInput()


# Get Mirror
$mirrors_xml  = Net::HTTP.get URI.parse("http://thetvdb.com/api/#{$thetvdb_api_key}/mirrors.xml")
$mirrors      = XmlSimple.xml_in($mirrors_xml)
$mirror       = $mirrors["Mirror"][0]["mirrorpath"][0]

# Find the series name
$foldername   = FindCurrentSeriesName()
$oldseriesname= $foldername.split("(")[0]

# Get Series ID, Name, Year
$esc_seriesname = CGI::escape($foldername)
$series_xml   = Net::HTTP.get URI.parse("http://www.thetvdb.com/api/GetSeries.php?seriesname=#{$esc_seriesname}")
$series       = XmlSimple.xml_in($series_xml)
if $series=={}
  $esc_seriesname = CGI::escape($oldseriesname)
  $series_xml   = Net::HTTP.get URI.parse("http://www.thetvdb.com/api/GetSeries.php?seriesname=#{$esc_seriesname}")
  $series       = XmlSimple.xml_in($series_xml)
end
p $series
$year         = $series["Series"][0]["FirstAired"][0]
$year         = $year.split('-')[0]
$name         = $series["Series"][0]["SeriesName"][0]
$seriesid     = $series["Series"][0]["seriesid"][0]

if $name.index('(') == nil
  $seriesname = $name + " (" + $year + ")"
else
  $seriesname = $name
end

puts "Series Name : " + $seriesname
puts "Folder Name : " + $foldername

if $seriesname != $foldername
  `mv "#{$foldername}" "#{$seriesname}"`
else
  puts "Folder already correctly named"
end

$seasons = []

$episodes_xml = Net::HTTP.get URI.parse("http://www.thetvdb.com/api/#{$thetvdb_api_key}/series/#{$seriesid}/all/en.xml")
$episodes       = XmlSimple.xml_in($episodes_xml)
p $episodes
def ConstructSxxExxDescriptor(season,episode)
  season = season.to_i
  episode = episode.to_i
  return "S"+"%02d"%season+"E"+"%02d"%episode
end

$episode_table = {}

for $episode in $episodes["Episode"] do
  puts $episode["SeasonNumber"][0]+":"+$episode["EpisodeNumber"][0]+":"+$episode["EpisodeName"][0]
  $episode_table[ConstructSxxExxDescriptor($episode["SeasonNumber"][0],$episode["EpisodeNumber"][0])] = $episode["EpisodeName"][0]
end

p $episode_table

# Load the files (take all files from the root and first child directories)
$files = []
rootfiles = `ls -p "#{$seriesname}"`
for file in rootfiles
  # Directory?
  file.strip!
  
  if file[-1,1]=="/"
    childfiles = `ls -p "#{$seriesname}/#{file}"`
    for childfile in childfiles
      # Regular File
      childfile.strip!
      if childfile[-1,1]!="/"
        $files<<"#{file}"+childfile.strip
      end
    end
  else
    $files << file.strip
  end
end

def GuessSeasonNumber(filename)
  puts "Guessing Season number"
  # does it contain something like S01,S1,s01,s1? 
  if filename =~ /S(\d{1,2})/i
    return $1.to_i
  end
  
  if filename =~ /\sS\s(\d{1,2})/i
    return $1.to_i
  end
  
  # does it contain something like Season 01/season 1/etc
  pos = filename =~ /Season\s*(\d{1,2})/i
  if pos != nil
    return $1.to_i
  end
  
  if filename =~ /Series\s*(\d{1,2})/i
    return $1.to_i
  end
  
  # like 1x1 12x03 03x04
  if filename =~ /(\d{1,2})x/i
    return $1.to_i
  end
  
  # like folder 1/
  if filename =~ /(\d{1,2})\//i
    return $1.to_i
  end
  
  # like 102
  if filename =~ /(\d)\d{1,2}/
    return $1.to_i
  end
  
  # like 1204
  if filename =~ /(\d\d)\d\d/
    return $1.to_i
  end
  
  return 0
end

def GuessEpisodeNumber(filename)
  filename = filename[0,filename.rindex('.')]
  filename = filename[filename.index('/'),filename.length]

  # does it contain something like E01,E1,e01,e1? 
  if filename =~ /E(\d{1,2})/i
    return $1.to_i
  end
  
  if filename =~ /\sE\s(\d{1,2})/i
    return $1.to_i
  end
  
  # does it contain something like Episode 01/episode 1/etc
  if filename =~ /Episode\s*(\d{1,2})/i
    return $1.to_i
  end
  
  # does it contain something like Episode 01/episode 1/etc
  if filename =~ /Ep\s*(\d{1,2})/i
    return $1.to_i
  end
  
  # like 1x1 12x03 03x04
  if filename =~ /x(\d{1,2})/i
    return $1.to_i
  end
  
  # like 102
  if filename =~ /\d(\d{1,2})/
    return $1.to_i
  end
  
  # like 1204
  if filename =~ /\d\d(\d\d)/
    return $1.to_i
  end
  
  # like 2 or 06 (at the end of the line)
  if pos=filename =~ /(\d{1,2})$/
      return $1.to_i
  end
  return 0
end

$episodes = []
$unsorted = []
$seasons  = []
for file in $files
  season        = GuessSeasonNumber(file)
  episode       = GuessEpisodeNumber(file)
  puts file+":"+episode.to_s
  sxxexx        = ConstructSxxExxDescriptor(season,episode)
  puts sxxexx
  title         = $episode_table[sxxexx]
  seasonfolder  = "Season %02d" % season
  extension = file.split(".")[-1]
  puts title
  if title
    correctfilename = $seriesname + " - " + sxxexx + " - " + title + "." + extension
    #correctfilename = correctfilename.delete ":"
    $episodes << {"file"=>file,"SxxExx"=>sxxexx,"title"=>title,"correctfilename"=>correctfilename,"seasonfolder"=>seasonfolder}
    $seasons << seasonfolder
  else
    $unsorted << file
  end
end

$seasons.uniq!

if not File.exists? "Unknown/#{$seriesname}"
      `mkdir -p "Unknown/#{$seriesname}"`
end

$seasons.each   { |name| `mkdir -p '#{$seriesname}/#{name}'` }
$episodes.each  { |hash| `mv "#{$seriesname}"/"#{hash['file']}" "#{$seriesname}"/"#{hash['seasonfolder']}/#{hash['correctfilename']}"` }

# move random left over ones
puts "Unsorted"
for unsorted in $unsorted
  if unsorted.split('/').length==2
    if unsorted.split('/')[0] =~ /^Season \d\d/
      $regex = "^"+$seriesname.gsub("(","\\(").gsub(")","\\)")+" -"
      if unsorted.split('/')[1] =~ /#{$regex}/
        $seasons << unsorted.split('/')[0]
        next
      end
    end
  end
        
  filename = "Unknown/#{$seriesname}/#{unsorted}"
  folder = filename[0,filename.rindex("/")]
  
  `mkdir -p '#{folder}'`
  `mv "#{$seriesname}/#{unsorted}" "Unknown/#{$seriesname}/#{unsorted}"`
end

$seasons.uniq!

#delete the old ones
dirs = `ls '#{$seriesname}'`
dirs = dirs.split("\n")
$seasons.each { |name| dirs.delete name } 
dirs.each { |name| `rmdir '#{$seriesname}/#{name}'` }

# Places the files in those directories
#for $file in $files do
#  $file = $file.strip
#  $pos = $file =~ /S(\d?\d?)-?E(\d?\d?)/i
#
#  $series = $1
#  $episode = $2
#  
#  $descriptor = ConstructSxxExxDescriptor($series,$episode)
#  $series = "%02d" % $series.to_i
#  
#  if $episode_table.has_key? $descriptor
#    $extension = $file.split('.')[-1]
#    $newfilename = $seriesname + " - " + $descriptor + " - " + $episode_table[$descriptor] + "." + $extension
#  
#    
#    if not File.exists? "#{$seriesname}/Season #{$series}"
#      puts "Creating Directory : #{$seriesname}/Season #{$series}"
#      `mkdir '#{$seriesname}/Season #{$series}'`
#    end
#    
#    puts "Creating : " + "#{$seriesname}/Season #{$series}/#{$newfilename}"
#    
#    `mv "#{$seriesname}/#{$file}" "#{$seriesname}/Season #{$series}/#{$newfilename}"`
#  else
#    puts "Can't find description for : #{$file} (moving to unknown)"
#    if not File.exists? "Unknown/#{$seriesname}"
#      `mkdir -p "Unsorted/#{$seriesname}"`
#    end
#    `mv "#{$seriesname}/#{$file}" "Unknown/#{$seriesname}/#{$file}"`
#  end
#end
