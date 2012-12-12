class Qbxml::Hash < ::Hash
  CONTENT_ROOT = '__content__'.freeze
  
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

  def self.from_xml(data, opts = {})
    doc = Nokogiri::XML(data)
    self.from_hash(xml_to_hash(doc.root), opts)
  end

private

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/conversions.rb
  #
  def hash_to_xml(opts = {})
    opts = opts.dup
    opts[:indent]          ||= 2
    opts[:root]            ||= :hash
    opts[:directive]       ||= [:xml, {}]
    opts[:attributes]      ||= self.delete('xml_attributes') || {} 
    opts[:builder]         ||= Builder::XmlMarkup.new(indent: opts[:indent])
    opts[:skip_types]      = true unless opts.key?(:skip_types) 
    builder = opts[:builder]

    unless opts.delete(:skip_instruct)
      builder.instruct!(opts[:directive].first, opts[:directive].last)
    end

    builder.tag!(opts[:root], opts.delete(:attributes)) do
      self.each do |key, val| 
        case val
        when Hash
          val.to_xml(opts.merge({root: key, skip_instruct: true}))
        else
          builder.tag!(key, val, {})
        end
      end

      yield builder if block_given?
    end
  end

  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/xml_mini/nokogiri.rb
  #
  def self.xml_to_hash(node, hash = {})
    node_hash = {}
    name = node.name

    # Insert node hash into parent hash correctly.
    case hash[name]
    when Array then hash[name] << node_hash
    when Hash  then hash[name] = [hash[name], node_hash]
    when nil   then hash[name] = node_hash
    else hash[name] = Array(hash[name])
    end

    # Handle child elements
    node.children.each do |c|
      if c.element?
        hash[name] = node_hash
        xml_to_hash(c, node_hash)
      elsif c.text? || c.cdata?
        node_hash[CONTENT_ROOT] ||= ''
        node_hash[CONTENT_ROOT] << c.content
      end
    end

    # Handle attributes
    node_hash['xml_attributes'] = {}
    node.attribute_nodes.each { |a| node_hash['xml_attributes'][a.node_name] = a.value }

    # Remove content node if it is blank and there are child tags
    if node_hash.length > 1 && node_hash[CONTENT_ROOT].strip.blank?
      node_hash.delete(CONTENT_ROOT)
    elsif node_hash.length == 2 && node_hash.include?(CONTENT_ROOT) && node_hash['xml_attributes'].empty?
      hash[name] = node_hash[CONTENT_ROOT]
    end


    hash
  end

private

  def self.deep_convert(hash, opts = {}, &block)
    ignored_keys = opts[:ignore] || ['xml_attributes']
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
