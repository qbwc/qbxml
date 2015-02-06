class Qbxml
  include Types

  SCHEMA_PATH = File.expand_path('../../../schema', __FILE__)

  SCHEMAS = {
    qb: {
      "2.0" => "#{SCHEMA_PATH}/qbxmlops20.xml",
      "CA3.0" => "#{SCHEMA_PATH}/qbxmlopsCA30.xml",
      "3.0" => "#{SCHEMA_PATH}/qbxmlops30.xml",
      "4.0" => "#{SCHEMA_PATH}/qbxmlops40.xml",
      "4.1" => "#{SCHEMA_PATH}/qbxmlops41.xml",
      "5.0" => "#{SCHEMA_PATH}/qbxmlops50.xml",
      "6.0" => "#{SCHEMA_PATH}/qbxmlops60.xml",
      "7.0" => "#{SCHEMA_PATH}/qbxmlops70.xml",
      "8.0" => "#{SCHEMA_PATH}/qbxmlops80.xml",
      "10.0" => "#{SCHEMA_PATH}/qbxmlops100.xml",
      "11.0" => "#{SCHEMA_PATH}/qbxmlops110.xml",
      "12.0" => "#{SCHEMA_PATH}/qbxmlops120.xml",
      "13.0" => "#{SCHEMA_PATH}/qbxmlops130.xml"
    },
    qbpos: {
      "3.0" => "#{SCHEMA_PATH}/qbposxmlops30.xml"
    }
  }.freeze

  HIDE_IVARS = [:@doc].freeze

  def initialize(key = :qb, version = "7.0")
    @schema  = key
    @version = version
    @doc     = parse_schema(key, version)
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

    Qbxml::Hash.to_xml(hash, schema: XML_DIRECTIVES[@schema], version: @version)
  end

  # converts qbxml to a hash
  #
  def from_qbxml(xml, opts = {})
    hash = Qbxml::Hash.from_xml(xml, underscore: true, schema: @doc)

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

  def parse_schema(key, version)
    File.open(select_schema(key, version)) { |f| Nokogiri::XML(f) }
  end

  def select_schema(schema_key, version)
    # Try to handle it if a user gave us a numeric version. Assume 1 decimal.
    version = '%.1f' % version if version.is_a?(Numeric)
    raise "invalid schema '#{schema_key}', must be one of #{SCHEMAS.keys.inspect}" if !SCHEMAS.has_key?(schema_key)
    raise "invalid version '#{version}' for schema #{schema_key}, must be one of #{SCHEMAS[schema_key].keys.inspect}" if !SCHEMAS[schema_key].has_key?(version)
    return SCHEMAS[schema_key][version]
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
      next if k == Qbxml::Hash::ATTR_ROOT
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
