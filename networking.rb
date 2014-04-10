module Networking
  MESSAGE_START_TOKEN = '__JSON__START__'
  MESSAGE_END_TOKEN = '__JSON__END__'
  TOKEN_START_LENGTH = MESSAGE_START_TOKEN.length

  module Actions
    SEND_REQUEST_PLAYER_ACTION = 1
    SEND_NEW_BATTLE_ACTION = 2
    SEND_BATTLE_START_ACTION = 3
    SEND_REQUEST_LOBBY_DATA_ACTION = 4
    SEND_SPAWN_UNIT_ACTION = 5
    SEND_UNIT_PRODUCTION_TASK_ACTION = 6
    SEND_SPELL_CAST_ACTION = 7
    SEND_RESPONSE_BATTLE_ACTION = 8
    SEND_PING_ACTION = 9
    SEND_BUILDING_PRODUCTION_TASK_ACTION = 10
    SEND_DO_HARVESTING_ACTION = 11
    SEND_REQUEST_CURRENT_MINE_AMOUNT = 12

    RECEIVE_SPELL_CAST_ACTION = 101
    RECEIVE_SPAWN_UNIT_ACTION = 102
    RECEIVE_BATTLE_SYNC_ACTION = 103
    # RECEIVE_START_BATTLE_ACTION = 104
    RECEIVE_FINISH_BATTLE_ACTION = 105
    # RECEIVE_REQUEST_NEW_BATTLE_ACTION = 106
    RECEIVE_GAME_DATA_ACTION = 107
    RECEIVE_INVITE_TO_BATTLE_ACTION = 108
    RECEIVE_LOBBY_DATA_ACTION = 109
    RECEIVE_PUSH_UNIT_QUEUE_ACTION = 110
    RECEIVE_START_TASK_IN_UNIT_QUEUE_ACTION = 111
    RECEIVE_SYNC_BUILDING_STATE_ACTION = 112
    RECEIVE_CREATE_NEW_BATTLE_ON_CLIENT_ACTION = 113
    RECEIVE_HARVESTING_RESULTS_ACTION = 114

    RECEIVE_PING_ACTION = 555
    RECEIVE_CUSTOM_EVENT = 777
  end

  module SendData
    def login
      write_log "Login..."
      login_data = {
        :token => @token,
        :name => @username,
        :email => @email,
        :provider => 'facebook'
      }
      write_data [Networking::Actions::SEND_REQUEST_PLAYER_ACTION, login_data]
    end

    def response_invitation(battle_uid, decision)
      write_data [Networking::Actions::SEND_RESPONSE_BATTLE_ACTION, battle_uid, decision]
    end

    def request_battle opponent_id
      write_data [Networking::Actions::SEND_NEW_BATTLE_ACTION, opponent_id, false]
    end

    def request_battle_start
      write_data [Networking::Actions::SEND_BATTLE_START_ACTION]
    end

    def update_building uid
      write_log "Update building= #{uid}"
      write_data [Networking::Actions::SEND_BUILDING_PRODUCTION_TASK_ACTION, uid]
    end

    def produce_unit uid
      write_log "Produce unit= #{uid}"
      write_data [Networking::Actions::SEND_UNIT_PRODUCTION_TASK_ACTION, uid]
    end

    def do_harvest
       write_data [Networking::Actions::SEND_DO_HARVESTING_ACTION]
    end

    def request_lobby_data
      write_data [Networking::Actions::SEND_REQUEST_LOBBY_DATA_ACTION]
    end

    def write_data data
      json = JSON.generate(data)
      @socket.write "__JSON__START__#{json}__JSON__END__"
    end
  end

  class Request

    def self.listen_socket(socket)
      raise "Socket is dead!" if socket.nil?
      raise "No block given!" unless block_given?

      begin
        data_str = socket.read

        str_start = data_str.index(MESSAGE_START_TOKEN)
        str_end = data_str.index(MESSAGE_END_TOKEN)
        data = nil

        if str_start and str_end
          json = data_str[ str_start + TOKEN_START_LENGTH .. str_end - 1 ]



          action, *data = JSON.parse(json, :symbolize_names => true)
        end

      end until yield( action, data )

    end

  end
end
