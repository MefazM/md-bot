#!/usr/bin/env ruby
require 'pry'
require 'optparse'
require 'login_data'
require 'monkey'

HOST = '0.0.0.0'
PORT = 3000
# HOST = 'zoe-games.com'
# PORT = 27015

THREADS_COUNT = 5

Thread.abort_on_exception = true

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

require 'logger'

logger = Logger.new(STDOUT)

authentications = LoginData.instance.auth_data
auth_count = authentications.length
batch_size = auth_count / THREADS_COUNT

logger.info("*** Start MagicBot. Connect to: #{HOST}:#{PORT}. ***")
logger.info("Authentications: #{authentications.size}. Threads: #{THREADS_COUNT}, batch size: #{batch_size}")

authentications.each_slice(batch_size) do |batch|

  Thread.new do
    monkeys = []

    Thread.new do
      batch.each do |auth|
        zbot = Monkey.new(HOST, PORT)
        zbot.login(auth)

        monkeys << zbot
      end

      loop do
        ready = IO.select(monkeys)
        ready[0].each {|s| s.receive_data}
      end

    end

    logger.info("#{batch.size} bots connected!")

    loop do
      monkeys.each {|monkey| monkey.do_some_actions unless monkey.nil? }
    end

  end
end

sleep
