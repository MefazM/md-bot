#!/usr/bin/env ruby
require 'optparse'
require 'login_data'
require 'client'


options = {}
OptionParser.new do |opts|
  opts.banner = "Magic Towers bot usage: [options]"

  opts.on("--clear", "Cleat saved login data") do |v|
    LoginData.instance.clear
    exit
  end

  opts.on("--show", "Show auth data") do |v|
    LoginData.instance.show_auth_data
    exit
  end

  opts.on("--generate N", Integer, "Generate bot auth data") do |n|
    LoginData.instance.generate_auth_data n
    exit
  end

end.parse!

auth_data = LoginData.instance.auth_data
print "Connectings..."
auth_data.each {|auth| Monkey.new(auth).async.run! }
print "Ready!\n"
sleep