# Instascraper

A simple Ruby application to scrape Instagram posts, built using a set of helpers and proxies to bypass [the API's rate limit](https://developers.facebook.com/docs/instagram-api/overview/#rate-limiting/).

The scraper can be used with a Ruby gem, a CLI app, or a [Sinatra](http://sinatrarb.com/)-based API.

## Usage

### Ruby

Install the gem with `gem install instascraper`.

```ruby
require "instascraper"

options = {
  target: %w[@lewagonlisbon @gabrisquonk #lewagon],
  min_likes: 100,
  start_date: Date.new(2018, 01, 01),
  keywords: %w[coding ruby lisbon]
}

instascraper(options) # => TODO: posts
```

### CLI

> ⚠️ Make sure to have `./bin` in your `$PATH`

Run locally, specifying one or multiple (comma-separated) usernames or hashtags as targets:

```sh
instascraper -T @gabrielecanepa,#lewagon -l 50 -k coding,lisbon
```

Print the usage message in your terminal:

```sh
instascraper -h
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
