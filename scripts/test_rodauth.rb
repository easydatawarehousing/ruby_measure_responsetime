#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

GC.disable
require 'net/http'
require 'json'

uris = []

uris << Net::HTTP::Get.new('http://127.0.0.1:9292/')

uris << Net::HTTP::Get.new('http://127.0.0.1:9292/create-account')

uris << Net::HTTP::Get.new('http://127.0.0.1:9292/reset-password-request')

# uris << begin
#   uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
#   uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth1')
#   uri
# end

# uris << begin
#   uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
#   uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'Rodauth2')
#   uri
# end

# uris << begin
#   uri = Net::HTTP::Post.new('http://127.0.0.1:9292/login')
#   uri.set_form_data('login' => 'ivo@mydomain.com', 'password' => 'A')
#   uri
# end

uris << begin
  uri = Net::HTTP::Get.new('http://127.0.0.1:9292/')
  uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hh%3D%3D"
  uri
end

uris << begin
  uri = Net::HTTP::Get.new('http://127.0.0.1:9292/')
  uri['Cookie'] = "_App.session=AdRodaLW916eR4imshinUdXYHcRhluUu7GHEmSeL5frzBhRW-oCUbmD9hNAwszFxS-YgVlSJydKk8HUoxVYHMjzPo_Ir6SmWJD_z1I7RiLsXqZQSXL_CrhM-TRcbkEc1djj_fpyefTC1AC5Mdj9TJlcx8mn9L4xrXwHzrrjc95clj5hu6MTfyLvPUsOc5M22hg%3D%3D"
  uri
end

# Start Roda and get Ruby version
version = Net::HTTP.get(URI('http://127.0.0.1:9292/version'))
mjit = !!version['+JIT']
yjit = !!version['+YJIT']
m = version.match(/ruby ([\d\.]+)[p,]+.*\z/)
version = [m[1], mjit ? 'MJIT' : nil, yjit ? 'YJIT' : nil].compact.join(' ') if m
puts version

N = 50_000
results = []
error_count = success_count = 0
total_time = 0.0

Net::HTTP.start('127.0.0.1', 9292) do |http|
  N.times do |x|
    begin
      uris.each_with_index do |uri, i|
        t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        http.request(uri)
        t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
        y = t2 - t1
        results << [i, x, y]
        total_time    += y
        success_count += 1
      end
    rescue
      error_count +=1
    end

    print "\r#{x+1} "
  end
end

# Create csv and header row
unless File.exist?('data/rodauth.csv')
  f = File.open('data/rodauth.csv', 'w')
  f.write("version,run,uri,x,y,mgc\n")
  f.close
end

# Get GC info
mgcs = JSON.parse(Net::HTTP.get(URI('http://127.0.0.1:9292/gc')))

f = File.open('data/rodauth.csv', 'a')
results.each_with_index do |r, i|
  f.write("\"#{version}\",1,#{r[0]},#{r[1]},#{r[2].round(3)},#{mgcs.include?(r[1]) ? 1 : 0}\n")
end
f.close

puts "\nAverage time = #{(total_time / success_count.to_f).round(1)}ms Errors = #{error_count}"
