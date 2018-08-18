# Cab: Lightweight code reloader for Ruby

```ruby
cab = Cab.new(dir: __dir__) do
  require_relative 'app'
  p App.run
end

# This runs the block and tracks all required file:
cab.run

# Now modify app.rb (or one if its included files)

# This will now be executed with the new files loaded:
cab.run
```

##### Table of Contents

- [Functionality](#functionality)
- [Public API](#public-api)
- [Versioning](#versioning)
- [Other alternatives](#other-alternatives)
- [License](#license)

## Functionality

- Made for applications that use explicit `require`/`require_relative`
- Tracks all required files
- Tracks all defined classes/modules
- `#run` checks if any of the files have changed (modification time), and
  reloads the files
- All defined classes/modules are un-defined before the file is loaded again
- Does not track autoloaded files
- Simple: 100 lines of code, no dependencies
- Cross platform: Uses only plain Ruby features

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
techniques. See code reloading libraries and techniques: ["Code
Reloading"][roda-code-reloading].

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

