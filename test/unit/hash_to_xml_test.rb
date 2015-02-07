require 'minitest/autorun'
require 'qbxml'

class VersionTest < Minitest::Test

  def test_hash_to_xml
    assert_equal "<foo>\n  <bar>baz</bar>\n</foo>\n", Qbxml::Hash.to_xml({:foo => {:bar => 'baz'}}, {skip_instruct: true})
  end

  def test_array_of_strings
    assert_equal "<foo>\n  <bar>baz</bar>\n  <bar>guh</bar>\n</foo>\n", Qbxml::Hash.to_xml({:foo => {:bar => ['baz', 'guh']}}, {skip_instruct: true})
  end

end
