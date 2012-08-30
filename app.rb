#
# Init
#

Twitter.configure do |config|
  config.consumer_key, config.consumer_secret =
    env!("TWITTER_CONSUMER_KEY"), env!("TWITTER_CONSUMER_SECRET")
  config.oauth_token, config.oauth_token_secret =
    env!("TWITTER_OAUTH_TOKEN"), env!("TWITTER_OAUTH_SECRET")
end

#
# Sources
#

source :github_heroku do
  feed = Feedzirra::Feed.fetch_and_parse(env!("GITHUB_HEROKU_URL"))
  feed.entries.map do |entry|
    { title: entry.title, content: entry.content, tag: entry.id,
      url: entry.url, published_at: entry.published }
  end
end

source :twitter_brandur do
  tweets = Twitter.home_timeline
  tweets.map do |tweet|
    { content: tweet.text, tag: tweet.id.to_s,
      url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}",
      published_at: tweet.created_at }
  end
end
