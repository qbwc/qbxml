class Qbxml
  include Types

  SCHEMA_PATH = File.expand_path('../../../schema', __FILE__)

  SCHEMAS = {
    qb:    "#{SCHEMA_PATH}/qbxmlops70.xml",
    qbpos: "#{SCHEMA_PATH}/qbposxmlops30.xml" 
  }.freeze

  HIDE_IVARS = [:@doc].freeze

  def initialize(key = :qb)
    @schema = key
    @doc    = parse_schema(key)
  end

  # returns all xml nodes matching a specified pattern
  #
  def types(pattern = nil)
    @types ||= @doc.xpath("//*").map { |e| e.name }.uniq

    pattern ?
      @types.select { |t| t =~ Regexp.new(pattern) } :
      @types
  end

  # returns the xml node for the specified type
  #
  def describe(type)
    @doc.xpath("//#{type}").first
  end

  # converts a hash to qbxml with optional validation
  #
  def to_qbxml(hash, opts = {})
    hash = Qbxml::Hash.from_hash(hash, camelize: true)
    hash = namespace_qbxml_hash(hash) unless opts[:no_namespace] 
    validate_qbxml_hash(hash) if opts[:validate]

    Qbxml::Hash.to_xml(hash, xml_directive: XML_DIRECTIVES[@schema])
  end

  # converts qbxml to a hash
  #
  def from_qbxml(xml, opts = {})
    hash = Qbxml::Hash.from_xml(@doc, xml, underscore: true)

    opts[:no_namespace] ? hash : namespace_qbxml_hash(hash)
  end

  # making this more sane so that it doesn't dump the whole schema doc to stdout
  # every time
  #
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
      next if k == Qbxml::HASH::ATTR_ROOT
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
