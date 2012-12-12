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

  def to_qbxml(h, opts = {})
    qbxml_hash = 
      unless opts[:skip_namespace]
        
      else h
      end
    XmlHash[h].to_xml(opts)
  end

  def from_qbxml(xml)
    XmlHash.to_hash(xml)
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

end
