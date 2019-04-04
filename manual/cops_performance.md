# Performance

## Performance/Caller

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.49 | -

This cop identifies places where `caller[n]`
can be replaced by `caller(n..n).first`.

### Examples

```ruby
# bad
caller[1]
caller.first
caller_locations[1]
caller_locations.first

# good
caller(2..2).first
caller(1..1).first
caller_locations(2..2).first
caller_locations(1..1).first
```

## Performance/CaseWhenSplat

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Disabled | Yes | Yes (Unsafe) | 0.34 | 0.59

Reordering `when` conditions with a splat to the end
of the `when` branches can improve performance.

Ruby has to allocate memory for the splat expansion every time
that the `case` `when` statement is run. Since Ruby does not support
fall through inside of `case` `when`, like some other languages do,
the order of the `when` branches should not matter. By placing any
splat expansions at the end of the list of `when` branches we will
reduce the number of times that memory has to be allocated for
the expansion. The exception to this is if multiple of your `when`
conditions can be true for any given condition. A likely scenario for
this defining a higher level when condition to override a condition
that is inside of the splat expansion.

This is not a guaranteed performance improvement. If the data being
processed by the `case` condition is normalized in a manner that favors
hitting a condition in the splat expansion, it is possible that
moving the splat condition to the end will use more memory,
and run slightly slower.

### Examples

```ruby
# bad
case foo
when *condition
  bar
when baz
  foobar
end

case foo
when *[1, 2, 3, 4]
  bar
when 5
  baz
end

# good
case foo
when baz
  foobar
when *condition
  bar
end

case foo
when 1, 2, 3, 4
  bar
when 5
  baz
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

## Performance/Casecmp

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.36 | -

This cop identifies places where a case-insensitive string comparison
can better be implemented using `casecmp`.

### Examples

```ruby
# bad
str.downcase == 'abc'
str.upcase.eql? 'ABC'
'abc' == str.downcase
'ABC'.eql? str.upcase
str.downcase == str.downcase

# good
str.casecmp('ABC').zero?
'abc'.casecmp(str).zero?
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#stringcasecmp-vs-stringdowncase---code](https://github.com/JuanitoFatas/fast-ruby#stringcasecmp-vs-stringdowncase---code)

## Performance/ChainArrayAllocation

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Disabled | Yes | No | 0.59 | -

This cop is used to identify usages of
Each of these methods (`compact`, `flatten`, `map`) will generate a
new intermediate array that is promptly thrown away. Instead it is
faster to mutate when we know it's safe.

### Examples

```ruby
# bad
array = ["a", "b", "c"]
array.compact.flatten.map { |x| x.downcase }
```
```ruby
# good.
array = ["a", "b", "c"]
array.compact!
array.flatten!
array.map! { |x| x.downcase }
array
```

### References

* [https://twitter.com/schneems/status/1034123879978029057](https://twitter.com/schneems/status/1034123879978029057)

## Performance/CompareWithBlock

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.46 | -

This cop identifies places where `sort { |a, b| a.foo <=> b.foo }`
can be replaced by `sort_by(&:foo)`.
This cop also checks `max` and `min` methods.

### Examples

```ruby
# bad
array.sort { |a, b| a.foo <=> b.foo }
array.max { |a, b| a.foo <=> b.foo }
array.min { |a, b| a.foo <=> b.foo }
array.sort { |a, b| a[:foo] <=> b[:foo] }

# good
array.sort_by(&:foo)
array.sort_by { |v| v.foo }
array.sort_by do |var|
  var.foo
end
array.max_by(&:foo)
array.min_by(&:foo)
array.sort_by { |a| a[:foo] }
```

## Performance/Count

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.31 | 0.39

This cop is used to identify usages of `count` on an `Enumerable` that
follow calls to `select` or `reject`. Querying logic can instead be
passed to the `count` call.

`ActiveRecord` compatibility:
`ActiveRecord` will ignore the block that is passed to `count`.
Other methods, such as `select`, will convert the association to an
array and then run the block on the array. A simple work around to
make `count` work with a block is to call `to_a.count {...}`.

Example:
  Model.where(id: [1, 2, 3].select { |m| m.method == true }.size

  becomes:

  Model.where(id: [1, 2, 3]).to_a.count { |m| m.method == true }

### Examples

```ruby
# bad
[1, 2, 3].select { |e| e > 2 }.size
[1, 2, 3].reject { |e| e > 2 }.size
[1, 2, 3].select { |e| e > 2 }.length
[1, 2, 3].reject { |e| e > 2 }.length
[1, 2, 3].select { |e| e > 2 }.count { |e| e.odd? }
[1, 2, 3].reject { |e| e > 2 }.count { |e| e.even? }
array.select(&:value).count

# good
[1, 2, 3].count { |e| e > 2 }
[1, 2, 3].count { |e| e < 2 }
[1, 2, 3].count { |e| e > 2 && e.odd? }
[1, 2, 3].count { |e| e < 2 && e.even? }
Model.select('field AS field_one').count
Model.select(:value).count
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
SafeMode | `true` | Boolean

## Performance/Detect

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | 0.39

This cop is used to identify usages of
`select.first`, `select.last`, `find_all.first`, and `find_all.last`
and change them to use `detect` instead.

`ActiveRecord` compatibility:
`ActiveRecord` does not implement a `detect` method and `find` has its
own meaning. Correcting ActiveRecord methods with this cop should be
considered unsafe.

### Examples

```ruby
# bad
[].select { |item| true }.first
[].select { |item| true }.last
[].find_all { |item| true }.first
[].find_all { |item| true }.last

# good
[].detect { |item| true }
[].reverse.detect { |item| true }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
SafeMode | `true` | Boolean

### References

* [https://github.com/JuanitoFatas/fast-ruby#enumerabledetect-vs-enumerableselectfirst-code](https://github.com/JuanitoFatas/fast-ruby#enumerabledetect-vs-enumerableselectfirst-code)

## Performance/DoubleStartEndWith

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.36 | 0.48

This cop checks for double `#start_with?` or `#end_with?` calls
separated by `||`. In some cases such calls can be replaced
with an single `#start_with?`/`#end_with?` call.

### Examples

```ruby
# bad
str.start_with?("a") || str.start_with?(Some::CONST)
str.start_with?("a", "b") || str.start_with?("c")
str.end_with?(var1) || str.end_with?(var2)

# good
str.start_with?("a", Some::CONST)
str.start_with?("a", "b", "c")
str.end_with?(var1, var2)
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
IncludeActiveSupportAliases | `false` | Boolean

## Performance/EndWith

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes (Unsafe) | 0.36 | 0.44

This cop identifies unnecessary use of a regex where `String#end_with?`
would suffice.

### Examples

```ruby
# bad
'abc'.match?(/bc\Z/)
'abc' =~ /bc\Z/
'abc'.match(/bc\Z/)

# good
'abc'.end_with?('bc')
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

### References

* [https://github.com/JuanitoFatas/fast-ruby#stringmatch-vs-stringstart_withstringend_with-code-start-code-end](https://github.com/JuanitoFatas/fast-ruby#stringmatch-vs-stringstart_withstringend_with-code-start-code-end)

## Performance/FixedSize

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.35 | -

Do not compute the size of statically sized objects.

### Examples

```ruby
# String methods
# bad
'foo'.size
%q[bar].count
%(qux).length

# Symbol methods
# bad
:fred.size
:'baz'.length

# Array methods
# bad
[1, 2, thud].count
%W(1, 2, bar).size

# Hash methods
# bad
{ a: corge, b: grault }.length

# good
foo.size
bar.count
qux.length

# good
:"#{fred}".size
CONST = :baz.length

# good
[1, 2, *thud].count
garply = [1, 2, 3]
garly.size

# good
{ a: corge, **grault }.length
waldo = { a: corge, b: grault }
waldo.size
```

## Performance/FlatMap

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | -

This cop is used to identify usages of

### Examples

```ruby
# bad
[1, 2, 3, 4].map { |e| [e, e] }.flatten(1)
[1, 2, 3, 4].collect { |e| [e, e] }.flatten(1)

# good
[1, 2, 3, 4].flat_map { |e| [e, e] }
[1, 2, 3, 4].map { |e| [e, e] }.flatten
[1, 2, 3, 4].collect { |e| [e, e] }.flatten
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnabledForFlattenWithoutParams | `false` | Boolean

### References

* [https://github.com/JuanitoFatas/fast-ruby#enumerablemaparrayflatten-vs-enumerableflat_map-code](https://github.com/JuanitoFatas/fast-ruby#enumerablemaparrayflatten-vs-enumerableflat_map-code)

## Performance/InefficientHashSearch

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | No | Yes  | 0.56 | -

This cop checks for inefficient searching of keys and values within
hashes.

`Hash#keys.include?` is less efficient than `Hash#key?` because
the former allocates a new array and then performs an O(n) search
through that array, while `Hash#key?` does not allocate any array and
performs a faster O(1) search for the key.

`Hash#values.include?` is less efficient than `Hash#value?`. While they
both perform an O(n) search through all of the values, calling `values`
allocates a new array while using `value?` does not.

### Examples

```ruby
# bad
{ a: 1, b: 2 }.keys.include?(:a)
{ a: 1, b: 2 }.keys.include?(:z)
h = { a: 1, b: 2 }; h.keys.include?(100)

# good
{ a: 1, b: 2 }.key?(:a)
{ a: 1, b: 2 }.has_key?(:z)
h = { a: 1, b: 2 }; h.key?(100)

# bad
{ a: 1, b: 2 }.values.include?(2)
{ a: 1, b: 2 }.values.include?('garbage')
h = { a: 1, b: 2 }; h.values.include?(nil)

# good
{ a: 1, b: 2 }.value?(2)
{ a: 1, b: 2 }.has_value?('garbage')
h = { a: 1, b: 2 }; h.value?(nil)
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#hashkey-instead-of-hashkeysinclude-code](https://github.com/JuanitoFatas/fast-ruby#hashkey-instead-of-hashkeysinclude-code)

## Performance/OpenStruct

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Disabled | No | No | 0.61 | -

This cop checks for `OpenStruct.new` calls.
Instantiation of an `OpenStruct` invalidates
Ruby global method cache as it causes dynamic method
definition during program runtime.
This could have an effect on performance,
especially in case of single-threaded
applications with multiple `OpenStruct` instantiations.

### Examples

```ruby
# bad
class MyClass
  def my_method
    OpenStruct.new(my_key1: 'my_value1', my_key2: 'my_value2')
  end
end

# good
class MyClass
  MyStruct = Struct.new(:my_key1, :my_key2)
  def my_method
    MyStruct.new('my_value1', 'my_value2')
  end
end
```

## Performance/RangeInclude

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | No | Yes  | 0.36 | -

This cop identifies uses of `Range#include?`, which iterates over each
item in a `Range` to see if a specified item is there. In contrast,
`Range#cover?` simply compares the target item with the beginning and
end points of the `Range`. In a great majority of cases, this is what
is wanted.

This cop is `Safe: false` by default because `Range#include?` and
`Range#cover?` are not equivalent behaviour.

### Examples

```ruby
# bad
('a'..'z').include?('b') # => true

# good
('a'..'z').cover?('b') # => true

# Example of a case where `Range#cover?` may not provide
# the desired result:

('a'..'z').cover?('yellow') # => true
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#cover-vs-include-code](https://github.com/JuanitoFatas/fast-ruby#cover-vs-include-code)

## Performance/RedundantBlockCall

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.36 | -

This cop identifies the use of a `&block` parameter and `block.call`
where `yield` would do just as well.

### Examples

```ruby
# bad
def method(&block)
  block.call
end
def another(&func)
  func.call 1, 2, 3
end

# good
def method
  yield
end
def another
  yield 1, 2, 3
end
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#proccall-and-block-arguments-vs-yieldcode](https://github.com/JuanitoFatas/fast-ruby#proccall-and-block-arguments-vs-yieldcode)

## Performance/RedundantMatch

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.36 | -

This cop identifies the use of `Regexp#match` or `String#match`, which
returns `#<MatchData>`/`nil`. The return value of `=~` is an integral
index/`nil` and is more performant.

### Examples

```ruby
# bad
do_something if str.match(/regex/)
while regex.match('str')
  do_something
end

# good
method(str =~ /regex/)
return value unless regex =~ 'str'
```

## Performance/RedundantMerge

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.36 | -

This cop identifies places where `Hash#merge!` can be replaced by
`Hash#[]=`.

### Examples

```ruby
hash.merge!(a: 1)
hash.merge!({'key' => 'value'})
hash.merge!(a: 1, b: 2)
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MaxKeyValuePairs | `2` | Integer

### References

* [https://github.com/JuanitoFatas/fast-ruby#hashmerge-vs-hash-code](https://github.com/JuanitoFatas/fast-ruby#hashmerge-vs-hash-code)

## Performance/RegexpMatch

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.47 | -

In Ruby 2.4, `String#match?`, `Regexp#match?`, and `Symbol#match?`
have been added. The methods are faster than `match`.
Because the methods avoid creating a `MatchData` object or saving
backref.
So, when `MatchData` is not used, use `match?` instead of `match`.

### Examples

```ruby
# bad
def foo
  if x =~ /re/
    do_something
  end
end

# bad
def foo
  if x !~ /re/
    do_something
  end
end

# bad
def foo
  if x.match(/re/)
    do_something
  end
end

# bad
def foo
  if /re/ === x
    do_something
  end
end

# good
def foo
  if x.match?(/re/)
    do_something
  end
end

# good
def foo
  if !x.match?(/re/)
    do_something
  end
end

# good
def foo
  if x =~ /re/
    do_something(Regexp.last_match)
  end
end

# good
def foo
  if x.match(/re/)
    do_something($~)
  end
end

# good
def foo
  if /re/ === x
    do_something($~)
  end
end
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#regexp-vs-stringmatch-vs-string-vs-stringmatch-code-](https://github.com/JuanitoFatas/fast-ruby#regexp-vs-stringmatch-vs-string-vs-stringmatch-code-)

## Performance/ReverseEach

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | -

This cop is used to identify usages of `reverse.each` and
change them to use `reverse_each` instead.

### Examples

```ruby
# bad
[].reverse.each

# good
[].reverse_each
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#enumerablereverseeach-vs-enumerablereverse_each-code](https://github.com/JuanitoFatas/fast-ruby#enumerablereverseeach-vs-enumerablereverse_each-code)

## Performance/Size

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.30 | -

This cop is used to identify usages of `count` on an
`Array` and `Hash` and change them to `size`.

TODO: Add advanced detection of variables that could
have been assigned to an array or a hash.

### Examples

```ruby
# bad
[1, 2, 3].count

# bad
{a: 1, b: 2, c: 3}.count

# good
[1, 2, 3].size

# good
{a: 1, b: 2, c: 3}.size

# good
[1, 2, 3].count { |e| e > 2 }
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#arraylength-vs-arraysize-vs-arraycount-code](https://github.com/JuanitoFatas/fast-ruby#arraylength-vs-arraysize-vs-arraycount-code)

## Performance/StartWith

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes (Unsafe) | 0.36 | 0.44

This cop identifies unnecessary use of a regex where
`String#start_with?` would suffice.

### Examples

```ruby
# bad
'abc'.match?(/\Aab/)
'abc' =~ /\Aab/
'abc'.match(/\Aab/)

# good
'abc'.start_with?('ab')
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

### References

* [https://github.com/JuanitoFatas/fast-ruby#stringmatch-vs-stringstart_withstringend_with-code-start-code-end](https://github.com/JuanitoFatas/fast-ruby#stringmatch-vs-stringstart_withstringend_with-code-start-code-end)

## Performance/StringReplacement

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.33 | -

This cop identifies places where `gsub` can be replaced by
`tr` or `delete`.

### Examples

```ruby
# bad
'abc'.gsub('b', 'd')
'abc'.gsub('a', '')
'abc'.gsub(/a/, 'd')
'abc'.gsub!('a', 'd')

# good
'abc'.gsub(/.*/, 'a')
'abc'.gsub(/a+/, 'd')
'abc'.tr('b', 'd')
'a b c'.delete(' ')
```

### References

* [https://github.com/JuanitoFatas/fast-ruby#stringgsub-vs-stringtr-code](https://github.com/JuanitoFatas/fast-ruby#stringgsub-vs-stringtr-code)

## Performance/TimesMap

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes (Unsafe) | 0.36 | 0.50

This cop checks for .times.map calls.
In most cases such calls can be replaced
with an explicit array creation.

### Examples

```ruby
# bad
9.times.map do |i|
  i.to_s
end

# good
Array.new(9) do |i|
  i.to_s
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

## Performance/UnfreezeString

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.50 | -

In Ruby 2.3 or later, use unary plus operator to unfreeze a string
literal instead of `String#dup` and `String.new`.
Unary plus operator is faster than `String#dup`.

Note: `String.new` (without operator) is not exactly the same as `+''`.
These differ in encoding. `String.new.encoding` is always `ASCII-8BIT`.
However, `(+'').encoding` is the same as script encoding(e.g. `UTF-8`).
So, if you expect `ASCII-8BIT` encoding, disable this cop.

### Examples

```ruby
# bad
''.dup
"something".dup
String.new
String.new('')
String.new('something')

# good
+'something'
+''
```

## Performance/UriDefaultParser

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes  | 0.50 | -

This cop identifies places where `URI::Parser.new`
can be replaced by `URI::DEFAULT_PARSER`.

### Examples

```ruby
# bad
URI::Parser.new

# good
URI::DEFAULT_PARSER
```
