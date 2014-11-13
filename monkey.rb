
require 'json'
require 'pry'
require 'socket'
require 'buildings_production_task'
require 'units_production_task'
require 'networking'

MESSAGE_START_TOKEN = '__JSON__START__'
MESSAGE_END_TOKEN = '__JSON__END__'

class Monkey < TCPSocket
  include BuildingsProductionTask
  include UnitsProductionTask
  include Networking::SendData

  RECEIVED_MAP = {
    ad: :authorised,
    gd: :game_data,
    png: :pong,
    gsc: :gold_storage_capacity,
    ntct: :notification,
    bsc: :building_sync,
    scs: :score_sync,
    mns: :mana_sync,
    sgs: :start_game_scene,
    su: :sync_units,
  }

  def initialize(*args)
    super(*args)

    @buffer = ''

    @ready = false
    @next_active_time = Time.now.to_i
  end

  def do_some_actions
    return unless @ready

    if @next_active_time < Time.now.to_i

      request_harvest

      case [:construct_building, :construct_unit].sample
      when :construct_building

        construct_building

      when :construct_unit

        rand(1..7).times do
          construct_unit
        end

      end


      enqueue(rand(3..5))
    end
  end

  def login(login_data)
    request_login(login_data)
  end

  def start_game_scene(data)
    @ready = true
    enqueue(rand(3..5))
  end

  def enqueue(offset)
    @next_active_time = Time.now.to_i + offset
  end

  def authorised(data)
    request_harvest
    @buildings = data[:buildings]
  end

  def game_data(data)
    @game_data = data
  end

  def gold_storage_capacity(data)
    @coins = data
  end

  def building_sync(data)
    @buildings[data[:uid].to_sym] = data
  end

  def perform(action, data)
    handler = RECEIVED_MAP[action.to_sym]
    if handler && respond_to?(handler)
      method(handler).call(data[0])
    else
      # error("Handler for: #{action} not found.")
    end
  end

  def receive_data
    buffer = recv_nonblock(1024)

    @buffer += buffer

    if buffer.length == 0
      return
    else

      loop do
        str_start = @buffer.index(MESSAGE_START_TOKEN)
        str_end = @buffer.index(MESSAGE_END_TOKEN)
        if str_start and str_end

          message = @buffer.slice!(str_start .. str_end + 12)
          json = message.slice(str_start + 15 .. str_end - 1)

          action, *payload = JSON.parse( json, :symbolize_names => true)

          perform( action, payload )
        else
          break
        end

      end

    end
  end

end