# Itamae::Secrets - Encrypted Data Bag for Itamae

This is [itamae](https://github.com/itamae-kitchen/itamae) plugin that provides store for secrets, like encrypted data bag in chef.

## Installation

```ruby
gem 'itamae-secrets'
```

or

```
$ gem install itamae-secrets
```

## Basic

- `itamae-secrets` command for storing data or manually reading
- `Itamae::Secrets` interface for itamae recipes
- Data are stored in _base directory._
  - You must avoid `${base}/keys` from checked into VCS. (`.gitignore` it!)

## Walkthrough

### Generate a key

##### randomly

```
$ itamae-secrets newkey --base=./secret --method=aes-random
```

##### from passphrase

```
$ itamae-secrets newkey --base=./secret --method=aes-passphrase
```

Both generates `./secret/keys/default`. Make sure `./secret/keys` be excluded from VCS.

### Store value

```
$ itamae-secrets set --base=./secret awesome_secret value
```

(when omit `value`, it'll read from STDIN until EOF. You can also use `--noecho` if you want hide value in your terminal's buffer completely.)

### Reading data from itamae

on your itamae recipe, do:

``` ruby
require 'itamae/secrets'
node[:secrets] = Itamae::Secrets(File.join(__dir__, 'secret'))

# Use it
p node[:secrets][:awesome_secret]
```

### Reading data from CLI

```
$ itamae-secrets get --base=./secret awesome_secret
```

### Remembering `--base`

```
$ echo 'base: ./secret' >> .itamae-secrets.yml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/itamae-secrets.

__Security issues?__ Send me directly at `security@sorah.jp`. My GPG key is available here: <http://sorah.jp/id.html> ([SSL](https://github.com/sorah/sorah.jp/tree/master/source/pgp-pubkeys))


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## To-dos

- [ ] Missing test :(
