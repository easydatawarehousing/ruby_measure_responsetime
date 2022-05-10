# frozen_string_literal: true

require 'session'
require 'net/http'
require 'json'
require 'yaml'
require 'ruby-progressbar'
require_relative 'ruby_measure_responsetime/rvm'
require_relative 'ruby_measure_responsetime/rbenv'
require_relative 'ruby_measure_responsetime/ruby_stats'
require_relative 'ruby_measure_responsetime/analyze'

# The main script running tests and perform analysis
# Module containing application specific code is included dynamically,
# based on the name of the application passed via a command-line argument
class RubyMeasureResponsetime

  include Analyze

  # Name of module containing test script
  MEASURE_MODULE_NAME = 'measure'

  # Name of file specifying which rubies should be used in the test
  RUBIES_TO_TEST_FILENAME = 'rubies.yml'

  # Set line-end to use. Might be \r\n on windows ?
  CSV_LINE_TERMINATOR = "\n"

  def initialize(app_name, n, run_id, analyze_only = false)
    @app_name     = app_name
    @n            = n
    @run_id       = run_id
    @analyze_only = analyze_only

    if @app_name.strip == ''
      puts "Invalid parameters, please specify an application name"
      exit 1
    end

    if !analyze_only && (@n < 0 || @run_id < 1)
      puts "Invalid parameters, please specify a number or times to run the test and optionally a run ID"
      exit 1
    end

    run
  end

  def run
    analyze_create_data_folders
    reset_result_variables
    require_measurement_script
    determine_ruby_manager
    determine_rubies
    render_screen

    if @n > 0 || @analyze_only
      run_tests unless @analyze_only
      analyze_results
      render_screen
      puts 'Done'
    end
  end

  def reset_result_variables
    @mgcs                  = []  # Major garbage collection runs
    @results               = []  # Measurement data
    @reported_ruby_version = nil # Version reported by server
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
    rubies = @ruby_manager.installed_rubies

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
      puts "Testing '#{@app_name}' with these rubies (N = #{@n})\n\n"
    else
      puts "#{@analyze_only ? 'Analyzing' : 'Testing'} Rubies for '#{@app_name}' (set N > 0 to run tests)\n\n"
    end

    if @rubies.length > 0
      puts @rubies.first.title_string
      @rubies.each { |r| puts r }
    else
      puts 'No rubies found'
    end
    puts ''
  end

  def run_tests
    @rubies.each do |version|
      bash = start_session
      test_server_still_running(bash)
      start_server(version, bash)
      log_server_memory_usage(version, bash, :start)
      run_test_script(version)
      save_measurements
      log_server_memory_usage(version, bash, :finish)
      stop_server(bash)
      save_statistics(version)
      bash.close!
      reset_result_variables
      render_screen
      GC.start
    end
  end

  def test_script(version)
    [
      @ruby_manager.cmd_initialize_ruby_version_manager,
      cmd_switch_to_application_folder,
      cmd_remove_application_gemfile_lock,
      @ruby_manager.cmd_switch_to_ruby(version.ruby_name),
      cmd_application_bundle_install,
    ].compact.join("\n")
  end

  def start_server(version, bash)
    puts "\nTesting #{version.full_name}\nInstalling ruby"

    # Ignore errors on Yaml safe loading and RubyGems version
    bash_execute(bash, test_script(version), /YAML|RubyGems/)

    puts "Starting server"
    bash_execute(bash, cmd_measurement_run_server(version.jit))

    # Give server some time to start. Increase this time if needed for your test setup
    sleep 2
  end

  def run_test_script(version)
    measurement_prepare
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    measure_run(version)
    t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    measure_finish(version)
    version.runtime = (t2 - t1).round(0)
    version.mgcs_count = @mgcs.length
  end

  def save_measurements
    puts "Saving results"
    f = if File.exist?(datafile_name)
      File.open(datafile_name, 'a')
    else
      f = File.open(datafile_name, 'w')
      f.write("version,run,uri,x,y,mgc#{CSV_LINE_TERMINATOR}")
      f
    end

    @results.each_with_index do |r, i|
      f.write("\"#{@reported_ruby_version}\",#{@run_id},#{r[0]},#{r[1]},#{r[2].round(3)},#{@mgcs.include?(i+1) ? 1 : 0}#{CSV_LINE_TERMINATOR}")
    end

    f.close
  end

  def save_statistics(version)
    puts "Saving statistics"
    f = if File.exist?(statsfile_name)
      File.open(statsfile_name, 'a')
    else
      f = File.open(statsfile_name, 'w')
      f.write("version,run,")
      f.write(RUNTIME_STATISTICS.join(','))
      f.write(CSV_LINE_TERMINATOR)
      f
    end

    f.write([
      "\"#{@reported_ruby_version}\"",
      @run_id,
      version.memory_start&.round(0)&.to_i,
      version.memory_finish&.round(0)&.to_i,
      version.runtime,
      version.error_count,
      version.mgcs_count,
    ].join(',') + CSV_LINE_TERMINATOR)

    f.close
  end

  def stop_server(bash)
    if pid = measurement_server_pid
      bash_execute(bash, "kill -9 #{pid}")
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

  def bash_execute(bash, commands, ignore_errors = nil)
    bash.execute(commands) do |out, err|
      puts out if out

      # Ignore errors on Yaml safe loading and RubyGems version
      if err && (!ignore_errors || err !~ ignore_errors)
        puts "Errors: #{err}"
        puts "\nCommand(s):\n#{commands}"
        exit 1
      end
    end
  end

  def log_server_memory_usage(version, bash, at)
    5.times do
      if pid = measurement_server_pid
        mb = `cat /proc/#{pid}/smaps | grep -i pss |  awk '{Total+=$2} END {print Total/1024}'`.strip.to_f

        if at == :start
          version.memory_start = mb
        else
          version.memory_finish = mb
        end

        return
      end

      sleep 1
    end
  end
end
