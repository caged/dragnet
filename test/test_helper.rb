require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dragnet'

def load_data(name)
  File.read(File.join(File.dirname(__FILE__), 'data', "#{name}.html"))
end

def sample_with_embedded_links
  load_data('the-fix')
end

class Test::Unit::TestCase
end
