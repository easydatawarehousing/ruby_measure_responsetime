#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'session'
require 'yaml'

system 'clear'

# Number of times to run the testset
N = 1000

# Name of file specifying which rubies should be used in the test
RUBIES_TO_TEST_FILENAME = 'rubies_to_test.yml'

def rvm_installed?
  (`rvm` =~ /\ARuby/) == 0
rescue
  false
end

def rbenv_installed?
  (`rbenv -v` =~ /\Arbenv/) == 0
rescue
  false
end

def determine_ruby_manager
  $ruby_manager = case
  when rvm_installed?
    :rvm
  when rbenv_installed?
    :rbenv
  else
    raise 'Please install RVM, Rbenv or change the script to use another Ruby version manager'
  end
end

def list_available_rubies
  versions = []

  case $ruby_manager
  when :rvm
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
          versions << [ version, '--yjit --yjit-exec-mem-size=8']
        end
      end

  when :rbenv
    `rbenv versions`
      .split("\n")
      .map { |version| version.scan(/[\* ]+([a-z\-+]*[\d\.\-p]+) *.*/)&.first&.first }
      .compact
      .sort
      .each do |version|
        versions << [ version, nil ]

        if version =~ /3.0/
          versions << [ version, '--jit']
        end

        if version =~ /3.1/
          versions << [ version, '--mjit']
          versions << [ version, '--yjit --yjit-exec-mem-size=8']
        end
      end

  end

  versions
end

def list_rubies
  rubies = list_available_rubies

  if File.exists?(RUBIES_TO_TEST_FILENAME)
    rubies_to_test = YAML.load(IO.read(RUBIES_TO_TEST_FILENAME))
    rubies_to_include = rubies_to_test['include'] || []
    rubies_to_exclude = rubies_to_test['exclude'] || []

    if !rubies_to_include.empty?
      rubies.delete_if { |r| !rubies_to_include.include?(r[0]) }
    elsif !rubies_to_exclude.empty?
      rubies.delete_if { |r| rubies_to_exclude.include?(r[0]) }
    end
  end

  puts 'Testing these rubies:'
  rubies.each { |r| puts r.compact.join(' ') }

  rubies
end

def cmd_remove_gemfile_lock
  'rm -f Gemfile.lock;'
end

# def cmd_create_ruby_version_file(folder, version)
#   if $ruby_manager == :rbenv
#     # "echo '#{version}' > #{folder}/.ruby-version;\neval \"$(rbenv init -)\";"
#     "eval \"$(rbenv init -)\";"
#   end
# end

def cmd_initialize_ruby_version_manager
  if $ruby_manager == :rbenv
    "eval \"$(rbenv init -)\";"
  end
end

def cmd_switch_to_folder(folder)
  "cd #{folder} > /dev/null;"
end

def cmd_switch_to_ruby(version)
  case $ruby_manager
  when :rvm
    "rvm use #{version} > /dev/null;"
  when :rbenv
    "export RBENV_VERSION=#{version};"
  end
end

def cmd_bundle_install
  'bundle install > /dev/null;'
end

def cmd_run_server(jit)
  rackup_cmd = `which rackup`.strip
  "ruby #{jit} #{rackup_cmd} --quiet > /dev/null 2>&1 &"
end

def start_server(version, bash, app_name)
  puts("\n# Ruby '#{version[0]}' #{version[1]} ".ljust(120, '-'))

  print "Installing ruby\r"

  script = [
    cmd_initialize_ruby_version_manager,
    cmd_switch_to_folder(app_name),
    cmd_remove_gemfile_lock,
    cmd_switch_to_ruby(version[0]),
    cmd_bundle_install,
  ].join("\n")

  bash.execute(script) do |out, err|
    puts out if out

    # Ignore errors on Yaml safe loading and RubyGems version
    if err && err !~ /YAML|RubyGems/
      puts "Errors: #{err}"
      exit 1
    end
  end

  print "Starting server\r"

  bash.execute(cmd_run_server(version[1])) do |out, err|
    puts out if out

    if err
      puts "Errors: #{err}"
      exit 1
    end
  end

  # Give server some time to start so we don't have to
  # handle 'server not found' errors in the testscript.
  # Increase this time if needed for your test setup.
  sleep 5
end

def run_test_script(app_name)
  print "Running test script\r"
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  response = `ruby scripts/test_#{app_name}.rb #{N}`.strip
  t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  puts response if response != ''
  puts "Finished in #{(t2 - t1).round(0)} seconds"
end

# /usr/lib/jvm/java-11-openjdk-amd64/bin/java -Djdk.home=/usr/lib/jvm/java-11-openjdk-amd64 -Djruby.home=/home/ivo/.rvm/rubies/jruby-9.3.3.0 -Djruby.script=jruby -Djruby.shell=/bin/sh -Djffi.boot.library.path=/home/ivo/.rvm/rubies/jruby-9.3.3.0/lib
def get_server_pid
  # `lsof -ti:9292`.strip
  pid = `ps -ef | awk '$8=="puma" {print $2}'`.strip
  pid == '' ? nil : pid
end

def stop_server(bash)
  if pid = get_server_pid
    bash.execute "kill -9 #{pid}" do |out, err|
      puts out if out

      if err
        puts "Kill server (pid=#{pid}) failed"
        puts "Errors: #{err}\n"
        # exit 1
      end
    end

    sleep 1
  end
end

def test_server_still_running
  if pid = get_server_pid
    puts "A server is already running, process ID: #{pid}"
    exit 1
  end
end

def start_session
  Session::Bash::Login.new(use_open3: true)
end

def log_server_memory_usage
  if pid = get_server_pid
    mb = `cat /proc/#{pid}/smaps | grep -i pss |  awk '{Total+=$2} END {print Total/1024}'`.strip.to_f
    puts "Server memory usage estimate: #{mb.round(0)}Mb"
  end
end

def analyze_results
  puts 'Analyzing'
  `R --vanilla < scripts/analyze_rodauth.R`
end

# Fun starts here
app_name = 'rodauth'

determine_ruby_manager

list_rubies.each do |version|
  test_server_still_running
  bash = start_session
  next if version[0] =~ /graal/
  start_server(version, bash, app_name)
  run_test_script(app_name)
  log_server_memory_usage
  stop_server(bash)
  bash.close!
break
end

analyze_results
