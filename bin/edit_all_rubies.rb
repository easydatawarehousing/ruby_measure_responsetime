#!/usr/bin/env ruby

# This is a script to list/remove/rename content of a measurements.csv file.
# It is only a simple script and can easily be improved upon. For now it does all it needs to.
#
# Note: Edit data/#{app_name}/statistics.csv manually

require 'csv'

puts('Please specify an application name') and exit(1) if ARGV.length == 0
puts("folder 'data/#{ARGV[0]}' does not exist") and exit(1) if !File.exist?("data/#{ARGV[0]}")

app_name = ARGV[0]
datafile_name = "data/#{app_name}/measurements.csv"
puts("Datafile 'data/#{app_name}/measurements.csv' does not exist" if !File.exist?(datafile_name)

command = ARGV.length > 1 ? ARGV[1].to_sym : :list
puts("Unknown command '#{command}'") and exit(1) if !%i[list remove rename].include?(command)

case command
when :list
  puts "Listing contents of '#{datafile_name}'"

  versions = {}
  i = 0
  CSV.foreach(datafile_name, headers: true, header_converters: :symbol) do |row|
    versions = [row[:version]].tally(versions)
    i += 1
      print("\r#{i}") if i % 100 == 0
  end

  puts "\rFound       "
  kl = versions.keys.max { |k| k.length }.length
  vl = versions.values.max { |k| k.to_s.length }.to_s.length
  versions.each { |k, v| puts "#{k.ljust(kl)}  #{v.to_s.rjust(vl)}" }

when :remove
  if ARGV.length >= 3
    versions = ARGV[2].split(',')
    puts "Remove version#{versions.length > 1 ? 's' : ''} \"#{versions.join('", "')}\" from '#{datafile_name}'"
    newfile_name = "data/#{app_name}/measurements_edited.csv"
    newfile = File.open(newfile_name, 'w+')

    i = 0
    removed = 0
    CSV.foreach(datafile_name, headers: true, header_converters: :symbol) do |row|
      newfile.write "#{row.headers.join(',')}\r\n" if i == 0

      if versions.include?(row[:version])
        removed += 1
      else
        newfile.write "#{row.fields.join(',')}\r\n"
      end

      i += 1
      print("\r#{i}") if i % 100 == 0
    end

    newfile.close
  else
    puts "Please specify one or more version strings to remove from the data file"
    exit(1)
  end

  puts "\rCreated or replaced file 'data/#{app_name}/measurements_edited.csv'. Removed #{removed} out of #{i} rows"

when :rename
  if ARGV.length == 4
    version_from = ARGV[2]
    version_from_length = version_from.length
    version_to = ARGV[3]
    puts "Rename version '#{version_from}' to '#{version_to}' in file '#{datafile_name}'"
    newfile_name = "data/#{app_name}/measurements_edited.csv"
    newfile = File.open(newfile_name, 'w+')

    i = 0
    renamed = 0
    CSV.foreach(datafile_name, headers: true, header_converters: :symbol) do |row|
      newfile.write "#{row.headers.join(',')}\r\n" if i == 0

      if version_from == row[:version][0, version_from_length]
        renamed += 1
        row[:version] = "#{version_to}#{row[:version][version_from_length..]}"
        newfile.write "#{row.fields.join(',')}\r\n"
      else
        newfile.write "#{row.fields.join(',')}\r\n"
      end

      i += 1
      print("\r#{i}") if i % 100 == 0
    end

    newfile.close
  else
    puts "Please specify one or more version strings to rename in the data file"
    exit(1)
  end

  puts "\rCreated or replaced file 'data/#{app_name}/measurements_edited.csv'. Renamed #{renamed} out of #{i} rows"
end
