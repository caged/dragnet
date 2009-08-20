I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true

require 'rubygems'
require 'nokogiri'
require 'dragnet/dragger'
require 'open-uri'
require 'pp'
require 'tidy'
require 'uri'

all_path = '../samples/index.html'
File.open(all_path, "w")

debug_path = '../samples/debug.html'
File.open(debug_path, "w")

DEBUG = false
RUNS  = 20

unless DEBUG
  Dir['/Users/justin/dev/me/ruby/sherlock/data/*.html'].each_with_index do |f, index|
    if index <= RUNS
      bname = File.basename(f)
      puts bname
      net = Dragnet::Dragger.drag!(File.read(f))
      #puts net.content
      file_url = "file://#{File.expand_path(f)}"
      txmt_url = "txmt://open/?url=#{file_url}"
      File.open(all_path, 'a') do |f|
        f << "<div>\n"
        f << "\n<h2>#{net.title} &mdash; #{bname}</h2>\n"
        f << %(\n<p style="font-size:92%;color:#666"><a href="#{txmt_url}">Textmate</a> <a target="_blank" href="#{file_url}">Open</a></p>\n)
        f << net.content rescue 'nil'
        f << "-" * 100
        f << "\n</div>\n\n"
      end
    end
  end
else
  %w(006921daf.html).each do |f|
  f = "/Users/justin/dev/me/ruby/sherlock/data/#{f}"

  bname = File.basename(f)
  puts bname
  net = Dragnet::Dragger.drag!(File.read(f))
  #puts net.content
  file_url = "file://#{File.expand_path(f)}"
  txmt_url = "txmt://open/?url=#{file_url}"

  File.open(debug_path, 'a') do |f|
    f << "<div>\n"
    f << "\n<h2>#{net.title} &mdash; #{bname}</h2>\n"
    f << %(\n<p style="font-size:92%;color:#666"><a href="#{txmt_url}">Textmate</a> <a target="_blank" href="#{file_url}">Open</a></p>\n)
    f << net.content rescue 'nil'
    f << "-" * 100
    f << "\n</div>\n\n"
  end
  end
end
#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/14cee27ee.html")).content
#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/0555370b0.html")).content
#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/2c7cb077d.html")).content
#puts Dragnet::Dragger.drag!(File.read("/Users/justin/dev/me/ruby/sherlock/data/efb53ea49.html")).content
