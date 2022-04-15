require_relative 'models'
require 'roda'

$f.write "\n#{RUBY_DESCRIPTION}\n"
$f.write "#{GC.stat}\n"
$f.flush

$req_count = 0
$last_mgc_count = GC.stat[:major_gc_count]
$mgcs = []

class App < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
    'Content-Type'=>'text/html',
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self, 'https://maxcdn.bootstrapcdn.com'
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  # plugin :route_csrf # Disabled for easier testing
  plugin :flash
  plugin :assets, css: 'app.css'
  plugin :render, engine: 'haml', layout: 'layout', views: './views'
  plugin :view_options
  plugin :public
  plugin :hash_routes

  plugin :not_found do
    @page_title = "File Not Found"
    view(:content=>"")
  end

  plugin :error_handler do |e|
    $f.write "ERROR #{e.class}: #{e.message}\n#{e.backtrace}\n"
    @page_title = "Internal Server Error"
    view(content: '')
  end

  plugin :rodauth, csrf: false do
    enable :create_account, :login, :logout, :lockout, :reset_password
    use_database_authentication_functions? false
    hmac_secret 'HMAC_SECRET_HMAC_SECRET_HMAC_SECRET_HMAC_SECRET'
  end

  plugin :sessions,
    key: '_App.session',
    secret: 'APP_SESSION_SECRET_APP_SESSION_SECRET_APP_SESSION_SECRET_APP_SESSION_SECRET',
    max_idle_seconds: nil

  route do |r|
    $req_count += 1

    mgc = GC.stat[:major_gc_count] || GC.stat[:count]
    if $last_mgc_count != mgc
      $mgcs << $req_count
      $last_mgc_count = mgc
    end

    r.public
    r.assets
    # check_csrf! # Disabled for easier testing
    r.rodauth
    r.root { view 'index' }

    r.get 'version' do
      mjit = RUBY_DESCRIPTION['+JIT'] || RUBY_DESCRIPTION['+MJIT'] ? ' MJIT' : ''
      yjit = RUBY_DESCRIPTION['+YJIT'] ? ' YJIT' : ''

      version = if defined?(RUBY_ENGINE_VERSION)
        RUBY_ENGINE_VERSION
      else
        m = RUBY_DESCRIPTION.match(/ruby ([\d\.]+)[p,]+.*\z/)
        m ? m[1] : RUBY_DESCRIPTION
      end

      "#{RUBY_ENGINE}-#{version}#{mjit}#{yjit}"
    end

    r.get 'gc' do
      $f.write "#{GC.stat}\n"
      $f.close
      $mgcs.to_s
    end
  end
end
