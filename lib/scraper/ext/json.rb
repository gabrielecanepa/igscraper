require "json"

module JSON
  class << self
    def parse_without_exceptions(json)
      JSON.parse(json)
    rescue JSON::ParserError
    end
  end
end
