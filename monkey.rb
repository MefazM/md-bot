require 'actions_headers'

require 'celluloid'
require 'celluloid/io'
require 'networking'
require 'json'
require 'pry'

class Monkey
  include Celluloid
  include Celluloid::IO
  include Celluloid::Logger
  include Networking::SendData

  BENCH_PACKEGES_COUNT = 500

  def initialize auth_data, host = '0.0.0.0', port = 27014
    info 'Initialize monkey...'
    @token = auth_data[:token]
    @username = auth_data[:username]
    @email = auth_data[:email]
    @socket = TCPSocket.new(host, port)
    @requests =  Networking::Request.new @socket

    @counter = 0

    @latency_samples = []
    @packeges_count = 0
  end

  def run!
    request_game_data

    async.listen
  end

  def listen
    @requests.listen_socket do |action, data|

      @packeges_count += 1

      case action.to_sym
      when ::Receive::AUTHORISED

        info "AUTHORISED!"

        @bench_start_time = Time.now.to_f

        request_ping({ counter: @counter, time: @bench_start_time })

      when ::Receive::GAME_DATA
        info "GAMEDATA RECIEVED!"
        @game_data = data[0]

        request_login

      when ::Receive::PONG

        time = Time.now.to_f

        received_counter = data[0][:counter]
        @latency_samples << time - data[0][:time]

        @counter += 1
        if received_counter != @counter
          puts("#{received_counter} != #{@counter}")
        end

        if @counter > BENCH_PACKEGES_COUNT
          bench_time = Time.now.to_f - @bench_start_time
          avg_lat = @latency_samples.inject(:+) / @latency_samples.length
          puts("#{BENCH_PACKEGES_COUNT} pings processed in #{bench_time} seconds. Total: #{@packeges_count}. AVG latency: #{avg_lat}. MAX: #{@latency_samples.max}. MIN: #{@latency_samples.min}")
        else
          request_ping({ counter: @counter, :time => Time.now.to_f })
        end


      else
        error "Unknow request: #{action}"
      end
    end
  end

end