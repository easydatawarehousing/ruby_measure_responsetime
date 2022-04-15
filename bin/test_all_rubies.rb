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

# Number of times to run the testset.
n = ARGV.length == 2 ? ARGV[1].to_i : 1_000

system 'clear'
RubyMeasureResponsetime.new(app_name, n)
