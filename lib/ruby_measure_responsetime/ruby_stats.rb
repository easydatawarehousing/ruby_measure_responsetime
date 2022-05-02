# frozen_string_literal: true

class RubyStats

  attr_reader   :ruby_name, :jit, :slow, :median
  attr_accessor :memory, :runtime, :mean, :error_count, :count, :mgcs

  def initialize(ruby)
    @ruby_name = ruby[0]
    @jit       = ruby[1]
  end

  def full_name
    "#{@ruby_name} #{jit_string}".strip
  end

  def match_name
    "#{@ruby_name.sub('-preview1', '').sub('-p648', '')} #{jit_string}".strip
  end

  def to_s
    [
      '',
      @ruby_name[0..23].ljust(25),
      # match_name.ljust(25),
      jit_string.ljust(4),
      memory_string.rjust(9),
      runtime_string.rjust(9),
      mean_string.rjust(9),
      median_string.rjust(9),
      @slow.to_s.rjust(8),
      @error_count.to_s.rjust(8),
      @count.to_s.rjust(8),
      @mgcs.to_s.rjust(8),
      '',
    ].join(' | ').strip
  end

  def title_string
    "| Ruby                      | JIT  |    Memory |   Runtime |      Mean |    Median |     Slow |   Errors |        N |  GC runs |\n" +
    '| ------------------------- | ---- | --------: | --------: | --------: | --------: |--------: | -------: | -------: | -------: |'
  end

  def set_metric_value(type, value)
    case type
    when :slow
      @slow = value.to_i
    when :mean
      @mean = value.to_f
    when :median
      @median = value.to_f
    when :count
      @count = value.to_i
    end
  end

  private

  def jit_string
    if ['--jit', '--mjit'].include?(@jit)
      'MJIT'
    elsif @jit.to_s['--yjit']
      'YJIT'
    else
      ''
    end
  end

  def memory_string
    @memory ? "#{@memory.round(0)}Mb" : ''
  end

  def runtime_string
    @runtime ? "#{@runtime.round(0)}s" : ''
  end

  def mean_string
    @mean ? "#{@mean.round(2)}ms" : ''
  end

  def median_string
    @median ? "#{@median.round(2)}ms" : ''
  end
end
