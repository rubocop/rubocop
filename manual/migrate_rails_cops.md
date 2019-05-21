Rails cops will be removed from RuboCop 0.72. Use the `rubocop-rails` gem instead.

Put this in your `Gemfile`.

```rb
gem 'rubocop-rails'
```

And then execute:

```sh
$ bundle install
```

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-rails
```

More information: https://github.com/rubocop-hq/rubocop-rails
