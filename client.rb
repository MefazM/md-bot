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

  HARVEST_TIME = 5 #sec
  UPDATE_PERIOD = 5 #sec

  AVAILABLE_BUILDINGS = [:gold_storage, :gold_mine, :mage_barrack, :bow_barrack, :barrack]

  UNITS_PRODUCE_BUILDINGS = [:bow_barrack, :mage_barrack, :barrack]

  STATES = [:produce_units, :update_buildings, :war]

  def initialize auth_data, host = '0.0.0.0', port = 3005

    write_log 'Initialize monkey...'

    @token = auth_data[:token]
    @username = auth_data[:username]
    @email = auth_data[:email]

    @socket = TCPSocket.new(host, port)
    @states = []
    @current_state = nil
  end

  def run!
    write_log 'Run...'

    async.listen
    async.login
    async.start
  end

  private
  # Emulate monkey player
  def start
    every (HARVEST_TIME) {
      do_harvest
    }

    @update_timer = after(UPDATE_PERIOD) {
      fill_states if @states.empty?
      @current_state = @states.pop

      send @current_state
    }
  end

  def fill_states
    @states = (STATES*3).shuffle
  end

  def produce_units
    uid = unit_uid_to_produce
    if uid
      units_count = rand 0..3
      units_count.times do
        produce_unit uid
      end
    end

    @update_timer.reset
  end

  def update_buildings
    uid = building_uid_to_update
    update_building uid if uid

    @update_timer.reset
  end

  def war
    request_lobby_data
  end

  # Dumshit at the bottom
  def listen
    Networking::Request.listen_socket(@socket) do |action, data|
      case action
      when RECEIVE_GAME_DATA_ACTION

        write_log "Setup game data..."

        payload = data[1]

        @buildings = payload[:player_data][:buildings]
        @units = payload[:player_data][:units]
        @buildings_production = payload[:game_data][:buildings_production]
        @buildings_info = payload[:game_data][:buildings_data]

      when RECEIVE_SYNC_BUILDING_STATE_ACTION

        uid, level, is_ready = data[1],data[2],data[3]

        if is_ready
          @buildings[uid.to_sym] = {
            :level => level,
            :ready => true,
            :uid => uid
          }

          write_log "Building added u = #{uid}, l = #{level}"
        end

      when RECEIVE_FINISH_BATTLE_ACTION
        @update_timer.reset if @current_state == :war

      when RECEIVE_CUSTOM_EVENT
        payload = data[1]
        @update_timer.reset if @current_state == :war && payload[2] == :inviteCanceledNotification

      when RECEIVE_LOBBY_DATA_ACTION

        payload = data[1]

        if @current_state == :war && payload.empty?
          @update_timer.reset
        else
          player = payload.sample
          request_battle player[0]
        end

      when RECEIVE_CREATE_NEW_BATTLE_ON_CLIENT_ACTION
        write_log 'Start new battle...'
        request_battle_start

      when RECEIVE_INVITE_TO_BATTLE_ACTION

        response_invitation(data[1], [true, false].sample)
      end

      false
    end
  end

  def unit_uid_to_produce
    buildings_uids = UNITS_PRODUCE_BUILDINGS.shuffle

    buildings_uids.each do |uid|
      @buildings_production[uid].each do |unit|
        if @buildings[uid]
          return unit[:uid].to_sym if @buildings[uid][:level] == unit[:level]
        end
      end

    end

    nil
  end

  def building_uid_to_update
    buildings_uids = AVAILABLE_BUILDINGS.shuffle

    uid = buildings_uids.find do |uid|
      if @buildings[uid]
        level = @buildings[uid][:level]
        @buildings_info["#{uid}_#{level}".to_sym][:actions][:build]
      else
        true
      end
    end

    uid
  end

  def write_log text
    info "P=#{@username}   | #{text}"
  end

end