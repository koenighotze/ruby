require 'test/unit'
require 'bookmarks/bookmark'
include Bookmarks

module Tests
  module Bookmarks
    class Bookmark_Test < Test::Unit::TestCase
      TITLE = "A TITLE"
      URL = "http://foo.bar"
      
      def setup 
        @valid_url = %Q!<A HREF="#{URL}">#{TITLE}</A>!
      end
      
      def tear_down
        @valid_url = nil
      end
      
      def test_happy_create
        a_bookmark = Bookmark.create(@valid_url)
        assert_equal(TITLE, a_bookmark.name, " The title differs!")
        assert_equal(URL, a_bookmark.url, "The url differs!")
      end
      
      def test_create_null_if_invalid
        empty_url = %q!!
        a_bookmark = Bookmark.create(empty_url)
        assert_nil(a_bookmark)

        invalid_ref_url = %q!<A HREF=""></A>!
        a_bookmark = Bookmark.create(invalid_ref_url)
        assert_nil(a_bookmark)

        invalid_title_url = %q!<A HREF="http://foo.bar"></A>!
        a_bookmark = Bookmark.create(invalid_title_url)
        assert_nil(a_bookmark)

        malformed_url = %q!<A HREF="http://foo.bar">sadds!
        a_bookmark = Bookmark.create(malformed_url)
        assert_nil(a_bookmark)
      end
    end
  end
end
