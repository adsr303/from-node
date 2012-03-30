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


  class AttrListWithXPath
    include FromNode
    xpath_attr_list :c, "b/@c"
  end

  def test_attr_list_with_xpath
    doc = xml('<a><b c="x"/><b c="y"/><b c="z"/></a>')
    a = AttrListWithXPath.new(doc.root)
    assert_equal(['x', 'y', 'z'], a.c)
  end


  class AttrListWithTextXPath
    include FromNode
    xpath_attr_list :c, "b/text()"
  end

  def test_attr_list_with_text_xpath
    doc = xml('<a><b>foo</b><b>bar</b></a>')
    a = AttrListWithTextXPath.new(doc.root)
    assert_equal(['foo', 'bar'], a.c)
  end
end
