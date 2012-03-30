require 'from_node'
require 'rexml/document'
require 'test/unit'

class TestFromNode < Test::Unit::TestCase
  # Helper method
  def xml(s)
    REXML::Document.new(s)
  end


  class AttrWithoutXPath
    include FromNode
    xpath_attr :b
  end

  def test_attr_without_xpath
    doc = xml('<a b="123"/>')
    a = AttrWithoutXPath.new(doc.root)
    assert_equal('123', a.b)
  end


  class AttrWithXPath
    include FromNode
    xpath_attr :b, "@b"
  end

  def test_attr_with_xpath
    doc = xml('<a b="123"/>')
    a = AttrWithXPath.new(doc.root)
    assert_equal('123', a.b)
  end


  class AttrInSubnodeWithXPath
    include FromNode
    xpath_attr :c, "b/@c"
  end

  def test_attr_in_subnode_with_xpath
    doc = xml('<a><b c="123"/></a>')
    a = AttrInSubnodeWithXPath.new(doc.root)
    assert_equal('123', a.c)
  end


  class AttrWithXPathAndNamespace
    include FromNode
    xpath_attr :c, "n:b/@c", {"n" => "bar"}
  end

  def test_attr_with_xpath_and_namespace
    doc = xml('<m:a xmlns:m="bar"><m:b c="xyz"/></m:a>')
    a = AttrWithXPathAndNamespace.new(doc.root)
    assert_equal('xyz', a.c)
  end
end
