class Nokogiri::XML::Node
  attr_accessor :content_score
  
  def word_count
    content.strip.split(' ').size
  end
end

module Dragnet
  class Dragger
    STRONG_KEYWORDS = %w(blog article body content entry hentry post story text post-entry 
                        post-body entry-content blogpost entry-body page-post postcontent pbody article-text)
    MEDIUM_KEYWORDS = %w(area container inner main story)
    IGNORE_KEYWORDS = %w(captcha classified comment footer footnote listing menu module 
                        nav navbar sidebar sbar sponsor tab toolbar tools trackback widget trail
                        toolbox reply comnt addstrip comments)
    INVALID_ELEMENTS = %w(form link head object iframe h1 script style embed param)
    CONTROL_SCORE = 20
    
    DEBUG = false
    DEBUG_CONTENT = ''
    
    attr_reader :content
    attr_reader :links
    attr_reader :author
    attr_reader :title
    
    def self.drag!(html)
      new(html)
    end
    
    def initialize(html)
      html.gsub!(/(<br\s*[^>]*>\n*){2,}/i, "<p />")
      
      # Tidy.path = '/opt/local/lib/libtidy-0.99.0.dylib'
      # cleaned = Tidy.open(:show_warnings => true) do |tidy|
      #   tidy.options.output_xhtml = true
      #   tidy.options.enclose_text = true
      #   tidy.options.enclose_block_text = true
      #   tidy.options.numeric_entities = true
      #   cleaned = tidy.clean(html)
      # end

      @doc = Nokogiri::HTML(html)      
      @title = @doc.at('//title').content rescue nil
      @links = []
      @high_score = -1
      parse!
    end
    
    def parse!
      # First try to extract the content as a microformat
      @content = parse_as_microformat(@doc)
      unless @content.nil?
        @links = extract_links_from_content(@content)
        return
      end
      
      content = []
      content_containers = []
      
      INVALID_ELEMENTS.each do |ename|
        @doc.css(ename).each { |e| e.remove }
      end
      paragraphs = @doc.css('p').to_a
      
      # If we have no paragraphs or the paragraph content we got was empty
      # lets try another method
      empty = paragraphs.collect {|c| c.content.strip}.join('').empty?
      if paragraphs.size == 0 || empty
        paragraphs = @doc.csss('div').to_a
      end
      
      paragraphs + @doc.css('blockquote').to_a
      paragraphs + @doc.children.collect {|c| c.is_a?(Nokogiri::XML::Text) }
      
      puts "Paragraphs: #{paragraphs.size}" if DEBUG
      
      paragraphs.each do |par|
        parent = par.parent
        parent.content_score = 0 if parent.content_score.nil?
        parent.content_score = build_score(parent, par)
        
        puts "PSCORE:#{parent.content_score}" if DEBUG && parent.content.include?(DEBUG_CONTENT)
        
        if parent.content_score > 0    
          unless content_containers.include?(parent)
            content_containers << parent 
          end
        end
      end
      
      content_containers.uniq!
      content_containers.delete_if do |container|
        ((@high_score < CONTROL_SCORE) && (container.content_score < @high_score))
      end
      
      content_containers.delete_if do |container|
        ((@high_score > CONTROL_SCORE) && (container.content_score < @high_score))
      end
      
      # Remove content elements that are decendants of other content elements     
      if content_containers.size > 1
        content_containers.delete_if do |container|
          container.children.any? do |child|
            content_containers.include?(child)
          end
        end
      end      
      
      # Remove all content elements with negative values
      content_containers.each do |container|
        container.children.each do |child|
          child.remove if child.content_score && child.content_score <= 0
        end
        
        # Extract all the links from what we assume is the content containers
        @links.concat(extract_links_from_content(container))
        
        cleaned_content = container.content.gsub(/[\r\n\t]+/i, ' ')
        content << cleaned_content.gsub(/\s{3,}/, '').gsub(/<\/?[^>]*>/, ' ').gsub(']]>', ' ').gsub(/↓|—/, ' ')
      end
      
      @content = content.join(' ')
    end  
    
    def build_score(parent, element)
      ancestors = parent.ancestors
      score = parent.content_score
      klasses = parent['class'].downcase rescue ''
      ancestor_klasses, ancestor_ids = keyword_collection_for(element)
      id = parent['id'].downcase rescue nil
      
      puts "SCORE FIRST:#{score}" if DEBUG && parent.content.include?(DEBUG_CONTENT)
      # Two points for every strong keyword
      STRONG_KEYWORDS.each do |keyword|        
        score += 1 if klasses =~ /#{keyword}/i
        score += 1 if id && id =~ /#{keyword}/i
        # # For every paragraph sibling, up the score.
        #score += parent.css('p').size
      end
      
      puts "SCORE STRONG:#{score}" if DEBUG && parent.content.include?(DEBUG_CONTENT)
      # One point for every medium keyword
      if score >= 1
        MEDIUM_KEYWORDS.each do |keyword|
          score += 1 if klasses =~ /#{keyword}/i
          score += 1 if id && id =~ /#{keyword}/i
        
          # # For every paragraph sibling, up the score.
          #score += parent.xpath('//p').size
        end
      end
      
      puts "SCORE MEDIUM:#{score}" if DEBUG && parent.content.include?(DEBUG_CONTENT)
      
      #Nuke the score for any bad or ignored keywords
      IGNORE_KEYWORDS.each do |keyword|
        score -= (CONTROL_SCORE * 0.3) if klasses =~ /#{keyword}/i
        score -= (CONTROL_SCORE * 0.3) if id && id =~ /#{keyword}/i        
        # score -= CONTROL_SCORE if ancestor_ids.include?(keyword)
        # score -= CONTROL_SCORE if ancestor_klasses.include?(keyword)
        
        # There wasn't an exact match, but we might have something like 
        # comment-1234 we'll take off half the control score
        # all_keywords = (klasses + ancestor_klasses + ancestor_ids)
        # all_keywords.each do |klass|
        #   #puts "#{klass} includes #{keyword}" if klass.include?(keyword) && element.content.include?('balance all accounts')
        #   score -= (CONTROL_SCORE / 2) if klass.include?(keyword)
        # end
        
        # unless ancestor_ids.include?(keyword) || ancestor_klasses.include?(keyword) || 
        #   klasses.include?(keyword) || (id && id.include?(keyword))
        #     if element.name == 'p' && element.word_count >= CONTROL_SCORE && !incremented_for_p
        #       score += 1;
        #       incremented_for_p = true;
        #     end
        # end
      end
      score += 1 if element.name == 'p' && element.word_count > CONTROL_SCORE       
      puts "SCORE FINAL:#{score}" if DEBUG && parent.content.include?(DEBUG_CONTENT)
         
      @high_score = score if score > @high_score
      score
    end
    
    private
    
      def parse_as_microformat(doc)
        hEntry.find(:first, :text => doc.to_s).entry_content rescue nil
      end
      
      def extract_links_from_content(content)
        links = []
        content = Nokogiri::HTML.fragment(content) if content.is_a?(String)
        
        content.css('a').each do |link|
          href = link['href']
          if (href && !href.nil?) || (href && !href.empty?)
            begin
              url = URI.parse(href)
              unless url.host.nil?
                links << {:text => link.content, :href => href}
              end
            rescue 
              
            end
          end          
        end
        links
      end
    
      def keyword_collection_for(element)
        ancestors = element.ancestors
        @ancestor_klasses ||= ancestors.collect {|c| c['class'] ? c['class'].split(' ') : nil }.flatten.uniq.compact
        @ancestor_ids ||= ancestors.collect {|c| c['id'] ? c['id'].split(' ') : nil }.flatten.uniq.compact
      
        [@ancestor_klasses, @ancestor_ids]
      end
    
  end
end