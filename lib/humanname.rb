require 'helix_runtime'
require 'humanname/version'
require 'humanname/native'

module HumanName
  Name = RustHumanName

  UTF8 = 'UTF-8'.freeze

  class Name
    def self.parse(string)
      string = string.encode(UTF8) unless string.encoding == UTF8
      parse_utf8(string)
    end

    def matches_slug_or_localpart(string)
      string = string.encode(UTF8) unless string.encoding == UTF8
      matches_slug_or_localpart_utf8(string)
    end

    JSON_PARTS = %w( surname given_name first_initial middle_initials middle_names suffix ).map(&:to_sym)

    def as_json(options = {})
      # We take an "options" argument for minimal compatibility with ActiveSupport,
      # but don't actually respect it
      [:root, :only, :except, :include].each do |opt|
        raise ArgumentError.new("Unsupported option: #{opt}") if options[opt]
      end

      to_h
    end

    def to_h
      JSON_PARTS.inject({}) do |memo, part|
        memo[part] = send(part)
        memo
      end
    end
  end

  def self.parse(string)
    Name.parse(string)
  end
end
