# dragnet
This is still very experimental.  


## Extracting readable content from HTML markup
This was inspired by the [Readability](http://lab.arc90.com/experiments/readability/) bookmarklet. 
The goal is to extract meaningful, readable content from HTML.  This will attempt to 
extract content from sources such as blogs articles and publications.  It will also attempt to 
extract links embedded within the readable content.


## Approach
Given the vast nasty of HTML tag soup regurgitated by some blog engines, it's very 
hard to get fully clean content from a page on any kind of consistent basis.  What works for one 
chunk of HTML, might not work for other chunks of HTML.  We want to attempt to get as clean of 
content as we can, but remain as abstract as possible.

A basic overview of what this library does:

1. Try to extract any hEntry microformat items from the page and return those.
2. Collect all paragraphs (if none found, collect text nodes and/or divs as last resort)
3. Iterate over the paragraphs, ascending up the hierarchy, scoring the parent based on 
   some common keywords and word count.

  
#### Notable Troublesome URLS
[x] Readability doesn't parse correctly : [-] Readability parses correctly

* [-] [http://www.politico.com/blogs/glennthrush/0809/Remains_of_the_day_August_24_2009.html](http://www.politico.com/blogs/glennthrush/0809/Remains_of_the_day_August_24_2009.html)
      Short content, invalid lines.
* [-] [http://www.tulsaworld.com/news/article.aspx?subjectid=298&articleid=20090824_298_0_TheTul317502&rss_lnk=1](http://www.tulsaworld.com/news/article.aspx?subjectid=298&articleid=20090824_298_0_TheTul317502&rss_lnk=1)
      No content paragraphs, uses spans and double <br /><br /> to signify paragraphs.
* [-] [http://article.nationalreview.com/?q=YTMxNGQyNmYyNjljYmE0NDVhZTdlMjlkZTM1Y2NiOTU=](http://article.nationalreview.com/?q=YTMxNGQyNmYyNjljYmE0NDVhZTdlMjlkZTM1Y2NiOTU=)
      Multiple page article
* [x] [http://politicalwire.com/archives/2009/08/24/bonus_quote_of_the_day.html](http://politicalwire.com/archives/2009/08/24/bonus_quote_of_the_day.html)
      Tiny amount of content with no paragraphs and a huge footer with paragraph content.
* [x] [http://briefingroom.thehill.com/2009/08/24/doctor-to-be-named-in-jackson-homicide-donated-to-republican-party-in-2004/](http://briefingroom.thehill.com/2009/08/24/doctor-to-be-named-in-jackson-homicide-donated-to-republican-party-in-2004/)
      Paragraphs embedded in spans
* [-] [http://www.nytimes.com/2009/08/25/us/politics/25detain.html?_r=1&partner=rss&emc=rss](http://www.nytimes.com/2009/08/25/us/politics/25detain.html?_r=1&partner=rss&emc=rss)
      Not sure what the problem is here.  It doesn't look like anything should be wrong here 
      at first glance.
* [-] [http://www.weeklystandard.com/weblogs/TWSFP/2009/08/kristol_gratitude_obamastyle.asp](http://www.weeklystandard.com/weblogs/TWSFP/2009/08/kristol_gratitude_obamastyle.asp)
      Everything looks fine.  Not sure why we're getting a blank block of content back
* [x] [http://www.cbsnews.com/stories/2009/08/24/entertainment/michaeljackson/main5262822.shtml](http://www.cbsnews.com/stories/2009/08/24/entertainment/michaeljackson/main5262822.shtml)
      Comments are included as readable content
* [x] [http://www.whitehouse.gov/blog/Diligence-on-H1N1/](http://www.whitehouse.gov/blog/Diligence-on-H1N1/)
      Uses divs for content, but contains paragraphs elsewhere.
* [-] [http://www.msnbc.msn.com/id/32518842/ns/meet_the_press/](http://www.msnbc.msn.com/id/32518842/ns/meet_the_press/)
      Parsing a bunch of unwanted, non readable content. I assume because it shares the same
      parent as the other content.
      
## TODO
* Parsing multiple page articles
* Consider searching for a 'print' link on the page and use this content instead.  This content 
  tends to be a cleaner version of the original and it also tends to bypass the multiple page 
  article issue.
  
## Note on Patches/Pull Requests
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Send me a pull request. Bonus points for topic branches.


## Copyright
Copyright (c) 2009 Justin Palmer. See LICENSE for details.
