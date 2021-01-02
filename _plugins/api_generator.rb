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
      puts JSON.generate(data.entries)
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
      categories = {}
      posts = []

      site.categories.each_key do |category|
        categories[category] = []
        site.categories[category].each_entry do |post|
          if post.data['draft']
            continue
          end
          inserted_post = post.data.clone
          categories[category].append(inserted_post)
          posts.append(inserted_post)
        end
      end
      
      site.categories.each_key do |category|
        site.pages << ListingPage.new(site, category, categories[category], :categories)
      end
      site.pages << ListingPage.new(site, "", posts, :posts_index)
      site.pages << ListingPage.new(site, "", categories.keys, :categories_index)
    end
  end
end