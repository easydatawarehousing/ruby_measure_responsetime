# frozen_string_literal: true

require 'fileutils'
require 'csv'

# All logic for running the analysis phase
module Analyze

  # Name of R script to analyze results
  ANALYZE_FILENAME = 'analyze.R'

  # Name folder holding measurement data
  ANALYZE_DATA_FOLDER = 'data'

  # Name folder holding plots
  ANALYZE_PLOTS_FOLDER = 'plots'

  # Metric types. Values should correspond to titles exported by R script
  METRIC_TYPES = {
    slow:   /Slow request counts (\d*)/,
    mean:   /Means/,
    median: /Medians/,
    count:  /Count/,
    stddev: /SD/,
  }

  # Statistics saved to csv file
  RUNTIME_STATISTICS = %i{ memory_start memory_finish runtime error_count mgcs_count }

  private

  def datafile_name
    @datafile_name ||= "#{ANALYZE_DATA_FOLDER}/#{@app_name}/measurements.csv"
  end

  def statsfile_name
    @statsfile_name ||= "#{ANALYZE_DATA_FOLDER}/#{@app_name}/statistics.csv"
  end

  def analyze_results
    puts 'Analyzing'
    if @rubies.length > 0 && File.exist?("#{ANALYZE_DATA_FOLDER}/#{@app_name}/measurements.csv")
      analyze_os_info
      analyze_cpu_info
      analyze_collect_runtime_statistics
      analyze_determine_measurement_statistics
      analyze_parse_measurement_statistics
      analyze_create_readme
    end
  end

  def analyze_create_data_folders
    FileUtils.mkdir_p "#{ANALYZE_DATA_FOLDER}/#{@app_name}/#{ANALYZE_PLOTS_FOLDER}"
  end

  def analyze_os_info
    @os_info = `uname -srvmo`.strip
  rescue
    @os_info = nil
  end

  def analyze_cpu_info
    cpu_info = JSON.parse(`lscpu -J`)['lscpu'].map { |f| [f['field'], f['data']] }.to_h
    @cpu_info = "#{cpu_info['Vendor ID:']} #{cpu_info['Model name:']}".strip
  rescue
    @cpu_info = nil
  end

  def analyze_collect_runtime_statistics
    # Collect saved statistics, calculate average statistic value and update rubies
    if File.exist?(statsfile_name)
      stats = {}

      CSV.foreach(statsfile_name, headers: true, header_converters: :symbol) do |r|
        row = r.to_hash
        key = row.delete(:version)
        row.delete(:run)
        row.transform_values! { |v| v.to_i if v && v.strip != '' }
        stats[key] = [] unless stats.key?(key)
        stats[key] << row
      end

      stats.each do |full_name, values|
        version = @rubies.find { |r| r.match_name == full_name }
        next unless version

        RUNTIME_STATISTICS.each do |stat|
          all_values = values.map { |v| v[stat] }.compact
          next if all_values.length == 0
          avg = (all_values.sum.to_f / all_values.length).round(0).to_i
          version.instance_variable_set("@#{stat}".to_sym, avg)
        end
      end
    end
  end

  def analyze_cmd_r
    `R --vanilla --quiet < scripts/#{@app_name}/#{ANALYZE_FILENAME}`
  end

  def analyze_determine_measurement_statistics
    # The R script prints some lines to stdout
    # For every metric a title line followed
    # by one line per ruby version
    @statistics = analyze_cmd_r
      .split("\n")
      .reject { |l| l =~ /options\(width/ }
      .map(&:strip)
  end

  def analyze_parse_measurement_statistics
    type = nil
    @statistics.each do |line|
      if line == ''
        type = nil
        next
      end

      METRIC_TYPES.each do |key, mt|
        m = line.match(mt)

        if m
          type = key

          if type == :slow && m.length >= 2
            @rubies.each { |r| r.set_metric_value(:slow_cutoff, m[1]) }
          end

          next
        end
      end

      if type
        m = line.match(/\A\d+\s+(.+)\s+([\d\.]+)\z/)
        @rubies.find { |r| r.match_name == m[1].strip }&.set_metric_value(type, m[2]) if m
      end
    end
  end

  def analyze_create_readme
    readme_file_name = "#{ANALYZE_DATA_FOLDER}/#{@app_name}/README.md"
    f = File.open(readme_file_name, 'w')

    f.write "# Analysis app '#{@app_name}'\n#{measure_readme_description}\n"

    f.write "## System\n"
    f.write "OS: #{@os_info}  \n" if @os_info
    f.write "CPU: #{@cpu_info}  \n" if @cpu_info
    f.write "\n"

    f.write "## Tested Rubies\n"
    f.write "#{@rubies.first.title_string}\n"
    @rubies.each { |ruby| f.write "#{ruby}\n" }

    f.write "\n## Winners\n\n"

    winner = @rubies.sort_by { |r| r.slow || 9e9 }.first
    f.write "- Ruby with lowest __slow__ response-count#{@rubies.first.slow_cutoff_string}: __#{winner&.full_name }__ (#{winner&.slow_string})\n"

    winner = @rubies.sort_by { |r| r.median || 9e9 }.first
    f.write "- Ruby with lowest __median__* response-time: __#{winner&.full_name }__ (#{winner&.median_string})\n"

    winner = @rubies.sort_by { |r| r.stddev || 9e9 }.first
    f.write "- Ruby with lowest __standard deviation__ response-time: __#{winner&.full_name }__ (#{winner&.stddev_string})\n"

    winner = @rubies.sort_by { |r| r.mean || 9e9 }.first
    f.write "- Ruby with lowest __mean__* response-time: __#{winner&.full_name }__ (#{winner&.mean_string})\n"

    winner = @rubies.sort_by { |r| r.memory_finish || 9e9 }.first
    f.write "- Ruby with lowest __memory__ use: __#{winner&.full_name }__ (#{winner&.memory_string(:end)})\n"

    f.write "\n\\* Mean and median are calculated after warmup (x > N/2).\n\n"

    analyze_add_plot(f,
      '0_overview',
      'Overview of response-times of all tested Rubies',
      '[Boxplot](https://en.wikipedia.org/wiki/Box_plot) showing ~99% of all measurements (sorted by responsetime)'
    )

    analyze_add_plot(f,
      '01_histogram',
      'Histograms of response-times of all tested Rubies',
      'Showing a single tested uri and the most occurring response-times'
    )

    f.write "## Scatter-plots\n"
    f.write "These scatter-plots show the response time of individual calls as dots. "
    f.write "Note that many dots may overlap each other.  \n"
    f.write "Vertical blue lines near the X-axis indicate major garbage collection runs (of Run-ID 1).\n"

    @rubies.each do |ruby|
      analyze_add_plot(f, "1_#{ruby.match_name}", "Response-times for: #{ruby.full_name}")
    end

    f.write "\n## Detailed scatter-plots\n"
    f.write "Same as above but focussing on the most ocurring response times. GC runs are not shown.\n"

    @rubies.each do |ruby|
      analyze_add_plot(f, "2_#{ruby.match_name}", "Detailed response-times for: #{ruby.full_name}")
    end

    f.close
  end

  def analyze_add_plot(f, plot_name, title, comment = nil)
    plot_file_name = "#{ANALYZE_DATA_FOLDER}/#{@app_name}/#{ANALYZE_PLOTS_FOLDER}/#{@app_name}_#{plot_name}.png"

    if File.exist?(plot_file_name)
      f.write "## #{title}\n#{comment}#{comment ? "\n" : ''}![#{title}](/#{plot_file_name.gsub(' ', '%20')} \"#{title}\")\n\n"
    end
  end
end
