Performance cops have been removed from RuboCop 0.68. Use the `rubocop-performance` gem instead.

Put this in your `Gemfile`.

```rb
gem 'rubocop-performance'
```

And then execute:

```sh
$ bundle install
```

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-performance
```

More information: https://github.com/rubocop-hq/rubocop-performance
