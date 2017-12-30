# Bundler

## Bundler/DuplicatedGem

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

A Gem's requirements should be listed only once in a Gemfile.

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `**/*.gemfile`, `**/Gemfile`, `**/gems.rb` | Array

## Bundler/InsecureProtocolSource

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

The symbol argument `:gemcutter`, `:rubygems` and `:rubyforge`
are deprecated. So please change your source to URL string that
'https://rubygems.org' if possible, or 'http://rubygems.org' if not.

This autocorrect will replace these symbols with 'https://rubygems.org'.
Because it is secure, HTTPS request is strongly recommended. And in
most use cases HTTPS will be fine.

However, it don't replace all `sources` of `http://` with `https://`.
For example, when specifying an internal gem server using HTTP on the
intranet, a use case where HTTPS can not be specified was considered.
Consider using HTTP only if you can not use HTTPS.

### Examples

```ruby
# bad
source :gemcutter
source :rubygems
source :rubyforge

# good
source 'https://rubygems.org' # strongly recommended
source 'http://rubygems.org'
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `**/*.gemfile`, `**/Gemfile`, `**/gems.rb` | Array

## Bundler/OrderedGems

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Gems should be alphabetically sorted within groups.

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `**/*.gemfile`, `**/Gemfile`, `**/gems.rb` | Array
TreatCommentsAsGroupSeparators | `true` | Boolean
