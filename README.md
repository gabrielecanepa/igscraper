# Instagram Scraper

A simple Ruby gem/application to scrape Instagram posts, built using a set of helpers and proxies to bypass [the API's rate limit](https://developers.facebook.com/docs/instagram-api/overview/#rate-limiting/).

The scraper can be used with <!-- TODO: a Ruby gem, -->a CLI app, or a [Sinatra](http://sinatrarb.com/)-based API.

## Usage

### Ruby

<!-- Install the gem with `gem install igscraper`. -->

```ruby
require_relative "lib/igscraper"

options = {
  min_likes: 50,
  start_date: Date.new(2017, 01, 01),
  end_date: Date.new(2020, 01, 01),
  keywords: ["coding", "lewagon"],
}

@scraper = InstagramScraper.new(options)
@scraper.scrape(["@gabrisquonk", "@lewagonlisbon"])
@scraper.posts # =>
# [{
#   :target=>"@gabrisquonk",
#   :target_url=>"https://www.instagram.com/gabrisquonk",
#   :shortcode=>"BgnpVPEHusZ",
#   :url=>"https://www.instagram.com/p/BgnpVPEHusZ",
#   :likes=>92,
#   :comments=>1,
#   :caption=> "Can we do it again, please? 🙏 #Batch122 #DemoDay # last Friday 🎤 🙌⚡️ One of the most theatrical shows # to ever be put on at Le Wagon.  This batched rocked it # #literally 🤘 Congrats you wonderful humans, you # 😘👏😆 Check out www.lewagon.com/demoday/122 to see # the live recording 📺💥 . . .  #learntocode # #changeyourlife #batch122 #startupportugal #lisbon # #lisboa #startups #ruby #rubyonrails #fullstack # #fullstackdeveloper #codeschool #entrepreneurs # #startuplife #codebootcamp #codingbootcamp #coding # #hiit #learning #erasmusforadults",
#   :date=>"2018-03-22",
#   :country_code=>nil,
#   :publisher=>"Le Wagon Lisbon",
#   :publisher_username=>"lewagonlisbon",
#   :publisher_url=>"https://www.instagram.com/lewagonlisbon"
# },
# {
#   ...
# }
@scraper.remove_post("BgnpVPEHusZ") # delete by post shortcode
```

### CLI

> ⚠️ Make sure to have `./bin` in your `$PATH`

Run locally, specifying one or multiple (comma-separated) usernames or hashtags as targets:

```sh
igscraper -T @gabrisquonk,@lewagonlisbon -l 50 -k coding,lisbon -o Desktop/data.csv
```

Print the usage message in your terminal:

```sh
igscraper -h
```

### API

Start a local server on port 5000 with:

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
