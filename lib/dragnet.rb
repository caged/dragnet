I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true

require 'rubygems'

require 'nokogiri'
require 'open-uri'
require 'pp'
require 'tidy'
require 'uri'
require 'hpricot'
require 'mofo'

require 'dragnet/dragger'

puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/dragnet/test/data/public-policy-polling.html")).links
pp Dragnet::Dragger.drag!(open('http://www.fivethirtyeight.com/2009/08/are-progressives-on-tilt.html').read).links