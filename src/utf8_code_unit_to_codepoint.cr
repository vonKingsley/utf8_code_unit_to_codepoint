require "./utf8_code_unit_to_codepoint/*"

module Utf8CodeUnitToCodepoint
  class InvalidHexException < Exception; end

  class Converter

    @binary_list = [] of String
    @codepoints  = [] of String
    @code_unit   = [] of String

    getter binary_list
    getter code_unit
    getter codepoints

    def initialize(@hex_code_units : Array(String))
      raise InvalidHexException.new if @hex_code_units.any? { |cu| cu =~ /[^[:xdigit:]]/ }
      @binary_list = hex_to_binary
      @codepoint_size = 0
    end

    def hex_to_binary
      bin_array = [] of String
      @hex_code_units.each do |unit|
        to_binary_string(unit).scan(/.{4}/).map do |data|
          data[0]
        end.each_slice(2) do |slice|
          bin_array << slice.join
        end
      end
      bin_array
    end

    def codepoint_size(first_byte)
      cps = first_byte[/^1*/].size
      @codepoint_size = (cps == 0 ? 1 : cps)
    end

    def all_code_units
      split_code_units = [] of Array(String)
      while !@binary_list.empty?
        split_code_units << code_unit
      end
      split_code_units
    end

    def code_unit
      current_code_unit = [] of String
      if @codepoint_size == 0 && !@binary_list.empty?
        codepoint_size(@binary_list.first)
      end
      @codepoint_size.times do
        current_code_unit << @binary_list.shift
      end
      @codepoint_size = 0
      @code_unit = current_code_unit
    end

    def all_codepoints
      codepoints_list = [] of String
      all_code_units.each do |cu|
        codepoints_list << codepoint(utf8_chop_shop(cu))
      end
      codepoints_list
    end

    def codepoint(utf8_converted)
      ("%02x" % utf8_converted.to_i(2)).rjust(4, '0')
    end

    def utf8_chop_shop(code_unit)
      #TODO raise if size ==1 and does not start with 0
      return code_unit.first if code_unit.size == 1
      cu_map = code_unit.map do |cu|
        cu.sub(/^1*0/) {""}
      end
      cu_map.join
    end

    private def to_binary_string(char)
      c = char.to_i(16).to_s(2)
      c.rjust(8,'0')
    end

  end

  def self.convert(hex_arr)
    convert = Converter.new(hex_arr)
    convert.all_codepoints.join(",")
  end
end

unless ARGV.empty?
  puts Utf8CodeUnitToCodepoint.convert(ARGV)
end

