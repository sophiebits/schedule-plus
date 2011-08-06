require 'open-uri'
load 'parse.rb'

urlToGet = 'https://scheduleman.org/schedules/MVv574PJer.ics'
filename = 'sample.ics'

writeOut = open(filename, "wb")
writeOut.write(open(urlToGet).read)
writeOut.close
puts "downloaded" + urlToGet + "\n"

Parser.parse(filename)
