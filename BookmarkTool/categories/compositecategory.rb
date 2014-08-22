module Categories
  require 'log4r'
  include Log4r

  class CompositeCategory < Category

    attr_reader :parent
    attr_writer :parent

    def initialize(aName)
      super(aName)
      @logger = Logger["Category"]

      @categories = {}
      @parent = self
    end

    def addCategory(aCategory)
      aCategory.nil? and raise "aCategory"

      unless (isKnownCategory(aCategory))
        aCategory.parent = self
        storeCategory(aCategory)
      else
        aCategory.bookmarks.each {|mark| getCategory(aCategory.name).addBookmark(mark)}
      end
    end

    def isKnownCategory(category)
      category.nil? and raise "category"
      return @categories.has_key?(category.name.downcase)
    end

    def storeCategory(category)
      category.nil? and raise "category"


      @logger.info("Add category #{category.name} to category #{self.name}")
      @categories[category.name.downcase] = category
    end

    def getCategory(name)
      name.nil? and raise "name must not be nil!"
      return @categories[name.downcase]
    end

    def CompositeCategory.create(aMozillaBookmark)
      aMozillaBookmark.nil? or aMozillaBookmark == "" and raise "Bookmark must not be empty!"

      return CompositeCategory.new($1) if aMozillaBookmark =~ %r{<DT><H3[^>]+>([^<]+)</H3>}
    end

    def toHtml
      foo =<<-EOT
	            <DT><H3>#{@name.capitalize}</H3>
	        EOT

      # foo += @categories.keys.sort.collect.join("\n")

      foo +=<<-EOT
	            <DL><P>
	        EOT

      foo += @categories.keys.sort.collect { |name| getCategory(name).toHtml } .join

      foo += @bookmarks.toHtml.join

      foo +=<<-EOT
	            </DL><P> <!-- #{@name} -->
	        EOT
    end
  end
end
