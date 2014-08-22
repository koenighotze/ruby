class Address
    attr_reader :name, :street, :number
    attr_writer :name, :street, :number

	def initialize(name, street, number)
		@name = name
		@street = street
		@number = number
	end

    def to_s
        "Address: #{@name} #{@street} #{@number}"
    end
end

class ExAddress < Address
    @@instances = 0

    def initialize(name, street, number)
        super(name, street, number)       
        @@instances += 1
    end

    def ExAddress.instances
        "Num instances==#@@instances"
    end
    
    def to_s
        super + " Num instances: #{@@instances}"
    end
end

foo = Address.new("Name", "Street", 12)
puts(foo)
puts foo.inspect

bar = ExAddress.new("A name", "a street", 2123)
puts(bar)
bar = ExAddress.new("A name", "a street", 2123)
puts(bar)
bar = ExAddress.new("A name", "a street", 2123)
puts(bar)

puts(bar.name)
bar.name = "Neuer name"
puts(bar.name)
puts(ExAddress.instances)
