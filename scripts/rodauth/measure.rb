# frozen_string_literal: true

# All logic specific to the application being tested goes here.
# The 'Measure' module is included in the main script,
# so all instance variables of the main script may be used.
module Measure

  # Hostname and port
  MEASURE_HOST = '127.0.0.1'
  MEASURE_PORT = 9292

  # Read / open timeouts in seconds
  NET_TIMEOUTS = [15, 10]

  # Log server memory usage after every x measurements
  MEMORY_LOG_INTERVAL = 1_000

  # Increment the measurement after which to log memory usage
  # by x for run_id > 1
  MEMORY_LOG_RUN_INCREMENT = 334

  private

  # Shell command to determine the process-id (pid) of the application server
  def measurement_server_pid
    # Getting the puma or rackup process seems most reliable way of determining the server pid.
    #
    # An alternative could be the pid associated with port 9292:
    # pid = `lsof -ti:9292`.strip
    #
    pid = `ps -ef | awk 'match($0,/puma|rackup/) && $8!="awk" && $8!="sh" {print $2}'`.strip
    pid == '' ? nil : pid
  end

  # Shell command to remove Gemfile.lock file
  def cmd_remove_application_gemfile_lock
    'rm -f Gemfile.lock;'
  end

  # Shell command to switch to the application folder
  def cmd_switch_to_application_folder
    "cd apps/#{@app_name} > /dev/null;"
  end

  # Shell command to bundle gems
  def cmd_application_bundle_install
    'bundle install > /dev/null;'
  end

  # Shell command to start the server process in the background, so end with &
  def cmd_measurement_run_server(jit)
    "bundle exec ruby #{jit} $(which rackup) --quiet > /dev/null 2>&1 &"
  end

  # Setup tests: set counters and determine uri's
  def measurement_prepare
    @uris          = [] # Uri's to test
    @error_count   = 0
    @success_count = 0
    @total_time    = 0.0

    # Select some uri's to test
    # Set to false to test if a side-channel attach is possible
    # on the login route (spoiler alert: there isn't)
    if true
      @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/")

      @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/create-account")

      @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/reset-password-request")

      # Bad cookie
      @uris << begin
        uri = Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/")
        uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hh%3D%3D"
        uri
      end

      # Good cookie
      @uris << begin
        uri = Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/")
        uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hg%3D%3D"
        uri
      end
    else
      # Correct password
      # @uris << begin
      #   uri = Net::HTTP::Post.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/login")
      #   uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth1')
      #   uri
      # end

      # Almost correct password
      @uris << begin
        uri = Net::HTTP::Post.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/login")
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth0')
        uri
      end

      # Incorrect passwords
      @uris << begin
        uri = Net::HTTP::Post.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/login")
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'A')
        uri
      end
      @uris << begin
        uri = Net::HTTP::Post.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/login")
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'z'*20)
        uri
      end
    end
  end

  # Execute tests: open connection to the server, run tests, show a progress-bar
  def measure_run(version)
    _measure_get_ruby_version
    @reported_ruby_version ||= version.full_name
    pid = measurement_server_pid

    bar = ProgressBar.create(title: 'Testing', format: '%t %a %j% |%B| %c/%C', total: @n)

    Net::HTTP.start(MEASURE_HOST, MEASURE_PORT, { read_timeout: NET_TIMEOUTS[0], open_timeout: NET_TIMEOUTS[1] }) do |http|
      @n.times do |x|
        pid ||= measurement_server_pid
        _measure_run_uris(x, http)
        _measure_memory(pid, x)
        bar.increment unless bar.finished?
      end
    end

    bar.finish
  end

  # Private method to test if the server is alive and
  # get the Ruby version reported by the server
  def _measure_get_ruby_version
    10.times do
      begin
        @reported_ruby_version = Net::HTTP.get(URI("http://#{MEASURE_HOST}:#{MEASURE_PORT}/version"))
        break
      rescue
        sleep 1
      end
    end
  end

  # Private method to execute one test per uri and measure response-times
  def _measure_run_uris(x, http)
    @uris.each_with_index do |uri, uri_index|
      # CLOCK_MONOTONIC should work on most platforms
      # A good alternative would be CLOCK_MONOTONIC_PRECISE
      # See: https://docs.ruby-lang.org/en/3.1/Process.html#method-c-clock_gettime
      t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      http.request(uri)
      t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
      y = t2 - t1

      @results       << [uri_index + 1, x + 1, y]
      @total_time    += y
      @success_count += 1
    end
  rescue => e
    # puts '', e
    @error_count +=1
  end

  # Private method to log server memory usage
  def _measure_memory(pid, x)
    if ((x + 1 - ((@run_id - 1) * MEMORY_LOG_RUN_INCREMENT)) % MEMORY_LOG_INTERVAL).zero?
      @memory_results << [x + 1, server_memory_in_megabytes(pid)]
    end
  end

  # Finish tests: get garbage collection information from the server,
  # log error-count and mean response-time
  def measure_finish(version)
    begin
      @mgcs = JSON.parse(
        Net::HTTP.get(URI("http://#{MEASURE_HOST}:#{MEASURE_PORT}/gc"))
      ).select { |mgc| mgc > 1 }
    rescue
      nil
    end

    if @success_count > 0
      version.mean = (@total_time / @success_count.to_f).round(1)
    end
    version.error_count = @error_count
  end

  # Descriptive text to add to the report
  def measure_readme_description
    <<~DESCRIPTION
      This is a test application based on [roda-sequel-stack](https://github.com/jeremyevans/roda-sequel-stack.git),
      using [Roda](https://github.com/jeremyevans/roda) as the web framework,
      [Sequel](https://github.com/jeremyevans/sequel) as the database library
      and [Rodauth](https://github.com/jeremyevans/rodauth) for authentication.

      Performance of this application was tested by continuously sending requests to the server.
      Five url's were included in the test:

      1. index-page without cookie (black)
      2. create-account-page (red)
      3. reset-password-request-page (green)
      4. index-page with good cookie (blue)
      5. index-page with bad cookie (cyan)
    DESCRIPTION
  end
end
