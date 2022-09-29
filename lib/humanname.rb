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

  class UnsupportedPlatform < StandardError
    def initialize
      platform = Gem::Platform.local
      super("Unsupported platform: #{platform.os}-#{platform.cpu}")
    end
  end

  module Native
    extend FFI::Library

    def self.init!
      path = native_lib_path
      if File.exist?(path)
        ffi_lib path
      else
        raise UnsupportedPlatform.new
      end

      attach_function :human_name_parse, [:string], :pointer
      attach_function :human_name_consistent_with, [:pointer, :pointer], :bool
      attach_function :human_name_hash, [:pointer], :uint64

      NAME_PARTS.each do |part|
        attach_function "human_name_#{part}".to_sym, [:pointer], :pointer
      end

      attach_function :human_name_matches_slug_or_localpart, [:pointer, :string], :bool
      attach_function :human_name_goes_by_middle_name, [:pointer], :bool
      attach_function :human_name_byte_len, [:pointer], :uint32

      attach_function :human_name_free_name, [:pointer], :void
      attach_function :human_name_free_string, [:pointer], :void
    end

    def self.native_lib_path
      platform = Gem::Platform.local

      filename = case platform.os
        when 'darwin'
          'libhuman_name.dylib'
        when 'linux'
          'libhuman_name.so'
        when /mswin|mingw/
          'human_name.dll'
        else
          raise UnsupportedPlatform.new
        end

      cpu = platform.cpu
      cpu = 'x86_64' if cpu == 'x64'

      File.expand_path(
        File.join('../native/', cpu, filename),
        __FILE__,
      )
    end
  end

  Native.init!
  private_constant :Native

  class NativeString < String
    DESTRUCTOR = Native.method(:human_name_free_string)

    def self.wrap(pointer)
      new(pointer) unless pointer.null?
    end

    def initialize(pointer)
      @pointer = FFI::AutoPointer.new(pointer, DESTRUCTOR)
      super(@pointer.read_string.force_encoding(UTF8))
    end
  end

  private_constant :NativeString

  class Name < FFI::AutoPointer
    DESTRUCTOR = Native.method(:human_name_free_name)

    def self.parse(string)
      string = string.encode(UTF8) unless string.encoding == UTF8
      pointer = Native.human_name_parse(string)
      new(pointer) unless pointer.null?
    end

    def initialize(pointer)
      super(pointer, DESTRUCTOR)
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

    def matches_slug_or_localpart(string)
      string = string.encode(UTF8) unless string.encoding == UTF8
      Native.human_name_matches_slug_or_localpart(self, string)
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

    def inspect
      "HumanName::Name(#{display_full})"
    end

  end

  def self.parse(string)
    Name.parse(string)
  end
end
