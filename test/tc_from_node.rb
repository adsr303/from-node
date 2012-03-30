require 'from_node'
require 'rexml/document'
require 'test/unit'

class TestFromNode < Test::Unit::TestCase
  # Helper method
  def xml(s)
    REXML::Document.new(s)
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
end
