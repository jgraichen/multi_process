# MultiProcess

Run multiple processes.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'multi_process'
```

And then execute:

```console
bundle
```

Or install it yourself as:

```console
gem install multi_process
```

## Usage

```ruby
receiver = MultiProcess::Logger $stdout, $stderr, sys: false
group = MultiProcess::Group.new receiver: receiver
group << MultiProcess::Process.new %w[ruby test.rb], title: 'rubyA'
group << MultiProcess::Process.new %w[ruby test.rb], title: 'rubyB'
group << MultiProcess::Process.new %w[ruby test.rb], title: 'rubyC'
group.start # Start in background
group.run   # Block until finished
group.wait  # Wait until finished
group.stop  # Stop processes
```

```text
(23311) rubyB | Output from B
(23308) rubyA | Output from A
(23314) rubyC | Output from C
(23314) rubyC | Output from C
(23311) rubyB | Output from B
(23308) rubyA | Output from A
```

## Contributing

1. Fork it (<http://github.com/jgraichen/multi_process/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright © 2019-2025 Jan Graichen

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
