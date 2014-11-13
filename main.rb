#!/usr/bin/env ruby

require 'optparse'
require 'login_data'
require 'monkey'

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

THREADS_COUNT = 5

authentications = LoginData.instance.auth_data
auth_count = authentications.length
batch_size = auth_count / THREADS_COUNT

logger.info('Start...')
logger.info("batch_size = #{batch_size}")

authentications.each_slice(batch_size) do |batch|

  Thread.new do
    monkeys = []

    Thread.new do
      batch.each do |auth|
        # zbot = Monkey.new('0.0.0.0', 27015)
        zbot = Monkey.new('zoe-games.com', 27015)
        zbot.login(auth)

        monkeys << zbot
      end

      while true
        ready = IO.select(monkeys)
        readable = ready[0]
        readable.each do |socket|
          socket.receive_data
        end

      end

    end

    loop do
      monkeys.each {|monkey| monkey.do_some_actions unless monkey.nil? }
    end

  end
end


sleep