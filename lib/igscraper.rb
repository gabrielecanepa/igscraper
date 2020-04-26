require_relative "scraper/client"
require_relative "scraper/ext/csv"

class InstagramScraper
  class PostNotFound < StandardError
    def initialize(shortcode = nil, msg: "can't find any saved post", exception_type: "custom")
      @exception_type = exception_type
      super(shortcode ? "#{msg} with shortcode #{shortcode}" : msg)
    end
  end

  class FileExists < StandardError
    def initialize(filepath = nil, msg: "file already exists", exception_type: "custom")
      @exception_type = exception_type
      super(filepath ? "#{msg} - #{filepath}" : msg)
    end
  end

  attr_reader :posts
  attr_accessor :options

  def initialize(options = {})
    scraper = Scraper::Client::Instagram.new(options)
    @options = scraper.options
    @posts = []
  end

  def scrape(target)
    scraper = Scraper::Client::Instagram.new(@options)
    posts = scraper.scrape_posts(target)
    @posts += posts
    posts
  end

  def remove_post(shortcode)
    post = @posts.select { |saved_post| saved_post[:shortcode] == shortcode }.first
    raise PostNotFound.new shortcode unless post

    @posts.delete(post)
  end

  def update(new_options)
    scraper = Scraper::Client::Instagram.new(@options.merge(new_options))
    @options = scraper.options
  end

  def to_csv(path = nil, force: false)
    default_path = "Downloads/Instagram Data (#{Time.now.strftime('%Y-%m-%d at %H.%M.%S')}).csv"
    filepath = "#{Dir.home}/#{path || default_path}"
    raise FileExists.new filepath if File.exist?(filepath) && !force

    file = File.open(filepath, "w+")
    !!CSV.insert_rows(file.path, @posts)
  end
end
