# Itamae::Secrets

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/itamae/secrets`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

```ruby
gem 'itamae-secrets'
```

or

    $ gem install itamae-secrets

## Basic

- `itamae-secrets` command for storing data or manually reading
  - specify base directory to `--base` option
  - you should exclude `{base}/keys` from checking into VCS.

## Usage

### Storing data

#### With a key file (AES)

##### Generating randomly

```
itamae-secrets genkey --base=./secret --method=aes-file useful_key
```

##### Generating from passphrase

```
itamae-secrets genkey --base=./secret --method=aes-passphrase useful_key
```

##### Store using it

```
itamae-secrets store --method=aes --key=useful_key awesome_secret
```

#### With a key file (RSA)

TBD

### Using data

#### CLI

```
itamae-secrets read awesome_secret
```

#### Itamae

on your itamae recipe, do:

```
require 'itamae/secrets'
node[:secrets] = Itamae::Secrets.load(File.join(__dir__, 'secrets'))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/itamae-secrets.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

