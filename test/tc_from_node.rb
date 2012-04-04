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

  def test_attr_with_xpath_missing_attr
    doc = xml('<a><x/></a>')
    a = AttrWithXPath.new(doc.root)
    assert(a.b.nil?)
  end


  class AttrWithXPathAndBlock
    include FromNode
    xpath_attr(:b, "@b") {|b| b.to_s.to_i }
  end

  def test_attr_with_xpath_and_block
    doc = xml('<a b="123"/>')
    a = AttrWithXPathAndBlock.new(doc.root)
    assert_equal(123, a.b)
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


  class AttrListWithText
    include FromNode
    xpath_attr_list :b
  end

  def test_attr_list_with_text
    doc = xml('<a><b>foo</b><b>bar</b></a>')
    a = AttrListWithText.new(doc.root)
    assert_equal(['foo', 'bar'], a.b)
  end


  class AttrListWithXPathAndBlock
    include FromNode
    xpath_attr_list(:c, "b/@c") {|c| c.to_s.to_i }
  end

  def test_attr_list_with_xpath_and_block
    doc = xml('<a><b c="9"/><b c="12"/><b c="8"/></a>')
    a = AttrListWithXPathAndBlock.new(doc.root)
    assert_equal([9, 12, 8], a.c)
  end


  class AttrHashWithXPath
    include FromNode
    xpath_attr_hash :b, "b", "@key", "@val"
  end

  def test_attr_hash_with_xpath
    doc = xml('<a><b key="g" val="h"/><b key="m" val="n"/></a>')
    a = AttrHashWithXPath.new(doc.root)
    assert_equal({'g' => 'h', 'm' => 'n'}, a.b)
  end


  class AttrHashWithXPathAndBlock
    include FromNode
    xpath_attr_hash(:b, "node()") {|v|
      key = REXML::XPath.first(v, "name()").to_s
      val = REXML::XPath.first(v, "text()").to_s.to_i
      [key, val]
    }
  end

  def test_attr_hash_with_xpath_and_block
    doc = xml('<a><g>8</g><m>12</m></a>')
    a = AttrHashWithXPathAndBlock.new(doc.root)
    assert_equal({'g' => 8, 'm' => 12}, a.b)
  end


  class AttrHashWithBlock
    include FromNode
    xpath_attr_hash(:b) {|v|
      key = REXML::XPath.first(v, "@id").to_s
      val = (REXML::XPath.first(v, "@content") ||
             REXML::XPath.first(v, "text()")).to_s
      [key, val]
    }
  end

  def test_attr_hash_with_xpath_and_block
    s = <<-EOF
    <a>
      <b id="c1" content="Content 1"/>
      <b id="c2">Some other content</b>
    </a>
    EOF
    doc = xml(s)
    a = AttrHashWithBlock.new(doc.root)
    assert_equal('Content 1', a.b['c1'])
    assert_equal('Some other content', a.b['c2'])
  end


  class AttrChildWithXPath
    include FromNode
    xpath_attr :a1
    xpath_child :z, "z", AttrWithoutXPath
  end

  def test_attr_child_class
    doc = xml('<a a1="5"><z b="8"/></a>')
    a = AttrChildWithXPath.new(doc.root)
    assert_equal('5', a.a1)
    assert_kind_of(AttrWithoutXPath, a.z)
    assert_equal('8', a.z.b)
  end

  def test_attr_child_class_missing
    doc = xml('<a a1="5"></a>')
    a = AttrChildWithXPath.new(doc.root)
    assert_equal('5', a.a1)
    assert(a.z.nil?)
  end


  class AttrChildListWithXPath
    include FromNode
    xpath_child_list :z, "z", AttrWithoutXPath
  end

  def test_attr_child_class_list
    doc = xml('<a><z b="8"/><z b="2"/></a>')
    a = AttrChildListWithXPath.new(doc.root)
    assert_equal(['8', '2'], a.z.collect {|z| z.b })
  end


  class AttrChildHashWithXPath
    include FromNode
    xpath_child_hash :z, "z", "@k", ".", AttrWithoutXPath
  end

  def test_attr_child_class_hash
    doc = xml('<a><z k="p" b="8"/><z k="q" b="2"/></a>')
    a = AttrChildHashWithXPath.new(doc.root)
    assert_equal('8', a.z['p'].b)
    assert_equal('2', a.z['q'].b)
  end
end
