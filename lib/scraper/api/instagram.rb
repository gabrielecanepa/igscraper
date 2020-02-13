require_relative "base"
require_relative "../client/instagram"

module Scraper
  class Api
    class Instagram < self
      get "/" do
        run_instagram_scraper(params)
      end

      private

      def run_instagram_scraper(params)
        @options = parse_params(params)
        validate_instagram_options
        return render_errors unless @errors.empty?

        @scraper = Client::Instagram.new(@options)
        posts = scrape_posts_from_resources
        posts.empty? ? render_unsuccess_message : generate_csv_from_hash(posts, @options[:output])
      end

      def scrape_posts_from_resources
        resources = [*@options[:users]&.map { |u| "@#{u}" }, *@options[:hashtags]&.map { |h| "##{h}" }]

        resources.reduce([]) do |posts, resource|
          resource_posts = @scraper.scrape_posts(resource)
          next posts unless resource_posts

          posts + resource_posts
        end
      end

      def validate_instagram_options
        validate_options do
          [*@options[:users], *@options[:hashtags]].empty? && add_error("You must specify at least one user or hashtag")
          return unless @options[:start_date] && @options[:end_date] && @options[:start_date] > @options[:end_date]

          add_error("Start date must come before end date")
        end
      end

      def parse_params(params) # rubocop:disable Metrics/AbcSize
        {
          users: params[:users]&.split(","),
          hashtags: params[:hashtags]&.split(","),
          keywords: params[:keywords]&.split(","),
          min_likes: params[:min_likes]&.to_i,
          start_date: params[:start_date] && Date.new(*params[:start_date]&.split("-")&.map(&:to_i)),
          end_date: params[:end_date] && Date.new(*params[:end_date]&.split("-")&.map(&:to_i)),
          output: params[:output] || "Instagram Data (#{Time.now.strftime('%Y-%m-%d at %H.%M.%S')}).csv",
        }
      end
    end
  end
end
