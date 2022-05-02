#!/usr/bin/env ruby

require_relative '../lib/ruby_measure_responsetime'

# Application name
app_name = if ARGV.length >= 1 
  if File.exist?("scripts/#{ARGV[0]}")
    ARGV[0]
  else
    raise "folder 'scripts/#{ARGV[0]}' does not exist"
  end
else
  'rodauth'
end

# Run the test application
RubyMeasureResponsetime.new(app_name, 0, nil, true)
