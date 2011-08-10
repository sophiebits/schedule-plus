require 'open-uri'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

load 'parse.rb'

#urlToGet = 'https://scheduleman.org/schedules/MVv574PJer.ics'
urlToGet = 'https://scheduleman.org/schedules/sqGWsIDrvN.ics'
filename = 'sample.ics'

writeOut = open(filename, "wb")
writeOut.write(open(urlToGet).read)
writeOut.close
puts "downloaded: " + urlToGet + "\n"

Parser.parse(filename, 3)
