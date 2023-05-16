class HomeController < ApplicationController

  before_action :authenticate_user!, only: :authenticated

  def index
  end

  def authenticated
    render :index
  end

  def gc
    render plain: $mgcs.to_s
  end

  def version
    mjit = RUBY_DESCRIPTION['+JIT'] || RUBY_DESCRIPTION['+MJIT'] ? ' MJIT' : ''
    yjit = RUBY_DESCRIPTION['+YJIT'] ? ' YJIT' : ''
    rjit = RUBY_DESCRIPTION['+RJIT'] ? ' RJIT' : ''

    version = if defined?(RUBY_ENGINE_VERSION)
      RUBY_ENGINE_VERSION
    else
      m = RUBY_DESCRIPTION.match(/ruby ([\d\.]+)[p,]+.*\z/)
      m ? m[1] : RUBY_DESCRIPTION
    end

    render plain: "#{RUBY_ENGINE}-#{version}#{mjit}#{yjit}#{rjit}"
  end
end
