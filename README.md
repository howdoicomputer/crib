# Crib [![Build Status](https://travis-ci.org/rafalchmiel/crib.svg?branch=master)](https://travis-ci.org/rafalchmiel/crib) [![Coverage Status](https://coveralls.io/repos/rafalchmiel/crib/badge.svg?branch=master)](https://coveralls.io/r/rafalchmiel/crib?branch=master) [![Documentation Status](http://inch-ci.org/github/rafalchmiel/crib.svg?branch=master)](http://inch-ci.org/github/rafalchmiel/crib) [![Code Climate](https://codeclimate.com/github/rafalchmiel/crib/badges/gpa.svg)](https://codeclimate.com/github/rafalchmiel/crib) [![Gem Version](https://badge.fury.io/rb/crib.svg)](http://badge.fury.io/rb/crib)
**Crib** allows you to dynamically explore and package most REST APIs using an intuitive syntax that resembles a HTTP URI path. It uses [Sawyer](https://github.com/lostisland/sawyer) under the hood so things like authentication and passing certain headers to every request are simple.

In the below example, we are using the Dribbble API to [get the name of the currently authenticated user](http://developer.dribbble.com/v1/users/#get-the-authenticated-user), then just a single user in order to demonstrate arguments:

```ruby
dribbble = Crib::API.new('https://api.dribbble.com/v1') do |http|
  http.authorization 'Bearer', '1aea05cfdbb92294be2fcf63ee11b412fd88c65051bd3144302c30ae8ba18896'
end

me = dribbble.user
me._get.name
 # => "Rafal Chmiel"

dan = dribbble.users('simplebits')
dan._get.name
 # => "Dan Cederholm"
```

If you're interested in building a REST API client you can use the `Crib::Resource` class which provides a DSL. Here's an interesting example of this functionality demonstrated using the [GitHub API](https://developer.github.com/v3/):

```ruby
class GitHub < Crib::Resource
  define 'https://api.github.com' do |http|
    http.headers[:user_agent] = 'crib'
  end

  action :user do |user|
    get api.users(user)
  end

  action :issues do |repo, options = {}|
    get api.repos(*repo.split('/')).issues, options
  end
end

github = GitHub.new

me = github.user('rafalchmiel')
me.name
 # => "Rafal Chmiel"

rails_issues = github.issues('rails/rails', per_page: 2)
rails_issues.count
 # => 2
```

## Philosophy
The aim of this project is to be able to explore and package most REST APIs using a straightforward syntax and an intuitive DSL. **Crib** uses Sawyer to simplify requests and easily read responses, which means there's no need to overcomplicate response handling and middleware.

### Inspiration
**Crib** takes a lot of its inspiration from [Blanket](https://github.com/inf0rmer/blanket). The aim of this project is not to compete with Blanket, but to produce a very different flavour of it. Some parts of the documentation and code are borrowed from [Octokit](https://github.com/octokit/octokit.rb) and [Resource Kit](https://github.com/digitalocean/resource_kit).

## Quick Start
Install the latest stable version of **Crib** via RubyGems:

```bash
$ gem install crib
```

Alternatively add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'crib'
```

At the top of your code, require the library:

```ruby
require 'crib'
```

### Defining an API
In order to define a REST API in **Crib** you need to initialise a new `Crib::API` class passing it the endpoint, any optional Sawyer options, and an optional block for Sawyer to yield connection options to.

As Sawyer is built on top of [Faraday](https://github.com/lostisland/faraday), the options in this block are yielded to a `Faraday::Connection` which means you can set headers, authentication stuff, and middleware like this:

```ruby
dribbble = Crib::API.new('https://api.dribbble.com/v1') do |http|
  http.headers[:user_agent] = 'crib'
  http.authorization 'Bearer', '1aea05cfdbb92294be2fcf63ee11b412fd88c65051bd3144302c30ae8ba18896'
  http.response :logger # take note of this, it logs all requests in the following examples
end

dribbble.users('simplebits')._get.id
 # I, [2015-01-02T14:59:20.183319 #6990]  INFO -- : get https://api.dribbble.com/v1/users/simplebits
 # D, [2015-01-02T14:59:20.183436 #6990] DEBUG -- request: User-Agent: "crib"
 # Authorization: "Bearer 1aea05cfdbb92294be2fcf63ee11b412fd88c65051bd3144302c30ae8ba18896"
 # I, [2015-01-02T14:59:20.183742 #6990]  INFO -- Status: 200
 # D, [2015-01-02T14:59:20.183890 #6990] DEBUG -- response: server: "nginx"
 # date: "Fri, 02 Jan 2015 14:59:20 GMT"
 # content-type: "application/json; charset=utf-8"
 # (...)
 #
 # => 1
```

Defining an API using the DSL is almost the same: just replace `Crib::API.new` with `define` (the definition will be accessible via `#api`):

```ruby
class Dribbble < Crib::Resource
  define 'https://api.dribbble.com/v1' do |http|
    http.headers[:user_agent] = 'crib'
    http.authorization 'Bearer', '1aea05cfdbb92294be2fcf63ee11b412fd88c65051bd3144302c30ae8ba18896'
    http.response :logger
  end

  # ...
end
```

### Constructing Requests
**Crib** uses `#method_missing` for `Crib::API` and `Crib::Request` instances. This means when you call, for example, `#users('rafalchmiel')` on your API a new instance of `Crib::Request` is created and returned (with the private instance variable `@uri` set to `"users/rafalchmiel"`). This allows you to chain methods together, because these new instances create new instances of their own class, each time joining together their URIs. For example:

```ruby
# GET /users/:user/followers
dribbble.users('rafalchmiel').followers
 # => <Crib::Request @api=#<Crib::API @_agent=<Sawyer::Agent https://api.dribbble.com/v1>, @_last_response=#<Sawyer::Response 200 @rels={} @data={...}>, @uri="users/rafalchmiel/followers">
```

Alternatively you can use `#send` passing it a String containing a path. For example the above can be written as:

```ruby
dribbble.send('users/rafalchmiel/followers')
 # => <Crib::Request @api=#<Crib::API @_agent=<Sawyer::Agent https://api.dribbble.com/v1>, @_last_response=#<Sawyer::Response 200 @rels={} @data={...}>, @uri="users/rafalchmiel/followers">
```

Constructing requests when using the DSL is exactly the same. After you defined your API, your instance of `Crib::API` will be stored in the class that inherits `Crib::Resource`. You can get that instance using `#api`:

```ruby
class Dribbble < Crib::Resource
  # ...

  action :user do
    get api.user # currently authenticated user
  end
end
```

### Consuming Resources
So far we have only *constructed* a request. It's time to execute the request with a HTTP verb of your choice. You can call any of the HTTP verbs (prefixed with an underscore to keep the namespace unpoluted) on any `Crib::Request` instance you constructed. All these HTTP verb methods take an optional parameter and header Hash also (pass parameters in `:query` Hash and headers in `:headers` Hash). For example:

```ruby
followers = dribbble.users('rafalchmiel').followers
followers._get
 # I, [2015-01-02T15:54:00.196740 #6990]  INFO -- : get https://api.dribbble.com/v1/users/rafalchmiel/followers
 # (...)
 #
 # => [{:id=>3178237 (...)}]

dribbble.shots._get(query: { sort: :comments })
 # I, [2015-01-02T16:44:00.989936 #8284]  INFO -- : get https://api.dribbble.com/v1/shots?sort=comments
 # (...)
 #
 # => [{:id=>1865147 (...)}]
```

All responses are `Sawyer::Resource` objects which provide dot notation and `[]` access for fields returned in the API response:

```ruby
me = dribbble.users('rafalchmiel')._get
me.name
 # => "Rafal Chmiel"
me.fields
 # => #<Set: {:id, :name, :username, :html_url, :avatar_url, :bio, :location, :links, :buckets_count, :followers_count, :followings_count, :likes_count, :projects_count, :shots_count, :teams_count, :type, :pro, :buckets_url, :followers_url, :following_url, :likes_url, :projects_url, :shots_url, :teams_url, :created_at, :updated_at}>
me[:username]
 # => "RafalChmiel"
me.rels[:followers].href
 # => "https://api.dribbble.com/v1/users/97203/followers"
```

*Note:* URL fields are culled into a separate `.rels` collection for easier [Hypermedia](#hypermedia-agent) support.

Consuming requests is similar when using the DSL. You define *actions* which have a name and a block. They are then created as instance methods of the class that inherited `Crib::Resource`. The return value of the block you pass to `.action` is the return value of the method it defines, most likely a `Sawyer::Response`.

In order to keep your DSL code as clean as possible, Crib provides HTTP verb methods so that you don't have to call `#_get`, `#_post`, etc. every single time you define an action and want to request a resource. The DSL methods include: `.get`, `.post`, `.put`, `.patch`, `.delete`, and `.head`. They take a `Crib::Request` object and an optional *options* Hash (just like the verb methods prefixed with an underscore).

A great example of all this can be presented using this example:

```ruby
class GitHub < Crib::Resource
  # ...

  action :issues do |repo, options = {}|
    get api.repos(*repo.split('/')).issues, options
  end
end

github = GitHub.new
github.issues('rails/rails', per_page: 2)
 # => ...
```

If you need to, you can override the API definition set in the class with `.define` and instead pass your own, when initialising your class:

```ruby
custom_github = GitHub.new(Crib::API.new('https://api.github.dev'))
```

#### Accessing HTTP Responses
While all HTTP verb methods (`#_get`, `#_post`, etc.) return a `Sawyer::Resource` object, sometimes you may need access to the raw HTTP response headers. You can access the last HTTP response like this:

```ruby
last_response = dribbble._last_response
 # => #<Sawyer::Response 200 @rels={} @data={:id=>97203 (...)}>
last_response.headers[:last_modified]
 # => "Fri, 02 Jan 2015 14:35:08 GMT"
```

When using the DSL, you can access the most recent response using `#last_response`:

```ruby
class Dribbble < Crib::Resource
  # ...
end

dribbble = Dribbble.new
dribbble.user
 # => ...

dribbble.last_response
 # => #<Sawyer::Response 200 @rels={} @data={:id=>97203 (...)}>
```

#### Hypermedia Agent
**Crib** is [hypermedia](http://en.wikipedia.org/wiki/Hypermedia)-enabled. Under the hood, **Crib** uses Sawyer, a hypermedia client built on Faraday.

Resources returned by the underscore-prefixed HTTP methods contain not only data but hypermedia link relations:

```ruby
me = dribbble.users('rafalchmiel')._get

me.rels
 # => {:html_url=>"https://dribbble.com/RafalChmiel",
 #   :avatar_url=>
 #   "https://d13yacurqjgara.cloudfront.net/users/97203/avatars/normal/profile-icon-margin-transparent.png?1385898916",
 #   :buckets_url=>"https://api.dribbble.com/v1/users/97203/buckets",
 #   :followers_url=>"https://api.dribbble.com/v1/users/97203/followers",
 #   :following_url=>"https://api.dribbble.com/v1/users/97203/following",
 #   :likes_url=>"https://api.dribbble.com/v1/users/97203/likes",
 #   :projects_url=>"https://api.dribbble.com/v1/users/97203/projects",
 #   :shots_url=>"https://api.dribbble.com/v1/users/97203/shots",
 #   :teams_url=>"https://api.dribbble.com/v1/users/97203/teams"}

# Get the followers 'rel', returned from the API as 'followers_url'
me.rels[:followers].href
 # => "https://api.dribbble.com/v1/users/97203/followers"

followers = me.rels[:followers].get.data
followers.first.follower.name
 # => "Kevin Halley"
```

When processing API responses, all `*_url` attributes are culled in to the link relations collection. Any `url` attribute becomes `.rels[:self]`.

## Supported Ruby Versions
**Crib** aims to support and is [tested against](https://travis-ci.org/rafalchmiel/crib) the following Ruby implementations:

  - 2.2.0
  - 2.1.5
  - 2.0.0-p598
  - 1.9.3-p551

If something doesn't work on one of these Ruby versions, it's a bug. **Crib** may inadvertently work (or seem to work) on other Ruby implementations, however support will only be provided for the versions listed above.

If you would like **Crib** to support another Ruby version, you may volunteer to be a maintainer. Being a maintainer entails making sure all tests run and pass on that implementation. When something breaks on your implementation, you will be responsible for providing patches in a timely fashion. If critical issues for a particular implementation exist at the time of a major release, support for that Ruby version may be dropped.

## Development
If you want to hack on **Crib** locally, we try to make [bootstrapping the project](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) as painless as possible. Just clone and run:

```bash
$ script/bootstrap
```

This will install project dependencies and get you up and running. If you want to run a Pry console to poke on **Crib**, you can crank one up with:

```bash
$ script/console
```

Using the scripts in `./script` instead of `bundle exec rspec`, `bundle console`, etc. ensures your dependencies are up-to-date.
