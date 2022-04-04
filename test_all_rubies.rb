#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'session'

system 'clear'

def rvm_installed?
  (`rvm` =~ /\ARuby/) == 0
rescue
  false
end

def list_rubies
  versions = []

  `rvm list`
    .split("\n")
    .map { |version| version.scan(/ ([a-z]+\-[\d\.\-p]+) +.*/)&.first&.first }
    .compact
    .sort
    .each do |version|
      versions << [ version, nil ]

      if version =~ /ruby\-3.0/
        versions << [ version, '--jit']
      end

      if version =~ /ruby\-3.1/
        versions << [ version, '--mjit']
      end

      if version =~ /ruby\-3.1/
        versions << [ version, '--yjit --yjit-exec-mem-size=8']
      end
    end

  versions
end

def cmd_remove_gemfile_lock
  'rm -f Gemfile.lock;'
end

def cmd_switch_to_folder(folder)
  "cd #{folder};"
end

def cmd_switch_to_ruby(version)
  "rvm use #{version} > /dev/null;"
end

def cmd_bundle_install
  'bundle install > /dev/null;'
end

def cmd_run_server(jit)
  rackup_cmd = `which rackup`.strip
  "ruby #{jit} #{rackup_cmd} --quiet > /dev/null 2>&1 &"
end

def start_server(version, bash)
  puts("\n# Ruby '#{version[0]}' #{version[1]} ".ljust(120, '-'))

  bash.execute([
    cmd_remove_gemfile_lock,
    cmd_switch_to_ruby(version[0]),
    cmd_bundle_install,
    cmd_run_server(version[1]),
  ].join("\n"))

  # Give server some time to start so we don't have to
  # handle 'server not found' errors in the testscript
  sleep 7.5
end

def run_test_script
  puts 'Running test script'
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  response = `ruby scripts/test_rodauth.rb`.strip
  t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  puts response if response != ''
  puts "Finished in #{(t2 - t1).round(0)} seconds"
end

def stop_server(bash)
  pid = `lsof -ti:9292`.strip
  if pid != ''
    puts 'Kill server'
    bash.execute "kill -9 #{pid}" do |out, err|
      puts out if out
      puts "Errors: #{err}\n" if err
    end
  end
end

def start_session(app_folder)
  bash = Session::Bash::Login.new

  bash.execute cmd_switch_to_folder(app_folder) do |out, err|
    puts out if out

    if err
      puts "Errors: #{err}"
      exit 1
    end
  end

  bash
end

def analyze_results
  puts 'Analyzing'
  `R --vanilla < scripts/analyze_rodauth.R`
end

# Fun starts here

raise 'Please install RVM or change the script to use another Ruby version manager' unless rvm_installed?

app_folder = 'rodauth'

bash = start_session(app_folder)

list_rubies.each do |version|
  # next if version[0].sub('truffle','').sub('ruby-','')[0..2] < '3.1'
  # next if !version[0]['truffle']
  start_server(version, bash)
  run_test_script
  stop_server(bash)
end

analyze_results
