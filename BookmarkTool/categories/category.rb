module Categories
  require 'log4r'
  include Log4r

  require 'bookmarks/bookmarkmap'
  include Bookmarks

  class Category

    attr_reader :name, :bookmarks

    def initialize(aName)
      aName.nil? or "" == aName and raise "aName must not be empty!"
      @logger = Logger["Category"]
      @logger.debug("Create new category #{aName}")

      @name = aName
      @bookmarks = BookmarkMap.new
    end

    def addBookmark(aBookmark)
      aBookmark.nil? and raise "aBookmark"

      @logger.info("Add bookmark #{aBookmark} to category #{@name}")

      @bookmarks.addBookmark(aBookmark)
    end

    def Category.create(aMozillaBookmark)
      aMozillaBookmark.nil? or aMozillaBookmark == "" and raise "Bookmark must not be empty!"

      return Category.new($1) if aMozillaBookmark =~ %r{<DT><H3[^>]+>([^<]+)</H3>}
    end

    def Category.isEnd?(aLine)
      aLine.nil? and raise "aLine"

      return aLine =~ %r{</DL>}
    end

    def toHtml
      foo =<<-EOT
	            <DT><H3>#{@name}</H3>
	            <DL><P>
	        EOT

      foo += @bookmarks.toHtml.join

      foo +=<<-EOT
	            </DL><P>
	        EOT
    end
  end
end
