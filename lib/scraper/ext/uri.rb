require "open-uri"

module URI
  class Proxy
    PROXIES_API_URL = "https://api.proxyscrape.com".freeze

    DEFAULTS = {
      proxytype: "http",
      timeout: 1000,
      country: "all",
      ssl: "yes",
      anonymity: "elite",
    }.freeze

    def initialize(options = DEFAULTS)
      @proxies = scrape_and_parse_proxies(options)
      @proxy_index = 0
    end

    def open(uri)
      URI.open(uri)
    rescue StandardError => e
      handle_network_error(uri, e)
    end

    private

    def scrape_and_parse_proxies(options)
      URI.open("#{PROXIES_API_URL}?request=getproxies&#{URI.encode_www_form(options)}").read.split(/\r\n/)
    end

    def open_with_proxy(uri)
      proxy = @proxies[@proxy_index]
      unless proxy
        @proxy_index = 0
        self.open(uri)
      end

      URI.open(uri, proxy: "http://#{proxy}")
    rescue StandardError => e
      handle_network_error(uri, e)
    end

    def handle_network_error(uri, error)
      raise error if error.class == OpenURI::HTTPError && error.io.status.first == "404"

      @proxy_index += 1
      open_with_proxy(uri)
    end
  end
end
