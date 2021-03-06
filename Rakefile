# frozen_string_literal: true
require 'colorize'

VERSION = File.read('version.txt').strip

@errors = []

desc 'intro text'
task :intro do
  puts "-------------------------\n"\
       "Running Install script.\n"\
       "Version: #{VERSION}\n"\
       '-------------------------'.red.on_blue
  puts ''
end

desc 'list all files in directory'
task :list do
  puts "Listing all files in directory..\n".red
  @dir = Dir['*.*'].map { |file| puts file.to_s.blue }
  puts ''
end

desc 'check ffmpeg version'
task :check_ffmpeg do
  puts "Checking FFMPEG Version..\n".red
  match_pattern = /(version) 3.1|3.2/

  version = `ffmpeg -version`.chomp
  if version =~ match_pattern
    puts version.blue
    puts "PASS\n".green
  else
    puts "Version number too low\n"\
         'Please install ffmpeg > v3.1'.red
    @errors << ''.red
  end
  puts ''
end

desc 'check imagemagik installation'
task :check_imagemagik do
  puts "Checking Imagemagik Version..\n".red
  match_pattern = /(6.7)/

  version = `convert -version`.chomp
  if version =~ match_pattern
    puts version.blue
    puts "PASS\n".green
  else
    puts "Version number mismatch\n"\
         'Please install imagemagick >= v6.7'.red
  end
end

desc 'check postgres'
task :check_postgres do
  puts "Checking Postgres Version..\n".red
  psql_min_version = 9.5
  version = `psql --version`.chomp
  # this will fall down if versions of psql get longer than 6 characters
  puts version.blue if version
  case
  when version == nil
    puts "YOU HAVE NO POSTGRES INSTALLATION\n".red
    puts "INSTALLING POSTGRES\n".green
    Rake::Task['install_postgres'].invoke
  when version[-5..-1].to_f < psql_min_version
    puts "YOUR POSTGRES VERSION IS TOO LOW\n".red
    puts "PLEASE UPGRADE TO A VERSION > #{psql_min_version}"
  else
    puts "PASS\n".green
  end

  # if version[-6..-1].to_f >= psql_min_version
  #   puts version.blue
  #   puts "PASS\n".green
  # else
  #   puts "POSTGRES VERSION TOO LOW\n".red
  # end
end

desc 'install postgres'
task :install_postgres do
  puts 'Downloading Postgres....'
end

desc 'check install'
desc 'clone latest repo'
desc 'install app'

desc 'run install script'
task install: [:intro, :list, :check_ffmpeg, :check_imagemagik,
               :check_postgres] do
  puts "-------------------------\n"\
       "Install script finished.\n"\
       "Thank you for choosing mscmgmt\n"\
       '-------------------------'.red.on_blue
  puts "\n"\
       "Error messages will follow: \n"
  puts @errors
end

## check sys variables ENV[''] and then prompt for variables
