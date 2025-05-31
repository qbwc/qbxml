require 'bigdecimal'

module Qbxml::Types

  XML_DIRECTIVES = {
    :qb => :qbxml,
    :qbpos => :qbposxml
  }.freeze

  FLOAT_CAST = Proc.new {|d| d ? d.to_f : 0.0}
  BOOL_CAST  = Proc.new {|d| d ? (d.to_s.downcase == 'true' ? true : false) : false }
  DATE_CAST  = Proc.new {|d| d ? Date.parse(d).strftime("%Y-%m-%d") : Date.today.strftime("%Y-%m-%d") }
  TIME_CAST  = Proc.new {|d| d ? Time.parse(d).xmlschema : Time.now.xmlschema }
  INT_CAST   = Proc.new {|d| d ? Integer(d.to_i) : 0 }
  STR_CAST   = Proc.new {|d| d ? String(d) : ''}
  BIGDECIMAL_CAST = Proc.new {|d| d ? BigDecimal(d) : 0.0}

  TYPE_MAP= {
    "AMTTYPE"          => FLOAT_CAST,
    "BOOLTYPE"         => BOOL_CAST,
    "DATETIMETYPE"     => TIME_CAST,
    "DATETYPE"         => DATE_CAST,
    "ENUMTYPE"         => STR_CAST,
    "FLOATTYPE"        => FLOAT_CAST,
    "GUIDTYPE"         => STR_CAST,
    "IDTYPE"           => STR_CAST,
    "INTTYPE"          => INT_CAST,
    "PERCENTTYPE"      => FLOAT_CAST,
    "PRICETYPE"        => FLOAT_CAST,
    "QUANTYPE"         => BIGDECIMAL_CAST,
    "STRTYPE"          => STR_CAST,
    "TIMEINTERVALTYPE" => STR_CAST
  }

  # Strings in tag names that should be capitalized in QB's XML
  ACRONYMS = ['AP', 'AR', 'COGS', 'COM', 'UOM', 'QBXML', 'UI', 'AVS', 'ID',
              'PIN', 'SSN', 'COM', 'CLSID', 'FOB', 'EIN', 'UOM', 'PO', 'PIN', 'QB']

  # Based on the regexp in ActiveSupport::Inflector.camelize
  # Substring 1: Start of string, lower case letter, or slash
  # Substring 2: One of the acronyms above, In Capitalized Casing
  # Substring 3: End of string or capital letter
  ACRONYM_REGEXP = Regexp.new("(?:(^|[a-z]|\\/))(#{ACRONYMS.map{|a| a.capitalize}.join("|")})([A-Z]|$)")

end
