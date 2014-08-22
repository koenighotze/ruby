#!/usr/bin/ruby -w

require 'log4r'
require 'log4r/configurator'
include Log4r
Configurator['logpath'] = './logs'
Configurator.load_xml_file('genTodoList.xml')

class Todo 
    def initialize(aText)
        raise "aText" if aText.nil? or  "" == aText
    end

    def Todo.createFrom(aLine)
        raise "aLine" if aLine.nil?
    end
end
