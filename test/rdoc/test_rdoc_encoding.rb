require 'rubygems'
require 'minitest/autorun'
require 'rdoc'
require 'rdoc/encoding'

require 'tempfile'

class TestRDocEncoding < MiniTest::Unit::TestCase

  def setup
    @tempfile = Tempfile.new 'test_rdoc_encoding'
  end

  def test_class_read_file
    @tempfile.write "hi everybody"
    @tempfile.flush

    assert_equal "hi everybody", RDoc::Encoding.read_file(@tempfile.path, nil)
  end

  def test_class_read_file_encoding
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    expected = "# coding: utf-8\nhi everybody"

    @tempfile.write expected
    @tempfile.flush

    # FIXME 1.9 fix on windoze
    expected.gsub!("\n", "\r\n") if RUBY_VERSION =~ /^1.9/ && RUBY_PLATFORM =~ /mswin|mingw/

    contents = RDoc::Encoding.read_file @tempfile.path, Encoding::UTF_8
    assert_equal expected, contents
    assert_equal Encoding::UTF_8, contents.encoding
  end

  def test_class_read_file_encoding_convert
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    content = ""
    content.encode! 'ISO-8859-1'
    content << "# coding: ISO-8859-1\nhi \xE9verybody"

    @tempfile.write content
    @tempfile.flush

    contents = RDoc::Encoding.read_file @tempfile.path, Encoding::UTF_8
    assert_equal Encoding::UTF_8, contents.encoding
    assert_equal "# coding: ISO-8859-1\nhi \u00e9verybody", contents.sub("\r", '')
  end

  def test_class_read_file_encoding_fancy
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    expected = "# -*- coding: utf-8; fill-column: 74 -*-\nhi everybody"
    expected.encode! Encoding::UTF_8

    @tempfile.write expected
    @tempfile.flush

    # FIXME 1.9 fix on windoze
    expected.gsub!("\n", "\r\n") if RUBY_VERSION =~ /^1.9/ && RUBY_PLATFORM =~ /win32|mingw32/

    contents = RDoc::Encoding.read_file @tempfile.path, Encoding::UTF_8
    assert_equal expected, contents
    assert_equal Encoding::UTF_8, contents.encoding
  end

  def test_class_read_file_encoding_guess
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    path = File.expand_path '../test.ja.txt', __FILE__
    content = RDoc::Encoding.read_file path, Encoding::UTF_8

    assert_equal Encoding::UTF_8, content.encoding
  end

  def test_class_read_file_encoding_with_signature
    skip "Encoding not implemented" unless defined? ::Encoding

    @tempfile.write "\xEF\xBB\xBFhi everybody"
    @tempfile.flush

    bug3360 = '[ruby-dev:41452]'
    content = RDoc::Encoding.read_file @tempfile.path, Encoding::UTF_8
    assert_equal Encoding::UTF_8, content.encoding, bug3360
    assert_equal "hi everybody", content, bug3360
  end

  def test_class_set_encoding
    s = "# coding: UTF-8\n"
    RDoc::Encoding.set_encoding s

    # sanity check for 1.8

    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    assert_equal Encoding::UTF_8, s.encoding

    s = "#!/bin/ruby\n# coding: UTF-8\n"
    RDoc::Encoding.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding

    s = "<?xml version='1.0' encoding='UTF-8'?>\n"
    expected = s.encoding
    RDoc::Encoding.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding

    s = "<?xml version='1.0' encoding=\"UTF-8\"?>\n"
    expected = s.encoding
    RDoc::Encoding.set_encoding s

    assert_equal Encoding::UTF_8, s.encoding
  end

  def test_class_set_encoding_bad
    skip "Encoding not implemented" unless Object.const_defined? :Encoding

    s = ""
    expected = s.encoding
    RDoc::Encoding.set_encoding s

    assert_equal expected, s.encoding

    s = "# vim:set fileencoding=utf-8:\n"
    expected = s.encoding
    RDoc::Encoding.set_encoding s

    assert_equal expected, s.encoding

    s = "# vim:set fileencoding=utf-8:\n"
    expected = s.encoding
    RDoc::Encoding.set_encoding s

    assert_equal expected, s.encoding

    assert_raises ArgumentError do
      RDoc::Encoding.set_encoding "# -*- encoding: undecided -*-\n"
    end
  end

end
