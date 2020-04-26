require "json"
require "sinatra/base"
require_relative "../ext/csv"

module Scraper
  class Api < Sinatra::Base
    configure do
      set :show_exceptions, false
    end

    before do
      @errors = []
    end

    not_found do
      add_error("This route doesn't exist")
      render_errors
    end

    error do |e|
      add_error(e.message)
      render_errors
    end

    private

    def validate_options
      yield if block_given? && @errors.empty?
    end

    def add_error(error)
      @errors << error
    end

    def render_errors
      content_type :json
      status 400

      { errors: @errors }.to_json
    end

    def render_unsuccess_message
      content_type :json
      status 200

      { message: "No results found with the specified options" }.to_json
    end

    def generate_csv_from_hash(hash, file_name = "data.csv")
      content_type "application/csv"
      status 200
      attachment file_name

      CSV.from_h(hash)
    end
  end
end
