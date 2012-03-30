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
          send(k, REXML::XPath.first(@node, n).to_s)
        end
      end
    }

    def klass.xpath_attr(name, xpath)
      attr_accessor name
      @xpath_attr_mapping["#{name.to_s}=".to_sym] = xpath
    end

    def klass.xpath_attr_mapping
      @xpath_attr_mapping
    end
  end
end
