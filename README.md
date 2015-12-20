# Grape::Generator

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-generator

## Usage

```
$ grape 
Commands:
  grape help [COMMAND]  # Describe available commands or one specific command
  grape new NAME        # Generate project scaffolding.

Options:
  -V, [--verbose], [--no-verbose]  
```

### grape new

```
$ grape help new
Usage:
  grape new NAME

Options:
  -r, [--rails], [--no-rails]                  # Generate the ORM with Rails
      [--rails-new-options=RAILS_NEW_OPTIONS]  # Options for rails new
                                               # Default: -fBJST
  -V, [--verbose], [--no-verbose]              

Generate project scaffolding.
```

Examples:

```
$ grape new app
      inside  ./app
      create    app/Gemfile
         run    bundle install --path vendor/bundle --without production from "./app"
      create  app/lib/tasks/routes.rake
      create  app/config/boot.rb
      create  app/config/environment.rb
      create  app/app/apis/errors.rb
      create  app/app/apis/app_api.rb
   identical  app/Gemfile
      create  app/config.ru
      create  app/Rakefile
      create  app/log/.keep
      create  app/app/apis/resources/.keep
$ cd app/
$ tree -I vendor
.
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── app
│   └── apis
│       ├── app_api.rb
│       ├── errors.rb
│       └── resources
├── config
│   ├── boot.rb
│   └── environment.rb
├── config.ru
├── lib
│   └── tasks
│       └── routes.rake
└── log

7 directories, 9 files
$ rake routes
       Verb URI Pattern
       GET  /(.:format)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grape-generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

