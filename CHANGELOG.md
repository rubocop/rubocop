# Changelog

## master (unreleased)

## 0.14.1 (10/10/2013)

### New features

* [#551](https://github.com/bbatsov/rubocop/pull/551) - New cop `BracesAroundHashParameters` checks for braces in function calls with hash parameters.
* New cop `SpaceAfterNot` tracks redundant space after the `!` operator.

### Bugs fixed

* Fix bug concerning table and separator alignment of multi-line hash with multiple keys on the same line.
* Fix a bug where `ClassLength` counted lines of inner classes/modules
* Fix a false positive for namespace class in `Documentation`
* Fix "Parser::Source::Range spans more than one line" bug in clang formatter
* [#552](https://github.com/bbatsov/rubocop/pull/552) - `RaiseArgs` allows exception constructor calls with more than one 1 argument.

## 0.14.0 (07/10/2013)

### New features

* [#491](https://github.com/bbatsov/rubocop/issues/491) - New cop `MethodCalledOnDoEndBlock` keeps track of methods called on `do`...`end` blocks.
* [#456](https://github.com/bbatsov/rubocop/issues/456) - New configuration parameter `AllCops`/`RunRailsCops` can be set to `true` for a project, removing the need to give the `-R`/`--rails` option with every invocation of `rubocop`.
* [#501](https://github.com/bbatsov/rubocop/issues/501) - `simple`/`clang`/`progress`/`emacs` formatters now print `[Corrected]` along with offence message when the offence is automatically corrected.
* [#501](https://github.com/bbatsov/rubocop/issues/501) - `simple`/`clang`/`progress` formatters now print count of auto-corrected offences in the final summary.
* [#501](https://github.com/bbatsov/rubocop/issues/501) - `json` formatter now outputs `corrected` key with boolean value in offence objects whether the offence is automatically corrected.
* New cop `ClassLength` checks for overly long class definitions
* New cop `Debugger` checks for forgotten calls to debugger or pry
* New cop `RedundantException` checks for code like `raise RuntimeError, message`
* [#526](https://github.com/bbatsov/rubocop/issues/526) - New cop `RaiseArgs` checks the args passed to `raise/fail`.

### Changes

* Cop `MethodAndVariableSnakeCase` replaced by `MethodName` and `VariableName`, both having the configuration parameter `EnforcedStyle` with values `snake_case` (default) and `camelCase`.
* [#519](https://github.com/bbatsov/rubocop/issues/519) - `HashSyntax` cop is now configurable and can enforce the use of the classic hash rockets syntax
* [#520](https://github.com/bbatsov/rubocop/issues/520) - `StringLiterals` cop is now configurable and can enforce either single-quoted or double-quoted strings.
* [#528](https://github.com/bbatsov/rubocop/issues/528) - Added a config option to `RedundantReturn` to allow a `return` with multiple values.
* [#524](https://github.com/bbatsov/rubocop/issues/524) - Added a config option to `Semicolon` to allow the use of `;` as an expression separator.
* [#525](https://github.com/bbatsov/rubocop/issues/525) - `SignalException` cop is now configurable and can enforce the semantic rule or an exclusive use of `raise` or `fail`.
* `LambdaCall` is now configurable and enforce either `Proc#call` or `Proc#()`.
* [#529](https://github.com/bbatsov/rubocop/issues/529) - Added config option `EnforcedStyle` to `SpaceAroundBraces`.
* [#529](https://github.com/bbatsov/rubocop/issues/529) - Changed config option `NoSpaceBeforeBlockParameters` to `SpaceBeforeBlockParameters`.
* Support Parser 2.0.0 (non-beta)

### Bugs fixed

* [#514](https://github.com/bbatsov/rubocop/issues/514) - Fix alignment of the hash containing different key lengths in one line
* [#496](https://github.com/bbatsov/rubocop/issues/496) - Fix corner case crash in `AlignHash` cop: single key/value pair when configuration is `table` for '=>' and `separator` for `:`.
* [#502](https://github.com/bbatsov/rubocop/issues/502) - Don't check non-decimal literals with `NumericLiterals`
* [#448](https://github.com/bbatsov/rubocop/issues/448) - Fix auto-correction of parameters spanning more than one line in `AlignParameters` cop.
* [#493](https://github.com/bbatsov/rubocop/issues/493) - Support disabling `Syntax` offences with `warning` severity
* Fix bug appearing when there were different values for the `AllCops`/`RunRailsCops` configuration parameter in different directories.
* [#512](https://github.com/bbatsov/rubocop/issues/512) - Fix bug causing crash in `AndOr` auto-correction.
* [#515](https://github.com/bbatsov/rubocop/issues/515) - Fix bug causing `AlignParameters` and `AlignArray` auto-correction to destroy code.
* [#516](https://github.com/bbatsov/rubocop/issues/516) - Fix bug causing `RedundantReturn` auto-correction to produce invalid code.
* [#527](https://github.com/bbatsov/rubocop/issues/527) - Handle `!=` expressions in `EvenOdd` cop
* `SignalException` cop now finds `raise` calls anywhere, not only in `begin` sections.
* [#538](https://github.com/bbatsov/rubocop/issues/538) - Fix bug causing `Blocks` auto-correction to produce invalid code.

## 0.13.1 (19/09/2013)

### New features

* `HashSyntax` cop does auto-correction.
* Allow calls to self to fix name clash with argument [#484](https://github.com/bbatsov/rubocop/pull/484)
* Renamed `SpaceAroundBraces` to `SpaceAroundBlockBraces`.
* `SpaceAroundBlockBraces` now has a `NoSpaceBeforeBlockParameters` config option to enforce a style for blocks with parameters like `{|foo| puts }`.
* New cop `LambdaCall` tracks uses of the obscure `lambda.(...)` syntax

### Bugs fixed

* Fix crash on empty input file in `FinalNewline`.
* [#485](https://github.com/bbatsov/rubocop/issues/485) - Fix crash on multiple-assignment and op-assignment in `UselessSetterCall`.
* [#497](https://github.com/bbatsov/rubocop/issues/497) - Fix crash in `UselessComparison` and `NilComparison`

## 0.13.0 (13/09/2013)

### New features

* New configuration parameter `AllowAdjacentOneLineDefs` for `EmptyLineBetweenDefs`.
* New cop `MultilineBlockChain` keeps track of chained blocks spanning multiple lines.
* `RedundantSelf` cop does auto-correction
* `AvoidPerlBackrefs` cop does auto-correction.
* `AvoidPerlisms` cop does auto-correction.
* `RedundantReturn` cop does auto-correction.
* `Blocks` cop does auto-correction.
* New cop `TrailingBlankLines` keeps track of extra blanks lines at the end of source file.
* New cop `AlignHash` keeps track of bad alignment in multi-line hash literals.
* New cop `AlignArray` keeps track of bad alignment in multi-line array literals.
* New cop `SpaceBeforeModifierKeyword` keeps track of missing space before a modifier keyword (`if`, `unless`, `while`, `until`).
* New cop `FinalNewline` keeps tracks of the required final newline in a source file.
* Highlightling corrected in `SpaceInsideHashLiteralBraces` and `SpaceAroundBraces` cops.

### Changes

* [#447](https://github.com/bbatsov/rubocop/issues/447) - `BlockAlignment` cop now allows `end` to be aligned with the start of the line containing `do`.
* `SymbolName` now has an `AllowDots` config option to allow symbols like `:'whatever.submit_button'`.
* [#469](https://github.com/bbatsov/rubocop/issues/469) - Extracted useless setter call tracking part of `UselessAssignment` cop to `UselessSetterCall`.
* [#469](https://github.com/bbatsov/rubocop/issues/469) - Merged `UnusedLocalVariable` cop into `UselessAssignment`.
* [#458](https://github.com/bbatsov/rubocop/issues/458) - The merged `UselessAssignment` cop now has advanced logic that tracks not only assignment at the end of the method but also every assignment in every scope.
* [#466](https://github.com/bbatsov/rubocop/issues/466) - Allow built-in JRuby global vars in `AvoidGlobalVars`
* Added a config option `AllowedVariables` to `AvoidGlobalVars` to allow users to whitelist certain global variables
* Renamed `AvoidGlobalVars` to `GlobalVars`
* Renamed `AvoidPerlisms` to `SpecialGlobalVars`
* Renamed `AvoidFor` to `For`
* Renamed `AvoidClassVars` to `ClassVars`
* Renamed `AvoidPerlBackrefs` to `PerlBackrefs`
* `NumericLiterals` now accepts a config param `MinDigits` - the minimal number of digits in the integer portion of number for the cop to check it.

### Bugs fixed

* [#449](https://github.com/bbatsov/rubocop/issues/449) - Remove whitespaces between condition and `do` with `WhileUntilDo` auto-correction
* Continue with file inspection after parser warnings. Give up only on syntax errors.
* Don’t trigger the HashSyntax cop on digit-starting keys.
* Fix crashes while inspecting class definition subclassing another class stored in a local variable in `UselessAssignment` (formerly of `UnusedLocalVariable`) and `ShadowingOuterLocalVariable` (like `clazz = Array; class SomeClass < clazz; end`).
* [#463](https://github.com/bbatsov/rubocop/issues/463) - Do not warn if using destructuring in second `reduce` argument (`ReduceArguments`)

## 0.12.0 (23/08/2013)

### New features

* [#439](https://github.com/bbatsov/rubocop/issues/439) Added formatter 'OffenceCount' which outputs a summary list of cops and their offence count
* [#395](https://github.com/bbatsov/rubocop/issues/395) Added `--show-cops` option to show available cops.
* New cop `NilComparison` keeps track of comparisons like `== nil`
* New cop `EvenOdd` keeps track of occasions where `Fixnum#even?` or `Fixnum#odd?` should have been used (like `x % 2 == 0`)
* New cop `IndentationWidth` checks for files using indentation that is not two spaces.
* New cop `SpaceAfterMethodName` keeps track of method definitions with a space between the method name and the opening parenthesis.
* New cop `ParenthesesAsGroupedExpression` keeps track of method calls with a space before the opening parenthesis.
* New cop `HashMethods` keeps track of uses of deprecated `Hash` methods.
* New Rails cop `HasAndBelongsToMany` checks for uses of `has_and_belongs_to_many`.
* New Rails cop `ReadAttribute` tracks uses of `read_attribute`.
* `Attr` cop does auto-correction
* `CollectionMethods` cop does auto-correction
* `SignalException` cop does auto-correction
* `EmptyLiteral` cop does auto-correction
* `MethodCallParentheses` cop does auto-correction
* `DefWithParentheses` cop does auto-correction
* `DefWithoutParentheses` cop does auto-correction

### Changes

* Dropped `-s`/`--silent` option. Now `progress`/`simple`/`clang` formatters always report summary and `emacs`/`files` formatters no longer report.
* Dropped the `LineContinuation` cop

### Bugs fixed

* [#432](https://github.com/bbatsov/rubocop/issues/432) - Fix false positive for constant assignments when rhs is a method call with block in `ConstantName`
* [#434](https://github.com/bbatsov/rubocop/issues/434) - Support classes and modules defined with `Class.new`/`Module.new` in `AccessControl`
* Fix which ranges are highlighted in reports from IfUnlessModifier, WhileUntilModifier, and MethodAndVariableSnakeCase cop.
* [#438](https://github.com/bbatsov/rubocop/issues/438) - Accept setting attribute on method argument in `UselessAssignment`

## 0.11.1 (12/08/2013)

### Changes

* [#425](https://github.com/bbatsov/rubocop/issues/425) - `
  ColonMethodCalls` now allows
  constructor methods (like `Nokogiri::HTML()` to be called with double colon.

### Bugs fixed

* [#427](https://github.com/bbatsov/rubocop/issues/427) - FavorUnlessOverNegatedIf triggered when using elsifs
* [#429](https://github.com/bbatsov/rubocop/issues/429) - Fix `LeadingCommentSpace` offence reporting
* Fixed `AsciiComments` offence reporting
* Fixed `BlockComments` offence reporting

## 0.11.0 (09/08/2013)

### New features

* [#421](https://github.com/bbatsov/rubocop/issues/421) - `
  TrivialAccessors` now ignores methods on user-configurable
  whitelist (such as `to_s` and `to_hash`)
* New option `--auto-gen-config` outputs RuboCop configuration that disables all
  cops that detect any offences (for
  [#369](https://github.com/bbatsov/rubocop/issues/369)).
* The list of annotation keywords recognized by the `CommentAnnotation` cop is now configurable.
* Configuration file names are printed as they are loaded in `--debug` mode.
* Auto-correct support added in `AlignParameters` cop.
* New cop `UselessComparison` checks for comparisons of the same arguments.
* New cop `UselessAssignment` checks for useless assignments to local variables.
* New cop `SignalException` checks for proper usage of `fail` and `raise`.
* New cop `ModuleFunction` checks for usage of `extend self` in modules.

### Bugs fixed

* [#374](https://github.com/bbatsov/rubocop/issues/374) - Fixed error at post condition loop (`begin-end-while`, `begin-end-until`) in `UnusedLocalVariable` and `ShadowingOuterLocalVariable`
* [#373](https://github.com/bbatsov/rubocop/issues/373) and [#376](https://github.com/bbatsov/rubocop/issues/376) - allow braces around multi-line blocks if `do`-`end` would change the meaning of the code
* `RedundantSelf` now allows `self.` followed by any ruby keyword
* [#391](https://github.com/bbatsov/rubocop/issues/391) - Fix bug in counting slashes in a regexp.
* [#394](https://github.com/bbatsov/rubocop/issues/394) - `DotPosition` cop handles correctly code like `l.(1)`
* [#390](https://github.com/bbatsov/rubocop/issues/390) - `CommentAnnotation` cop allows keywords (e.g. Review, Optimize) if they just begin a sentence.
* [#400](https://github.com/bbatsov/rubocop/issues/400) - Fix bug concerning nested defs in `EmptyLineBetweenDefs` cop.
* [#399](https://github.com/bbatsov/rubocop/issues/399) - Allow assignment inside blocks in `AssignmentInCondition` cop.
* Fix bug in favor_modifier.rb regarding missed offences after else etc.
* [#393](https://github.com/bbatsov/rubocop/issues/393) - Retract support for multiline chaining of blocks (which fixed [#346](https://github.com/bbatsov/rubocop/issues/346)), thus rejecting issue 346.
* [#389](https://github.com/bbatsov/rubocop/issues/389) - Ignore symbols that are arguments to Module#private_constant in `SymbolName` cop.
* [#387](https://github.com/bbatsov/rubocop/issues/387) - Do autocorrect in `AndOr` cop only if it does not change the meaning of the code.
* [#398](https://github.com/bbatsov/rubocop/issues/398) - Don't display blank lines in the output of the clang formatter
* [#283](https://github.com/bbatsov/rubocop/issues/283) - Refine `StringLiterals` string content check

## 0.10.0 (17/07/2013)

### New features

* New cop `RedundantReturn` tracks redundant `return`s in method bodies
* New cop `RedundantBegin` tracks redundant `begin` blocks in method definitions.
* New cop `RedundantSelf` tracks redundant uses of `self`.
* New cop `EmptyEnsure` tracks empty `ensure` blocks.
* New cop `CommentAnnotation` tracks formatting of annotation comments such as TODO.
* Added custom rake task.
* New formatter `FileListFormatter` outputs just a list of files with offences in them (related to [#357](https://github.com/bbatsov/rubocop/issues/357)).

### Changes

* `TrivialAccessors` now has an `ExactNameMatch` config option (related to [#308](https://github.com/bbatsov/rubocop/issues/308)).
* `TrivialAccessors` now has an `ExcludePredicates` config option (related to [#326](https://github.com/bbatsov/rubocop/issues/326)).
* Cops don't inherit from `Parser::AST::Rewriter` anymore. All 3rd party Cops should remove the call to `super` in their
  callbacks. If you implement your own processing you need to define the `#investigate` method instead of `#inspect`. Refer to
  the documentation of `Cop::Commissioner` and `Cop::Cop` classes for more information.
* `EndAlignment` cop split into `EndAlignment` and `BlockAlignment` cops.

### Bugs fixed

* [#288](https://github.com/bbatsov/rubocop/issues/288) - work with absolute Excludes paths internally (2nd fix for this issue)
* `TrivialAccessors` now detects class attributes as well as instance attributes
* [#338](https://github.com/bbatsov/rubocop/issues/338) - fix end alignment of blocks in chained assignments
* [#345](https://github.com/bbatsov/rubocop/issues/345) - add `$SAFE` to the list of built-in global variables
* [#340](https://github.com/bbatsov/rubocop/issues/340) - override config parameters rather than merging them
* [#349](https://github.com/bbatsov/rubocop/issues/349) - fix false positive for `CharacterLiteral` (`%w(?)`)
* [#346](https://github.com/bbatsov/rubocop/issues/346) - support method chains for block end alignment checks
* [#350](https://github.com/bbatsov/rubocop/issues/350) - support line breaks between variables on left hand side for block end alignment checks
* [#356](https://github.com/bbatsov/rubocop/issues/350) - allow safe assignment in `ParenthesesAroundCondition`

### Misc

* Improved performance on Ruby 1.9 by about 20%
* Improved overall performance by about 35%

## 0.9.1 (05/07/2013)

### New features

* Added `-l/--lint` option to allow doing only linting with no style checks (similar to running `ruby -wc`).

### Changes

* Removed the `BlockAlignSchema` configuration option from `EndAlignment`. We now support only the default alignment schema - `StartOfAssignment`.
* Made the preferred collection methods in `CollectionMethods` configurable.
* Made the `DotPosition` cop configurable - now both `leading` and `trailing` styles are supported.

### Bugs fixed

* [#318](https://github.com/bbatsov/rubocop/issues/318) - correct some special cases of block end alignment
* [#317](https://github.com/bbatsov/rubocop/issues/317) - fix a false positive in `LiteralInCondition`
* [#321](https://github.com/bbatsov/rubocop/issues/321) - Ignore variables whose name start with `_` in `ShadowingOuterLocalVariable`
* [#322](https://github.com/bbatsov/rubocop/issues/322) - Fix exception of `UnusedLocalVariable` and `ShadowingOuterLocalVariable` when inspecting keyword splat argument
* [#316](https://github.com/bbatsov/rubocop/issues/316) - Correct nested postfix unless in `MultilineIfThen`
* [#327](https://github.com/bbatsov/rubocop/issues/327) - Fix false offences for block expression that span on two lines in `EndAlignment`
* [#332](https://github.com/bbatsov/rubocop/issues/332) - Fix exception of `UnusedLocalVariable` and `ShadowingOuterLocalVariable` when inspecting named captures
* [#333](https://github.com/bbatsov/rubocop/issues/333) - Fix a case that `EnsureReturn` throws an exception when ensure has no body

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
* Add support for auto-correction of some offences with `-a`/`--auto-correct`.

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
