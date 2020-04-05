require_relative "scraper/client"

class Instascraper
  attr_reader :posts
  attr_writer :options

  def initialize(options = {})
    @options = options
    @scraper = Scraper::Client::Instagram.new(@options)
    @posts = []
  end

  def scrape(targets)
    targets.each { |target| @posts += @scraper.scrape_posts(target) }
    @posts
  end

  def remove_post(post_shortcode)
    post = @posts.select { |stored_post| stored_post[:post_shortcode] == post_shortcode }.first
    raise Error "Can't find post with shortcode #{post_shortcode}" unless post

    require "pry-byebug"
    binding.pry
  end

  def reset
    @scraper = Scraper::Client::Instagram.new(@options)
  end
end
