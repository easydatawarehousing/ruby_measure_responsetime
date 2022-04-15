if RUBY_ENGINE == 'jruby'
  require 'jdbc/sqlite3'
  require 'sequel/core'
  DB=Sequel.jdbc("sqlite:tmp/test.db")
else
  require 'sequel/core'
  DB = Sequel.sqlite('tmp/test.db')
end
