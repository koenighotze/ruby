class Token
    private
    def initialize(aName, aPattern)
        aName.nil? and raise "nil name"
        aPattern.nil? and raise "nil pattern"
    
        @name = aName
        @pattern = aPattern
    end

    public
    attr_reader :pattern
    
    OPERATOR = Token.new("OPERATOR", /^[+-\/*]$/)
    EQUALS   = Token.new("EQUALS", /^[=]$/)
    NUMBER   = Token.new("NUMBER", /^\d+(\.\d+)?$/)
end


class Stack
    def initialize
        @a = []
    end

    def push(el)
        case el
            when Token::OPERATOR.pattern
                x2 = pop()
                x1 = pop()

                x1 = 0 unless x1
                x2 = 0 unless x2

                exp = "#{x1} #{el} #{x2}"
                puts(exp + " = " + (x3 = eval(exp)).to_s)
                @a.unshift(x3)
            when Token::EQUALS.pattern
                res = pop() or 0
                puts("= " + res.to_s)
                @a.unshift(res)
            when Token::NUMBER.pattern
                puts(el.to_s)
                @a.unshift(el.to_f)
            else 
                raise "Cannot parse '#{el}'"
        end
    
        self
    end

    def pop() 
        @a.shift
    end

    def each()
        while el = pop()
            yield el
        end
    end
end


puts("UPN Calculator")


st = Stack.new
print("> ")
while gets
    begin
        st.push($_.chomp.strip)
    rescue RuntimeError => e
        puts e
    end
    print("> ")
end

