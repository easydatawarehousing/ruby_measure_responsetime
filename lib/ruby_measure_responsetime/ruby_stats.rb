class RubyStats

  attr_reader   :ruby_name, :jit
  attr_accessor :memory, :runtime, :average, :error_count

  def initialize(ruby)
    @ruby_name = ruby[0]
    @jit       = ruby[1]
  end

  def to_s
    [
      @ruby_name[0..23].ljust(25),
      jit_string.ljust(5),
      memory_string.rjust(9),
      runtime_string.rjust(9),
      average_string.rjust(9),
      @error_count.to_s.rjust(8),
    ].join('')
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

  def average_string
    @average ? "#{@average.round(1)}ms" : ''
  end
end
