require 'test_helper'

class DragnetTest < Test::Unit::TestCase
  context "When extracting content from a page with no links" do
    setup do 
      @net = Dragnet::Dragger.drag!(sample_with_good_structure)
      pp @net.content
    end
    
    should "extract content" do
      assert(@net.content.length > 0, @net.content)
    end
    
    should "not extract any links" do
      assert_equal(@net.links.size, 0)
    end
  end
  
  context "When Extracting Links From Content" do
    setup do
      @net = Dragnet::Dragger.drag!(sample_with_embedded_links)
    end
    
    should "extract only links within the content area" do
      assert_equal(@net.links.size, 23)
    end
  end
end
