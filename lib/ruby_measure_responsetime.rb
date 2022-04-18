# frozen_string_literal: true

require 'session'
require 'net/http'
require 'json'
require 'yaml'
require 'ruby-progressbar'
require_relative 'ruby_measure_responsetime/rvm'
require_relative 'ruby_measure_responsetime/rbenv'
require_relative 'ruby_measure_responsetime/ruby_stats'

class RubyMeasureResponsetime

  # Name of module containing test script
  MEASURE_MODULE_NAME = 'measure'

  # Name of file specifying which rubies should be used in the test
  RUBIES_TO_TEST_FILENAME = 'rubies.yml'

  # Name of R script to analyze results
  ANALYZE_FILENAME = 'analyze.R'

  def initialize(app_name, n, run_id)
    @app_name = app_name
    @n        = n
    @run_id   = run_id
    if @app_name.strip == '' || @n < 0 || @run_id < 1
      puts "Invalid parameters, please specify an application name, number or times to run the test and optionally a run ID"
      exit 1
    end

    require_measurement_script
    determine_ruby_manager
    determine_rubies

    if @n > 0
      run_tests
      analyze_results
    end

    render_screen
  end

  def require_measurement_script
    require_relative "../scripts/#{@app_name}/#{MEASURE_MODULE_NAME}"
    self.class.send(:include, Measure)
  end

  def determine_ruby_manager
    @ruby_manager = Rvm.ruby_manager || Rbenv.ruby_manager

    unless @ruby_manager
      raise 'Please install RVM, Rbenv or change the script to use another Ruby version manager'
    end
  end

  def determine_rubies
    rubies   = @ruby_manager.installed_rubies
    filename = "scripts/#{@app_name}/#{RUBIES_TO_TEST_FILENAME}"

    if File.exists?(filename)
      rubies_to_test = YAML.load(IO.read(filename))
      rubies_to_include = rubies_to_test['include'] || []
      rubies_to_exclude = rubies_to_test['exclude'] || []

      if !rubies_to_include.empty?
        rubies.delete_if { |r| !rubies_to_include.include?(r[0]) }
      elsif !rubies_to_exclude.empty?
        rubies.delete_if { |r| rubies_to_exclude.include?(r[0]) }
      end
    end

    @rubies = rubies.map { |r| RubyStats.new(r) }
  end

  def render_screen
    system 'clear'
    if @n > 0
      puts "Testing '#{@app_name}' with these rubies (N = #{@n})"
    else
      puts "Rubies for testing '#{@app_name}' (set N > 0 to run tests)"
    end

    puts "\nRuby                     JIT     Memory  Runtime  Average  Errors"
    puts '–' * 65
    @rubies.each { |r| puts r }
    puts '–' * 65
  end

  def run_tests
    @rubies.each do |version|
      render_screen
      bash = start_session
      test_server_still_running(bash)
      start_server(version, bash)
      run_test_script(version)
      save_results
      log_server_memory_usage(version, bash)
      stop_server(bash)
      bash.close!
    end
  end

  def cmd_remove_gemfile_lock
    'rm -f Gemfile.lock;'
  end

  # def cmd_create_ruby_version_file(folder, version)
  #   if @ruby_manager == :rbenv
  #     # "echo '#{version}' > #{folder}/.ruby-version;\neval \"$(rbenv init -)\";"
  #     "eval \"$(rbenv init -)\";"
  #   end
  # end

  def cmd_initialize_ruby_version_manager
    @ruby_manager.cmd_initialize_ruby_version_manager
  end

  def cmd_switch_to_folder(folder)
    "cd apps/#{folder} > /dev/null;"
  end

  def cmd_switch_to_ruby(version)
    @ruby_manager.cmd_switch_to_ruby(version.ruby_name)
  end

  def cmd_bundle_install
    'bundle install > /dev/null;'
  end

  def cmd_run_server(jit)
    "ruby #{jit} $(which rackup) --quiet > /dev/null 2>&1 &"
  end

  def start_server(version, bash)
    puts "\nTesting #{version.full_name}\nInstalling ruby"

    script = [
      cmd_initialize_ruby_version_manager,
      cmd_switch_to_folder(@app_name),
      cmd_remove_gemfile_lock,
      cmd_switch_to_ruby(version),
      cmd_bundle_install,
    ].compact.join("\n")

    bash.execute(script) do |out, err|
      puts out if out

      # Ignore errors on Yaml safe loading and RubyGems version
      if err && err !~ /YAML|RubyGems/
        puts "Errors: #{err}"
        exit 1
      end
    end

    puts "Starting server"
    bash.execute(cmd_run_server(version.jit)) do |out, err|
      puts out if out

      if err
        puts "Errors: #{err}"
        exit 1
      end
    end

    # Give server some time to start.
    # Increase this time if needed for your test setup.
    sleep 2
  end

  def run_test_script(version)
    measurement_prepare
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    measure_run
    t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    measure_finish(version)
    version.runtime = (t2 - t1).round(0)
  end

  def save_results
    puts "Saving results"
    datafile_name = "data/#{@app_name}/measurements.csv"

    f = if File.exist?(datafile_name)
      File.open(datafile_name, 'a')
    else
      f = File.open(datafile_name, 'w')
      f.write("version,run,uri,x,y,mgc\n")
      f
    end

    @results.each do |r|
      f.write("\"#{@reported_ruby_version}\",#{@run_id},#{r[0]},#{r[1]},#{r[2].round(3)},#{@mgcs.include?(r[1]) ? 1 : 0}\n")
    end

    f.close
  end

  def stop_server(bash)
    if pid = measurement_server_pid
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

  def test_server_still_running(bash)
    if pid = measurement_server_pid
      puts "A server is already running, process ID: #{pid}"
      exit 1
    end
  end

  def start_session
    Session::Bash::Login.new
  end

  def log_server_memory_usage(version, bash)
    if pid = measurement_server_pid
      mb = `cat /proc/#{pid}/smaps | grep -i pss |  awk '{Total+=$2} END {print Total/1024}'`.strip.to_f
      # puts "Server memory usage estimate: #{mb.round(0)}Mb"
      version.memory = mb
    end
  end

  def analyze_results
    puts 'Analyzing'
    `R --vanilla < scripts/#{@app_name}/#{ANALYZE_FILENAME}`
  end
end
