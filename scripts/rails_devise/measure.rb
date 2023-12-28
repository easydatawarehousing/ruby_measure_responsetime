# frozen_string_literal: true

# All logic specific to the application being tested goes here.
# The 'Measure' module is included in the main script,
# so all instance variables of the main script may be used.
module Measure

  # Hostname and port
  MEASURE_HOST = '127.0.0.1'
  MEASURE_PORT = 3000

  # Read / open timeouts in seconds
  NET_TIMEOUTS = [10, 10]

  private

  # Shell command to determine the process-id (pid) of the application server
  def measurement_server_pid
    # Getting the puma or rackup process seems most reliable way of determining the server pid.
    #
    # An alternative could be the pid associated with port 9292:
    # pid = `lsof -ti:3000`.strip
    #
    pid = `ps -ef | awk 'match($0,/puma/) && $8!="awk" && $8!="sh" {print $2}'`.strip
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
    if jit
      "RUBYOPT=\"#{jit}\" bin/rails server > /dev/null 2>&1 &"
    else
      "bin/rails server > /dev/null 2>&1 &"
    end
  end

  # Setup tests: set counters and determine uri's
  def measurement_prepare
    @uris          = [] # Uri's to test
    @error_count   = 0
    @success_count = 0
    @total_time    = 0.0

    @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/")

    @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/users/sign_up")

    @uris << Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/users/password/new")

    # Bad cookie
    @uris << begin
      uri = Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/authenticated")
      uri['Cookie'] = "_rails_devise_session=fTx77RlCaR3dmefOV%2FWP8IaKEROVdi1xPaTm69kxRV19NPgpi15BMXRLK%2B69sNaAW%2BELw3XQiJc9N6NaN5JaVTzcnI8%2FaZL0wmOQ%2Bdo3oyZrvGz9iltpC3lyHwWbyZ26YnYMCRtytGsbAwsEh%2BzRETYWn%2F6IVRQnlDWYOkt1lXr5S2Feg9n8W5sr7rQEKR%2BexodfNcpvUsy3cMwC%2BWqabgqgeupIa4E5shZumQfb4%2FePiNsSJuGpi%2FA5Vane05UjJ6Z3JnFJCpieakZSyp8XETxbCz%2F7eClJjisqz5jbhKDqkXy4gC%2FMPdXUyKbuOiHuMbyx1iHlunS1Ah9ADLiv5ynM8N9b2gNb10Luo0YztelF2Oe3riIfrEUvICiO2f4s3vWS7gtUHqtqsysJyQ%3D%3D--52YUKi8hw5UKkUF4--0QLZdS6i8sUz2jZLGga7Rw%3D%3D"
      uri
    end

    # Good cookie
    @uris << begin
      uri = Net::HTTP::Get.new("http://#{MEASURE_HOST}:#{MEASURE_PORT}/authenticated")
      uri['Cookie'] = "_rails_devise_session=fTx77RlCaR3dmefOV%2FWP8IaKEROVdi1xPaTm69kxRV19NPgpi15BMXRLK%2B69sNaAW%2BELw3XQiJc9N6NaN5JaVTzcnI8%2FaZL0wmOQ%2Bdo3oyZrvGz9iltpC3lyHwWbyZ26YnYMCRtytGsbAwsEh%2BzRETYWn%2F6IVRQnlDWYOkt1lXr5S2Feg9n8W5sr7rQEKR%2BexodfNcpvUsy3cMwC%2BWqabgqgeupIa4E5shZumQfb4%2FePiNsSJuGpi%2FA5Vane05UjJ6Z3JnFJCpieakZSyp8XETxbCz%2F7eClJjisqz5jbhKDqkXy4gC%2FMPdXUyKbuOiHuMbyx1iHlunS1Ah9ADLiv5ynM8N9b2gNb10Luo0YztelF2Oe3riIfrEUvICiO2f4s3vWS7gtUHqtqsysJyQ%3D%3D--52YUKi8hw5UKkUF4--0QLZdS6i8sUz2jZLGga7Rx%3D%3D"
      uri
    end
  end

  # Execute tests: open connection to the server, run tests, show a progress-bar
  def measure_run(version)
    _measure_get_ruby_version
    @reported_ruby_version ||= version.full_name

    bar = ProgressBar.create(title: 'Testing', format: '%t %a %j% |%B| %c/%C', total: @n)

    Net::HTTP.start(MEASURE_HOST, MEASURE_PORT, { read_timeout: NET_TIMEOUTS[0], open_timeout: NET_TIMEOUTS[1] }) do |http|
      @n.times do |x|
        _measure_run_uris(x + 1, http)
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

      @results       << [uri_index + 1, x, y]
      @total_time    += y
      @success_count += 1
    end
  rescue
    @error_count +=1
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
      version.mean        = (@total_time / @success_count.to_f).round(1)
    end
    version.error_count = @error_count
  end

  # Descriptive text to add to the report
  def measure_readme_description
    <<~DESCRIPTION
      This is a test application based on [Ruby-on-Rails](https://rubyonrails.org/),
      using [Devise](https://github.com/heartcombo/devise) for authentication.

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
