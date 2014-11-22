module Networking
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

  end
end
