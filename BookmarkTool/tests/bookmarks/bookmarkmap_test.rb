require 'test/unit'
require 'bookmarks/bookmarkmap'
include Bookmarks
 
module Tests 
 module Bookmarks
   class BookmarkMap_Test < Test::Unit::TestCase
     def setup      
        @map = BookmarkMap.new
     end
     
     def tear_down
        @map = nil
     end
     
     def test_get_unique_name
     end
     
     def test_happy_add_bookmark
        tmpBookmark = Bookmark.new("A name", "An Url")
        @map.addBookmark(tmpBookmark)

        tmpStoredMark = @map.getBookmarkByUrl("An Url")
        assert_not_nil(tmpStoredMark)
        assert_equal(tmpBookmark, tmpStoredMark)
     end
     
     def test_add_existing_bookmark
     end
     
     def test_add_bookmark_existing_name_differing_url
     end
   end
 end
end 
