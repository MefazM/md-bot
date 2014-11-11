require 'actions_headers'
require 'celluloid'
require 'celluloid/io'

require 'networking'
require 'json'
require 'pry'

require 'buildings_production_task'

class Monkey
  include Celluloid
  include Celluloid::IO
  include Celluloid::Logger
  include Networking::SendData

  include BuildingsProductionTask

  BENCH_PACKEGES_COUNT = 500

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

  def make_hardcore!

    @g += 1

    return if @g < 3

    loop do

      sleep(rand(2..7))

      do_some_actions
    end
  end

  def authorised(data)
    request_harvest
    @buildings = data[:buildings]

    make_hardcore!
  end

  def game_data(data)
    @game_data = data

    make_hardcore!
  end

  def gold_storage_capacity(data)
    @coins = data

    make_hardcore!
  end

  def building_sync(data)
    @buildings[data[:uid].to_sym] = data

    rescue Exception => e
      binding.pry
  end

  # def initialize(auth_data, host = '0.0.0.0', port = 27014) , 27014
  def initialize(auth_data, host = 'zoe-games.com', port = 27014)
    info 'Initialize monkey...'
    @token = auth_data[:token]
    @username = auth_data[:username]
    @email = auth_data[:email]
    @socket = TCPSocket.new(host, port)
    @requests =  Networking::Request.new @socket

    @counter = 0

    @latency_samples = []
    @packeges_count = 0


    @g = 0
  end

  def do_some_actions
    # info('Do some actions.....')
    request_harvest

    case [:construct_building, :construct_unit].sample
    when :construct_building

      construct_building

      info 'Try to construct building....'

    when :construct_unit
      # info 'Try to construct unit'

    end
  end

  def run!
    request_login

    async.listen
  end

  def listen
    @requests.listen_socket do |action, data|
      handler = RECEIVED_MAP[action.to_sym]
      if handler && respond_to?(handler)
        method(handler).call(data[0])
      else
        # error("Handler for: #{action} not found.")
      end
    end
  end

end