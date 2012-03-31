require 'rexml/xpath'

module FromNode
  def self.included(klass)
    klass.class_eval {
      @xpath_attr_mapping = {}

      alias_method :init_pre_from_node, :initialize
      def initialize(*args)
        @node = args.shift
        init_pre_from_node(*args)

        self.class.xpath_attr_mapping.each do |k, n|
          type, xpath, namespaces, block = n
          case type
          when :attr
            send("#{k.to_s}=".to_sym,
                 block[REXML::XPath.first(@node, xpath, namespaces)])
          when :attrlist
            send("#{k.to_s}=".to_sym, [])
            REXML::XPath.each(@node, xpath, namespaces) do |v|
              send(k) << block[v]
            end
          when :attrhash
            send("#{k.to_s}=".to_sym, {})
            REXML::XPath.each(@node, xpath, namespaces) do |v|
              key, val = block[v]
              send(k)[key] = val
            end
          end
        end
      end
    }

    def klass.xpath_attr(name, xpath=nil, namespaces={}, &block)
      attr_accessor name
      xpath = "@#{name.to_s}" if xpath.nil?
      block = Proc.new {|v| v.to_s } unless block_given?
      @xpath_attr_mapping[name] = [:attr, xpath, namespaces, block]
    end

    def klass.xpath_attr_list(name, xpath=nil, namespaces={}, &block)
      attr_accessor name
      xpath = "#{name.to_s}/text()" if xpath.nil?
      block = Proc.new {|v| v.to_s } unless block_given?
      @xpath_attr_mapping[name] = [:attrlist, xpath, namespaces, block]
    end

    def klass.xpath_attr_hash(name, xpath=nil, key_xpath=nil, val_xpath=nil,
                              namespaces={}, &block)
      attr_accessor name
      xpath = "@#{name.to_s}" if xpath.nil?
      unless block_given?
        block = Proc.new {|v|
          key = REXML::XPath.first(v, key_xpath).to_s
          val = REXML::XPath.first(v, val_xpath).to_s
          [key, val]
        }
      end
      @xpath_attr_mapping[name] = [:attrhash, xpath, namespaces, block]
    end

    def klass.xpath_child(name, xpath, clazz, namespaces={})
      xpath_attr(name, xpath, namespaces) {|v| clazz.new(v) }
    end

    def klass.xpath_child_list(name, xpath, clazz, namespaces={})
      xpath_attr_list(name, xpath, namespaces) {|v| clazz.new(v) }
    end

    def klass.xpath_child_hash(name, xpath, key_xpath, val_xpath, clazz,
                               namespaces={})
      xpath_attr_hash(name, xpath, key_xpath, val_xpath, namespaces) {|v|
        key = REXML::XPath.first(v, key_xpath).to_s
        val = clazz.new(REXML::XPath.first(v, val_xpath))
        [key, val]
      }
    end

    def klass.xpath_attr_mapping
      @xpath_attr_mapping
    end
  end
end
