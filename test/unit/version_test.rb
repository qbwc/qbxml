require 'minitest/autorun'
require 'qbxml'

class VersionTest < Minitest::Test

  def test_string_version
    Qbxml.new(:qb, '7.0')
  end

  def test_bad_version
    assert_raises RuntimeError do
      Qbxml.new(:qb, '3.14')
    end
  end

  def test_float_version
    Qbxml.new(:qb, 7.0)
  end

  def test_int_version
    Qbxml.new(:qb, 7)
  end

end
