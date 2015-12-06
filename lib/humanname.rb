require 'ffi'
require 'humanname/version'

module HumanName
  UTF8 = 'UTF-8'.freeze
  NAME_PARTS = %w(
    surname
    given_name
    initials
    first_initial
    middle_initials
    middle_names
    suffix
    display_first_last
    display_full
    display_initial_surname
  ).freeze

  module Native
    extend FFI::Library

    extension = RUBY_PLATFORM =~ /darwin|mac os/i ? 'dylib' : 'so'
    ffi_lib File.expand_path("../libhuman_name.#{extension}", __FILE__)

    attach_function :human_name_parse, [:string], :pointer
    attach_function :human_name_consistent_with, [:pointer, :pointer], :bool
    attach_function :human_name_hash, [:pointer], :uint64

    NAME_PARTS.each do |part|
      attach_function "human_name_#{part}".to_sym, [:pointer], :pointer
    end

    attach_function :human_name_goes_by_middle_name, [:pointer], :bool
    attach_function :human_name_byte_len, [:pointer], :uint32

    attach_function :human_name_free_name, [:pointer], :void
    attach_function :human_name_free_string, [:pointer], :void
  end

  class NativeString < String
    def self.wrap(pointer)
      new(pointer) unless pointer.null?
    end

    def initialize(pointer)
      @pointer = FFI::AutoPointer.new(pointer, Native.method(:human_name_free_string))
      super(@pointer.read_string.force_encoding(UTF8))
    end
  end

  class Name < FFI::AutoPointer
    def self.parse(string)
      string = string.encode(UTF8) unless string.encoding == UTF8
      pointer = Native.human_name_parse(string)
      new(pointer) unless pointer.null?
    end

    def initialize(pointer)
      super(pointer, Native.method(:human_name_free_name))
    end

    def ==(other)
      other.is_a?(Name) && Native.human_name_consistent_with(self, other)
    end
    alias_method :eql?, :==

    def hash
      Native.human_name_hash(self)
    end

    NAME_PARTS.each do |part|
      native_method = "human_name_#{part}".to_sym

      define_method part do
        pointer = Native.send(native_method, self)
        NativeString.wrap(pointer)
      end
    end

    def goes_by_middle_name
      Native.human_name_goes_by_middle_name(self)
    end

    def length
      Native.human_name_byte_len(self)
    end

    JSON_PARTS = %w( surname given_name first_initial middle_initials middle_names suffix ).map(&:to_sym)

    def as_json(options = {})
      # We take an "options" argument for minimal compatibility with ActiveSupport,
      # but don't actually respect it
      %i( root only except include ).each do |opt|
        raise ArgumentError.new("Unsupported option: #{opt}") if options[opt]
      end

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
