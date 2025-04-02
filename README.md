> [!IMPORTANT]
> This project uses a version of the Instagram API Platform [deprecated in early 2020](https://developers.facebook.com/blog/post/2018/01/30/instagram-graph-api-updates) and **is now read-only**.

# Instagram Scraper

A simple Ruby application to scrape Instagram posts, built using a set of helpers and proxies to bypass [Instagram API's rate limit](https://developers.facebook.com/docs/instagram-api/overview/#rate-limiting).

The app **doesn't need any API key** and can be used with a CLI app or a [Sinatra](http://sinatrarb.com)-based API.

## Table of contents

- [Usage](#usage)
  - [Ruby](#ruby)
  - [CLI](#cli)
  - [API](#api)
- [Contributing](#contributing)
- [License](#license)

## Usage

You must have Ruby 2.6.2 in order to run this application. If you don't already, install it with `rbenv install 2.6.2` or `rvm install ruby-2.6.2`.

Then, install the required gems with [Bundler](https://bundler.io):

```sh
bundle install
```

### Ruby

```ruby
require_relative "lib/igscraper"

options = {
  min_likes: 50,
  start_date: Date.new(2017, 01, 01),
  end_date: Date.new(2020, 01, 01),
  keywords: ["coding", "lewagon"],
}

@igscraper = InstagramScraper.new(options)

# Scrape posts by username or hashtag
@igscraper.scrape("@gabrisquonk")
@igscraper.scrape("@lewagonlisbon")
@igscraper.scrape("#lewagon")

# Read posts
@igscraper.posts # =>
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

# Remove a post by shortcode
@igscraper.remove_post("BgnpVPEHusZ")

# Update the options
new_options = {
  min_likes: 0,
  start_date: Date.new(2019, 01, 01),
  end_date: Date.today,
  keywords: [],
}
@igscraper.update(new_options)

# Scrape new posts using the updated options
@igscraper.scrape("@fedesquonk")

# Generate a CSV file containing the current posts
@igscraper.to_csv("Desktop/posts.csv") # path relative to $HOME
```

### CLI

> ⚠️ Make sure to have `./bin` in your `$PATH` and be in the `igscraper` folder

Run locally, specifying one or multiple comma-separated usernames/hashtags as target (without `#` before an hashtag):

```sh
igscraper -T @gabrisquonk,lewagon -l 50 -k coding,lisbon -o Desktop/posts.csv
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

Returns a CSV file containing the posts matching the specified parameters or an eventual error in JSON format.

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

\*at least one has to be specified

## Contributing

If you wish to contribute please [create a new issue](https://github.com/gabrielecanepa/igscraper/issues/new/choose) or [fork the repository](https://github.com/gabrielecanepa/igscraper/fork) and open a new pull request.

## License

[MIT](LICENSE)
