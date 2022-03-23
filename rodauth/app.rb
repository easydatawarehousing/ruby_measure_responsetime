require_relative 'models'
require 'roda'

$count = 0
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

  # if ENV['RACK_ENV'] == 'development'
  #   plugin :exception_page
  #   class RodaRequest
  #     def assets
  #       exception_page_assets
  #       super
  #     end
  #   end
  # end

  plugin :error_handler do |e|
    # case e
    # when Roda::RodaPlugins::RouteCsrf::InvalidToken
    #   @page_title = "Invalid Security Token"
    #   response.status = 400
    #   view(:content=>"<p>An invalid security token was submitted with this request, and this request could not be processed.</p>")
    # else
    # $stderr.print "#{e.class}: #{e.message}\n"
    # $stderr.puts e.backtrace
    next exception_page(e, :assets=>true) if ENV['RACK_ENV'] == 'development'
    @page_title = "Internal Server Error"
    view(:content=>"")
    # end
  end

  plugin :rodauth, csrf: false do
    enable :create_account, :login, :logout, :lockout, :reset_password
    use_database_authentication_functions? false
    hmac_secret 'HMAC_SECRET_HMAC_SECRET_HMAC_SECRET_HMAC_SECRET'
  end

  plugin :sessions, key: '_App.session', secret: 'APP_SESSION_SECRET_APP_SESSION_SECRET_APP_SESSION_SECRET_APP_SESSION_SECRET'

  route do |r|
    $count += 1
    mgc = GC.stat[:major_gc_count] || GC.stat[:count]
    if $last_mgc_count != mgc
      $mgcs << $count
      $last_mgc_count = mgc
    end

    r.public
    r.assets
    # check_csrf! # Disabled for easier testing
    r.rodauth
    r.root { view 'index' }

    r.get 'version' do
      RUBY_DESCRIPTION
    end

    r.get 'gc' do
      p GC.stat
      $mgcs.to_s
    end
  end
end
