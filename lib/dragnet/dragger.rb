class Nokogiri::XML::Node
  attr_accessor :content_score
  
  def word_count
    content.strip.split(' ').size
  end
end

module Dragnet
  class Dragger
    STRONG_KEYWORDS = %w(article body content entry hentry post story text post-entry post-body)
    MEDIUM_KEYWORDS = %w(area container inner main)
    IGNORE_KEYWORDS = %w(ad captcha classified comment footer footnote leftcolumn listing menu meta module nav navbar rightcolumn sidebar sbar sponsor tab toolbar tools trackback widget)
    CONTROL_SCORE = 20
    INVALID_ELEMENTS = %w(form object iframe h1)
    
    def self.drag!(html)
      new(html).parse!
    end
    
    def initialize(html)
      html.gsub!(/(<br\s*[^>]*>\n*){2,}/i, "<p />")
      @doc = Nokogiri::HTML(html)
      # 
      # @doc.at('p#foo').children.each do |p|
      #   if p.is_a?(Nokogiri::XML::Text)
      #     puts p.content
      #   end
      # end
      # 
      # @doc.xpath("//p//p").each do |par|
      #   paragraph_in_paragraph = par.ancestors.detect {|a| a.name.downcase == 'p'}
      #   if paragraph_in_paragraph
      #     paragraph_in_paragraph.name = 'div'          
      #     pp paragraph_in_paragraph.attributes
      #   end
      # end
      puts @doc.at('//title').content
      @high_score = -1
    end
    
    def parse!
      content = []
      content_containers = []
      paragraphs = @doc.xpath('//p').to_a
      paragraphs = @doc.xpath('//div').to_a if paragraphs.size == 0
      paragraphs + @doc.children.collect {|c| c.is_a?(Nokogiri::XML::Text) }
      
      paragraphs.each do |par|
        parent = par.parent
        parent.content_score = 0 if parent.content_score.nil?
        parent.content_score = build_score(parent, par)
        if parent.content_score > 0
          content_containers << parent unless content_containers.include?(parent)
        end
      end
      
      content_containers.delete_if do |container|
        @high_score < CONTROL_SCORE && container.content_score < @high_score
      end

      content_containers.delete_if do |c|
        (@high_score > CONTROL_SCORE) && (c.content_score < @high_score)
      end
            
      if content_containers.size > 1
        content_containers.delete_if do |container|
          container.children.detect do |child|
            content_containers.include?(child)
          end
        end
      end
      
      content_containers.each do |container|
        unless INVALID_ELEMENTS.include?(container.name.downcase)
          cleaned_content = container.content.gsub(/[\r\n\t]+/i, '')
          content << cleaned_content.gsub(/\s{3,}/, '').gsub(/<\/?[^>]*>/, " ").gsub(']]>', ' ')
        end
      end
      
      content.join
    end
    
    def build_score(parent, element)
      puts "SELF:#{element['id']} PARENT:#{parent['id']} SCORE:#{parent.content_score}"
      score = parent.content_score
      klasses = parent['class'].split(' ').collect {|c| c.downcase} rescue []
      id      = parent['id'].downcase rescue nil
      
      # Two points for every strong keyword
      STRONG_KEYWORDS.each do |keyword|
        score += 2 if klasses.include?(keyword)
        score += 2 if id && id.include?(keyword)
      end
      
      if score >= 2
        # One point for every medium keyword
        MEDIUM_KEYWORDS.each do |keyword|
          score += 1 if klasses.include?(keyword)
          score += 1 if id && id.include?(keyword)
        end
      end
      
      # Nuke the score for any bad or ignored keywords
      IGNORE_KEYWORDS.each do |keyword|
        score -= CONTROL_SCORE if klasses.include?(keyword)
        score -= CONTROL_SCORE if id && id.include?(keyword)
      end
    
      score += 1 if element.name == 'p'
      score += 1 if element.word_count >= CONTROL_SCORE
      
      @high_score = score if score > @high_score
      score
    end
  end
end