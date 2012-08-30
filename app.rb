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
# Utilities
#

def twitter_url(user, status_id)
  "https://twitter.com/#{user}/status/#{status_id}"
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

source :hackernews do
  feed = Feedzirra::Feed.fetch_and_parse("http://news.ycombinator.com/rss")
  feed.entries.map do |entry|
    { title: entry.title, tag: entry.summary.gsub(/^.*id=(\d+).*$/, '\\1'), 
      # Hacker News doesn't include a published date of any kind ...
      url: entry.url, published_at: Time.now.utc, metadata: {
        comments_url: entry.summary.gsub(/^.*"(http:.*)".*$/, '\\1')
    } }
  end
end

source :twitter_brandur do
  tweets = Twitter.home_timeline(include_entities: true)
  tweets.map do |tweet|
    content = tweet.text
    # expand urls, because short urls are terrible
    tweet.urls.each { |url| content.sub!(url.url, url.expanded_url) }
    { content: tweet.text, tag: tweet.id.to_s,
      url: twitter_url(tweet.user.screen_name, tweet.id),
      published_at: tweet.created_at, metadata: {
        in_reply_to_url: tweet.in_reply_to_status_id ?
          twitter_url(tweet.in_reply_to_screen_name, tweet.in_reply_to_status_id) : nil,
        in_reply_to_status: tweet.in_reply_to_status_id,
        in_reply_to_user: tweet.in_reply_to_screen_name,
        user: tweet.user.screen_name, name: tweet.user.name
    } }
  end
end
