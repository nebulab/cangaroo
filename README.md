[![Gem Version](https://badge.fury.io/rb/cangaroo.svg)](https://badge.fury.io/rb/cangaroo)
[![Code Climate](https://codeclimate.com/github/nebulab/cangaroo/badges/gpa.svg)](https://codeclimate.com/github/nebulab/cangaroo)
[![BuildStatus](https://travis-ci.org/nebulab/cangaroo.svg?branch=master)](https://travis-ci.org/nebulab/cangaroo)
[![Test Coverage](https://codeclimate.com/github/nebulab/cangaroo/badges/coverage.svg)](https://codeclimate.com/github/nebulab/cangaroo/coverage)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/nebulab/cangaroo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Cangaroo

Cangaroo is a Rails Engine that helps developers integrating their apps with 
any service. 
It's like a message broker, it receive messages from apps/services then based 
on developer defined rules it can route the messages to other apps/services or 
just execute jobs. 

[TODO] add self-explanatory image here.

#### When/Why you should use Cangaroo?

Cangaroo allows to move the logic related to external services connection and
synchronization between multiple applications.

This logic will reside in a shared area without the need to replicate it for
any system component. It's especially useful when working with larger
system formed by multiple applications that need to send messages to each other
and to external services.

This kind of configuration allows:
- don't overload your application resources allowing to scale the number
of requests that can be handled;
- in case of errors or downtimes of any system component, Cangaroo stores each
message and retry sending it until it's successfully delivered;
- use and contribute to a lot of integrations that has already be done by the
community.

## Dependencies

  - rails (>= 4.2.4)

## Installation

Cangaroo is a Rails Engine so as usual you can install it by using
[Bundler](http://bundler.io) by adding it to your application's Gemfile:

```ruby
  # Gemfile
  gem 'cangaroo'
```

And then executing:

    $ bundle

Install the needed migration with:

    $ bin/rake cangaroo:install:migrations

And then executing:

    $ bin/rake db:migrate

Now mount the engine into your `routes.rb` file:

```ruby
  # routes.rb
  ...
  mount Cangaroo::Engine => "/cangaroo"
  ...
```

## Usage

To authenticate incoming messages from an app/service we need to instruct 
Cangaroo, this is done through [connections](https://github.com/nebulab/cangaroo/wiki/Connection).
A basic connection have a custom `name` the `url` of that connection and a `key`
and `password` for authentication; on the other side the `connection` will use
the [Push API](https://github.com/nebulab/cangaroo/wiki/Push-API) to send messages to Cangaroo.
Praticaly create a `connection` means add it to the database:

```ruby
  Cangaroo::Connection.create(
    name: 'mystore',
    url: 'http://www.mystore.com',
    key: 'puniethahquoe5aisefoh9ci0Shuaniemei6jahx',
    token: 'ahsh8phuezu3xuhohs6kai5vaB1tae0wiy1shohp'
  )
```

Then Jobs are used to do stuff with incoming connection messages, they are 
simple `ActiveJob::Base` with a little more features, Cangaroo provide three 
different kind of jobs:

- Simple Job
- [Push Job](https://github.com/nebulab/cangaroo/wiki/Push-Job)
- Poll Job

in this example the simple job is used, suppose that an ecommerce sends a 
message to Cangaroo with all new orders and the only feature is to log only the 
`completed` orders. 
For this feature is needed a `Job` that inherits from `Cangaroo::Job` class,
this job implement two method, the standard `perform` method that will log
the message and a `perform?` method, this is were rules that decide to run or
not run the job leaves. 
The job could be something like this:

```ruby
module Cangaroo
  class LogJob < Cangaroo::Job
    def perform(:source_connection, :type, :payload)
      super
      Cangaroo.logger.info 'New order received', payload: payload
    end
    
    def perform?
      type == 'orders' &&
      payload['status'] == 'completed'
    end
  end
end
```

The first thing to notice is that `super` is called on the `perform` method, 
this is because `Cangaroo::Job#perform` sets the `source_connection`, `type` and 
the `payload` attributes so they can be used in `perform?` and `perform` 
methods. 
The `perform?` method check if the message type is an `orders` kind and if 
the the order is completed looking into the payload. Every time Cangaroo receive
a message run the `perform?` method for each job, if it return `true`
it enqueue the job.
Then the `perform` method simple log the information.

The last thing to do is let Cangaroo know that the job exists, this is done by
add it to the `Rails.configuration.cangaroo.jobs`:

```ruby
  # config/initializers/cangaroo.rb

  Rails.configuration.cangaroo.jobs = [Cangaroo::LogJob]
```

## How it works

Cangaroo provides a Push API where you can send your data. After data has
been received, Cangaroo run jobs based on your business logic.

This is the detailed flow:

  - Cangaroo receives the data
  - If some error like "wrong key and token" or "malformed json" is raised
    Cangaroo returns an HTTP status code based on the error type:
    - `406` for wrong request
    - `401` for Unauthorized
    - `500` for wrong json schema
    - `500` for Cangaroo internal errors
  - If there are no errors, for each object in the json body, Cangaroo checks
    what jobs must be enqueued by calling the `#perform?` method. Each job
    returning `true` to `#perform?` will be enqueued.

## Tests

Tests are written using rspec and Appraisals

* Run `bundle exec appraisal install` before running any specs
* `bundle exec rake` will run the test suite for rails 4 and rails 5
* `bundle exec rspec` will run specs for a single rails version
* if you want run specs only for for rails 4 run `appraisal rails-4 rake`, for rails 5 run `appraisal rails-5 rake`.

## License

Cangaroo is copyright © 2016 [Nebulab](http://nebulab.it/). It is free software, and may be redistributed under the terms specified in the [license].

## About

![Nebulab](http://nebulab.it/assets/images/public/logo.svg)

Cangaroo is funded and maintained by the [Nebulab](http://nebulab.it/) team.

We firmly believe in the power of open-source. [Contact us](http://nebulab.it/contact-us/) if you like our work and you need help with your project design or development.

[license]: MIT-LICENSE
