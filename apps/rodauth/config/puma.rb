unless RUBY_VERSION['truffle']
  workers 0
  threads 0, 1
end

preload_app!
