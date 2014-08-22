#!/usr/local/bin/ruby

tmpPattern = ARGV.shift

ARGF.each { 
	|line|
	puts("Found #{tmpPattern} on line #{line}") if line =~ /#{tmpPattern}/
}
