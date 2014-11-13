module Networking
  MESSAGE_START_TOKEN = '__JSON__START__'
  MESSAGE_END_TOKEN = '__JSON__END__'
  TOKEN_START_LENGTH = MESSAGE_START_TOKEN.length

  module SendData
    LOGIN = :ln
    GAME_DATA = :gd
    HARVESTING = :hg


    NEW_BATTLE = :nb
    BATTLE_START = :bs
    LOBBY_DATA = :ld
    SPAWN_UNIT = :su
    UNIT_PRODUCTION_TASK = :upt
    CAST_SPELL = :cs
    RESPONSE_BATTLE_INVITE = :rbi
    PING = :pg

    CONSTUCT_BUILDING = :cb
    CONSTUCT_UNIT = :cu

    def request_login(login_data)
      write_data [LOGIN, login_data]
    end

    def request_game_data
      write_data [GAME_DATA]
    end

    def request_harvest
      write_data [HARVESTING]
    end

    def request_ping(data)
      write_data [PING, data]
    end

    def request_constuct_building(uid)
      write_data([CONSTUCT_BUILDING, uid])
    end

    def request_constuct_unit(uid)
      write_data([CONSTUCT_UNIT, uid])
    end

    def write_data data
      json = JSON.generate(data)
      write "__JSON__START__#{json}__JSON__END__"
    end
  end

end
