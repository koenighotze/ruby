#!/usr/bin/ruby -w

require 'log4r'
require 'log4r/configurator'
include Log4r
Configurator['logpath'] = './logs'
Configurator.load_xml_file('.xml')

