# frozen_string_literal: true

require 'fileutils'

# All logic for running the analysis phase
module Analyze

  # Name of R script to analyze results
  ANALYZE_FILENAME = 'analyze.R'

  # Name folder holding plots
  ANALYZE_PLOTS_FOLDER = 'plots'

  # Metric types
  METRIC_TYPES = {
    slow:   'Slow request counts',
    mean:   'Means',
    median: 'Medians',
    count:  'Count'
  }

  private

  def analyze_results
    puts 'Analyzing'
    analyze_create_data_folders
    analyze_os_info
    analyze_cpu_info
    analyze_determine_statistics
    analyze_parse_statistics
    analyze_create_readme
  end

  def analyze_create_data_folders
    FileUtils.mkdir_p "data/#{@app_name}/#{ANALYZE_PLOTS_FOLDER}"
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

  def analyze_cmd_r
    `R --vanilla --quiet < scripts/#{@app_name}/#{ANALYZE_FILENAME}`
  end

  def analyze_determine_statistics
    @statistics = analyze_cmd_r
      .split("\n")
      .select { |l| l !~ /options\(width/ }
      .map(&:strip)
  end

  def analyze_parse_statistics
    type = nil
    @statistics.each do |line|
      if METRIC_TYPES.values.include?(line)
        type = METRIC_TYPES.find { |_, mt| mt == line }[0]
        next
      end

      if type
        m = line.match(/\A\d+\s+(.+)\s+([\d\.]+)\z/)
        @rubies.find { |r| r.match_name == m[1].strip }&.set_metric_value(type, m[2]) if m
      end
    end
  end

  def analyze_create_readme
    readme_file_name = "data/#{@app_name}/README.md"
    f = File.open(readme_file_name, 'w')

    f.write "# Analysis app '#{@app_name}'\n#{measure_readme_description}\n"

    f.write "## System\n"
    f.write "OS: #{@os_info}  \n" if @os_info
    f.write "CPU: #{@cpu_info}  \n" if @cpu_info
    f.write "\n"

    f.write "## Tested Rubies\n"
    f.write "#{@rubies.first.title_string}\n"
    @rubies.each { |ruby| f.write "#{ruby}\n" }

    half_n = @rubies.max { |ruby| ruby.count }.count / 2
    f.write "\n## Winners\nMean and median after warmup (x > #{half_n}).\n\n"
    f.write "- Ruby with lowest __slow__ response-count: __#{@rubies.sort_by { |r| r.slow || 9e9 }&.first&.full_name }__\n"
    f.write "- Ruby with lowest __median__ response-time: __#{@rubies.sort_by { |r| r.median || 9e9 }&.first&.full_name }__\n"
    f.write "- Ruby with lowest __mean__ response-time: __#{@rubies.sort_by { |r| r.mean || 9e9 }&.first&.full_name }__\n\n"

    analyze_add_plot(f, '0_overview', 'Overview of response-times of all tested Rubies', 'Boxplot showing ~99% of all measurements (sorted by responsetime)')

    @rubies.each do |ruby|
      analyze_add_plot(f, "1_#{ruby.match_name}", "Response-times #{ruby.full_name}")
    end

    @rubies.each do |ruby|
      analyze_add_plot(f, "2_#{ruby.match_name}", "Detailed response-times #{ruby.full_name}")
    end

    f.close
  end

  def analyze_add_plot(f, plot_name, title, comment = nil)
    plot_file_name = "data/#{@app_name}/#{ANALYZE_PLOTS_FOLDER}/#{@app_name}_#{plot_name}.png"

    if File.exists?(plot_file_name)
      f.write "## #{title}\n#{comment}#{comment ? "\n" : ''}![#{title}](/#{plot_file_name.gsub(' ', '%20')} \"#{title}\")\n\n"
    end
  end
end
