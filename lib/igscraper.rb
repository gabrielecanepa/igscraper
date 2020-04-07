require_relative "scraper/client"
require_relative "scraper/ext/csv"

class InstagramScraper
  class PostNotFound < StandardError
    def initialize(shortcode = nil, msg: "Can't find any post", exception_type: "custom")
      @exception_type = exception_type
      super(shortcode ? "#{msg} with shortcode #{shortcode}" : msg)
    end
  end

  attr_reader :posts
  attr_accessor :options

  def initialize(options = {})
    @options = options
    @scraper = Scraper::Client::Instagram.new(@options)
    @posts = []
  end

  def scrape(targets)
    @posts = targets.map { |target| @posts += @scraper.scrape_posts(target) }
  end

  def remove_post(shortcode)
    post = @posts.select { |saved_post| saved_post[:shortcode] == shortcode }.first
    raise PostNotFound.new shortcode unless post

    @posts.delete(post)
  end

  def update(options)
    @scraper = Scraper::Client::Instagram.new(options)
    @options = options
  end

  def to_csv(filepath = nil)
    file = File.new("~/Desktop/data.csv", "w+")
    CSV.insert_rows(filepath || file.path, @posts)
  end
end
