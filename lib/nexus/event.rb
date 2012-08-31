require "time"

class Event < Sequel::Model
  include Term::ANSIColor

  def log
    Slides.log(:event, {
      title: title ? bold { cyan { title } } : nil,
      content: content ? green { sanitize(content) } : nil,
      url: url,
      tag: tag,
      published_at: published_at,
      source: source
    }.merge(metadata ? metadata : {}))
  end

  def to_json_v1
    {
      title: title,
      content: content ? sanitize(content) : nil,
      url: url,
      tag: tag,
      published_at: published_at.iso8601,
      source: source,
      metadata: metadata ? metadata.hash : {}
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
