require 'rexml/xpath'

module FromNode
  def self.included(klass)
    klass.class_eval {
      class << self
        attr :xpath_attr_mapping
        attr :xpath_namespaces_mapping
      end
      @xpath_attr_mapping = {}
      @xpath_namespaces = {}

      alias_method :init_pre_from_node, :initialize
      def initialize(node, *args)
        init_pre_from_node(*args)
        @node = node

        namespaces = self.class.xpath_namespaces_mapping
        self.class.xpath_attr_mapping.each do |k, n|
          type, xpath, block = n
          case type
          when :attr
            v = REXML::XPath.first(@node, xpath, namespaces)
            send("#{k.to_s}=".to_sym, block[v, namespaces])
          when :attrlist
            send("#{k.to_s}=".to_sym, [])
            REXML::XPath.each(@node, xpath, namespaces) do |v|
              send(k) << block[v, namespaces]
            end
          when :attrhash
            send("#{k.to_s}=".to_sym, {})
            REXML::XPath.each(@node, xpath, namespaces) do |v|
              key, val = block[v, namespaces]
              send(k)[key] = val
            end
          end
        end
      end
    }

    def klass.xpath_attr(name, xpath=nil, &block)
      attr_accessor name
      xpath = "@#{name.to_s}" if xpath.nil?
      block = Proc.new { |v,| v.to_s unless v.nil? } unless block_given?
      @xpath_attr_mapping[name] = [:attr, xpath, block]
    end

    def klass.xpath_attr_list(name, xpath=nil, &block)
      attr_accessor name
      xpath = "#{name.to_s}/text()" if xpath.nil?
      block = Proc.new { |v,| v.to_s } unless block_given?
      @xpath_attr_mapping[name] = [:attrlist, xpath, block]
    end

    def klass.xpath_attr_hash(name, xpath=nil, key_xpath=nil, val_xpath=nil,
                              &block)
      attr_accessor name
      xpath = name.to_s if xpath.nil?
      unless block_given?
        block = Proc.new { |v, n|
          key = REXML::XPath.first(v, key_xpath, n).to_s
          val = REXML::XPath.first(v, val_xpath, n).to_s
          [key, val]
        }
      end
      @xpath_attr_mapping[name] = [:attrhash, xpath, block]
    end

    def klass.xpath_child(name, xpath, clazz)
      xpath_attr(name, xpath) { |v,| clazz.new(v) unless v.nil? }
    end

    def klass.xpath_child_list(name, xpath, clazz)
      xpath_attr_list(name, xpath) { |v,| clazz.new(v) }
    end

    def klass.xpath_child_hash(name, xpath, key_xpath, val_xpath, clazz)
      xpath_attr_hash(name, xpath, key_xpath, val_xpath) { |v, n|
        key = REXML::XPath.first(v, key_xpath, n).to_s
        val = clazz.new(REXML::XPath.first(v, val_xpath, n))
        [key, val]
      }
    end

    def klass.xpath_namespaces(namespaces)
      @xpath_namespaces_mapping = namespaces
    end
  end
end
