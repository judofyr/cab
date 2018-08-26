# Cab: Lightweight code reloader for Ruby/Rack

[![Travis](https://img.shields.io/travis/com/judofyr/cab/master.svg)](https://travis-ci.com/judofyr/cab)


Replace `rackup` with `cabup` and files are automatically reloaded for you:

```
$ cabup
Puma starting in single mode...
* Version 3.11.4 (ruby 2.4.1-p111), codename: Love Song
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://localhost:9292
Use Ctrl-C to stop
```

##### Table of Contents

- [Functionality](#functionality)
- [Usage](#usage)
- [Public API](#public-api)
- [Versioning](#versioning)
- [Other alternatives](#other-alternatives)
- [License](#license)

## Functionality

- `cabup`: Command-line tool which replaces `rackup`
- Made for applications that use explicit `require`/`require_relative`
- Tracks all required files
- Tracks all defined classes/modules
- `#run` checks if any of the files have changed (modification time), and
  reloads the files
- All defined classes/modules are un-defined before the file is loaded again
- Does not track autoloaded files
- Simple: 150 lines of code, no dependencies
- Cross platform: Uses only plain Ruby features

## Usage

Reloading Ruby projects is rather complicated since any file can execute
arbitary code, and before you can load the new, modified file, Cab needs to
unload the previous file. Cab doesn't aim to magically support all complicated
use cases, but instead requires you to write Ruby files which are reloadable.
This shouldn't be a big problem since files that are easy to reload turns out
to be files that are easy to reason about.

As long as you follow these rules you should be fine:

- Rule 1: Files that *only* define their own classes/modules will always work.
- Rule 2: Files should `require` (or `require_relative`) their dependencies.
- Rule 3: Files that execute code when they load must be idempotent (see below).
- Rule 4: Not everything can be reloaded and changes in some files (e.g.
  initializers) might require you to restart the server. That's okay. Cab
  strives to be *useful*, not perfect.

### Dealing with idempotency

If you're trying out Cab with Sinatra you will quickly discover that reloading
doesn't appear to work:

```ruby
require 'sintra'

get '/' do
  'Hello world!'
end
```

Here's what happens:

- You start the application with `cabup`
- The application is loaded and one route is defined
- You modify the application
- Cab tries to unload the file, but there's nothing to do since there are no
  classes/modules
- Cab then loads the file again
- The Sintra application now has *two* routes defined, but the first one will
  always shadow the later one

There are two ways to handle this. Solution 1 is to start the file with
cleaning up from the previous time it was loaded:

```ruby
require 'sinatra'
Sinatra::Application.reset!

get '/' do
  'Hello world!'
end
```

Solution 2 (the preferred way) is to use a class instead:

```ruby
require 'sinatra'

class MyApp < Sinatra::Application
  get '/' do
    'Hello world!'
  end
end
```

## Public API

### class: Cab

#### Cab.new(dir:, &blk)
- dir: Only track files inside this directory
- blk: The block used by `#run`
- returns: Cab

```ruby
cab = Cab.new(dir: __dir__) do
  require_relative 'app'
  App.do_something
end
```

#### Cab#run
- returns: The return value of the block

Checks if any of the tracked files has changed, reloads them if needed, and then
executes the block and returns its value:

```ruby
cab = Cab.new(dir: __dir__) do
  require_relative 'app'
  1 + 1
end

cab.run  # => 2
```

#### Cab.rack(&blk)
- blk: A block which should return a Rack app
- returns: A Rack app which automatically reloads on all requests

```ruby
app = Cab.rack do
  require_relative 'app'
  Sinatra::Application
end

# If we're in a config.ru:
run app
```

## Versioning

Cab is currently not yet released.

## Other alternatives

The Roda framework has a summary of various code reloading libraries and
techniques: ["Code Reloading"][roda-code-reloading].

[roda-code-reloading]: http://roda.jeremyevans.net/rdoc/files/README_rdoc.html#label-Code+Reloading

## License

Cab is is available under the 0BSD license:

> Copyright (C) 2018 Magnus Holm <judofyr@gmail.com>
>
> Permission to use, copy, modify, and/or distribute this software for any
> purpose with or without fee is hereby granted.
>
> THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
> REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
> AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
> INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
> LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
> OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
> PERFORMANCE OF THIS SOFTWARE.

