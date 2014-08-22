module Categories
  class CatchAllCategory < CompositeCategory
    def initialize(aName)
      super(aName)

      subCategories = 'a'..'z'
      subCategories.each do |name|
        addCategory(CompositeCategory.new(name))
      end
      subCategories = '0'..'9'
      subCategories.each do |name|
        addCategory(CompositeCategory.new(name))
      end
    end

    def addBookmark(aBookmark)
      aBookmark.nil? and raise "aBookmark"

      first = aBookmark.name[0,1]
      category = getCategory(first.downcase)
      if category.nil?
        super(aBookmark)
      else
        category.addBookmark(aBookmark)
      end
    end
  end
end
