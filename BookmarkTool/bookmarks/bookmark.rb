module Bookmarks
  class Bookmark
    attr_reader :url, :name
    attr_writer :name

    def initialize(aName, anUrl)
      aName.nil? or aName == "" and raise "Name must not be nil!"
      anUrl.nil? or anUrl == "" and raise "Url must not be nil!"

      @name = aName
      @url = anUrl
    end

    def Bookmark.create(aMozillaBookmark)
      aMozillaBookmark.nil? and raise "Bookmark must not be nil!"
      return Bookmark.new($2, $1) if aMozillaBookmark =~ %r{<A HREF="([^"]+)?".*>([^<]+)</A>}
    end

    def toHtml
      foo =<<-EOT
	               <DT><A HREF="#{@url}">#{@name}</A>
	        EOT
    end

    def to_s
      @name + " " + @url
    end
  end
end
