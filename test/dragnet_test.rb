require 'test_helper'

class DragnetTest < Test::Unit::TestCase
  context "When extracting content from a page with an hEntry item" do
    setup do
      @net = Dragnet::Dragger.drag!(sample_with_microformat)
    end

    should "parse hentry body as content" do
      assert(@net.content.include?("I got quite a vociferous e-mail today saying the only reason our Colorado polling was showing Michael Bennet and Bill Ritter"))
      assert_match(/Ritter\.$/, @net.content)
    end
    
    should "only extract links from hentry content" do
      assert_equal(@net.links.size, 0)
    end
  end
  
  context "When Extracting Content" do
    setup do
      @net = Dragnet::Dragger.drag!(sample_with_embedded_links)
    end
    
    should "ignore invalid content such as comments, etc. even if it shares the same parent as valid article content" do
      assert_match(/Associated\sPress$/i, @net.content)
    end
    
    should "extract links from content" do
      assert_equal("Polling done earlier this week by NBC", @net.links.first[:text])
      assert_equal("John Ensign", @net.links.last[:text])
    end
    
    should "extract only links within the content area" do
      assert_equal(@net.links.size, 23)
    end
  end
end
