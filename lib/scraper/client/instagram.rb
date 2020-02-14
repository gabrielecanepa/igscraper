require "date"
require_relative "../ext/json"
require_relative "../ext/uri"

module Scraper
  class Client
    class Instagram
      BASE_URL = "https://www.instagram.com".freeze
      USER_QUERY_HASH = "ff260833edf142911047af6024eb634a".freeze
      HASHTAG_QUERY_HASH = "174a5243287c5f3a7de741089750ab3b".freeze

      DEFAULTS = {
        keywords: [],
        min_likes: 500,
        start_date: Date.new(2019, 1, 1),
        end_date: Date.today,
      }.freeze

      attr_accessor :keywords, :min_likes, :start_date, :end_date

      def initialize(options = {})
        @keywords = options[:keywords] || DEFAULTS[:keywords]
        @min_likes = options[:min_likes] || DEFAULTS[:min_likes]
        @start_date = options[:start_date] || DEFAULTS[:start_date]
        @end_date = options[:end_date] || DEFAULTS[:end_date]
        @uri_proxy = URI::Proxy.new
      end

      def scrape_posts(target)
        symbol, name = target.split("", 2)
        return unless %w[@ #].include?(symbol)

        type, path = symbol == "@" ? ["user", name] : ["hashtag", "explore/tags/#{name}"]
        resource = scrape_resource(path)[type]
        return unless resource

        resource[:type], resource[:path] = type, path
        posts = scrape_and_parse_posts(resource)
        target_info = { target: "#{symbol}#{name}", target_url: "#{BASE_URL}/#{path}" }
        posts.map { |post| target_info.merge(post) }
      end

      private

      ### Scrape a generic resource
      #
      #
      def scrape_resource(resource_path)
        resource_url = "#{BASE_URL}/#{resource_path}/?__a=1"
        response = @uri_proxy.open(resource_url).read
        resource = JSON.parse_without_exceptions(response)
        return unless resource

        resource["graphql"]
      end

      ### Scrape posts from a resource
      #
      #
      def scrape_and_parse_posts(resource, end_cursor: "")
        posts = []

        while end_cursor
          posts_data, end_cursor = scrape_posts_data_and_cursor(resource, end_cursor)
          break unless posts_data

          posts_data.each do |post_data|
            post = parse_post(post_data["node"])
            posts << post if post
          end
        end

        posts
      end

      def scrape_posts_data_and_cursor(resource, end_cursor)
        posts_url = build_posts_url(resource, end_cursor)
        data = JSON.parse_without_exceptions(@uri_proxy.open(posts_url).read)
        return unless data

        edge_type = resource[:type] == "user" ? "edge_user_to_photos_of_you" : "edge_hashtag_to_media"
        filtered_data = data["data"][resource[:type]][edge_type]
        [filtered_data["edges"], filtered_data["page_info"]["end_cursor"]]
      end

      def build_posts_url(resource, end_cursor)
        variables = { first: 50, after: end_cursor }
        variables[:id] = resource["id"] if resource[:type] == "user"
        variables[:tag_name] = resource["name"] if resource[:type] == "hashtag"
        query_hash = resource[:type] == "user" ? USER_QUERY_HASH : HASHTAG_QUERY_HASH
        query_params = { query_hash: query_hash, variables: variables.to_json }
        "#{BASE_URL}/graphql/query/?#{URI.encode_www_form(query_params)}"
      end

      ### Parse a post
      #
      #
      def parse_post(post_node)
        post = parse_post_node(post_node)
        return unless post_is_valid?(post)

        country_code, publisher = scrape_country_code_and_publisher(post[:shortcode])
        filtered_post = filter_post(post)
        filtered_post.merge(country_code: country_code, **(publisher || {}))
      end

      def parse_post_node(post_node)
        {
          caption: post_node["edge_media_to_caption"]["edges"]&.first&.[]("node")&.[]("text")&.gsub(/\n/, " "),
          comments: post_node["edge_media_to_comment"]["count"],
          likes: post_node["edge_liked_by"]["count"],
          shortcode: post_node["shortcode"],
          timestamp: post_node["taken_at_timestamp"],
        }
      end

      def filter_post(post)
        {
          post_url: "#{BASE_URL}/p/#{post[:shortcode]}",
          likes: post[:likes],
          comments: post[:comments],
          caption: post[:caption],
          date: Time.at(post[:timestamp]).strftime("%Y-%m-%d"),
        }
      end

      def post_is_valid?(post)
        conditions = [
          post[:likes] > @min_likes,
          post[:timestamp].between?(@start_date.to_time.to_i, @end_date.to_time.to_i),
          @keywords.empty? ||
            post[:caption] && @keywords.map(&:downcase).any? { |word| post[:caption].downcase.include?(word) },
        ]
        conditions.all?(true)
      end

      def scrape_country_code_and_publisher(post_shortcode)
        data = scrape_resource("p/#{post_shortcode}")&.[]("shortcode_media")
        return unless data

        address_json = data["location"]&.[]("address_json")
        country_code = address_json && JSON.parse_without_exceptions(address_json)&.[]("country_code")
        publisher = parse_publisher_data(data["owner"])
        [country_code, publisher]
      end

      def parse_publisher_data(data)
        name, username = data["full_name"], data["username"]
        {
          publisher: name,
          publisher_username: username,
          publisher_url: "#{BASE_URL}/#{username}",
        }
      end
    end
  end
end
