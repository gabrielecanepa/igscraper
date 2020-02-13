# Instagram Scraper

A simple Ruby application to scrape Instagram posts (tagged or from an hashtag), built using a set of helpers and proxies necessary to bypass the API rate limit.

The scraper can be used with a CLI or a Sinatra-based API.

## Setup

Install the required gems with:

```sh
bundle
```

## Usage

### Ruby

```ruby
require_relative "lib/scraper"

scrape_instagram_posts("@nike", min_likes: 10_000, keywords: %w[sportswear shoes influencer]) # => array of posts
```

### CLI

Run locally, specifying one or multiple (comma-separated) usernames or hashtags as target:

```sh
bin/instagram_scraper -T @nike,@adidas -l 10000 -k sportswear,shoes,influencer
```

Print the usage message in your terminal:

```sh
bin/instagram_scraper -h
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
