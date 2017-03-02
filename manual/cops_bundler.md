# Bundler

## Bundler/DuplicatedGem

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

A Gem's requirements should be listed only once in a Gemfile.

### Example

```ruby
# bad
gem 'rubocop'
gem 'rubocop'

# bad
group :development do
  gem 'rubocop'
end

group :test do
  gem 'rubocop'
end

# good
group :development, :test do
  gem 'rubocop'
end

# good
gem 'rubocop', groups: [:development, :test]
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/Gemfile, \*\*/gems.rb

## Bundler/OrderedGems

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Gems in consecutive lines should be alphabetically sorted

### Example

```ruby
# bad
gem 'rubocop'
gem 'rspec'

# good
gem 'rspec'
gem 'rubocop'

# good
gem 'rubocop'

gem 'rspec'
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/Gemfile, \*\*/gems.rb

