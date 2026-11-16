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

### Output

Each run writes its results on a single line:

```
tests.count="6" tests.skipped="1" tests.failures="3" tests.errors="0" tests.retries="1" tests.slow_files="1" tests.slowest_file_ms="48213" tests.slowest_file="./spec/models/deal_spec.rb"
```

When `TEST_ENV_NUMBER` is set (e.g. by [flatware][flatware] or
[parallel_tests][parallel_tests]) the line starts with the worker number,
`tests.worker="3"`, so each parallel worker's result is self-contained.

  [flatware]: https://github.com/briandunn/flatware
  [parallel_tests]: https://github.com/grosser/parallel_tests

`tests.retries` is only populated when using [rspec-retry][rspec-retry].

### Slow spec files

The formatter times each top-level example group (wall clock, including
`before(:all)` hooks) and sums them per spec file:

* `tests.slowest_file_ms` / `tests.slowest_file`: the slowest spec file and its duration in milliseconds
* `tests.slow_files`: how many spec files took longer than the threshold

The threshold defaults to 60000ms and can be set with the
`RSPEC_LOGFMT_SLOW_FILE_THRESHOLD_MS` environment variable. These fields are
omitted when no example groups ran.

  [rspec-retry]: https://github.com/NoRedInk/rspec-retry

### Parallel tests

You can combine the output of several runs in one file using `rspec_logfmt_formatter_collate rspec.txt`.
Counts are summed and the slowest file is the slowest across all runs.

It will rewrite a file like:

```
tests.worker="1" tests.count="3" tests.slowest_file_ms="900" tests.slowest_file="./spec/a_spec.rb"
tests.worker="2" tests.count="1" tests.slowest_file_ms="1500" tests.slowest_file="./spec/b_spec.rb"
```

into:

```
tests.count="4"
tests.slowest_file_ms="1500"
tests.slowest_file="./spec/b_spec.rb"
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
3. Update the version in the [gemspec](./rspec_logfmt_formatter.gemspec)
4. Run `bundle exec rake upload`
5. Check the tag was pushed and the new version was released

## License

The MIT License, see [LICENSE](./LICENSE).
