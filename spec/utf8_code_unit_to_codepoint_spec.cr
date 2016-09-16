require "./spec_helper"

def converter
  Utf8CodeUnitToCodepoint::Converter.new(%w(e5 85 a8))
end

describe Utf8CodeUnitToCodepoint do

  it "rejects initialize if not a valid hex number" do
    expect_raises Utf8CodeUnitToCodepoint::InvalidHexException do
      Utf8CodeUnitToCodepoint::Converter.new(%w(e3 w5 65))
    end
    expect_raises Utf8CodeUnitToCodepoint::InvalidHexException do
      Utf8CodeUnitToCodepoint::Converter.new(%w(e3 d5 6s))
    end
  end

  it "converts to binary" do
    (converter.hex_to_binary).should eq ["11100101", "10000101", "10101000"]
  end

  it "determines number of bytes in codepoint" do
    (converter.codepoint_size("11100101")).should eq 3
    (converter.codepoint_size("11000101")).should eq 2
    (converter.codepoint_size("01100101")).should eq 1
  end

  it "returns the codeunit in split binary array" do
    con = Utf8CodeUnitToCodepoint::Converter.new(%w(e5 85 a8 68))
    (con.code_unit).should eq ["11100101", "10000101", "10101000"]
  end

  it "returns all code_units in binary" do
    con = Utf8CodeUnitToCodepoint::Converter.new(%w(e5 85 a8 68))
    (con.all_code_units).should eq [["11100101", "10000101", "10101000"],["01101000"]]
  end

  it "takes an array of binary code units, and returns a single String of the binary codepoint" do
    converter.utf8_chop_shop(["11100101", "10000101", "10101000"]).should eq "0101000101101000"
    converter.utf8_chop_shop(["01100101"]).should eq "01100101"
  end

  it "takes binary codepoint and returns hex codepoint" do
    converter.codepoint("0101000101101000").should eq "5168"
  end

  it "returns all codepoints" do
    con = Utf8CodeUnitToCodepoint::Converter.new(%w(e5 85 a8 68 e6 a3 32))
    con.all_codepoints.should eq ["5168","0068","d1b2"]
  end

  it "converts" do
    Utf8CodeUnitToCodepoint.convert(["e5", "85", "a8"]).should eq "5168"
  end
end
