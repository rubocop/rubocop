# Gemspec

## Gemspec/OrderedDependencies

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Dependencies in the gemspec should be alphabetically sorted.

### Example

```ruby
# bad
spec.add_dependency 'rubocop'
spec.add_dependency 'rspec'

# good
spec.add_dependency 'rspec'
spec.add_dependency 'rubocop'

# good
spec.add_dependency 'rubocop'

spec.add_dependency 'rspec'

# bad
spec.add_development_dependency 'rubocop'
spec.add_development_dependency 'rspec'

# good
spec.add_development_dependency 'rspec'
spec.add_development_dependency 'rubocop'

# good
spec.add_development_dependency 'rubocop'

spec.add_development_dependency 'rspec'

# bad
spec.add_runtime_dependency 'rubocop'
spec.add_runtime_dependency 'rspec'

# good
spec.add_runtime_dependency 'rspec'
spec.add_runtime_dependency 'rubocop'

# good
spec.add_runtime_dependency 'rubocop'

spec.add_runtime_dependency 'rspec'

# good only if TreatCommentsAsGroupSeparators is true
# For code quality
spec.add_dependency 'rubocop'
# For tests
spec.add_dependency 'rspec'
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/\*.gemspec
TreatCommentsAsGroupSeparators | true

## Gemspec/RequiredRubyVersion

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Checks that `required_ruby_version` of gemspec and `TargetRubyVersion`
of .rubocop.yml are equal.
Thereby, RuboCop to perform static analysis working on the version
required by gemspec.

### Example

```ruby
# When `TargetRubyVersion` of .rubocop.yml is `2.3`.

# bad
Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.2.0'
end

# bad
Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.4.0'
end

# good
Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.0'
end

# good
Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3'
end

# good
Gem::Specification.new do |spec|
  spec.required_ruby_version = ['>= 2.3.0', '< 2.5.0']
end
```

### Important attributes

Attribute | Value
--- | ---
Include | \*\*/\*.gemspec
