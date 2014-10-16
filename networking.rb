require 'actions_headers'

module Networking
  MESSAGE_START_TOKEN = '__JSON__START__'
  MESSAGE_END_TOKEN = '__JSON__END__'
  TOKEN_START_LENGTH = MESSAGE_START_TOKEN.length

  module SendData
    def login
      login_data = {
        :token => @token,
        :name => @username,
        :email => @email,
        :provider => 'facebook'
      }
      write_data [::Send::LOGIN, login_data]
    end

    def request_game_data
      write_data [::Send::GAME_DATA]
    end

    def ping
      write_data [::Send::PING]
    end

    def write_data data
      json = JSON.generate(data)
      @socket.write "__JSON__START__#{json}__JSON__END__"
    end
  end

  class Request

    def initialize socket
      @socket = socket

      @buffer = ''
      @multipart_package = false
    end

    def listen_socket
      raise "Socket is dead!" if @socket.nil?
      raise "No block given!" unless block_given?

      loop {
        data = @socket.read
        @buffer += data

        loop {
          str_start = @buffer.index MESSAGE_START_TOKEN
          str_end = @buffer.index MESSAGE_END_TOKEN
          if str_start and str_end

            message = @buffer.slice!(str_start .. str_end + 12)
            json = message.slice(str_start + 15 .. str_end - 1)

            action, *payload = JSON.parse( json, :symbolize_names => true)

            yield( action, payload )
          else
            break
          end
        }
      }
    end
  end
end
