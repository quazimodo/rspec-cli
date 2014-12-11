# RSpec::Cli

This is an extension to rspec to fascilitate cli testing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-cli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-cli

## Usage

In your rspec config

```ruby
RSpec.configure do |config|
  config.include RSpec::Cli, type: :feature

  config.alias_example_group_to :feature, :type => :feature
  config.alias_example_to :scenario
end
```
or similar.

Now your feature specs will have helper methods
```new_cli_process(%w[echo hi there :D])``` and ```spawn_cli_process(%w[echo hi there :D])```

The first one returns a CliProcess instance that hasn't spawned your command yet.

The second one returns a CliProcess instance that has spawned your command.

The CliProcess instance has some useful methods like ```#read_all``` to read from it's stdout, ```#write(string)``` to write to it's stdin and ```#status``` to get the process's status.

## Versioning
As close to semantic versioning as I can be sure of (earlier in the project I broke semantic versioning, but everything past tag 0.2.0 is correct)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
