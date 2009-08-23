I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true

require 'rubygems'
require 'nokogiri'
require 'dragnet/dragger'
require 'open-uri'
require 'pp'
require 'tidy'
require 'uri'
require 'hpricot'

module Dragnet
  VERSION = '0.3.0' unless defined?(Dragnet::VERSION)
end

# template = <<-TEMPLATE
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
#   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
# <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
# <head>
#   <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
#   <title>Content Scores</title>
#   <link rel="stylesheet" href="style.css" type="text/css" />
# </head>
# <body>
#   <div id="content">
#     SCORED_CONTENT
#   </div>
# </body>
# </html>
# TEMPLATE
# 
# 
# all_path = '../samples/index.html'
# 
# debug_path = '../samples/debug.html'
# File.open(debug_path, "w")
# 
# DEBUG = false
# RUNS  = 20
# 
# unless DEBUG
#   content = ""
#   Dir['/Users/justin/dev/me/ruby/sherlock/data/*.html'].each_with_index do |f, index|
#     if index <= RUNS
#       bname = File.basename(f)
#       puts bname
#       net = Dragnet::Dragger.drag!(File.read(f))
#       #puts net.content
#       file_url = "file://#{File.expand_path(f)}"
#       txmt_url = "txmt://open/?url=#{file_url}"
#     
#       content << "<div>\n"
#       content << "\n<h2>#{net.title} &mdash; #{bname}</h2>\n"
#       content << %(\n<p style="font-size:92%;color:#666"><a href="#{txmt_url}">Textmate</a> <a target="_blank" href="#{file_url}">Open</a></p>\n)
#       content << net.content rescue 'nil'
#       content << "\n</div>\n\n"
#     end
#   end
#   File.open(all_path, "w") do |f|
#     f << template.gsub(/SCORED_CONTENT/, content)
#   end
# else
#   #puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/00e3dcf9b.html")).content
#   puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/014f6118e.html")).content
#   
#   #puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/006b11117.html")).content
# end
# #puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/efb53ea49.html")).content
