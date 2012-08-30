require "timeout"

module Nexus
  class Consumer
    include Term::ANSIColor

    def initialize(context)
      @context = context
    end

    def run
      loop do
        process_sources
        sleep(60)
      end
    end

    private

    def find_or_insert_source(name)
      sources = DB[:sources]
      sources.first(name: name) ||
        sources.insert(name: name) and sources.first(name: name)
    end

    def log(opts={})
      Slides.log(:event, opts)
    end

    def process_sources
      events = []
      @context.sources.each do |source|
        begin
          Timeout.timeout(10) do
            events += source[:block].call.map do |event|
              event[:source] = find_or_insert_source(source[:name].to_s)
              event
            end
          end
        rescue
          Slides.log :error, message: $!.message, backtrace: $!.backtrace
        end
      end
      events.sort_by! { |e| e[:published_at] }
      events.each do |event|
        unless DB[:events].first(tag: event[:tag])
          DB[:events].insert(tag: event[:tag], title: event[:title],
            url: event[:url], content: event[:content],
            source_id: event[:source][:id], published_at: event[:published_at],
            metadata: event[:metadata] ? event[:metadata].hstore : nil)
          log({ title: event[:title] ? bold { cyan { event[:title] } } : nil,
            content: event[:content] ? green { sanitize(event[:content]) } : nil,
            url: event[:url], tag: event[:tag],
            published_at: event[:published_at], source: event[:source][:name] }.
            merge(event[:metadata] ? event[:metadata] : {}))
        end
      end
    end

    def sanitize(content)
      content = content.gsub(%r{</?[^>]+?>}, '').
        gsub(%r{\w+ \d{1,2}, \d{4}}, '').gsub(%r{\n+}, ' ').
        gsub(%r{\s+}, ' ').strip
      HTMLEntities.new.decode(content)
    end
  end
end
