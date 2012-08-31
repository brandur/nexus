#
# Helpers
#

helpers do
  def curl?
    !!(request.user_agent =~ /curl/)
  end
end

#
# Error handling
#

error do
  log :error, type: env['sinatra.error'].class.name,
    message: env['sinatra.error'].message,
    backtrace: env['sinatra.error'].backtrace
  [500, { message: "Internal server error" }.to_json]
end

#
# Public
#

get "/events" do
  events = Event.order(:id.desc).limit(100).map(&:to_json_v1)
  [200, MultiJson.encode(events, pretty: curl?)]
end
