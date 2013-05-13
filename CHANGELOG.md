# Changelog

## master (unreleased)

### New features

## 0.7.2 (05/13/2013)

### Bugs fixed

* [#155](https://github.com/bbatsov/rubocop/issues/155) 'Do not use semicolons to terminate expressions.' is not implemented correctly
* `OpMethod` now handles definition of unary operators without crashing.
* `SymbolSnakeCase` now handles aliasing of operators without crashing.
* `RescueException` now handles the splat operator `*` in a `rescue` clause without crashing.
* [#159](https://github.com/bbatsov/rubocop/issues/159) AvoidFor cop misses many violations

## 0.7.1 (05/11/2013)

### Bugs fixed

* Added missing files to the gemspec

## 0.7.0 (05/11/2013)

### New features

* Added ability to include or exclude files/directories through `.rubocop.yml`
* Added option --only for running a single cop.
* Relax semicolon rule for one line methods, classes and modules
* Configuration files, such as `.rubocop.yml`, can now include configuration from other files through the `inherit_from` directive. All configuration files implicitly inherit from `config/default.yml`.
* New cop `ClassMethods` checks for uses for class/module names in definitions of class/module methods
* New cop `SingleLineMethods` checks for methods implemented on a single line
* New cop `FavorJoin` checks for usages of `Array#*` with a string argument
* New cop `BlockComments` tracks uses of block comments(`=begin/=end` comments)
* New cop `EmptyLines` tracks consecutive blank lines
* New cop `WordArray` tracks arrays of words.
* [#108](https://github.com/bbatsov/rubocop/issues/108) New cop `SpaceInsideHashLiteralBraces` checks for spaces inside hash literal braces - style is configurable
* New cop `LineContinuation` tracks uses of the line continuation character (`\`)
* New cop `SymbolArray` tracks arrays of symbols.
* Print warnings for unrecognized names in configuration files.
* New cop `TrivialAccessors` tracks method definitions that could be automatically generated with `attr_*` methods.
* New cop `LeadingCommentSpace` checks for missing space after `#` in comments.
* New cop `ColonMethodCall` tracks uses of `::` for method calls.
* New cop `AvoidGlobalVars` tracks uses of non built-in global variables.
* New cop `SpaceAfterControlKeyword` tracks missing spaces after `if/elsif/case/when/until/unless/while`.
* New cop `Not` tracks uses of the `not` keyword.
* New cop `Eval` tracks uses of the `eval` function.

### Bugs fixed

* [#101](https://github.com/bbatsov/rubocop/issues/101) `SpaceAroundEqualsInParameterDefault` doesn't work properly with empty string
* Fix `BraceAfterPercent` for `%W`, `%i` and `%I` and added more tests
* Fix a false positive in the `Alias` cop. `:alias` is no longer treated as keyword
* `ArrayLiteral` now properly detects `Array.new`
* `HashLiteral` now properly detects `Hash.new`
* `VariableInterpolation` now detects regexp back references and doesn't crash.
* Don't generate pathnames like some/project//some.rb
* [#151](https://github.com/bbatsov/rubocop/issues/151) Don't print the unrecognized cop warning several times for the same `.rubocop.yml`

### Misc

* Renamed `Indentation` cop to `CaseIndentation` to avoid confusion
* Renamed `EmptyLines` cop to `EmptyLineBetweenDefs` to avoid confusion

## 0.6.1 (04/28/2013)

### New features

* Split `AsciiIdentifiersAndComments` cop in two separate cops

### Bugs fixed

* [#90](https://github.com/bbatsov/rubocop/issues/90) Two cops crash when scanning code using `super`
* [#93](https://github.com/bbatsov/rubocop/issues/93) Issue with `whitespace?': undefined method`
* [#97](https://github.com/bbatsov/rubocop/issues/97) Build fails
* [#100](https://github.com/bbatsov/rubocop/issues/100) `OpMethod` cop doesn't work if method arg is not in braces
* `SymbolSnakeCase` now tracks Ruby 1.9 hash labels as well as regular symbols

### Misc

* [#88](https://github.com/bbatsov/rubocop/issues/88) Abort gracefully when interrupted with Ctrl-C
* No longer crashes on bugs within cops. Now problematic checks are skipped and a message is displayed.
* Replaced `Term::ANSIColor` with `Rainbow`.
* Add an option to disable colors in the output.
* Cop names are now displayed alongside messages when `-d/--debug` is passed.

## 0.6.0 (04/23/2013)

### New features

* New cop `ReduceArguments` tracks argument names in reduce calls
* New cop `MethodLength` tracks number of LOC (lines of code) in methods
* New cop `RescueModifier` tracks uses of `rescue` in modifier form.
* New cop `PercentLiterals` tracks uses of `%q`, `%Q`, `%s` and `%x`.
* New cop `BraceAfterPercent` tracks uses of % literals with
  delimiters other than ().
* Support for disabling cops locally in a file with rubocop:disable comments.
* New cop `EnsureReturn` tracks usages of `return` in `ensure` blocks.
* New cop `HandleExceptions` tracks suppressed exceptions.
* New cop `AsciiIdentifiersAndComments` tracks uses of non-ascii
  characters in identifiers and comments.
* New cop `RescueException` tracks uses of rescuing the `Exception` class.
* New cop `ArrayLiteral` tracks uses of Array.new.
* New cop `HashLiteral` tracks uses of Hash.new.
* New cop `OpMethod` tracks the argument name in operator methods.
* New cop `PercentR` tracks uses of %r literals with zero or one slash in the regexp.
* New cop `FavorPercentR` tracks uses of // literals with more than one slash in the regexp.

### Bugs fixed

* [#62](https://github.com/bbatsov/rubocop/issues/62) - Config files in ancestor directories are ignored if another exists in home directory
* [#65](https://github.com/bbatsov/rubocop/issues/65) - Suggests to convert symbols `:==`, `:<=>` and the like to snake_case
* [#66](https://github.com/bbatsov/rubocop/issues/66) - Does not crash on unreadable or unparseable files
* [#70](https://github.com/bbatsov/rubocop/issues/70) - Support `alias` with bareword arguments
* [#64](https://github.com/bbatsov/rubocop/issues/64) - Performance issue with Bundler
* [#75](https://github.com/bbatsov/rubocop/issues/75) - Make it clear that some global variables require the use of the English library
* [#79](https://github.com/bbatsov/rubocop/issues/79) - Ternary operator missing whitespace detection

### Misc

* Dropped Jeweler for gem release management since it's no longer
  actively maintained.
* Handle pluralization properly in the final summary.

## 0.5.0 (04/17/2013)

### New features

* New cop `FavorSprintf` that checks for usages of `String#%`
* New cop `Semicolon` that checks for usages of `;` as expression separator
* New cop `VariableInterpolation` that checks for variable interpolation in double quoted strings
* New cop `Alias` that checks for uses of the keyword `alias`
* Automatically detect extensionless Ruby files with shebangs when search for Ruby source files in a directory

### Bugs fixed

* [#59](https://github.com/bbatsov/rubocop/issues/59) - Interpolated variables not enclosed in braces are not noticed
* [#42](https://github.com/bbatsov/rubocop/issues/42) - Received malformed format string ArgumentError from rubocop
