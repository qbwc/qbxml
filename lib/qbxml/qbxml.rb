class Qbxml

  SCHEMAS = {
    qb:    'xml_schema/qbxmlops70.xml',
    qbpos: 'xml_schema/qbposxmlops30.xml' 
  }

  HIDE_IVARS = [:@doc]
  
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
    hash = namespace_qbxml_hash(hash) unless opts[:no_napespace]
    inner_xml = XmlHash.to_xml(hash, opts)
  end

  def from_qbxml(xml, opts = {})
    inner_hash = XmlHash.to_hash(xml, opts)
    opts[:no_namespace] ? inner_hash : namespace_qbxml_hash(inner_hash)
  end

  def validate
    
  end

  def inspect
    prefix = "#<#{self.class}:0x#{self.__id__.to_s(16)} "

    (instance_variables - HIDE_IVARS).each do |var|
      prefix << "#{var}=#{instance_variable_get(var).inspect}"
    end

    return "#{prefix}>"
  end

private

  def parse_schema(key)
    File.open(select_schema(key)) { |f| Nokogiri::XML(f) }
  end

  def select_schema(schema_key)
    SCHEMAS[schema_key] || raise("invalid schema, must be one of #{SCHEMA.keys.inspect}")
  end

  def namespace_qbxml_hash(hash)
    root_key = hash.keys.first
    node = describe(root_key) 
    while parent = node.parent
      hash = XmlHash[parent.name => hash]
    end
  end

end
