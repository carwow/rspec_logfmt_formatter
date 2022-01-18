# Contributing

We love pull requests from everyone. By participating in this project, you
agree to abide by the [code of conduct].

[code of conduct]: https://github.com/carwow/rspec_logfmt_formatter/blob/master/CODE_OF_CONDUCT.md

Here are some ways *you* can contribute:

* by reporting bugs
* by writing or editing documentation
* by writing specifications
* by writing code ( **no patch is too small** : fix typos, add comments, clean up inconsistent whitespace )
* by refactoring code
* by closing [issues][]
* by reviewing patches

[issues]: https://github.com/carwow/rspec_logfmt_formatter/issues

## Submitting an Issue
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. When submitting a bug report, please include a [Gist][]
that includes a stack trace and any details that may be necessary to reproduce
the bug, including your gem version, Ruby version, and operating system.
Ideally, a bug report should include a pull request with failing specs.

[gist]: https://gist.github.com/

## Submitting a Pull Request
1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Implement your feature or bug fix.
4. Add, commit, and push your changes.
5. [Submit a pull request.][pr]

[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/using-pull-requests/

### Notes

* Please add tests if you changed code. Contributions without tests won't be accepted.
* Please don't update the Gem version.

## Setting up

```sh
bundle install
```

## Running the test suite

```sh
bundle exec rspec
```

To run an individual rspec test, you can provide a path and line number:

```sh
bundle exec rspec spec/path/to/spec.rb:123
```

## Formatting

Use [rubocop] to automatically format your code:

```sh
bundle exec rubocop -c .rubocop.yml -A
```

[rubocop]: https://github.com/rubocop/rubocop

Inspired by https://github.com/thoughtbot/factory_bot/blob/main/CONTRIBUTING.md
