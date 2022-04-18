# frozen_string_literal: true

module Measure

  MEASURE_HOST = '127.0.0.1'
  MEASURE_PORT = 9292

  private

  def measurement_server_pid
    # Getting the 'puma' process seems most reliable way of determining the server pid.
    # It doesn't work for JRuby.
    # An alternative could be the pid associated with port 9292:
    # `lsof -ti:9292`.strip
    pid = `ps -ef | awk '$8=="puma" {print $2}'`.strip
    pid == '' ? nil : pid
  end

  def measurement_prepare
    @uris          = [] # Uri's to test
    @mgcs          = [] # Major garbage collection runs
    @results       = [] # Measurement data
    @error_count   = 0
    @success_count = 0
    @total_time    = 0.0

    if true
      @uris << Net::HTTP::Get.new('http://127.0.0.1:9292/')

      @uris << Net::HTTP::Get.new('http://127.0.0.1:9292/create-account')

      @uris << Net::HTTP::Get.new('http://127.0.0.1:9292/reset-password-request')

      # Bad cookie
      @uris << begin
        uri = Net::HTTP::Get.new('http://127.0.0.1:9292/')
        uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hh%3D%3D"
        uri
      end

      # Good cookie
      @uris << begin
        uri = Net::HTTP::Get.new('http://127.0.0.1:9292/')
        uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hg%3D%3D"
        uri
      end
    else
      @uris << begin
        uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth1')
        uri
      end

      @uris << begin
        uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth2')
        uri
      end

      @uris << begin
        uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
        uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'A')
        uri
      end
    end
  end

  def measure_run
    _measure_get_ruby_version

    bar = ProgressBar.create(title: 'Testing', format: '%t %a %j% |%B| %c/%C', total: @n)

    Net::HTTP.start(MEASURE_HOST, MEASURE_PORT, { read_timeout: 2, open_timeout: 2 }) do |http|
      @n.times do |x|
        _measure_run_uris(x + 1, http)
        bar.increment unless bar.finished?
      end
    end

    bar.finish
  end

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

    GC.start if x % 5_000 == 0
  rescue
    @error_count +=1
  end

  def measure_finish(version)
    begin
      @mgcs = JSON.parse(Net::HTTP.get(URI("http://#{MEASURE_HOST}:#{MEASURE_PORT}/gc")))
    rescue
      nil
    end

    version.average     = (@total_time / @success_count.to_f).round(1) if @success_count > 0
    version.error_count = @error_count
  end
end
