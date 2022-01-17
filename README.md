# RSpec logfmt Formatter

[![CircleCI](https://circleci.com/gh/carwow/rspec_logfmt_formatter/tree/master.svg?style=svg)](https://circleci.com/gh/carwow/rspec_logfmt_formatter/tree/master)

[RSpec][rspec] 3 results in the [logfmt][logfmt] format that you can push to you observability tool such as [Honeycomb][honeycomb]

  [rspec]: http://rspec.info/
  [logfmt]: https://brandur.org/logfmt
  [honeycomb]: https://www.honeycomb.io/

## Usage

Install the gem:
<details>
<summary>WIP</summary>

```sh
gem install rspec_logfmt_formatter
```

</details>

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
--format RspecLogfmtFormatter
--out rspec.txt
```
  [bundler]: https://bundler.io
  [rspec-file]: https://relishapp.com/rspec/rspec-core/v/3-6/docs/configuration/read-command-line-configuration-options-from-files

### Parallel tests

For use with `parallel_tests`, add `$TEST_ENV_NUMBER` in the output file option (in `.rspec` or `.rspec_parallel`) to avoid concurrent process write conflicts.

```sh
--format RspecLogfmtFormatter
--out tmp/rspec<%= ENV["TEST_ENV_NUMBER"] %>.txt
```

### How to push to Honeycomb

TODO

## Development

TODO

## Releasing

TODO

## License

The MIT License, see [LICENSE](./LICENSE).
