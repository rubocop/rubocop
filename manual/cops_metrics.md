# Metrics

## Metrics/AbcSize

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that the ABC size of methods is not higher than the
configured maximum. The ABC size is based on assignments, branches
(method calls), and conditions. See http://c2.com/cgi/wiki?AbcMetric

### Important attributes

Attribute | Value
--- | ---
Max | 15

### References

* [http://c2.com/cgi/wiki?AbcMetric](http://c2.com/cgi/wiki?AbcMetric)

## Metrics/BlockLength

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks if the length of a block exceeds some maximum value.
Comment lines can optionally be ignored.
The maximum allowed length is configurable.
The cop can be configured to ignore blocks passed to certain methods.

### Important attributes

Attribute | Value
--- | ---
CountComments | false
Max | 25
ExcludedMethods | 

## Metrics/BlockNesting

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for excessive nesting of conditional and looping
constructs.

You can configure if blocks are considered using the `CountBlocks`
option. When set to `false` (the default) blocks are not counted
towards the nesting level. Set to `true` to count blocks as well.

The maximum level of nesting allowed is configurable.

### Important attributes

Attribute | Value
--- | ---
CountBlocks | false
Max | 3

### References

* [https://github.com/bbatsov/ruby-style-guide#three-is-the-number-thou-shalt-count](https://github.com/bbatsov/ruby-style-guide#three-is-the-number-thou-shalt-count)

## Metrics/ClassLength

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks if the length a class exceeds some maximum value.
Comment lines can optionally be ignored.
The maximum allowed length is configurable.

### Important attributes

Attribute | Value
--- | ---
CountComments | false
Max | 100

## Metrics/CyclomaticComplexity

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that the cyclomatic complexity of methods is not higher
than the configured maximum. The cyclomatic complexity is the number of
linearly independent paths through a method. The algorithm counts
decision points and adds one.

An if statement (or unless or ?:) increases the complexity by one. An
else branch does not, since it doesn't add a decision point. The &&
operator (or keyword and) can be converted to a nested if statement,
and ||/or is shorthand for a sequence of ifs, so they also add one.
Loops can be said to have an exit condition, so they add one.

### Important attributes

Attribute | Value
--- | ---
Max | 6

## Metrics/LineLength

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks the length of lines in the source code.
The maximum length is configurable.

### Important attributes

Attribute | Value
--- | ---
Max | 80
AllowHeredoc | true
AllowURI | true
URISchemes | http, https
IgnoreCopDirectives | false
IgnoredPatterns | 

### References

* [https://github.com/bbatsov/ruby-style-guide#80-character-limits](https://github.com/bbatsov/ruby-style-guide#80-character-limits)

## Metrics/MethodLength

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks if the length of a method exceeds some maximum value.
Comment lines can optionally be ignored.
The maximum allowed length is configurable.

### Important attributes

Attribute | Value
--- | ---
CountComments | false
Max | 10

### References

* [https://github.com/bbatsov/ruby-style-guide#short-methods](https://github.com/bbatsov/ruby-style-guide#short-methods)

## Metrics/ModuleLength

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks if the length a module exceeds some maximum value.
Comment lines can optionally be ignored.
The maximum allowed length is configurable.

### Important attributes

Attribute | Value
--- | ---
CountComments | false
Max | 100

## Metrics/ParameterLists

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for methods with too many parameters.
The maximum number of parameters is configurable.
On Ruby 2.0+ keyword arguments can optionally
be excluded from the total count.

### Important attributes

Attribute | Value
--- | ---
Max | 5
CountKeywordArgs | true

### References

* [https://github.com/bbatsov/ruby-style-guide#too-many-params](https://github.com/bbatsov/ruby-style-guide#too-many-params)

## Metrics/PerceivedComplexity

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop tries to produce a complexity score that's a measure of the
complexity the reader experiences when looking at a method. For that
reason it considers `when` nodes as something that doesn't add as much
complexity as an `if` or a `&&`. Except if it's one of those special
`case`/`when` constructs where there's no expression after `case`. Then
the cop treats it as an `if`/`elsif`/`elsif`... and lets all the `when`
nodes count. In contrast to the CyclomaticComplexity cop, this cop
considers `else` nodes as adding complexity.

### Example

```ruby
def my_method                   # 1
  if cond                       # 1
    case var                    # 2 (0.8 + 4 * 0.2, rounded)
    when 1 then func_one
    when 2 then func_two
    when 3 then func_three
    when 4..10 then func_other
    end
  else                          # 1
    do_something until a && b   # 2
  end                           # ===
end                             # 7 complexity points
```

### Important attributes

Attribute | Value
--- | ---
Max | 7

