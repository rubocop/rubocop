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

## Bundler/InsecureProtocolSource

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

The source `:gemcutter`, `:rubygems` and `:rubyforge` are deprecated
because HTTP requests are insecure. Please change your source to
'https://rubygems.org' if possible, or 'http://rubygems.org' if not.

### Example

```ruby
# bad
source :gemcutter
source :rubygems
source :rubyforge

# good
source 'https://rubygems.org' # strongly recommended
source 'http://rubygems.org'
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/Gemfile, \*\*/gems.rb

## Bundler/OrderedGems

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Gems should be alphabetically sorted within groups.

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

# good only if TreatCommentsAsGroupSeparators is true
# For code quality
gem 'rubocop'
# For tests
gem 'rspec'
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/Gemfile, \*\*/gems.rb
TreatCommentsAsGroupSeparators | true
