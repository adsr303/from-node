require 'rexml/xpath'

module FromNode
  def self.included(klass)
    klass.class_eval {
      @xpath_attr_mapping = {}
      @xpath_attr_list_mapping = {}
      @xpath_child_mapping = {}
      @xpath_child_list_mapping = {}

      alias_method :init_pre_from_node, :initialize
      def initialize(*args)
        @node = args.shift
        init_pre_from_node(*args)

        self.class.xpath_attr_mapping.each do |k, n|
          send(k, REXML::XPath.first(@node, *n).to_s)
        end

        self.class.xpath_attr_list_mapping.each do |k, n|
          send("#{k.to_s}=".to_sym, [])
          REXML::XPath.each(@node, *n) do |v|
            send(k) << v.to_s
          end
        end

        self.class.xpath_child_mapping.each do |k, n|
          xpath, clazz, namespaces = n
          send(k, clazz.new(REXML::XPath.first(@node, xpath, namespaces)))
        end

        self.class.xpath_child_list_mapping.each do |k, n|
          send("#{k.to_s}=".to_sym, [])
          xpath, clazz, namespaces = n
          REXML::XPath.each(@node, xpath, namespaces) do |v|
            send(k) << clazz.new(v)
          end
        end
      end
    }

    def klass.xpath_attr(name, xpath=nil, namespaces={})
      attr_accessor name
      xpath = "@#{name.to_s}" if xpath.nil?
      @xpath_attr_mapping["#{name.to_s}=".to_sym] = [xpath, namespaces]
    end

    def klass.xpath_attr_list(name, xpath, namespaces={})
      attr_accessor name
      @xpath_attr_list_mapping[name] = [xpath, namespaces]
    end

    def klass.xpath_child(name, xpath, clazz, namespaces={})
      attr_accessor name
      @xpath_child_mapping["#{name.to_s}=".to_sym] =
        [xpath, clazz, namespaces]
    end

    def klass.xpath_child_list(name, xpath, clazz, namespaces={})
      attr_accessor name
      @xpath_child_list_mapping[name] = [xpath, clazz, namespaces]
    end

    def klass.xpath_attr_mapping
      @xpath_attr_mapping
    end

    def klass.xpath_attr_list_mapping
      @xpath_attr_list_mapping
    end

    def klass.xpath_child_mapping
      @xpath_child_mapping
    end

    def klass.xpath_child_list_mapping
      @xpath_child_list_mapping
    end
  end
end
