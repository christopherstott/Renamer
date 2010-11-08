# Need to give mention to thetvdb.com

# Takes 1 input file & renames it & moves it into an organised directory tree

# Hierarchy looks like
# - Films
#   - Film Name (Year).extension
# - TV Episodes
#   - Series Name (Year)
#     - Season 0x
#       - Series Name (Year) - S0xE0y - Episode Name.extension
# - Uncertain TV
# - Uncertain Film
# - Quarantine


require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'cgi'

$thetvdb_api_key = "89909344A1B56E06"
$themoviedb_api_key = "e89374c1f4a9921af76dd3fc28f1a247"
$destination_root = '/SortedFiles'

$movies_root  = "/Volumes/MEDIA2/Movies/"
$tv_root      = "/Volumes/MEDIA2/TV Episodes/"

####################################################################
#
def ValidateFile(filename)
  if not File.exists? filename
    return false
  end
  
  if File.directory? filename
    return false
  end
  
  return true
end

####################################################################
#
def ShouldDelete?(filename)
  extension = filename[-4..-1]
  if [".txt",".nfo",".srt",".jpg",".png"].include?(extension)
    return true
  else
    if filename.downcase.include?('sample')
      return true
    else
      return false
    end
  end
end

####################################################################
#
def IsVideoFile?(filename)
  extension = filename[-4..-1]
  return [".avi",".mp4",".mkv",".mov"].include?(extension)
end

####################################################################
#
def StripConfusingThings(filename)
  filename = filename.gsub(/\[.*?\]/,'')
  filename = filename.gsub(/\{.*?\}/,'')
  filename = filename.gsub(/AC3/i,'')
  filename = filename.gsub(/H264/i,'')
  filename = filename.gsub(/20\d\d\D/,'')
  filename = filename.gsub(/19\d\d\D/,'')
  filename = filename.gsub(/dvdrip/i,'')
  filename = filename.gsub(/XviD/i,'')
  filename = filename.gsub('-aXXo','')
  filename = filename.gsub('1337x','')
  filename = filename.gsub(/720\S*/,'')
  filename = filename.gsub('KLAXXON','')
  filename = filename.gsub("Collector's Edition",'')
end

####################################################################
#
def IsMovie?(filename,base_directory)
  
  
  #$message = isMovieSized ? "Yes" : "No"
  
  
  short_filename = filename.sub(base_directory+'/','')
  modded_filename = StripConfusingThings(short_filename[0..-5])
  #filename_pieces = modded_filename.split('/')

  hasSeasonNumber = FindCertainSeasonNumber(modded_filename)!=0
  
  if (hasSeasonNumber)
    return false
  else
    isMovieSized = File.size(filename) > 600*1024*1024
    
    if (isMovieSized)
      return true
    else
      return false
    end
  end
  
  


  #if (filename_pieces.length>1)
  #  #
  
  #$message = filename_pieces.to_s
  #p "#{filename_pieces} : #{GuessSeasonNumber(modded_filename)}"
  return 
end

def TVDBQuery(url)
  if $cached_queries == nil
    $cached_queries = {}
  end
  
  if !$cached_queries.has_key?(url)
    $cached_queries[url] = Net::HTTP.get URI.parse(url)
  end
  
  return $cached_queries[url]    
end

def HasResults(movie)
  r = !(movie["totalResults"][0] == "0" || movie[0]=="Nothing found.")
  #puts "#{movie["totalResults"][0] == "0"} || #{movie[0]=="Nothing found."}"
  return r
end

def LookupMovie(name,alternative,year)
  #puts "LookupMovie #{name},#{alternative},#{year}"
  movie = {}
  if name != ''
    encname = CGI::escape(name)
    #puts "http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encname}"
    if (encname != '')
      movie_xml = Net::HTTP.get URI.parse("http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encname}")
      movie = XmlSimple.xml_in(movie_xml)
    end
  end
  if (!HasResults(movie))
    encalternative = CGI::escape(alternative)
    #puts "http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}"
    if (encalternative != '')
      movie_xml = Net::HTTP.get URI.parse("http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}")
      movie = XmlSimple.xml_in(movie_xml)
    end
  end
  if (!HasResults(movie))
    encalternative = CGI::escape(name.downcase.gsub('and','&'))
    #puts "http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}"
    if (encalternative != '')
      movie_xml = Net::HTTP.get URI.parse("http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}")
      movie = XmlSimple.xml_in(movie_xml)
    end
  end
  if (!HasResults(movie))
    encalternative = CGI::escape(alternative.downcase.gsub('and','&'))
    #puts "http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}"
    if (encalternative != '')
      movie_xml = Net::HTTP.get URI.parse("http://api.themoviedb.org/2.1/Movie.search/en/xml/#{$themoviedb_api_key}/#{encalternative}")
      movie = XmlSimple.xml_in(movie_xml)
    end
  end
  
  if (!HasResults(movie))
    return nil
  end
  
  movies = movie["movies"]
  
  #p movies[0]["movie"]
  #p movies[0]["movie"].length
  
  found_name = name
  found_released = year
  
  if (movies[0]["movie"].length==1)
    #puts "Only one movie"
    found_name = movies[0]["movie"][0]["name"]
    found_released = movies[0]["movie"][0]["released"][0]
  else
    if (year != '')
      movies[0]["movie"].each do |m|
        if (m["released"][0].include?(year))
          #puts "Grabbed by year #{year}"
          found_name = m["name"][0]
          found_released = m["released"][0]
          break
        end
      end
    else
      #puts "Grabbed the first"
      found_name = movies[0]["movie"][0]["name"][0]
      found_released = movies[0]["movie"][0]["released"][0]
    end
  end
  
  info = {}
  info[:name] = found_name
  info[:year] = found_released.sub(/-.*/,'')
  return info
end

def ApplyCommonTVSeriesSubstitutions(name)
  name = name.gsub('HIGNFY','Have I Got News For You')
  return name
end

def LookupTVSeries(foldername,season,episode,filename)
  foldername.strip!
  foldername = foldername.sub('-',' ')
  foldername = ApplyCommonTVSeriesSubstitutions(foldername)
  puts "foldername = #{foldername}"
  # Get Series ID, Name, Year
  esc_seriesname = CGI::escape(foldername)
  series_xml   = TVDBQuery("http://www.thetvdb.com/api/GetSeries.php?seriesname=#{esc_seriesname}")
  series       = XmlSimple.xml_in(series_xml)

  if series == {} || series == 'seriesname is required'

    foldername = foldername.sub(/\S+?$/,'')
    if (foldername=='')
      return nil
    end
    esc_seriesname = CGI::escape(foldername)
    series_xml   = TVDBQuery("http://www.thetvdb.com/api/GetSeries.php?seriesname=#{esc_seriesname}")
    series       = XmlSimple.xml_in(series_xml)
    
    if series == {} || series == 'seriesname is required'


      foldername = filename.split('/')[-2]
        puts "trying yet again #{foldername}"
      if (foldername=='')
        return nil
      end
      esc_seriesname = CGI::escape(foldername)
      series_xml   = TVDBQuery("http://www.thetvdb.com/api/GetSeries.php?seriesname=#{esc_seriesname}")
      series       = XmlSimple.xml_in(series_xml)
    end
  end

  #p series["Series"][0]
  if series != {} and series != "seriesname is required"

    if series["Series"][0].has_key?("FirstAired")
      year         = series["Series"][0]["FirstAired"][0]
      year         = year.split('-')[0]
    else
      if filename =~ /((19|20)\d\d)/
        year = $1
      else
        year = ''
      end
    end
    name         = series["Series"][0]["SeriesName"][0]
    seriesid     = series["Series"][0]["seriesid"][0]
    info = {}
    info[:year] = year
    info[:name] = name
    info[:episodeName] = ""

    episodes_xml = TVDBQuery("http://www.thetvdb.com/api/#{$thetvdb_api_key}/series/#{seriesid}/all/en.xml")
    episodes       = XmlSimple.xml_in(episodes_xml)

    for e in episodes["Episode"] do
      if (e["SeasonNumber"][0]==season.to_s)
        if (e["EpisodeNumber"][0]==episode.to_s)
          info[:episodeName] = e["EpisodeName"][0]
        end
      end
    end
  end
  return info
end

####################################################################
#
def FindCertainSeasonNumber(filename)
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
  if filename =~ /(\s\d{1,2})x/i
    return $1.to_i
  end
  
  # like folder 1/
  #if filename =~ /(\d{1,2})\//i
  #  return $1.to_i
  #end
  
  # like 102
  #if filename =~ /(\d)\d{2}\D/
  #  return $1.to_i
  #end
  
  # like 1204
  #if filename =~ /(\d\d)\d\d/
  #  return $1.to_i
  #end
  
  return 0
end

####################################################################
#
def StripTVInfo(filename)
  filename = filename.sub(/S\d.*?$/,'')
  filename = filename.sub(/\s\d.*?$/,'')
  filename = filename.gsub('.',' ')
  
  parts = filename.split('/')
  if (parts.length > 1)
    return parts[-2]
  else
    return filename
  end
end

####################################################################
#
def GuessSeasonNumber(filename)
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
  if filename =~ /(\d)\d{2}\D/
    return $1.to_i
  end
  
  # like 1204
  if filename =~ /(\d\d)\d\d/
    return $1.to_i
  end
  
  return 0
end

####################################################################
#
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
  
  if filename =~ /Ep(\d{1,2})/i
    return $1.to_i
  end
  
  if filename =~ /(\d{1,2})of/i
    return $1.to_i
  end
  
  
  # like 1x1 12x03 03x04
  if filename =~ /x(\d{1,2})/i
    return $1.to_i
  end
  
  # like Pt8
  if filename =~ /Pt(\d{1,2})/i
    return $1.to_i
  end
  
  # like 102
  if filename =~ /\d(\d\d)/
    return $1.to_i
  end
  
  # like 1204
  if filename =~ /\d\d(\d\d)/
    return $1.to_i
  end
  
  # like 2 or 06 (at the end of the line)
  if pos=filename =~ /(\d\d)$/
    return $1.to_i
  end
  
  if pos=filename =~ /(\d)$/
    return $1.to_i
  end
  return 0
end

####################################################################
#
def GetMirror
  mirrors_xml  = Net::HTTP.get URI.parse("http://thetvdb.com/api/#{$thetvdb_api_key}/mirrors.xml")
  mirrors      = XmlSimple.xml_in(mirrors_xml)
  mirror       = mirrors["Mirror"][0]["mirrorpath"][0]
end


####################################################################
#
def FormTVFilename(filename,base_directory)
  short_filename = filename.sub(base_directory+'/','')
  extension = filename[-4..-1]
  season = GuessSeasonNumber(filename)
  episode = GuessEpisodeNumber(filename)
  puts "#{filename} #{season} #{episode}"
  info = LookupTVSeries(StripTVInfo(short_filename),season.to_i,episode.to_i,filename)
  if (info == nil)
    return
  end
  programfolder = "#{info[:name]} (#{info[:year]})"
  seasonfolder  = "Season %02d" % season.to_i
  newFilename = "#{info[:name]} (#{info[:year]}) - #{ConstructSxxExxDescriptor(season,episode)}"

  if info[:episodeName].to_s != ''
    newFilename = newFilename + " - " + info[:episodeName].to_s
  end
  
  
  return "#{programfolder}/#{seasonfolder}/#{newFilename}#{extension}"
end

####################################################################
#
def GutMovieName(file)
  file = file.sub(/\[.*?$/,'')
  file = file.sub(/\(.*?$/,'')
  file = file.sub(/\{.*?$/,'')
  file = file.sub(/19\d\d.*?$/,'')
  file = file.sub(/20\d\d.*?$/,'')
  file = file.gsub('.',' ')
  file = file.sub(/WS.*?$/,'')
  file = StripConfusingThings(file)
  return file
end

####################################################################
#
def FormMovieFilename(filename,base_directory)
  extension = filename[-4..-1]
  file = filename.split('/')[-1][0..-5]
  file = GutMovieName(file)
  
  alt = filename.split('/')[-2][0..-5]
  alt = GutMovieName(alt)
  
  if filename =~ /((19|20)\d\d)/
    year = $1
  else
    year = ''
  end
  
  info = LookupMovie(file,alt,year)
  if info != nil
    if info[:year]!=''
      filename = "#{info[:name]} (#{info[:year]})#{extension}"
    else
      filename = "#{info[:name]}#{extension}"
    end
  else
    # Unable to name file
    filename = ''
  end
  return filename
end

####################################################################
#
def ConstructSxxExxDescriptor(season,episode)
  season = season.to_i
  episode = episode.to_i
  return "S"+"%02d"%season+"E"+"%02d"%episode
end

####################################################################
#
def PrintOutcome(outcome,oldfilename,newfilename)
  padding = " "*(16-outcome.length)
  puts "[#{outcome}]#{padding}#{oldfilename} -> #{newfilename}"
end

####################################################################
#
def ConfusedBy?(filename)
  if filename.downcase.include? 'cd1'
    return true
  elsif filename.downcase.include? 'cd2'
    return true
  elsif filename.downcase.include? 'daily.show'
    return true
  end
  return false
end

####################################################################
#
def Relocate(old_filename, new_filename)
    if not File.exists? new_filename
      directory = new_filename.split('/').slice(0..-2).join('/')      
      `mkdir -p "#{directory}"`
      `mv -n "#{old_filename}" "#{new_filename}"`
    end
end

####################################################################
#
def Rename(filename)
  new_filename = ''
  
  base_directory = filename.split('/').slice(0..-2).join('/')
  
  short_filename = filename.sub(base_directory+'/','')
  
  ######################################
  if (!ValidateFile(filename))
    PrintOutcome("leave",short_filename,'')
    return false
  end

  ######################################  
  if ShouldDelete?(filename)
    PrintOutcome("deleting",short_filename,'')
    `rm "#{filename}"`
    return false
  end
  
  ######################################
  if (!IsVideoFile?(filename))
    PrintOutcome("leave",short_filename,'')
    return false
  end

  ######################################  
  if ConfusedBy?(filename)
    PrintOutcome("confused",short_filename,'')
    return false
  end
  
  ######################################    
  if IsMovie?(filename,base_directory)
    new_filename = FormMovieFilename(filename,base_directory)
    if (new_filename != '')
      new_filename = $movies_root + new_filename
    end
    PrintOutcome("Movie",short_filename,new_filename)
  else
    new_filename = FormTVFilename(filename,base_directory)
    if (new_filename != nil && new_filename != '')
      new_filename = $tv_root + new_filename
    end
    PrintOutcome("TV Episode",short_filename,new_filename)
  end
end

####################################################################
#
def RenameAndMove(filename)
  new_filename = ''
  
  base_directory = filename.split('/').slice(0..-2).join('/')
  
  short_filename = filename.sub(base_directory+'/','')
  
  ######################################
  if (!ValidateFile(filename))
    PrintOutcome("leave",short_filename,'')
    return false
  end

  ######################################  
  if ShouldDelete?(filename)
    PrintOutcome("deleting",short_filename,'')
    `rm "#{filename}"`
    return false
  end
  
  ######################################
  if (!IsVideoFile?(filename))
    PrintOutcome("leave",short_filename,'')
    return false
  end

  ######################################  
  if ConfusedBy?(filename)
    PrintOutcome("confused",short_filename,'')
    return false
  end
  
  ######################################    
  if IsMovie?(filename,base_directory)
    new_filename = FormMovieFilename(filename,base_directory)
    if (new_filename != '')
      new_filename = $movies_root + new_filename
    end
    PrintOutcome("Movie",short_filename,new_filename)
  else
    new_filename = FormTVFilename(filename,base_directory)
    if (new_filename != nil && new_filename != '')
      new_filename = $tv_root + new_filename
    end
    PrintOutcome("TV Episode",short_filename,new_filename)
  end
  
  ######################################   
  if (new_filename != nil && new_filename != '') 
    Relocate(filename,new_filename)
  end
  
end

