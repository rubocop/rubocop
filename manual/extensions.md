## Extensions

It's possible to extend RuboCop with custom cops and formatters.

### Loading Extensions

Besides the `--require` command line option you can also specify ruby
files that should be loaded with the optional `require` directive in the
`.rubocop.yml` file:

```yaml
require:
 - ../my/custom/file.rb
 - rubocop-extension
```

Note: The paths are directly passed to `Kernel.require`.  If your
extension file is not in `$LOAD_PATH`, you need to specify the path as
relative path prefixed with `./` explicitly, or absolute path. Paths
starting with a `.` are resolved relative to `.rubocop.yml`.

### Custom Cops

You can configure the custom cops in your `.rubocop.yml` just like any
other cop.

#### Known Custom Cops

* [rubocop-rspec](https://github.com/nevir/rubocop-rspec) -
  RSpec-specific analysis
* [rubocop-cask](https://github.com/caskroom/rubocop-cask) - Analysis
  for Homebrew-Cask files.
* [rubocop-thread_safety](https://github.com/covermymeds/rubocop-thread_safety) -
  Thread-safety analysis
* [rubocop-require_tools](https://github.com/milch/rubocop-require_tools) -
  Dynamic analysis for missing require statements

### Custom Formatters

You can customize RuboCop's output format with custom formatters.

#### Creating a Custom Formatter

To implement a custom formatter, you need to subclass
`RuboCop::Formatter::BaseFormatter` and override some methods,
or implement all formatter API methods by duck typing.

Please see the documents below for more formatter API details.

* [RuboCop::Formatter::BaseFormatter](http://www.rubydoc.info/gems/rubocop/RuboCop/Formatter/BaseFormatter)
* [RuboCop::Cop::Offense](http://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Offense)
* [Parser::Source::Range](http://www.rubydoc.info/github/whitequark/parser/Parser/Source/Range)

#### Using a Custom Formatter from the Command Line

You can tell RuboCop to use your custom formatter with a combination of
`--format` and `--require` option.
For example, when you have defined `MyCustomFormatter` in
`./path/to/my_custom_formatter.rb`, you would type this command:

```sh
$ rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
```
