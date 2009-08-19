class Nokogiri::XML::Node
  attr_accessor :content_score
  
  def word_count
    content.strip.split(' ').size
  end
end

module Dragnet
  class Dragger
    STRONG_KEYWORDS = %w(article body content entry hentry post story text post-entry 
                        post-body blogpost entry-body page-post postcontent)
    MEDIUM_KEYWORDS = %w(area container inner main story)
    IGNORE_KEYWORDS = %w(ad captcha classified comment footer footnote leftcolumn 
                        listing menu meta module nav navbar rightcolumn sidebar sbar 
                        sponsor tab toolbar tools trackback widget trail right-column
                        toolbox reply comnt)
    INVALID_ELEMENTS = %w(form object iframe h1 script style embed param)
    CONTROL_SCORE = 20
    
    attr_reader :content
    attr_reader :links
    attr_reader :author
    attr_reader :title
    
    def self.drag!(html)
      new(html)
    end
    
    def initialize(html)
      html.gsub!(/(<br\s*[^>]*>\n*){2,}/i, "<p />")
      #html.gsub!(/↓+|—+/i, '')
      
      # Tidy.path = '/opt/local/lib/libtidy-0.99.0.dylib'
      # Tidy.open(:show_warnings => true) do |tidy|
      #   tidy.options.output_xhtml = true
      #   tidy.options.enclose_text = true
      #   tidy.options.enclose_block_text = true
      #   tidy.options.numeric_entities = true
      #   html = tidy.clean(html)
      #   # puts tidy.errors
      # end

      @doc = Nokogiri::HTML(html)
      @title = @doc.at('//title').content rescue nil
      @links = []
      @high_score = -1
      parse!
    end
    
    def parse!
      content = []
      content_containers = []
      paragraphs = @doc.xpath('//p').to_a
      paragraphs = @doc.xpath('//div').to_a if paragraphs.size == 0
      paragraphs + @doc.xpath('//blockquote').to_a
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
          container.css('a').each do |link|
            href = link['href']
            if href && !href.nil? || !href.empty?
              url = URI.parse(href)
              unless url.host.nil?
                @links << {:text => link.content, :href => href}
              end
            end
          end rescue nil
          
          cleaned_content = container.content.gsub(/[\r\n\t]+/i, '')
          content << cleaned_content.gsub(/\s{3,}/, '').gsub(/<\/?[^>]*>/, " ").gsub(']]>', ' ').gsub(/↓|—/, '')
        end
      end
      
      @content = content.join
    end
    
    def build_score(parent, element)
      ancestors = parent.ancestors
      score = parent.content_score
      klasses = parent['class'].split(' ').collect {|c| c.downcase} rescue []
      ancestor_classes = ancestors.collect {|c| c['class'] ? c['class'].split(' ') : nil }.flatten.uniq.compact
      ancestor_ids = ancestors.collect {|c| c['id'] ? c['id'].split(' ') : nil }.flatten.uniq.compact
      id = parent['id'].downcase rescue nil
      
      pp ancestor_classes
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
        score -= CONTROL_SCORE if ancestor_ids.include?(keyword)
        score -= CONTROL_SCORE if ancestor_classes.include?(keyword)
        
        # There wasn't an exact match, but we might have something like 
        # comment-1234 we'll take off half the control score
        all_keywords = (klasses + ancestor_classes + ancestor_ids)
        all_keywords.each do |klass|
          score -= (CONTROL_SCORE - 10) if klass.include?(keyword)
        end
      end
    
      score += 1 if element.name == 'p'
      score += 1 if element.word_count >= CONTROL_SCORE
      
      @high_score = score if score > @high_score
      score
    end
  end
end