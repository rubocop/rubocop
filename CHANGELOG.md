# Changelog

## master (unreleased)

### Bugs fixed

* [#318](https://github.com/bbatsov/rubocop/issues/318) - correct some special cases of block end alignment
* [#317](https://github.com/bbatsov/rubocop/issues/317) - fix a false positive in `LiteralInCondition`
* [#321](https://github.com/bbatsov/rubocop/issues/321) - Ignore variables whose name start with `_` in `ShadowingOuterLocalVariable`
* [#322](https://github.com/bbatsov/rubocop/issues/322) - Fix exception of `UnusedLocalVariable` and `ShadowingOuterLocalVariable` when inspecting keyword splat argument

## 0.9.0 (01/07/2013)

### New features

* Introduced formatter feature, enables custom formatted output and multiple outputs.
* Added progress formatter and now it's the default. (`--format progress`)
* Added JSON formatter. (`--format json`)
* Added clang style formatter showing the offending source
  code. (`--format clang`). The `clang` formatter marks a whole range
  rather than just the starting position, to indicate more clearly
  where the problem is.
* Added `-f`/`--format` option to specify formatter.
* Added `-o`/`--out` option to specify output file for each formatter.
* Added `-r/--require` option to inject external Ruby code into RuboCop.
* Added `-V/--verbose-version` option that displays Parser version and Ruby version as well.
* Added `-R/--rails` option that enables extra Rails-specific cops.
* Added support for auto-correction of some offences with `-a`/`--auto-correct`.
* New cop `CaseEquality` checks for explicit use of `===`
* New cop `AssignmentInCondition` checks for assignment in conditions.
* New cop `EndAlignment` tracks misaligned `end` keywords.
* New cop `Void` tracks uses of literals/variables/operators in possibly void context.
* New cop `Documentation` checks for top level class/module doc comments.
* New cop `UnreachableCode` tracks unreachable code segments.
* New cop `MethodCallParentheses` tracks unwanted braces in method calls.
* New cop `UnusedLocalVariable` tracks unused local variables for each scope.
* New cop `ShadowingOuterLocalVariable` tracks use of the same name as outer local variables for block arguments or block local variables.
* New cop `WhileUntilDo` tracks uses of `do` with multi-line `while/until`.
* New cop `CharacterLiteral` tracks uses of character literals (`?x`).
* New cop `EndInMethod` tracks uses of `END` in method definitions.
* New cop `LiteralInCondition` tracks uses of literals in the conditions of `if/while/until`.
* New cop `BeginBlock` tracks uses of `BEGIN` blocks.
* New cop `EndBlock` tracks uses of `END` blocks.
* New cop `DotPosition` tracks the dot position in multi-line method calls.
* New cop `Attr` tracks uses of `Module#attr`.

### Changes

* Deprecated `-e`/`--emacs` option. (Use `--format emacs` instead)
* Made `progress` formatter the default.
* Most formatters (`progress`, `simple` and `clang`) now print relative file paths if the paths are under the current working directory.
* Migrate all cops to new namespaces. `Rubocop::Cop::Lint` is for cops that emit warnings. `Rubocop::Cop::Style` is for cops that do not belong in other namespaces.
* Merge `FavorPercentR` and `PercentR` into one cop called `RegexpLiteral`, and add configuration parameter `MaxSlashes`.
* Add `CountKeywordArgs` configuration option to `ParameterLists` cop.

### Bugs fixed

* [#239](https://github.com/bbatsov/rubocop/issues/239) - fixed double quotes false positives
* [#233](https://github.com/bbatsov/rubocop/issues/233) - report syntax cop offences
* Fix off-by-one error in favor_modifier.
* [#229](https://github.com/bbatsov/rubocop/issues/229) - recognize a line with CR+LF as a blank line in AccessControl cop.
* [#235](https://github.com/bbatsov/rubocop/issues/235) - handle multiple constant assignment in ConstantName cop
* [#246](https://github.com/bbatsov/rubocop/issues/246) - correct handling of unicode escapes within double quotes
* Fix crashes in Blocks, CaseEquality, CaseIndentation, ClassAndModuleCamelCase, ClassMethods, CollectionMethods, and ColonMethodCall.
* [#263](https://github.com/bbatsov/rubocop/issues/263) - do not check for space around operators called with method syntax
* [#271](https://github.com/bbatsov/rubocop/issues/271) - always allow line breaks inside hash literal braces
* [#270](https://github.com/bbatsov/rubocop/issues/270) - fixed a false positive in ParenthesesAroundCondition
* [#288](https://github.com/bbatsov/rubocop/issues/288) - get config parameter AllCops/Excludes from highest config file in path
* [#276](https://github.com/bbatsov/rubocop/issues/276) - let columns start at 1 instead of 0 in all output of column numbers
* [#292](https://github.com/bbatsov/rubocop/issues/292) - don't check non-regular files (like sockets, etc)
* Fix crashes in WordArray on arrays of character literals such as `[?\r, ?\n]`
* Fix crashes in Documentation on empty modules

## 0.8.3 (18/06/2013)

### Bug fixes

* Lock Parser dependency to version 2.0.0.beta5.

## 0.8.2 (06/05/2013)

### New features

* New cop `BlockNesting` checks for excessive block nesting

### Bug fixes

* Correct calculation of whether a modifier version of a conditional statement will fit.
* Fix an error in `MultilineIfThen` cop that occurred in some special cases.
* [#231](https://github.com/bbatsov/rubocop/issues/231) - fix a false positive for modifier if

## 0.8.1 (05/30/2013)

### New features

* New cop `Proc` tracks uses of `Proc.new`

### Changes

* Renamed `NewLambdaLiteral` to `Lambda`.
* Aligned the `Lambda` cop more closely to the style guide - it now
  allows the use of `lambda` for multi-line blocks.

### Bugs fixed

* [#210](https://github.com/bbatsov/rubocop/issues/210) - fix a false positive for double quotes in regexp literals
* [#211](https://github.com/bbatsov/rubocop/issues/211) - fix a false positive for `initialize` method looking like a trivial writer
* [#215](https://github.com/bbatsov/rubocop/issues/215) - Fixed a lot of modifier `if/unless/while/until` issues
* [#213](https://github.com/bbatsov/rubocop/issues/213) - Make sure even disabled cops get their configuration set
* [#214](https://github.com/bbatsov/rubocop/issues/214) - Fix SpaceInsideHashLiteralBraces to handle string interpolation right

## 0.8.0 (05/28/2013)

### Changes

* Folded `ArrayLiteral` and `HashLiteral` into `EmptyLiteral` cop
* The maximum number of params `ParameterLists` accepts in now configurable
* Reworked `SymbolSnakeCase` into `SymbolName`, which has an option `AllowCamelCase` enabled by default.
* Migrated from `Ripper` to the portable [Parser](https://github.com/whitequark/parser).

### New features

* New cop `ConstantName` checks for constant which are not using `SCREAMING_SNAKE_CASE`.
* New cop `AccessControl` checks private/protected indentation and surrounding blank lines.
* New cop `Loop` checks for `begin/end/while(until)` and suggests the use of `Kernel#loop`.

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
