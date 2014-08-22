module Bookmarks
  require 'log4r'
  include Log4r
  
  class BookmarkMap
    include Enumerable
    
    def initialize
      @logger = Logger["Bookmark"]
      @map = {}
      @urlmap = {}
    end
 
    def getBookmarkByUrl(aBookmarkUrl) 
        aBookmarkUrl.nil? and raise "aBookmarkUrl"

        return @map[@urlmap[aBookmarkUrl]]
    end
 
    def addBookmark(aBookmark)
      aBookmark.nil? and raise "Bookmark must not be nil!"
      
      if (@urlmap.has_key?(aBookmark.url))
        @logger.warn("Will not store url twice #{aBookmark.url}")
        return
      end
      
      if (@map.has_key?(aBookmark.name) and @map[aBookmark.name].url != aBookmark.url)
        @logger.warn("Will not overwrite existing bookmark '#{ @map[aBookmark.name] }' with '#{aBookmark}'")
        aBookmark.name = getUniqueName(aBookmark.name)
        @logger.warn("Use #{aBookmark.name} as name!")
      end
      @urlmap[aBookmark.url] = aBookmark.name
      @map[aBookmark.name] = aBookmark
    end
    
    def getUniqueName(aName)
      aName.nil? and raise "aName must not be nil!"
      
      aPostfix = 1
      while (@map.has_key?(aName + aPostfix.to_s))
        aPostfix += 1
      end
      return aName + aPostfix.to_s
    end
    
    def each(&aBlock)
      @map.each(&aBlock)
    end
    
    def toHtml
      @map.keys.sort.collect { |name| @map[name].toHtml }
    end
    
    def to_s
      @map.each_value {|bookmark| puts bookmark}
    end
  end
end
