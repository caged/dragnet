I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true

require 'rubygems'
require 'nokogiri'
require 'dragnet/dragger'
require 'open-uri'
require 'pp'

Dir['/Users/justin/dev/me/ruby/sherlock/data/*.html'].each do |f|
  puts File.basename(f)
  puts Dragnet::Dragger.drag!(File.read(f))
  puts ""
  puts "-" * 100
  puts ""
end

#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/14cee27ee.html"))
#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/0555370b0.html"))
