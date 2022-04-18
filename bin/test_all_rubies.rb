#!/usr/bin/env ruby

require_relative '../lib/ruby_measure_responsetime'

# Use manual garbage collection
GC.disable

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

# Number of times to run the testset
n = ARGV.length >= 2 ? ARGV[1].to_i : 1_000

# Run ID
run_id = ARGV.length >= 3 ? ARGV[2].to_i : 1

# Run the test application
RubyMeasureResponsetime.new(app_name, n, run_id)
