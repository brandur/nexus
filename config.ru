
require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

def env!(k)
  ENV[k] || raise("missing_environment=#{k}")
end

DB = Sequel.connect(env!("DATABASE_URL"))

configure do
  set :show_exceptions, false
end

require "./lib/nexus"

# Sinatra app
require "./web"

map "/" do
  use Rack::SSL if ENV["FORCE_SSL"]
  use Rack::Instruments
  run Sinatra::Application
end
