#
# Helpers
#

helpers do
  def authenticate_with_http_basic
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      yield(@auth.credentials)
  end

  def authorized?
    authenticate_with_http_basic do |username, password|
      password == ENV["HTTP_API_KEY"] ||
        raise("missing_environment=HTTP_API_KEY")
    end
  end

  def authorized!
    unless authorized?
      log :unauthorized
      throw(:halt, [401, { message: "Not authorized" }.to_json])
    end
  end

  def curl?
    !!(request.user_agent =~ /curl/)
  end

  def log(action, attrs = {})
    Slides.log(action, attrs.merge!(id: env["REQUEST_ID"]))
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
  authorized!
  events = Event.order(:id.desc).limit(params[:count] || 100).map(&:to_json_v1)
  [200, MultiJson.encode(events, pretty: curl?)]
end
