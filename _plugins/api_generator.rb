require 'json'

module Jekyll
  class PostConverter < Converter
    safe true
    priority :low
    def matches(ext)
      ext =~ /^\.md$/i
    end

    def output_ext(ext)
      ".json"
    end

    def convert(content)
      content
    end
  end

  def Jekyll.serialize(item)
    JSON.generate(JSON.parse(item))
  end

  Hooks.register :posts, :post_render do |post|
    post.output = serialize(post.output)
  end

  Hooks.register :pages, :post_render do |page|
    page.output = serialize(page.output)
  end

  class ListingPage < Page
    def initialize(site, category, entries, type)
      @site = site
      @base = site.source
      @dir = category
     
      @basename = 'index'
      @ext = '.json'
      @name = 'index.json'
      @data = {
        'entries' => entries
      }
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(relative_path, type, key)
      end
    end

    def url_placeholders
      {
        :category   => @dir,
        :path => @dir,
        :basename   => basename,
        :output_ext => output_ext,
      }
    end
  end
  
  class ApiGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      posts = site.posts.docs.map{ |post| post.data.clone }

      site.categories.each_key do |category|
        categories = site.categories[category].map{ |post| post.data.clone }

        site.pages << ListingPage.new(site, 
                                      category, 
                                      categories, 
                                      :categories)
      end
      site.pages << ListingPage.new(site, 
                                    "", 
                                    posts, 
                                    :posts_index)
      site.pages << ListingPage.new(site, 
                                    "", 
                                    site.categories.keys, 
                                    :categories_index)
    end
  end
end