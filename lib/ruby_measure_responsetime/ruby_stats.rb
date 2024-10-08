# frozen_string_literal: true

class RubyStats

  attr_reader   :ruby_name, :jit

  attr_accessor :memory_start, :memory_finish, :runtime,
                :mean, :median, :stddev,
                :slow, :slow_cutoff, :error_count, :count, :mgcs_count

  def initialize(ruby)
    @ruby_name = ruby[0]
    @jit       = ruby[1]
  end

  def full_name
    "#{@ruby_name} #{jit_string}".strip
  end

  def match_name
    name = @ruby_name
      .sub('-preview1', '')
      .sub('-preview2', '')
      .sub('-p648', '')
      .sub('-rc1', '')

    "#{name} #{jit_string}".strip
  end

  def to_s
    [
      '',
      @ruby_name[0..23].ljust(25),
      # match_name.ljust(25),
      jit_string.ljust(4),
      memory_string(:start).rjust(9),
      memory_string(:finish).rjust(9),
      runtime_string.rjust(9),
      mean_string.rjust(9),
      median_string.rjust(9),
      stddev_string.rjust(9),
      @slow.to_s.rjust(8),
      @error_count.to_s.rjust(8),
      @count.to_s.rjust(8),
      @mgcs_count.to_s.rjust(8),
      '',
    ].join(' | ').strip
  end

  def title_string
    "| Ruby                      | JIT  | Mem start |   Mem end |   Runtime |      Mean |    Median |   Std.Dev |     Slow |   Errors |        N |  GC runs |\n" +
    '| ------------------------- | ---- | --------: | --------: | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |'
  end

  def set_metric_value(type, value)
    if value != ''
      case type
      when :slow
        @slow = value.to_i
      when :slow_cutoff
        @slow_cutoff = value.to_i
      when :mean
        @mean = value.to_f
      when :median
        @median = value.to_f
      when :stddev
        @stddev = value.to_f
      when :count
        @count = value.to_i
      end
    end
  end

  def slow_string
    @slow ? "#{@slow}x" : ''
  end

  def slow_cutoff_string
    @slow_cutoff ? " (> #{@slow_cutoff}ms)" : ''
  end

  def mean_string
    @mean ? "#{@mean.round(2)}ms" : ''
  end

  def median_string
    @median ? "#{@median.round(2)}ms" : ''
  end

  def stddev_string
    @stddev ? "#{@stddev.round(2)}ms" : ''
  end

  def memory_string(at)
    if at == :start
      @memory_start ? "#{@memory_start.round(0)}Mb" : ''
    else
      @memory_finish ? "#{@memory_finish.round(0)}Mb" : ''
    end
  end

  private

  def jit_string
    if ['--jit', '--mjit'].include?(@jit)
      'MJIT'
    elsif @jit.to_s['--yjit']
      'YJIT'
    elsif @jit.to_s['--rjit']
      'RJIT'
    else
      ''
    end
  end

  def runtime_string
    @runtime ? "#{@runtime.round(0)}s" : ''
  end
end
