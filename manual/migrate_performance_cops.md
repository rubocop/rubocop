Performance Cops will be removed from RuboCop 0.68. Use rubocop-performance gem instead.

Put this in your Gemfile.

  gem 'rubocop-performance'

And then execute:

  $ bundle install

Put this into your .rubocop.yml.

  require: rubocop-performance

More information: https://github.com/rubocop-hq/rubocop-performance
