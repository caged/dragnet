require 'rubygems'

require 'nokogiri'
require 'open-uri'
require 'pp'
require 'tidy'
require 'uri'
require 'hpricot'
require 'mofo'

require 'dragnet/dragger'

Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/dragnet/test/data/the-fix.html")).links
#Dragnet::Dragger.drag!(open('http://www.fivethirtyeight.com/2009/08/are-progressives-on-tilt.html').read).links