[![Gem Version](https://badge.fury.io/rb/cangaroo.svg)](https://badge.fury.io/rb/cangaroo)
[![Code Climate](https://codeclimate.com/github/nebulab/cangaroo/badges/gpa.svg)](https://codeclimate.com/github/nebulab/cangaroo)
[![BuildStatus](https://travis-ci.org/nebulab/cangaroo.svg?branch=master)](https://travis-ci.org/nebulab/cangaroo)
[![Test Coverage](https://codeclimate.com/github/nebulab/cangaroo/badges/coverage.svg)](https://codeclimate.com/github/nebulab/cangaroo/coverage)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/nebulab/cangaroo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Cangaroo

Cangaroo helps developers integrating their apps with any service.

## The whole story

Some time ago Spree decided to shut down Wombat and to release its closed
source code to customers only, so we had to decide how to continue, installing
Wombat by ourselves for some of our clients or starting a new open source
project with an API compliant with Wombat's.

We believe in open source so we chose the latter and this project was born.
The idea is a little different from Wombat, the goal of this project is to
provide a backwards compatible API and give the developers the freedom to change
it and customize it.

For the first release we won't have an admin interface because we believe
developers prefer code and the Rails console.
We hope this project can help to make the migration from Wombat easier and we
believe the Spree community will help to make it better.

## Dependencies

  - rails (>= 4.2.4)
  - postgresql

## Installation

Cangaroo is a Rails Engine so as usual you can install it using
[Bundler](http://bundler.io) by adding it to your application's Gemfile:

```ruby
  # Gemfile
  ...
  gem 'cangaroo'
  ...
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

First create a `connection`:

```ruby
  Cangaroo::Connection.create(
    name: 'mystore',
    url: 'http://www.mystore.com',
    key: 'puniethahquoe5aisefoh9ci0Shuaniemei6jahx',
    token: 'ahsh8phuezu3xuhohs6kai5vaB1tae0wiy1shohp'
  )
```

then create a `cangaroo job`:

```ruby
module Cangaroo
  class ShipmentJob < Cangaroo::Job
    connection :mystore
    path '/update_shipment'

    def perform?
      type == 'shipments' &&
      payload['status'] == 'shipped'
    end
  end
end
```

and add this job to the `Rails.configuration.cangaroo.jobs`:

```ruby
  # config/initializers/cangaroo.rb

  Rails.configuration.cangaroo.jobs = [Cangaroo::ShipmentJob]
```

## How it works

Cangaroo provides a Push API where you can send your data, after the data has
been received, Cangaroo sends data to integrations and webhooks based on your
business logic.

This is the detailed flow:

  - Cangaroo receives the data
  - If some error like "wrong key and token" or "malformed json" is raised
    Cangaroo returns an HTTP status code based on the kind of error:
    - 406 for wrong request
    - 401 for Unauthorized
    - 500 for wrong json schema
    - 500 for Cangaroo internal errors
  - If there are no errors, for each object in the json body, Cangaroo checks
    what jobs must be enqueued by calling the `#perform?` method. Each job
    returning `true` to `#perform?` will be enqueued.

## Push API

Cangaroo has just a single endpoint where you can push your data, based on
where `Cangaroo::Engine` is mounted, it will be reachable under the `/enpoint`
path. For example, if the `Cangaroo::Engine` is mounted under `/cangaroo` the
Push API path will be `/cangaroo/endpoint`.

When you push to the endpoint the HTTP Request must respect this conventions:

  * It must be a `POST` request
  * It must be an `application/json` request so you have to set the
    `Content-Type` header to `application/json`
  * The request must have the `X-Hub-Store` and `X-Hub-Access-Token` headers set
    to a value that exists in the `Cangaroo::Connection` model (to learn more
    refer to the `Connection` documentation below)
  * The request body must be a well formatted json.

The json body contains data that will be processed by Cangaroo, the following is
an example of an order that will be processed on Cangaroo:

```json
{
  "orders": [
    {
      "id": "O154085346",
      "status": "complete",
      "email": "user@example.com"
    }
  ]
}
```

The root objects of the json body must contain an array with the objects that
Cangaroo needs to process. The only required field for the objects contained
in the arrays will be the `id` key.
Push API also supports multiple objects so a request with the following body:

```json
  {
     "orders":[
        {
           "id":"O154085346172",
           "state":"cart"
        },
        {
           "id":"O154085343224",
           "state":"payed"
        }
     ],
     "shipments":[
        {
           "id":"S53454325",
           "state":"shipped"
        },
        {
           "id":"S53565543",
           "state":"waiting"
        }
     ]
  }

```

will create 2 `orders` and 2 `shipments`.

When Cangaroo receives the request it responds with a 200(OK) HTTP status code
and the response body will contain numbers of the objects in the payload, for
example for the previous request the response will be:

```json
  {
    "orders": 2,
    "shipments": 2
  }
```

if something goes wrong Cangaroo responds with an HTTP error code with an error
message in the body, for example:

```json
  {
    "error": "The property '#/orders/0' did not contain a required property of 'id' in schema"
  }
```

## Connection

Connection are services that can send and receive data from Cangaroo.
Each connection must have these fields:

  * name - (required, String) A generic name for this connection
  * url - (required, String) The url where Cangaroo pushes the data
  * key - (required, String) It's used for authentication
    (used to check the request's 'X-Hub-Store' header)
  * token - (required, String) It's used for authentication
    (used to check the request's 'X-Hub-Access-Token' header)
  * parameters - (optional, Hash) Used as parameters when Cangaroo makes a
    request to this connection

For now we don't have a Web GUI so you have to create the connection on your
own by running the code somewhere on your server, for example from the Rails
console:

```ruby
  Cangaroo::Connection.create(
    name: 'mystore',
    url: 'http://www.mystore.com',
    key: 'puniethahquoe5aisefoh9ci0Shuaniemei6jahx',
    token: 'ahsh8phuezu3xuhohs6kai5vaB1tae0wiy1shohp',
    parameters: {
      'channel': 'mysubstore'
    }
  )
```

## Cangaroo Jobs

Jobs are where the `payload` is pushed to the configured connection.

To allow a job to be executed add it to the `Rails.configuration.cangaroo.jobs`
configuration, for example in an initializer:

```ruby
  # config/initializers/cangaroo.rb

  Rails.configuration.cangaroo.jobs = [Cangaroo::AddOrderJob, Cangaroo::UpdateShipmentJob]
```

The `Cangaroo::Job` class inherits from `ActiveJob::Base`, so you can use
any 3rd-party queuing library supported by ActiveJob.
When the job is performed Cangaroo makes a `POST` request to the connection with
the configured path and build the json body with the result of the `#transform`
instance method merged with this attributes:

  * `request_id` - is the `job_id` coming from `ActiveJob::Base`
  * `parameters` - are the parameters configured by the `parameters` class method

You can use the following `Cangaroo::Job` class methods to configure the job's
behaivor:

  * connection - is the connection name (see connection for more info)
  * path - this path will be appended to your `connection.url`
  * parameters - these parameters will be merged with `connection.parameters`,
    they will be added to the json body.

it also has a `#perform?` instance method that must be implemented. This method
must return `true` or `false` as Cangaroo will use it to understand if the job
must be performed. Inside the `#perform?` method you'll be able to access the
`source_connection`, `type` and `payload` instance attributes.

The `#transform` instance method can be overridden to customize the json body
request, it will have the `source_connection`, `type` and `payload` variables
(like the `#perform?` method) and must return an `Hash`.

The following is an example of a `Cangaroo::Job`:

```ruby
  module Cangaroo
    class ShipmentJob < Cangaroo::Job
      connection :mystore
      path '/update_shipment'
      parameters({ timestamp: Time.now })

      def transform
        payload = super
        payload['shipment']['updated_at'] = Time.now
        payload
      end

      def perform?
        type == 'shipments' &&
        payload['status'] == 'shipped'
      end
    end
  end
```

Suppose that the `mystore` connection has a `url` set to "http://mystore.com"
an the `payload` is like this:

```ruby
  { "id": "S123", "status": "shipped" }
```

it will do a `POST` request to `http://mystore.com/update_shipment` with
this json body:

```json
{
  "request_id": "088e29b0ab0079560dea5d3e5aeb2f7868af661e",
  "parameters": {
    "timestamp": "2015-11-04 14:14:30 +0100"
  },
  "shipment": {
    "id": "S123",
    "status": "shipped"
  }
}
```

This project rocks and uses MIT-LICENSE.
