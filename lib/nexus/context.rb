module Nexus
  class Context
    attr_accessor :sources

    def initialize
      @sources = []
    end

    def source(name, &block)
      @sources << { name: name, block: block }
    end
  end
end
