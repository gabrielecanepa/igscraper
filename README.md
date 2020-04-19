# Instagram Scraper

A simple Ruby application to scrape Instagram posts, built using a set of helpers and proxies to bypass [Instagram API's rate limit](https://developers.facebook.com/docs/instagram-api/overview/#rate-limiting).

The scraper can be used with ([TODO: a gem](https://github.com/gabrielecanepa/igscraper/issues/2)), a CLI app, or a [Sinatra](http://sinatrarb.com)-based API.

## Table of contents

- [Usage](#usage)
  - [Ruby](#ruby)
  - [CLI](#cli)
  - [API](#api)
- [Development](#development)
- [License](#license)

## Usage

### Ruby

<!-- Install the gem with `gem install igscraper`. -->

```ruby
require_relative "lib/igscraper" # TODO: change to `require "igscraper"` when issue #2 is done

options = {
  min_likes: 50,
  start_date: Date.new(2017, 01, 01),
  end_date: Date.new(2020, 01, 01),
  keywords: ["coding", "lewagon"],
}

@scraper = InstagramScraper.new(options)

# Scrape posts by username or hashtag
@scraper.scrape(["@gabrisquonk", "#learntocode"])

# Read posts
@scraper.posts # =>
# [
#   {
#     :target=>"@gabrisquonk",
#     :target_url=>"https://www.instagram.com/gabrisquonk",
#     :shortcode=>"BgnpVPEHusZ",
#     :url=>"https://www.instagram.com/p/BgnpVPEHusZ",
#     :likes=>92,
#     :comments=>1,
#     :caption=> "Can we do it again, please? 🙏 #Batch122 #DemoDay Last Friday @lewagon 🎤 🙌 #coding #learning #erasmusforadults",
#     :date=>"2018-03-22",
#     :country_code=>"PT",
#     :publisher=>"Le Wagon Lisbon",
#     :publisher_username=>"lewagonlisbon",
#     :publisher_url=>"https://www.instagram.com/lewagonlisbon"
#   },
#   {
#     ...,
#   }
# ]

# Remove post by shortcode
@scraper.remove_post("BgnpVPEHusZ")

# Update the options
new_options = {
  min_likes: 200,
  start_date: Date.new(2019, 01, 01),
}
@scraper.update(new_options)

# Generate a csv file listing the posts
@scraper.to_csv("~/Desktop/posts.csv")
```

### CLI

> ⚠️ Make sure to have `./bin` in your `$PATH` and be in the `igscraper` folder

Run locally, specifying one or multiple (comma-separated) usernames/hashtags as targets:

```sh
igscraper -T @gabrisquonk,@lewagonlisbon -l 50 -k coding,lisbon -o Desktop/posts.csv
```

Print the usage message in your terminal:

```sh
igscraper --help
```

### API

> A `Procfile` has also been included for easy deployment! 🚀

Start a local server on port 5000:

```sh
foreman start
```

#### Endpoints

##### `GET` Get posts

Returns a CSV file as attachment, containing the posts matching the specified parameters or an eventual error in JSON format.

- **URL**: `/`

- **Method**: `GET`

- **URL Params**:

  - `users=[list]`\*
  - `hashtags=[list]`\*
  - `keywords=[list]`
  - `min_likes=[number]`
  - `start_date=[date]`
  - `end_date=[date]`
  - `output=[filename]`

\* at least one has to be specified

## Development

You must have Ruby 2.6.2 in order to run this application. If you don't already, just run `rbenv install 2.6.2` or `rvm install ruby-2.6.2`.

Then, install the required gems with [bundler](https://bundler.io):

```sh
bundle install
```

If you want to contribute, please [create an issue](https://github.com/gabrielecanepa/igscraper/issues/new/choose), or [fork the repository](https://github.com/gabrielecanepa/igscraper/fork) and open a new pull request.

## License

[MIT](./LICENSE)
