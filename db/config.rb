# Database options for various Rack environments.
# Use any options accepted by PG::Connection#new.
module DB
  Config = {
    'development' => {
      'host'     => 'localhost',
      'user'     => 'vagrant',
      'password' => 'vagrant',
      'dbname'   => 'ninenine-delta_development'
    },
    'test'        => { }
  }
end