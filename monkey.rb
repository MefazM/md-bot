require 'celluloid'
require 'celluloid/io'
require 'networking'
require 'json'
require 'pry'

class Monkey
  include Celluloid
  include Celluloid::IO
  include Celluloid::Logger

  include Networking::Actions
  include Networking::SendData

  def initialize auth_data, host = '0.0.0.0', port = 27014
    info 'Initialize monkey...'
    @token = auth_data[:token]
    @username = auth_data[:username]
    @email = auth_data[:email]
    @socket = TCPSocket.new(host, port)
    @requests =  Networking::Request.new @socket

    @counter = 0
  end

  def run!
    request_game_data

    async.listen
  end

  def listen
    @requests.listen_socket do |action, data|
      case action
      when 'authorised'
        @uid = data[0][:uid]
        info "UID: #{@uid}| AUTHORISED!"

        write_data ['ping', { :counter => @counter }]

      when 'game_data'
        info "GAMEDATA RECIEVED!"
        @game_data = data[0]

        login

      when 'pong'

        r_counter = data[0][:counter] + 1

        @counter += 2
        if r_counter != @counter
          puts( "#{r_counter} != #{@counter}")
        end

        write_data ['ping', { :counter => @counter }]
      end
    end
  end

end