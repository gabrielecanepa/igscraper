require_relative "scraper/client"

def scrape_instagram_posts(target, options = {})
  scraper = Scraper::Client::Instagram.new(options)
  scraper.scrape_posts(target)
end
