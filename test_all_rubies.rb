#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

system 'clear'

def rvm_installed?
  (`rvm` =~ /\ARuby/) == 0
rescue
  false
end

def list_rubies
  `rvm list`
    .split("\n")
    .map { |version| version.scan(/ ([a-z]+\-[\d\.\-p]+) +.*/)&.first&.first }
    .compact
    .sort
end

def remove_gemfile_lock(folder)
  fn = "#{folder}/Gemfile.lock"
  File.delete(fn) if File.exist?(fn)
end

def cmd_setup_rvm
  home = `echo $HOME`.strip
  # "export PATH=$PATH:/bin:/sbin:$HOME/.rvm/bin;echo $PATH;source #{home}/.rvm/scripts/rvm"
  # "echo $PATH;source #{home}/.rvm/scripts/rvm"
  "#{home}/.rvm/scripts/rvm"
end

def cmd_switch_to_folder(folder)
  "cd #{folder}"
end

def cmd_switch_to_ruby(version)
  "rvm use #{version}"
end

def cmd_bundle_install
  'bundle install'
end

def cmd_run_server(jit)
  rackup_cmd = `which rackup`.strip
  "ruby #{jit} #{rackup_cmd} --quiet"
end

def stop_server(ppid)
  if ppid
    pids = `ps -eo pid,ppid | grep #{ppid} | grep -iv grep`
      .split("\n")
      .map { |line| line.split(' ').first.to_i }

    pids.each do |pid|
      Process.detach(pid)
      Process.kill('QUIT', pid)
    end
  end
end

raise 'Please install RVM or change the script to use another Ruby version manager' unless rvm_installed?

app_folder = 'rodauth'

list_rubies.each do |version|
  [
    '',
    version =~ /ruby\-3.0/ ? '--jit' : nil,
    version =~ /ruby\-3.1/ ? '--mjit' : nil,
    version =~ /ruby\-3.1/ ? '--yjit' : nil,
  ].compact.each do |jit|
    puts "\nTest #{version} #{jit}"

    remove_gemfile_lock(app_folder)

    cmd = [
      # '/bin/bash -l',
      # cmd_setup_rvm,
      # cmd_switch_to_folder(app_folder),
      # cmd_switch_to_ruby(version),
      # cmd_bundle_install,
      # cmd_run_server(jit),
    ].join(';')

    puts cmd
    ppid = Process.spawn(cmd, pgroup: true)
    sleep 10
    stop_server(ppid)
    break
  end
  break
end
