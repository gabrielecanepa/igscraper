require "optparse"
require_relative "../client/instagram"
require_relative "../ext/csv"
require_relative "../ext/logger"
require_relative "../version"

module Scraper
  class Cli
    class Instagram
      class Options
        attr_accessor :target, :keywords, :min_likes, :start_date, :end_date, :output

        def initialize(options = {})
          @target = options[:target]
          @keywords = options[:keywords]
          @min_likes = options[:min_likes]
          @start_date = options[:start_date]
          @end_date = options[:end_date]
          @output = options[:output]
        end

        def define_parser_options(parser)
          @parser = parser
          @parser.program_name = "instascraper v#{VERSION}"
          @parser.banner = "Usage: #{@parser.program_name} -T <target> [options]"
          @parser.separator "\nArguments:"
          define_arguments
          @parser.separator "\nOptions:"
          define_options
        end

        def to_hash
          Hash[instance_variables.map { |option| [option[1..-1].to_sym, instance_variable_get(option)] }]
        end

        private

        def define_arguments
          @parser.on("-T <target>",
                     Array,
                     "Specify one or multiple (comma-separated) usernames or hashtags to scrape from " \
                     "(e.g. @nike,#shoes)") do |target|
            @target = target
          end
        end

        def define_options
          define_keywords_option
          define_min_likes_option
          define_start_date_option
          define_end_date_option
          define_output_option
          define_help_option
          define_version_option
          define_joke_option
        end

        def define_keywords_option
          @parser.on("-k", "--keywords [x,y,z]",
                     Array,
                     "Specify one or multiple (comma-separated) keywords that must be present in a post caption " \
                     "(e.g. sportswear,influencer)") do |keywords|
            @keywords = keywords
          end
        end

        def define_min_likes_option
          @parser.on("-l", "--min-likes [NUM]",
                     Integer,
                     "Specify the minimum amount of likes for a post " \
                     "(defaults to 500)") do |min_likes|
            @min_likes = min_likes
          end
        end

        def define_start_date_option
          @parser.on("-s", "--start-date [DATE]",
                     String,
                     "Specify the minimum date for a post in YYYY-MM-DD format " \
                     "(defaults to 2019-01-01)") do |start_date|
            @start_date = Date.new(*start_date.split("-").map(&:to_i))
          end
        end

        def define_end_date_option
          @parser.on("-e", "--end-date [DATE]",
                     String,
                     "Specify the maximum date for a post in YYYY-MM-DD format " \
                     "(defaults to today)") do |end_date|
            @end_date = Date.new(*end_date.split("-").map(&:to_i))
          end
        end

        def define_output_option
          @parser.on("-o", "--output [PATH]",
                     String,
                     "Specify an output file relative to your home directory " \
                     "(defaults to 'Downloads/Instagram Data (:timestamp).csv')") do |output|
            @output = output
          end
        end

        def define_help_option
          @parser.on_tail("-h", "--help", "Print this help message") do
            Logger.log_message(@parser)
            exit
          end
        end

        def define_version_option
          @parser.on_tail("-v", "--version", "Print the current version of the scraper") do
            Logger.log_message(VERSION)
            exit
          end
        end

        def define_joke_option
          @parser.on_tail("--joke", "Print a random bad joke") do
            joke = open("https://icanhazdadjoke.com", "Accept" => "text/plain").read
            Logger.log_message(joke)
            exit
          end
        end
      end

      DEFAULTS = {
        output: "Downloads/Instagram Data (#{Time.now.strftime('%Y-%m-%d at %H.%M.%S')}).csv",
      }.freeze

      def initialize(args, defaults = DEFAULTS)
        @args = args
        @defaults = defaults
        @posts_count = 0
      end

      def run
        @options = parse_options
        @scraper = Client::Instagram.new(@options)
        run_client
        log_final_message
      end

      private

      ### Parse and validate options
      #
      #
      def parse_options
        options = Instagram::Options.new(@defaults)
        parse_with_optparse(options)
      rescue OptionParser::ParseError => e
        Logger.log_error_message(e)
        exit
      else
        options.to_hash
      end

      def parse_with_optparse(options)
        OptionParser.new do |parser|
          options.define_parser_options(parser)
          parser.parse!(@args)
          validate_options(options)
        end
        options
      end

      def validate_options(options)
        output_dir = options.output.rpartition("/")[0]
        raise OptionParser::MissingArgument, "you must specify at least one brand or hashtag" unless options.target
        raise OptionParser::InvalidArgument, "#{options.output} already exists" if File.exist?(options.output)
        return if File.directory?("#{Dir.home}/#{output_dir}")

        raise OptionParser::InvalidArgument, "the folder #{output_dir} doesn't exist"
      end

      ### Run the client
      #
      #
      def run_client
        @options[:target].each do |resource|
          posts = scrape_posts(resource)
          next unless posts

          @posts_count += posts.count
          store_posts(resource, posts)
        end
      end

      def scrape_posts(resource)
        Logger.log_recursive_message("Scraping data from #{resource}..")
        @scraper.scrape_posts(resource)
      rescue OpenURI::HTTPError
        symbol, name = resource[0], resource[1..-1]
        Logger.log_error_message("The #{symbol == '@' ? 'username' : 'hashtag'} #{name} doesn't exist")
      end

      def store_posts(resource, posts)
        if posts.empty?
          Logger.log_error_message("Can't find any valid post for #{resource}")
        else
          CSV.append_rows_from_hash("#{Dir.home}/#{@options[:output]}", posts)
          Logger.log_success_message("Scraped #{posts.count} posts from #{resource}")
        end
      end

      def log_final_message
        Logger.log_break
        if @posts_count.zero?
          Logger.log_error_message("😱 No posts were found with the specified options")
        else
          Logger.log_success_message("🎉 Done! #{@posts_count} posts successfully saved in #{@options[:output]}")
        end
      end
    end
  end
end
