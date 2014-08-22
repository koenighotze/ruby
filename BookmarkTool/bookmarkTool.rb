#!/usr/local/bin/ruby 
require 'log4r'
require 'log4r/configurator'
include Log4r

require 'categories/category'
require 'categories/compositecategory'
require 'categories/catchallcategory'
require 'bookmarks/bookmark'
include Categories
include Bookmarks

Configurator['logpath'] = './logs'
Configurator.load_xml_file('bookmarkToolConfig.xml')

LOGGER = Logger['base']

LOGGER.info("Starting bookmark tool...")

Header =<<-EOT
<HTML>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>

<DL><p>
    <DT><H3>Importierte bookmarks</H3>
    <DL><p>
EOT
Footer =<<-EOT
    </DL>
</DL>
EOT

catchAllCategory = CatchAllCategory.new("Top")
currentCategory = catchAllCategory
while gets
    LOGGER.debug("Read #{$_}")

    if (Category.isEnd?($_))
        LOGGER.info("End of category #{currentCategory.name}")
        currentCategory = currentCategory.parent
        next
    end

    category = CompositeCategory.create($_)
    unless (category.nil?)
        currentCategory.addCategory(category)
        currentCategory = category
        LOGGER.info("Start of category #{currentCategory.name}")
        next
    end

    bookmark = Bookmark.create($_)
    unless (bookmark.nil?)
        currentCategory.addBookmark(bookmark)
    end
end

puts Header
puts catchAllCategory.toHtml
puts Footer

LOGGER.info("Finished bookmark tool!")
