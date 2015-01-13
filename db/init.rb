require 'pg'
require './db/config.rb'

module DB
  def self.connect env=nil
    if ENV['DATABASE_URL']
      uri  = URI.parse ENV['DATABASE_URL']
      opts = {
        'host'     => uri.host,
        'user'     => uri.user,
        'password' => uri.password,
        'dbname'   => uri.path.split('/')[1],
        'port'     => uri.port
      }
    else
      opts = DB::Config['development']
    end
    PG::Connection.new opts
  end
end