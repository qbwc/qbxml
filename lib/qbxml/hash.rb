class Qbxml::Hash < ::Hash
  CONTENT_ROOT = '__content__'.freeze
  ATTR_ROOT    = 'xml_attributes'.freeze
  
  def self.from_hash(hash, opts = {}, &block)
    if opts[:camelize]
      deep_convert(hash, opts) { |k| k.camelize } 
    elsif opts[:underscore]
      deep_convert(hash, opts) { |k| k.underscore } 
    else
      deep_convert(hash, opts, &block)
    end
  end

  def to_xml(opts = {})
    hash_to_xml(opts)
  end

  def self.from_xml(schema, data, opts = {})
    doc = Nokogiri::XML(data)
    self.from_hash(xml_to_hash(schema, doc.root), opts)
  end

private

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/conversions.rb
  #
  def hash_to_xml(opts = {})
    opts = opts.dup
    opts[:indent]          ||= 2
    opts[:root]            ||= :hash
    opts[:directive]       ||= [:xml, {}]
    opts[:attributes]      ||= self.delete(ATTR_ROOT) || {} 
    opts[:builder]         ||= Builder::XmlMarkup.new(indent: opts[:indent])
    opts[:skip_types]      = true unless opts.key?(:skip_types) 
    opts[:skip_instruct]   = true unless opts.key?(:skip_instruct)
    builder = opts[:builder]

    unless opts.delete(:skip_instruct)
      builder.instruct!(opts[:directive].first, opts[:directive].last)
    end

    builder.tag!(opts[:root], opts.delete(:attributes)) do
      self.each do |key, val| 
        case val
        when Hash
          val.to_xml(opts.merge({root: key, skip_instruct: true}))
        when Array
          val.map { |i| i.to_xml(opts.merge({root: key, skip_instruct: true})) }
        else
          builder.tag!(key, val, {})
        end
      end

      yield builder if block_given?
    end
  end

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/xml_mini/nokogiri.rb
  #
  def self.xml_to_hash(schema, node, hash = {})
    node_hash = {CONTENT_ROOT => '', ATTR_ROOT => {}}
    name = node.name

    # Insert node hash into parent hash correctly.
    case hash[name]
    when Array then hash[name] << node_hash
    when Hash  then hash[name] = [hash[name], node_hash]
    else hash[name] = node_hash
    end

    # Handle child elements
    node.children.each do |c|
      if c.element?
        xml_to_hash(schema, c, node_hash)
      elsif c.text? || c.cdata?
        node_hash[CONTENT_ROOT] << c.content
      end
    end

    # Handle attributes
    node.attribute_nodes.each { |a| node_hash[ATTR_ROOT][a.node_name] = a.value }

    # TODO: Strip text
    # node_hash[CONTENT_ROOT].strip!

    # Format nodes
    if node_hash.size > 2 || node_hash[ATTR_ROOT].present?
      node_hash.delete(CONTENT_ROOT)
    elsif node_hash[CONTENT_ROOT].present?
      node_hash.delete(ATTR_ROOT)
      type_path = node.path.gsub(/\[\d+\]/,'')
      type_proc = Qbxml::TYPE_MAP[schema.xpath(type_path).first.try(:text)]
      raise "#{node.path} is not a valid type" unless type_proc
      hash[name] = type_proc[node_hash[CONTENT_ROOT]]
    else
      hash[name] = node_hash[CONTENT_ROOT]
    end
    binding.pry if name == "PoNumber"

    hash
  end

private

  def self.deep_convert(hash, opts = {}, &block)
    ignored_keys = opts[:ignore] || [ATTR_ROOT]
    hash.inject(self.new) do |h, (k,v)|
     ignored_key = ignored_keys.include?(k) 
      h[(block_given? && !ignored_key) ? yield(k.to_s) : k] = \
        ignored_key ? v :
          case v
          when Hash
            deep_convert(v, &block)
          when Array
            v.map { |i| i.is_a?(Hash) ? deep_convert(i, &block) : i }
          else v
          end; h
    end
  end

end
