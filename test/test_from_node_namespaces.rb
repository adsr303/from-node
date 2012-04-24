require 'from_node'
require 'rexml/document'
require 'test/unit'

class TestFromNodeNamespaces < Test::Unit::TestCase
  # Helper method
  def xml(s)
    REXML::Document.new(s)
  end


  class AttrWithXPathAndNamespace
    include FromNode
    xpath_namespaces "n" => "bar"
    xpath_attr :c, "n:b/@c"
  end

  def test_attr_with_xpath_and_namespace
    doc = xml('<m:a xmlns:m="bar"><m:b c="xyz"/></m:a>')
    a = AttrWithXPathAndNamespace.new(doc.root)
    assert_equal('xyz', a.c)
  end


  class AttrWithXPathAndNamespaceAtEnd
    include FromNode
    xpath_attr :c, "n:b/@c"
    xpath_namespaces "n" => "bar"
  end

  def test_attr_with_xpath_and_namespace_at_end
    doc = xml('<m:a xmlns:m="bar"><m:b c="xyz"/></m:a>')
    a = AttrWithXPathAndNamespaceAtEnd.new(doc.root)
    assert_equal('xyz', a.c)
  end


  class AttrChildWithXPathAndNamespace
    include FromNode
    xpath_namespaces "n" => "bar"
    xpath_child :x, "n:x", AttrWithXPathAndNamespace
  end

  def test_attr_child_with_xpath_and_namespace
    doc = xml('<m:a xmlns:m="bar"><m:x><m:b c="xyz"/></m:x></m:a>')
    a = AttrChildWithXPathAndNamespace.new(doc.root)
    assert_equal('xyz', a.x.c)
  end
end
