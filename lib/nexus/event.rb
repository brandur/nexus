require "time"

class Event < Sequel::Model
  include Term::ANSIColor

  def log
    Slides.log(:event, to_json_v1)
  end

  def to_json_v1
    {
      id: id,
      title: title,
      content: content ? sanitize(content) : nil,
      url: url,
      tag: tag,
      published_at: published_at.iso8601,
      source: source,
      metadata: metadata ? metadata.to_hash : {}
    }
  end

  private

  def sanitize(content)
    content = content.gsub(%r{</?[^>]+?>}, '').
      gsub(%r{\w+ \d{1,2}, \d{4}}, '').gsub(%r{\n+}, ' ').
      gsub(%r{\s+}, ' ').strip
    HTMLEntities.new.decode(content)
  end
end
