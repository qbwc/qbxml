class Qbxml::Hash < ::Hash
  CONTENT_ROOT = '__content__'.freeze
  
  def to_xml(opts = {})
    self.class.to_xml(self, opts)
  end

  def camelize
    transform_keys { |k| k.camelize }
  end

  def underscore
    transform_keys { |k| k.underscore}
  end

  def self.to_xml(hash, opts = {})
    hash_to_xml(hash, opts)
  end

  def self.to_hash(data, opts = {})
    doc = Nokogiri::XML(data)
    xml_to_hash(doc.root, opts)
  end

private

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/xml_mini/nokogiri.rb
  #
  def self.xml_to_hash(node, hash = {})
    node_hash = {}

    # Insert node hash into parent hash correctly.
    case hash[name]
      when Array then hash[name] << node_hash
      when Hash  then hash[name] = [hash[name], node_hash]
      when nil   then hash[name] = node_hash
    end

    # Handle child elements
    node.children.each do |c|
      if c.element?
        to_hash(c, node_hash)
      elsif c.text? || c.cdata?
        node_hash[CONTENT_ROOT] ||= ''
        node_hash[CONTENT_ROOT] << c.content
      end
    end

    # Remove content node if it is blank and there are child tags
    if node_hash.length > 1 && node_hash[CONTENT_ROOT].blank?
      node_hash.delete(CONTENT_ROOT)
    end

    # Handle attributes
    node.attribute_nodes.each { |a| node_hash[a.node_name] = a.value }

    hash
  end

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/conversions.rb
  #
  def self.hash_to_xml(hash, options = {})
    options = options.dup
    options[:indent]          ||= 2
    options[:root]            ||= :hash
    options[:builder]         ||= Builder::XmlMarkup.new(indent: options[:indent])
    options[:wrapped]         = true unless options.key?(:wrapped)
    options[:skip_types]      = true unless options.key?(:skip_types) 
    options[:skip_instruct]   = true unless options.key?(:skip_instruct) 

    if options[:wrapped]
      name, content = hash.first
      options[:root] = name
      hash = content
    end

    builder = options[:builder]
    builder.instruct! unless options.delete(:skip_instruct)

    root = ActiveSupport::XmlMini.rename_key(options[:root].to_s, options)
    xml_attributes = hash.delete(:xml_attributes) || {}

    builder.tag!(root, xml_attributes) do
      hash.each do |key, val| 
        val = (val.is_a?(Hash) ? XmlHash[val].camelize : val)
        ActiveSupport::XmlMini.to_tag(key, val, options)
      end

      yield builder if block_given?
    end
  end

protected

  def transform_keys(&block)
    return unless block_given?

    self.inject({}) do |h, (k,v)|
      h[yield k.to_s] = \
        case v
        when Hash
          v.transform_keys(&block)
        when Array
          v.map { |i| i.is_a?(Hash) ? i.transform_keys(&block): i }
        else v
        end; h
    end
  end

end
