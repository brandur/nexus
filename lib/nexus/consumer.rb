require "timeout"

module Nexus
  class Consumer
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

    def process_sources
      events = []
      @context.sources.each do |source|
        begin
          Timeout.timeout(10) do
            events += source[:block].call.map do |event|
              event[:source] = source[:name].to_s
              event
            end
          end
        rescue
          Slides.log :error, message: $!.message, backtrace: $!.backtrace
        end
      end
      events.sort_by! { |e| e[:published_at] }
      events.each do |event|
        unless Event.first(tag: event[:tag])
          event.save
          event.log
        end
      end
    end
  end
end
