# Instagram Scraper

A simple Ruby application to scrape Instagram posts, built using a set of helpers and proxies to bypass [Instagram API's rate limit](https://developers.facebook.com/docs/instagram-api/overview/#rate-limiting).

The scraper can be used with <!-- TODO: a Ruby gem! -->a CLI app, or a [Sinatra](http://sinatrarb.com)-based API.

## Setup

You must use Ruby 2.6.2 in order to run this application. If you have it, run `rvm install ruby-2.6.2` or `rbenv install 2.6.2`.

Once you have it, install the required gems with bundler:

```sh
bundle install
```

## Usage

### Ruby

<!-- Install the gem with `gem install igscraper`. -->

```ruby
require_relative "lib/igscraper" # TODO: change to `require "igscraper"` when the gem will be available (see https://github.com/gabrielecanepa/igscraper/projects/5#card-35874375)

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
@scraper.posts
# => [{
#       :target=>"@gabrisquonk",
#       :target_url=>"https://www.instagram.com/gabrisquonk",
#       :shortcode=>"BgnpVPEHusZ",
#       :url=>"https://www.instagram.com/p/BgnpVPEHusZ",
#       :likes=>92,
#       :comments=>1,
#       :caption=> "Can we do it again, please? 🙏 #Batch122 #DemoDay # last Friday 🎤 🙌⚡️ # lewagon #coding #learning #erasmusforadults",
#       :date=>"2018-03-22",
#       :country_code=>"PT",
#       :publisher=>"Le Wagon Lisbon",
#       :publisher_username=>"lewagonlisbon",
#       :publisher_url=>"https://www.instagram.com/lewagonlisbon"
#     },
#     ..,
#     {
#      ..,
#     }]

# Remove post by shortcode
@scraper.remove_post("BgnpVPEHusZ")

# Update the options
new_options = {
  min_likes: 200,
  start_date: Date.new(2019, 01, 01),
}
@scraper.update(new_options)

# Generate a csv file containing the posts
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

Start a local server on port 5000:

```sh
foreman start
```

#### Endpoints

##### `GET` Get posts

Returns a CSV file as attachment, containing the posts matching the specified parameters, or an eventual error in JSON format.

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

## License

[MIT](https://gabrielecanepa.mit-license.org)
