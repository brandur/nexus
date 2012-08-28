source :github_heroku do
  feed = Feedzirra::Feed.fetch_and_parse(env!("GITHUB_HEROKU_URL"))
  feed.entries.map do |entry|
    { title: entry.title, content: entry.content, tag: entry.id,
      url: entry.url, published_at: entry.published }
  end
end
