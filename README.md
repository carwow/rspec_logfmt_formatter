# RSpec logfmt Formatter

[![CircleCI](https://circleci.com/gh/carwow/rspec_logfmt_formatter/tree/master.svg?style=svg)](https://circleci.com/gh/carwow/rspec_logfmt_formatter/tree/master)
[![Gem Version](https://badge.fury.io/rb/rspec_logfmt_formatter.svg)](https://badge.fury.io/rb/rspec_logfmt_formatter)

[RSpec][rspec] 3 results in the [logfmt][logfmt] format that you can push to your observability tool such as [Honeycomb][honeycomb]

  [rspec]: http://rspec.info/
  [logfmt]: https://brandur.org/logfmt
  [honeycomb]: https://www.honeycomb.io/

## Usage

Install the gem:

```sh
gem install rspec_logfmt_formatter
```

Use it:

```sh
rspec --format RspecLogfmtFormatter --out rspec.txt
```

You'll get a file `rspec.txt` with your results in it.

You can use it in combination with other [formatters][rspec-formatters], too:

```sh
rspec --format progress --format RspecLogfmtFormatter --out rspec.txt
```

  [rspec-formatters]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/formatters

### Using in your project with Bundler

Add it to your Gemfile if you're using [Bundler][bundler]. Put it in the same groups as rspec.

```ruby
group :test do
  gem "rspec"
  gem "rspec_logfmt_formatter"
end
```

Put the same arguments as the commands above in [your `.rspec`][rspec-file]:

```sh
--format RspecLogfmtFormatter --out rspec.txt
```
  [bundler]: https://bundler.io
  [rspec-file]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/configuration/read-command-line-configuration-options-from-files

### Parallel tests

You can sum repeated values in one file using `rspec_logfmt_formatter_collate rspec.txt`.

It will rewrite a file like:

```
tests.count="3"
tests.count="1"
```

into:

```
tests.count="4"
```

### How to push to Honeycomb

There are many ways you can push this to honeycomb. One way is to use the [buildevents][buildevents] binary. Then output your spec output to `BUILDEVENT_FILE` e.g.

```sh
bundle exec rspec --format RspecLogfmtFormatter --out $BUILDEVENT_FILE
```

  [buildevents]: https://github.com/honeycombio/buildevents

## Development

Pull the repo and run `bundle install`, the specs are run with `bundle exec rspec` and make sure to read the [CONTRIBUTING.md](./CONTRIBUTING.md).

## Releasing

Currently this is a manual process and can only be run by a carwow developer.

1. Ensure your `~/.gem/credentials` are correct
2. Update the [CHANGELOG.md](./CHANGELOG.md)
3. Update the [version.rb](./lib/rspec_logfmt_formatter/version.rb)
4. Run `bundle exec rake upload`
5. Check the tag was pushed and the new version was released

## License

The MIT License, see [LICENSE](./LICENSE).
