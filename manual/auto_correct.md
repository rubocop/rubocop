## Auto-correct

In auto-correct mode, RuboCop will try to automatically fix offenses:

```sh
$ rubocop -a
```

For some offenses, it is not possible to implement automatic correction. 

Some automatic corrections that _are_ possible have not been implemented yet.

### Safe auto-correct

```sh
$ rubocop --safe-auto-correct
```

In RuboCop 0.60, we began to annotate cops as `Safe` or not safe. Eventually,
the safety of each cop will be determined.

> - Safe (true/false) - indicates whether the cop can yield false positives (by
>   design) or not.
> - SafeAutoCorrect (true/false) - indicates whether the auto-correct the cop
>   does is safe (equivalent) by design.
> https://github.com/rubocop-hq/rubocop/issues/5978#issuecomment-395958738

If a cop is annotated as "not safe", it will be omitted.

#### Example of Unsafe Cop

```ruby
array = []
array << 'Foo' <<
         'Bar' <<
         'Baz'
puts array.join('-')
```

`Style/LineEndConcatenation` will correct the above to:

```ruby
array = []
array << 'Foo' \
  'Bar' \
  'Baz'
puts array.join('-')
```

Therefore, in this (unusual) scenario, `Style/LineEndConcatenation` is unsafe.

(This is a contrived example. Real code would use `%w` for an array of string
literals.)
