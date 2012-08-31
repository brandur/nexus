
require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

DB = Sequel.connect(ENV["DATABASE_URL"] ||
  raise("missing_environment=DATABASE_URL"))

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
