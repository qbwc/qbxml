class Qbxml::Hash < ::Hash
  include Qbxml::Types

  CONTENT_ROOT = '__content__'.freeze
  ATTR_ROOT    = 'xml_attributes'.freeze
  
  def self.from_hash(hash, opts = {}, &block)
    key_proc = \
      if opts[:camelize]
        lambda { |k| k.camelize } 
      elsif opts[:underscore]
        lambda { |k| k.underscore } 
      end

    deep_convert(hash, opts, &key_proc)
  end

  def to_xml(opts = {})
    hash = self.hash_to_xml(self, opts)
  end

  def self.to_xml(hash, opts = {})
    opts[:root], hash = self.first
    opts[:attributes] = self.delete(ATTR_ROOT)
    hash_to_xml(hash, opts)
  end

  def self.from_xml(schema, data, opts = {})
    doc = Nokogiri::XML(data)
    from_hash(xml_to_hash(schema, doc.root), opts)
  end

private

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/conversions.rb
  #
  def self.hash_to_xml(hash, opts)
    opts = opts.dup
    opts[:indent]          ||= 2
    opts[:root]            ||= :hash
    opts[:attributes]      ||= {} 
    opts[:xml_directive]   ||= [:xml, {}]
    opts[:builder]         ||= Builder::XmlMarkup.new(indent: opts[:indent])
    opts[:skip_types]      = true unless opts.key?(:skip_types) 
    opts[:skip_instruct]   = false unless opts.key?(:skip_instruct)
    builder = opts[:builder]
    
    unless opts.delete(:skip_instruct)
      builder.instruct!(opts[:xml_directive].first, opts[:directive].last)
    end

    builder.tag!(opts[:root], opts.delete(:attributes)) do
      hash.each do |key, val| 
        case val
        when Hash
          self.hash_to_xml(val, opts.merge({root: key, skip_instruct: true}))
        when Array
          val.map { |i| self.hash_to_xml(i, opts.merge({root: key, skip_instruct: true})) }
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

    # Format node
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

    hash
  end

private

  def self.deep_convert(hash, opts = {}, &block)
    ignored_keys = opts[:ignore] || [ATTR_ROOT]

    hash.inject(self.new) do |h, (k,v)|
      ignored = ignored_keys.include?(k) 
      if ignored
        h[k] = v
      else
        key = block_given? ? yield(k.to_s) : k
        h[key] = \
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

end
