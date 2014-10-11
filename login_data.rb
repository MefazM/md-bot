require 'securerandom'
require 'singleton'
require 'yaml'

class LoginData
  include Singleton

  attr_reader :auth_data

  AUTH_FILE = 'auth.yml'

  def clear
    File.delete @auth_data_file_path
  end

  def generate_auth_data number
    Celluloid::Logger::info "Generating bot auth data"
    number.times do
      @auth_data << generate_player
    end
    Celluloid::Logger::info "#{number} new tokens generated"

    save_auth
  end

  def show_auth_data
    puts("Auth data:")
    format="%19s\t%21s\t%36s\n"
    printf(format, "Token", "Username", "Email")
    printf(format, "---------", "---------", "---------")
    @auth_data.each {|player| printf(format, player[:token], player[:username], player[:email])}
    print "\n---- COUT = #{@auth_data.length}\n"
  end

  private

  def initialize
    @auth_data_file_path = File.join( Dir.pwd, AUTH_FILE )
    @auth_data = load_auth
    @auth_data ||= []
  end

  def load_auth

    unless File.exists? AUTH_FILE
      Celluloid::Logger::warn "File with auth data not exists!"
      return nil
    end

    YAML::load( File.read(@auth_data_file_path) )

    rescue Exception => e

      Celluloid::Logger::error "File with auth data is broken! \n #{e}"

      nil
  end

  def save_auth
    File.open(@auth_data_file_path, "w") {|file| file.write @auth_data.to_yaml}
  end

  def generate_player
    auth_token = generate_auth_token

    {
      :token => auth_token,
      :username => "Bot_#{auth_token}",
      :email => "bot_#{auth_token}@botmail.com"
    }
  end

  def generate_auth_token
    SecureRandom.hex(10)
  end
end