class Qbxml
  SCHEMA_PATH = File.expand_path('../../../schema', __FILE__)

  SCHEMAS = {
    qb:    "#{SCHEMA_PATH}/qbxmlops70.xml",
    qbpos: "#{SCHEMA_PATH}/qbposxmlops30.xml" 
  }.freeze

  HIDE_IVARS = [:@doc].freeze

  DIRECTIVE_TAGS = { 
    :qb => [:qbxml, { version: '7.0' }],
    :qbpos => [:qbposxml, { version: '3.0' }]
  }.freeze

  FLOAT_CAST = Proc.new {|d| d ? Float(d) : 0.0}
  BOOL_CAST  = Proc.new {|d| d ? (d == 'True' ? true : false) : false }
  DATE_CAST  = Proc.new {|d| d ? Date.parse(d).strftime("%Y-%m-%d") : Date.today.strftime("%Y-%m-%d") }
  TIME_CAST  = Proc.new {|d| d ? Time.parse(d).xmlschema : Time.now.xmlschema }
  INT_CAST   = Proc.new {|d| d ? Integer(d.to_i) : 0 }
  STR_CAST   = Proc.new {|d| d ? String(d) : ''}

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
    "QUANTYPE"         => INT_CAST,
    "STRTYPE"          => STR_CAST,
    "TIMEINTERVALTYPE" => STR_CAST
  }

  ACRONYMS = ['AP', 'AR', 'COGS', 'COM', 'UOM', 'QBXML', 'UI', 'AVS', 'ID',
              'PIN', 'SSN', 'COM', 'CLSID', 'FOB', 'EIN', 'UOM', 'PO', 'PIN', 'QB']

  ActiveSupport::Inflector.inflections do |inflect|
    ACRONYMS.each { |a| inflect.acronym a }
  end

  def initialize(key = :qb)
    @schema = key
    @doc    = parse_schema(key)
  end

  def types(pattern = nil)
    types = @doc.xpath("//*").map { |e| e.name }.uniq

    pattern ?
      types.select { |t| t =~ Regexp.new(pattern) } :
      types
  end

  def describe(type)
    @doc.xpath("//#{type}").first
  end

  def to_qbxml(hash, opts = {})
    hash = Qbxml::Hash.from_hash(hash, camelize: true)

    opts[:validate]      = false unless opts.key?(:validate) 
    opts[:add_namespace] = true  unless opts.key?(:add_namespace) 
    hash = namespace_qbxml_hash(hash) if opts[:add_namespace] 
    validate_qbxml_hash(hash) if opts[:validate]

    opts[:root] = hash.keys.first
    opts[:attributes] = hash.delete('xml_attributes')
    opts[:directive] = DIRECTIVE_TAGS[@schema]
    hash = hash.values.first

    hash.to_xml(opts)
  end

  def from_qbxml(xml, opts = {})
    inner_hash = Qbxml::Hash.from_xml(@doc, xml, underscore: true)

    if opts[:no_namespace] 
      inner_hash 
    else 
      namespace_qbxml_hash(inner_hash)
    end
  end

  def inspect
    prefix = "#<#{self.class}:0x#{self.__id__.to_s(16)} "

    (instance_variables - HIDE_IVARS).each do |var|
      prefix << "#{var}=#{instance_variable_get(var).inspect}"
    end

    return "#{prefix}>"
  end

# private

  def parse_schema(key)
    File.open(select_schema(key)) { |f| Nokogiri::XML(f) }
  end

  def select_schema(schema_key)
    SCHEMAS[schema_key] || raise("invalid schema, must be one of #{SCHEMA.keys.inspect}")
  end

# hash to qbxml

  def namespace_qbxml_hash(hash)
    node = describe(hash.keys.first)
    return hash unless node

    path = node.path.split('/')[1...-1].reverse
    path.inject(hash) { |h,p| Qbxml::Hash[ p => h ] }
  end

  def validate_qbxml_hash(hash, path = [])
    hash.each do |k,v|
      next if k == 'xml_attributes'
      key_path = path.dup << k
      if v.is_a?(Hash)
        validate_qbxml_hash(v, key_path)
      else
        validate_xpath(key_path)
      end
    end
  end

  def validate_xpath(path)
    xpath = "/#{path.join('/')}"
    raise "#{xpath} is not a valid type" if @doc.xpath(xpath).empty?
  end

end
