require 'test_helper'

class DragnetTest < Test::Unit::TestCase
  context "When Extracting Links From Content" do
    setup do
      @net = Dragnet::Dragger.drag!(sample_with_embedded_links)
    end
    
    should "extract only links within the content area" do
      @net.links.size.should == 10
    end
  end
end
