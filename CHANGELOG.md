# Change log

<!---
  Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.

  Please add an entry file to the https://github.com/rubocop/rubocop/blob/master/changelog/
  named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.

  See https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
-->

## master (unreleased)

## 1.82.0 (2025-12-17)

### New features

* [#14655](https://github.com/rubocop/rubocop/issues/14655): Add `AllowRBSInlineAnnotation` option to `Layout/LineLength`. ([@koic][])
* [#14569](https://github.com/rubocop/rubocop/issues/14569): Add `IncludedMacroPatterns` configuration option to `Style/MethodCallWithArgsParentheses` for pattern-based macro method enforcement. ([@mmenanno][])
* [#14670](https://github.com/rubocop/rubocop/pull/14670): Add new cop `Style/ModuleMemberExistenceCheck`. ([@lovro-bikic][])
* [#14644](https://github.com/rubocop/rubocop/pull/14644): Support `TargetRubyVersion 4.0` (experimental). ([@koic][])

### Bug fixes

* [#14649](https://github.com/rubocop/rubocop/pull/14649): Fix an error for `Lint/LiteralAsCondition` when there are literals in multiple branches. ([@viralpraxis][])
* [#14678](https://github.com/rubocop/rubocop/pull/14678): Fix an error when running deprecated `rake rubocop:auto_correct` task. ([@koic][])
* [#14650](https://github.com/rubocop/rubocop/pull/14650): Fix wrong autocorrect for `Lint/RedundantSplatExpansion` when splatting a single literal. ([@earlopain][])
* [#14703](https://github.com/rubocop/rubocop/pull/14703): Fix false negatives for `Layout/RescueEnsureAlignment` when using self class definition. ([@koic][])
* [#14706](https://github.com/rubocop/rubocop/issues/14706): Fix false negatives for `Lint/NoReturnInBeginEndBlocks` when assigning instance variable, class variable, global variable, or constant. ([@koic][])
* [#14715](https://github.com/rubocop/rubocop/pull/14715): Fix false positives for `Layout/EmptyLineAfterGuardClause` when a guard clause follows a multiline heredoc in a parenthesized method call. ([@koic][])
* [#14667](https://github.com/rubocop/rubocop/issues/14667): Fix false positives for `Layout/EndAlignment` when a conditional assignment is used on the same line and the `end` with a safe navigation method call is aligned. ([@koic][])
* [#14688](https://github.com/rubocop/rubocop/pull/14688): Fix false positives for `Layout/EndAlignment` when a conditional assignment is used on the same line and the `end` with a numbered block or `it` block method call is aligned. ([@koic][])
* [#14699](https://github.com/rubocop/rubocop/pull/14699): Fix false positives for `Lint/RedundantSafeNavigation` when the receiver is used outside the singleton method definition scope. ([@koic][])
* [#14663](https://github.com/rubocop/rubocop/issues/14663): Fix false positives for `Style/EndlessMethod` when multiline or xstring heredoc is used in method body. ([@koic][])
* [#10173](https://github.com/rubocop/rubocop/issues/10173): Fix false positives for `Style/TrailingCommaInArguments` when `EnforcedStyleForMultiline` is set to `consistent_comma` and a multiline braced hash argument appears after another argument. ([@koic][])
* [#14680](https://github.com/rubocop/rubocop/pull/14680): Handle all `OptionParser` errors when running `rubocop` with input that causes an error. ([@dvandersluis][])
* [#14658](https://github.com/rubocop/rubocop/pull/14658): Fix incorrect behavior when `Layout/LineLength` is disabled. ([@koic][])
* [#14704](https://github.com/rubocop/rubocop/pull/14704): Fix incorrect Position character value in LSP. ([@tmtm][])
* [#14619](https://github.com/rubocop/rubocop/issues/14619): Store remote configuration caches in cache root. ([@Jack12816][])
* [#14476](https://github.com/rubocop/rubocop/issues/14476): Fix `Style/ClassAndModuleChildren` to skip compact style definitions inside another class or module when `EnforcedStyle: nested`. ([@rscq][])
* [#14281](https://github.com/rubocop/rubocop/issues/14281): Update `Layout/EndAlignment` with `EnforcedStyleAlignWith: variable` to handle conditionals inside `begin` nodes properly. ([@dvandersluis][])

### Changes

* [#14662](https://github.com/rubocop/rubocop/pull/14662): Add autocorrection for `Lint/UselessOr`. ([@r7kamura][])
* [#14668](https://github.com/rubocop/rubocop/pull/14668): Exclude `Severity` from configuration parameters. ([@r7kamura][])
* [#14684](https://github.com/rubocop/rubocop/issues/14684): Make `Style/CaseEquality` allow regexp case equality where the receiver is a regexp literal. ([@koic][])
* [#14645](https://github.com/rubocop/rubocop/pull/14645): Change `Lint/CircularArgumentReference` to detect offenses within long assignment chains. ([@viralpraxis][])
* [#14642](https://github.com/rubocop/rubocop/pull/14642): Make `Gemspec/RubyVersionGlobalsUsage` aware of `Ruby::VERSION`. ([@koic][])
* [#14695](https://github.com/rubocop/rubocop/issues/14695): Make `Layout/EmptyLineAfterMagicComment` aware of `# rbs_inline` magic comment. ([@koic][])
* [#10147](https://github.com/rubocop/rubocop/issues/10147): Make `Lint/ElseLayout` allow a single-line `else` body in `then` single-line conditional. ([@koic][])
* [#14661](https://github.com/rubocop/rubocop/pull/14661): Make `Lint/RedundantRequireStatement` aware of `pathname` when analyzing Ruby 4.0. ([@koic][])
* [#14698](https://github.com/rubocop/rubocop/pull/14698): Make `Lint/UnreachableCode` aware of singleton method redefinition. ([@koic][])
* [#14677](https://github.com/rubocop/rubocop/pull/14677): Make `Style/RedundantArgument` aware of `to_i`. ([@koic][])
* [#14660](https://github.com/rubocop/rubocop/pull/14660): Rename `IgnoreCopDirectives` to `AllowCopDirectives` in `Layout/LineLength`. ([@koic][])
* [#14492](https://github.com/rubocop/rubocop/issues/14492): Revert #14492, which added support for LSP positionEncoding 'utf-8' and 'utf-32' due to critical performance regression reports. ([@koic][])

## 1.81.7 (2025-10-31)

### Bug fixes

* [#14597](https://github.com/rubocop/rubocop/issues/14597): Fix an infinite loop error for `Layout/HashAlignment` when `EnforcedStyle: with_fixed_indentation` is specified for `Layout/ArgumentAlignment`. ([@koic][])
* [#14621](https://github.com/rubocop/rubocop/issues/14621): Fix an error for `Naming/PredicateMethod` when using an `in` pattern with empty parentheses body. ([@koic][])
* [#14631](https://github.com/rubocop/rubocop/pull/14631): Fix an error for `Style/SoleNestedConditional` when using nested single line `if`. ([@koic][])
* [#14626](https://github.com/rubocop/rubocop/issues/14626): Fix false positives in `Style/ConstantVisibility` when visibility is declared with multiple constants. ([@koic][])
* [#14628](https://github.com/rubocop/rubocop/issues/14628): Fix false positives for `Style/FloatDivision` when using `Regexp.last_match` or nth reference (e.g., `$1`). ([@koic][])
* [#14617](https://github.com/rubocop/rubocop/pull/14617): Handle non-specific issues with the Gemfile to allow fallback. ([@Fryguy][])
* [#14622](https://github.com/rubocop/rubocop/pull/14622): Fix an error for `Naming/MethodName` when the first argument to `alias` contains interpolation. ([@earlopain][])

## 1.81.6 (2025-10-21)

### Bug fixes

* [#14587](https://github.com/rubocop/rubocop/issues/14587): Fix an error for `Lint/SelfAssignment` when using `[]=` assignment with no arguments. ([@koic][])
* [#14572](https://github.com/rubocop/rubocop/issues/14572): Fix an error for `Style/ArrayIntersect` when `intersection(other).any?` is called without a receiver. ([@koic][])
* [#14599](https://github.com/rubocop/rubocop/pull/14599): Fix a crash when `Style/ConditionalAssignment` is configured with `assign_inside_conditional` and the conditional contains a multi-line regex. ([@martinemde][])
* [#14574](https://github.com/rubocop/rubocop/pull/14574): Fix false positives for `Style/RedundantInterpolation` when using a one-line `=>` pattern matching. ([@koic][])
* [#14602](https://github.com/rubocop/rubocop/issues/14602): Fix false positives for `Style/EndlessMethod` when heredoc is used in method body. ([@koic][])
* [#14594](https://github.com/rubocop/rubocop/issues/14594): Fix false positives for `Style/EndlessMethod` when the endless method would exceed the maximum line length. ([@koic][])
* [#14605](https://github.com/rubocop/rubocop/issues/14605): Fix false positive for `Lint/EmptyInterpolation` when interpolation is inside a `%W` literal. ([@dvandersluis][])
* [#14604](https://github.com/rubocop/rubocop/issues/14604): Fix `Style/RedundantFormat` false positive when a interpolated value is given to a specifier with a width or precision. ([@dvandersluis][])
* [#14607](https://github.com/rubocop/rubocop/pull/14607): Fix `Style/RedundantFormat` handling control characters like `\n`. ([@dvandersluis][])
* [#14577](https://github.com/rubocop/rubocop/pull/14577): Fix an incorrect autocorrect for `Style/Semicolon` when a method call using hash value omission without parentheses is terminated with a semicolon. ([@koic][])
* [#14552](https://github.com/rubocop/rubocop/issues/14552): Fix a false positive for `Security/JSONLoad` when `create_additions` is explicitly specified. ([@earlopain][])

### Changes

* [#14566](https://github.com/rubocop/rubocop/pull/14566): Enhance `Lint::ConstantOverwrittenInRescue` cop to detect offenses within fully qualified constants. ([@viralpraxis][])
* [#14575](https://github.com/rubocop/rubocop/pull/14575): Enhance `Lint/ConstantOverwrittenInRescue` cop to detect offenses within nested constants. ([@viralpraxis][])
* [#14596](https://github.com/rubocop/rubocop/pull/14596): Change `Lint/ConstantOverwrittenInRescue` to detect any constant assignment. ([@viralpraxis][])
* [#14568](https://github.com/rubocop/rubocop/pull/14568): Make `Style/LambdaCall` autocorrection contextual. ([@koic][])

## 1.81.1 (2025-09-26)

### Bug fixes

* [#14563](https://github.com/rubocop/rubocop/issues/14563): Fix incorrect autocorrection for `Lint/DeprecatedOpenSSLConstant` when `Cipher` appears twice. ([@koic][])

### Changes

* [#14565](https://github.com/rubocop/rubocop/pull/14565): Allow multiline method chain for `Style/NumberedParameters` and `Style/ItBlockParameter` with `EnforcedStyle: allow_single_line` when the block itself is on a single line. ([@earlopain][])

## 1.81.0 (2025-09-25)

### New features

* [#14512](https://github.com/rubocop/rubocop/pull/14512): Add `Style/ArrayIntersectWithSingleElement` cop. ([@r7kamura][])
* [#10971](https://github.com/rubocop/rubocop/issues/10971): Support `EnforcedStyleForMultiline: diff_comma` in `Style/TrailingCommaInArguments`. ([@akouryy][])

### Bug fixes

* [#14560](https://github.com/rubocop/rubocop/pull/14560): Fix an error for `Style/NilComparison` cop when using the `var.==(nil)` and `var.===(nil)` syntax. ([@viralpraxis][])
* [#14535](https://github.com/rubocop/rubocop/issues/14535): Fix autocorrect for `Style/ExplicitBlockArgument` when there are two methods that share the same implementation. ([@earlopain][])
* [#14527](https://github.com/rubocop/rubocop/pull/14527): Fix false negatives for `Style/NumberedParameters` and `Style/ItBlockParameter` when using multiline method chain with `EnforcedStyle: allow_single_line`. ([@koic][])
* [#14522](https://github.com/rubocop/rubocop/issues/14522): Fix false negatives for `Layout/MultilineOperationIndentation` when using indented code on LHS of equality operator in modifier method definition. ([@koic][])
* [#14496](https://github.com/rubocop/rubocop/issues/14496): Fix false negatives for `Layout/EmptyLineBetweenDefs` for `AllowAdjacentOneLineDefs: false` and `DefLikeMacros` that take no block. ([@earlopain][])
* [#14553](https://github.com/rubocop/rubocop/issues/14553): Fix false positives when `EnforcedStyle: allowed_in_returns` and `!!` appears across multiple lines in return position. ([@koic][])
* [#14557](https://github.com/rubocop/rubocop/issues/14557): Fix false positives for `Style/RedundantParentheses` when parentheses are used around a one-line `rescue` expression as a condition. ([@koic][])
* [#14525](https://github.com/rubocop/rubocop/pull/14525): Fix false positives for `Style/RedundantRegexpEscape` when an escaped variable sigil follows `#` (e.g., `/#\@foo/`, `/#\@@bar/`, `/#\$baz/`). ([@koic][])
* [#14529](https://github.com/rubocop/rubocop/issues/14529): Fix false negative in `Layout/RescueEnsureAlignment` with a block whose send node is split over multiple lines. ([@dvandersluis][])
* [#14528](https://github.com/rubocop/rubocop/issues/14528): Fix `Style/RedundantFormat` when the format string has a variable width that isn't given as a literal value. ([@dvandersluis][])
* [#14541](https://github.com/rubocop/rubocop/issues/14541): Fix gemspec parsing error when `ParserEngine: parser_prism` is configured in a base config file. ([@sudoremo][])
* [#14544](https://github.com/rubocop/rubocop/issues/14544): Fix an incorrect autocorrect for `Lint/Void` when using a return value in assignment method definition. ([@koic][])
* [#14543](https://github.com/rubocop/rubocop/issues/14543): Fix an incorrect autocorrect for `Style/RedundantRegexpArgument` when using escaped single quote character. ([@koic][])
* [#14540](https://github.com/rubocop/rubocop/issues/14540): Fix an incorrect autocorrect for `Style/UnlessElse` when using `unless` with `then`. ([@koic][])
* [#14507](https://github.com/rubocop/rubocop/pull/14507): Fix the built-in Ruby LSP add-on not restarting when config files (`.rubocop.yml`, `.rubocop_todo.yml`) change. ([@earlopain][])
* [#14514](https://github.com/rubocop/rubocop/pull/14514): Fix the built-in Ruby LSP add-on not respecting `.rubocop` config file. ([@earlopain][])
* [#14508](https://github.com/rubocop/rubocop/pull/14508): Fix the built-in Ruby LSP add-on getting in an irrecoverable state when the config is invalid on startup. ([@earlopain][])
* [#14534](https://github.com/rubocop/rubocop/issues/14534): Prevent `Layout/LineLength` autocorrection from splitting a block if its receiver contains a heredoc. ([@dvandersluis][])
* [#14497](https://github.com/rubocop/rubocop/pull/14497): Fix a false positive for `Lint/ShadowedArgument` when assigning inside a `rescue` block. ([@earlopain][])

### Changes

* [#14492](https://github.com/rubocop/rubocop/pull/14492): Add support for LSP `positionEncoding` `utf-8` and `utf-32`. ([@tmtm][])

## 1.80.2 (2025-09-03)

### Bug fixes

* [#14477](https://github.com/rubocop/rubocop/issues/14477): Fix a false positive for `Style/SafeNavigation` when using ternary expression with index access call with method chain. ([@koic][])
* [#14486](https://github.com/rubocop/rubocop/issues/14486): Fix false positives for `Style/RedundantParentheses` with unary operators and `yield`, `super`, or `defined?`. ([@earlopain][])
* [#14489](https://github.com/rubocop/rubocop/pull/14489): Fix false negatives for `Style/RedundantParentheses` with method calls taking argument without parentheses like `return (x y) if z`. ([@earlopain][])
* [#14499](https://github.com/rubocop/rubocop/issues/14499): Fix wrong autocorrect for `Style/StringConcatenation` when a double-quoted string contains escaped quotes and interpolation. ([@earlopain][])
* [#14502](https://github.com/rubocop/rubocop/issues/14502): Fix wrong autocorrect for `Style/StringConcatenation` when a single-quoted string contains interpolation like `'#{foo}'`. ([@earlopain][])

### Changes

* [#14493](https://github.com/rubocop/rubocop/issues/14493): Make `Naming/PredicateMethod` allow the `initialize` method. ([@koic][])

## 1.80.1 (2025-08-27)

### Bug fixes

* [#14479](https://github.com/rubocop/rubocop/issues/14479): Don't invalidate cache when `--display-time` option is used on the CLI. ([@lovro-bikic][])
* [#14473](https://github.com/rubocop/rubocop/pull/14473): Fix a false negative for `Style/RedundantBegin` using `begin` with multiple statements without `rescue` or `ensure`. ([@koic][])
* [#14475](https://github.com/rubocop/rubocop/issues/14475): Fix cop errors during autocorrect for the build in LSP when analyzing as Ruby 3.4. ([@earlopain][])

### Changes

* [#14474](https://github.com/rubocop/rubocop/pull/14474): Fix false negative for `Layout/EndAlignment` when `end` is not on a separate line. ([@lovro-bikic][])

## 1.80.0 (2025-08-22)

### Bug fixes

* [#14469](https://github.com/rubocop/rubocop/issues/14469): Fix an incorrect autocorrect for `Style/BitwisePredicate` when using `&` with LHS flags in conjunction with `==` for comparisons. ([@koic][])
* [#14459](https://github.com/rubocop/rubocop/pull/14459): Fix wrong autocorrect for `Style/For` with save navigation in the collection. ([@earlopain][])
* [#14435](https://github.com/rubocop/rubocop/issues/14435): Fix false negatives for regexp cops when `Lint/DuplicateRegexpCharacterClassElement` is enabled. ([@earlopain][])
* [#14419](https://github.com/rubocop/rubocop/issues/14419): Fix false positives for `Lint/UselessAssignment` when duplicate assignments appear in nested `if` branches inside a loop and the variable is used outside `while` loop. ([@koic][])
* [#14468](https://github.com/rubocop/rubocop/issues/14468): Fix false positives for `Naming/MethodName` when an operator method is defined using a string. ([@koic][])
* [#14427](https://github.com/rubocop/rubocop/pull/14427): Fix false positives for `Style/RedundantParentheses` when `do`...`end` block is wrapped in parentheses as a method argument. ([@koic][])
* [#14441](https://github.com/rubocop/rubocop/issues/14441): Better hash access handling in `Style/SafeNavigation`. ([@issyl0][])
* [#14443](https://github.com/rubocop/rubocop/issues/14443): Fix false positive in `Layout/EmptyLinesAfterModuleInclusion` when `include` does not have exactly one argument. ([@issyl0][])
* [#14424](https://github.com/rubocop/rubocop/pull/14424): Fix `Style/SafeNavigation` cop to preserve existing safe navigation in fixed code. ([@martinemde][])
* [#14455](https://github.com/rubocop/rubocop/pull/14455): Follow module inclusion with nonzero args with an empty line. ([@issyl0][])
* [#14445](https://github.com/rubocop/rubocop/issues/14445): Fix false positives for `Lint/UselessAssignment` with `for` loops when the variable is referenced in the collection. ([@earlopain][])
* [#14447](https://github.com/rubocop/rubocop/pull/14447): Fix wrong autocorrect for `Style/RedundantCondition` with a parenthesised method call in the condition. ([@earlopain][])

### Changes

* [#14428](https://github.com/rubocop/rubocop/pull/14428): Enhance `Lint/SelfAssignment` to handle indexed assignment with multiple arguments. ([@viralpraxis][])
* [#14464](https://github.com/rubocop/rubocop/pull/14464): Exclude `AutoCorrect` and `Include` from configuration parameters. ([@r7kamura][])
* [#14472](https://github.com/rubocop/rubocop/pull/14472): Make `Style/RedundantBegin` aware of `case` pattern matching. ([@koic][])
* [#14448](https://github.com/rubocop/rubocop/pull/14448): Register array intersection size checks as offenses under `Style/ArrayIntersect`. ([@lovro-bikic][])
* [#14431](https://github.com/rubocop/rubocop/pull/14431): Support LSP `TextDocumentSyncKind.Incremental`. ([@tmtm][])
* [#14453](https://github.com/rubocop/rubocop/issues/14453): Update `Style/RedundantBegin` to register `begin` blocks inside `if`, `unless`, `case`, `while` and `until` as redundant. ([@dvandersluis][])

## 1.79.2 (2025-08-05)

### Bug fixes

* [#11664](https://github.com/rubocop/rubocop/issues/11664): Cache wasn't getting used when using parallelization. ([@jvlara][])
* [#14411](https://github.com/rubocop/rubocop/issues/14411): Fix false negatives for `Layout/EmptyLinesAroundClassBody` when a class body starts with a blank line and defines a multiline superclass. ([@koic][])
* [#14413](https://github.com/rubocop/rubocop/issues/14413): Fix a false positive for `Layout/EmptyLinesAroundArguments` with multiline strings that contain only whitespace. ([@earlopain][])
* [#14408](https://github.com/rubocop/rubocop/pull/14408): Fix false-positive for `Layout/EmptyLinesAfterModuleInclusion` when inclusion is called with modifier. ([@r7kamura][])
* [#14402](https://github.com/rubocop/rubocop/issues/14402): Fix false positives for `Lint/UselessAssignment` when duplicate assignments appear in `if` branch inside a loop and the variable is used outside `while` loop. ([@koic][])
* [#14416](https://github.com/rubocop/rubocop/issues/14416): Fix false positives for `Style/MapToHash` when using `to_h` with block argument. ([@koic][])
* [#14418](https://github.com/rubocop/rubocop/pull/14418): Fix false positives for `Style/MapToSet` when using `to_set` with block argument. ([@koic][])
* [#14420](https://github.com/rubocop/rubocop/issues/14420): Fix false positives for `Style/SafeNavigation` when ternary expression with operator method call with method chain. ([@koic][])

### Changes

* [#14407](https://github.com/rubocop/rubocop/pull/14407): Register offense for parentheses around method calls with blocks in `Style/RedundantParentheses`. ([@lovro-bikic][])

## 1.79.1 (2025-07-31)

### Bug fixes

* [#14390](https://github.com/rubocop/rubocop/issues/14390): Fix wrong autocorrect for `Style/ArgumentsForwarding` when the method arguments contain `*`, `**` or `&`, and the method call contains `self` as the first argument. ([@earlopain][])
* [#14399](https://github.com/rubocop/rubocop/issues/14399): Fix false positives for `Layout/EmptyLinesAfterModuleInclusion` when `prepend` is used with block methods. ([@koic][])
* [#14396](https://github.com/rubocop/rubocop/pull/14396): Fix a false positive for `Style/RedundantParentheses` when parentheses are used around a one-line `rescue` expression inside a ternary operator. ([@koic][])
* [#14383](https://github.com/rubocop/rubocop/issues/14383): Fix false positives for `Lint/UselessAssignment` when duplicate assignments in `if` branch inside a loop. ([@koic][])
* [#14394](https://github.com/rubocop/rubocop/issues/14394): Fix false positive for `Lint/UselessAssignment` with `retry` in `rescue` branch. ([@earlopain][])
* [#14386](https://github.com/rubocop/rubocop/issues/14386): Fix false positives for `Style/RedundantParentheses` when parentheses are used around a one-line `rescue` expression inside array or hash literals. ([@koic][])
* [#14395](https://github.com/rubocop/rubocop/pull/14395): Fix LSP handling of URI-encoded paths with spaces. ([@hakanensari][])

### Changes

* [#14403](https://github.com/rubocop/rubocop/pull/14403): Enhance `Naming/MethodName` cop to detect offenses within `alias` and `alias_method` calls. ([@viralpraxis][])
* [#14389](https://github.com/rubocop/rubocop/pull/14389): Add support for `||` to `Lint/LiteralAsCondition`. ([@zopolis4][])

## 1.79.0 (2025-07-24)

### New features

* [#14348](https://github.com/rubocop/rubocop/pull/14348): Add new cop `Layout/EmptyLinesAfterModuleInclusion`. ([@lovro-bikic][])
* [#14374](https://github.com/rubocop/rubocop/pull/14374): Enhance `Naming/MethodName` cop to detect offenses within `Data` members. ([@viralpraxis][])

### Bug fixes

* [#14373](https://github.com/rubocop/rubocop/pull/14373): Fix an error for `Style/ParallelAssignment` when a lambda with parallel assignment is used on the RHS. ([@koic][])
* [#14370](https://github.com/rubocop/rubocop/issues/14370): Fix comment duplication bug in `Style/AccessorGrouping` separated autocorrect. ([@r7kamura][])
* [#14377](https://github.com/rubocop/rubocop/pull/14377): Fix a false positive for `Lint/UselessAssignment` when the assignment is inside a loop body. ([@5hun-s][])
* [#14355](https://github.com/rubocop/rubocop/pull/14355): Fix a false negative for `Style/RedundantParentheses` when using parentheses around a `rescue` expression on a one-line. ([@koic][])
* [#14354](https://github.com/rubocop/rubocop/pull/14354): Fix incorrect autocorrect for `Style/AccessModifierDeclarations` when using a grouped access modifier declaration. ([@girasquid][])
* [#14367](https://github.com/rubocop/rubocop/issues/14367): Fix an incorrect autocorrect for `Style/SingleLineMethods` when defining a single-line singleton method. ([@koic][])
* [#14344](https://github.com/rubocop/rubocop/issues/14344): Fix incorrect autocorrect for `Style/SingleLineMethods` when a single-line method definition contains a modifier. ([@koic][])
* [#14350](https://github.com/rubocop/rubocop/issues/14350): Fix `Naming/MethodName` cop false positives with `define_method` and operator names. ([@viralpraxis][])
* [#14333](https://github.com/rubocop/rubocop/issues/14333): Fix `Naming/PredicateMethod` ignoring the implicit `nil` from missing `else` branches. ([@earlopain][])
* [#14356](https://github.com/rubocop/rubocop/pull/14356): Fix `Style/ItBlockParameter` cop error on `always` style and missing block body. ([@viralpraxis][])
* [#14362](https://github.com/rubocop/rubocop/issues/14362): Update `Lint/RequireRangeParentheses` to not register false positives when range elements span multiple lines. ([@dvandersluis][])
* [#14309](https://github.com/rubocop/rubocop/issues/14309): Update `Style/SoleNestedConditional` to properly correct assignments within `and`. ([@dvandersluis][])

### Changes

* [#14358](https://github.com/rubocop/rubocop/pull/14358): Add `tsort` gem to runtime dependency for Ruby 3.5-dev. ([@koic][])
* [#14322](https://github.com/rubocop/rubocop/issues/14322): Expand the scope of `Style/ItAssignment` to consider all local variable and method parameter names. ([@dvandersluis][])
* [#14378](https://github.com/rubocop/rubocop/pull/14378): Change `Layout/SpaceAroundKeyword` to offend for missing whitespace between `return` and opening parenthesis. ([@lovro-bikic][])
* [#14360](https://github.com/rubocop/rubocop/pull/14360): Make `Layout/SpaceAroundOperators` aware of alternative and as pattern matchings. ([@koic][])
* [#14375](https://github.com/rubocop/rubocop/pull/14375): Make `Lint/RedundantSafeNavigation` aware of builtin convert methods `to_s`, `to_i`, `to_f`, `to_a`, and `to_h`. ([@koic][])
* [#13835](https://github.com/rubocop/rubocop/issues/13835): Add `InferNonNilReceiver` config to `Lint/RedundantSafeNavigation` to check previous code paths if the receiver is non-nil. ([@fatkodima][])
* [#14381](https://github.com/rubocop/rubocop/pull/14381): Offend `array1.any? { |elem| array2.member?(elem) }` and `array1.none? { |elem| array2.member?(elem) }` in `Style/ArrayIntersect`. ([@lovro-bikic][])

## 1.78.0 (2025-07-08)

### New features

* [#14331](https://github.com/rubocop/rubocop/pull/14331): Enhance `Naming/MethodName` cop to detect offenses within `define_method` calls. ([@viralpraxis][])
* [#14325](https://github.com/rubocop/rubocop/pull/14325): Enhance `Naming/MethodName` cop to handle offenses within `Struct` members. ([@viralpraxis][])
* [#14335](https://github.com/rubocop/rubocop/pull/14335): Enhance `Security/Eval` cop to detect `Kernel.eval` calls. ([@viralpraxis][])

### Bug fixes

* [#14343](https://github.com/rubocop/rubocop/pull/14343): Fix autocorrect code for `Style/HashConversion` to avoid syntax error. ([@koic][])
* [#14346](https://github.com/rubocop/rubocop/issues/14346): Avoid requiring parentheses for `Style/SingleLineMethods`. ([@koic][])
* [#14339](https://github.com/rubocop/rubocop/pull/14339): Fix bug where specifying `--format` disables parallelization. ([@r7kamura][])
* [#14300](https://github.com/rubocop/rubocop/pull/14300): Fix false positives for `Lint/DuplicateMethods` cop when self-alias trick is used. ([@viralpraxis][])
* [#14329](https://github.com/rubocop/rubocop/issues/14329): Fix false positives for `Lint/LiteralAsCondition` when a literal is used inside `||` in `case` condition. ([@koic][])
* [#14326](https://github.com/rubocop/rubocop/issues/14326): Fix additional autocorrection errors in `Style/HashConversion` for nested `Hash[]` calls. ([@dvandersluis][])
* [#14031](https://github.com/rubocop/rubocop/issues/14031): Honor --config options on server mode. ([@steiley][])
* [#14319](https://github.com/rubocop/rubocop/pull/14319): Fix the following incorrect autocorrect for `Lint/RedundantTypeConversion` when using parentheses with no arguments or any arguments. ([@koic][])
* [#14336](https://github.com/rubocop/rubocop/issues/14336): Fix incorrect autocorrect for `Style/ItBlockParameter` when using a single numbered parameter after multiple numbered parameters in a method chain. ([@koic][])
* [#11782](https://github.com/rubocop/rubocop/issues/11782): Move pending cops warning out of ConfigLoader. ([@nobuyo][])

### Changes

* [#14318](https://github.com/rubocop/rubocop/issues/14318): Add `WaywardPredicates` config to `Naming/PredicateMethod` to handle methods that look like predicates but aren't. ([@dvandersluis][])

## 1.77.0 (2025-06-20)

### New features

* [#14223](https://github.com/rubocop/rubocop/pull/14223): Add new `Gemspec/AttributeAssignment` cop. ([@viralpraxis][])
* [#14128](https://github.com/rubocop/rubocop/issues/14128): Allow long fully-qualified namespace strings to exceed max length. ([@niranjan-patil][])
* [#14288](https://github.com/rubocop/rubocop/pull/14288): Add new cop `Style/CollectionQuerying`. ([@lovro-bikic][])
* [#14165](https://github.com/rubocop/rubocop/issues/14165): Add new `DefaultToNil` option to `Style/FetchEnvVar` cop. ([@Yuhi-Sato][])
* [#14314](https://github.com/rubocop/rubocop/pull/14314): Enhance `Gemspec/RequireMFA` cop autocorrect to insert MFA directive after last `metadata` assignment. ([@viralpraxis][])
* [#14159](https://github.com/rubocop/rubocop/pull/14159): Enhance `Layout/SpaceInsideArrayLiteralBrackets` cop to analyze nested constant patterns. ([@viralpraxis][])

### Bug fixes

* [#14306](https://github.com/rubocop/rubocop/issues/14306): Fix an error for `Style/HashConversion` when using nested `Hash[]`. ([@koic][])
* [#14298](https://github.com/rubocop/rubocop/issues/14298): Fix an error for `Style/SoleNestedConditional` when autocorrecting nested if/unless/if. ([@ssagara00][])
* [#14313](https://github.com/rubocop/rubocop/issues/14313): Fix a false positive for `Layout/SpaceBeforeBrackets` when call desugared `Hash#[]` to lvar receiver with a space around the dot. ([@koic][])
* [#14292](https://github.com/rubocop/rubocop/issues/14292): Fix false positives for `Style/RedundantParentheses` when assigning a parenthesized one-line `in` pattern matching. ([@koic][])
* [#14296](https://github.com/rubocop/rubocop/issues/14296): Fix false positives for `Style/RedundantSelf` when receiver and lvalue have the same name in or-assignment. ([@koic][])
* [#14303](https://github.com/rubocop/rubocop/pull/14303): Fix `Lint/SelfAssignment` to allow inline RBS comments. ([@Morriar][])
* [#14307](https://github.com/rubocop/rubocop/issues/14307): Fix `Style/MethodCallWithArgsParentheses` false positive on forwarded keyword argument with additional arguments. ([@viralpraxis][])
* [#14301](https://github.com/rubocop/rubocop/issues/14301): Fix autocorrection syntax error for multiline expressions in `Style/RedundantParentheses`. ([@lovro-bikic][])

### Changes

* [#14295](https://github.com/rubocop/rubocop/pull/14295): Update `Naming/PredicateMethod` to consider negation (`!`/`not`) as boolean values. ([@dvandersluis][])
* [#14255](https://github.com/rubocop/rubocop/issues/14255): Update `Naming/PredicateMethod` to treat returned predicate method calls as boolean values. ([@dvandersluis][])

## 1.76.2 (2025-06-17)

### Bug fixes

* [#14273](https://github.com/rubocop/rubocop/issues/14273): Fix an error for `Lint/EmptyInterpolation` when using a boolean literal inside interpolation. ([@koic][])
* [#14260](https://github.com/rubocop/rubocop/issues/14260): Fix an error for `Lint/UselessDefaultValueArgument` when `fetch` call without a receiver. ([@koic][])
* [#14267](https://github.com/rubocop/rubocop/pull/14267): Fix an error for `Style/ConditionalAssignment` cop when using one-line branches. ([@viralpraxis][])
* [#14275](https://github.com/rubocop/rubocop/issues/14275): Fix false positives for `Style/RedundantParentheses` when using parenthesized one-line pattern matching in endless method definition. ([@koic][])
* [#14269](https://github.com/rubocop/rubocop/issues/14269): Fix false positives for `Style/RedundantSelf` when local variable assignment name is used in nested `if`. ([@koic][])
* [#14286](https://github.com/rubocop/rubocop/issues/14286): Fix incorrect autocorrect for `Lint/SafeNavigationChain` when a safe navigation is used on the left-hand side of a `-` operator when inside an array. ([@koic][])

### Changes

* [#14232](https://github.com/rubocop/rubocop/issues/14232): Add `AllowedPatterns` and `AllowBangMethods` configuration to `Naming/PredicateMethod`. ([@dvandersluis][])
* [#14268](https://github.com/rubocop/rubocop/pull/14268): Register operator expression range boundaries as offenses in `Lint/AmbiguousRange`. ([@lovro-bikic][])
* [#14264](https://github.com/rubocop/rubocop/pull/14264): Offend access modifiers used on top-level in `Lint/UselessAccessModifier`. ([@lovro-bikic][])
* [#14278](https://github.com/rubocop/rubocop/pull/14278): Register conditions wrapped in parentheses as offenses in `Style/MinMaxComparison`. ([@lovro-bikic][])

## 1.76.1 (2025-06-09)

### Bug fixes

* [#14245](https://github.com/rubocop/rubocop/pull/14245): Fix an error for `Lint/EmptyInterpolation` when using primitives in interpolation. ([@ka8725][])
* [#14233](https://github.com/rubocop/rubocop/issues/14233): Fix an error for `Style/SafeNavigation` when using ternary expression with index access call. ([@koic][])
* [#14236](https://github.com/rubocop/rubocop/issues/14236): Fix an error for `Style/SafeNavigation` when using ternary expression with operator method call. ([@koic][])
* [#14249](https://github.com/rubocop/rubocop/issues/14249): Fix false positives for `Style/RedundantArrayFlatten` when `Array#join` is used with an argument other than the default `nil`. ([@koic][])
* [#14239](https://github.com/rubocop/rubocop/issues/14239): Fix false positives for `Style/RedundantParentheses` when using one-line `in` pattern matching in operator. ([@koic][])
* [#14240](https://github.com/rubocop/rubocop/issues/14240): Fix `Naming/PredicateMethod` cop error on empty parentheses method body. ([@viralpraxis][])
* [#14235](https://github.com/rubocop/rubocop/pull/14235): Fix `Style/SafeNavigation` cop error on indexed assignment in ternary expression. ([@viralpraxis][])
* [#14247](https://github.com/rubocop/rubocop/pull/14247): Fix `Style/SafeNavigation` invalid autocorrection on double colon method call. ([@viralpraxis][])

## 1.76.0 (2025-06-04)

### New features

* [#12360](https://github.com/rubocop/rubocop/issues/12360): Add new `Naming/PredicateMethod` cop to check that predicate methods end with `?` and non-predicate methods do not. ([@dvandersluis][])
* [#13121](https://github.com/rubocop/rubocop/issues/13121): Add new `Style/EmptyStringInsideInterpolation` cop. ([@zopolis4][])
* [#14091](https://github.com/rubocop/rubocop/pull/14091): Add new cop `Style/RedundantArrayFlatten`. ([@lovro-bikic][])
* [#14184](https://github.com/rubocop/rubocop/pull/14184): Add new cop `Lint/UselessOr`. ([@lovro-bikic][])
* [#14221](https://github.com/rubocop/rubocop/pull/14221): Enhance `Gemspec` department cops to detect offenses if specification variable is `it` or a numbered parameter. ([@viralpraxis][])
* [#14166](https://github.com/rubocop/rubocop/pull/14166): Add new cop `Lint/UselessDefaultValueArgument`. ([@lovro-bikic][])

### Bug fixes

* [#14228](https://github.com/rubocop/rubocop/issues/14228): Fix a false positive for `Style/RedundantParentheses` when using a one-line `rescue` expression as a method argument. ([@koic][])
* [#14224](https://github.com/rubocop/rubocop/pull/14224): Fix false negatives for `Style/RedundantParentheses` when using one-line pattern matching. ([@koic][])
* [#14205](https://github.com/rubocop/rubocop/issues/14205): False negatives in `Style/SafeNavigation` when a ternary expression is used in a method argument. ([@steiley][])
* [#14226](https://github.com/rubocop/rubocop/pull/14226): Fix `Lint/LiteralAsCondition` autocorrect when branches of a condition have comments. ([@zopolis4][])

### Changes

* [#14066](https://github.com/rubocop/rubocop/pull/14066): Add `EnforcedStyle: allow_single_line` as the default to `Style/ItBlockParameter`. ([@koic][])
* [#13788](https://github.com/rubocop/rubocop/pull/13788): Disable `Lint/ShadowingOuterLocalVariable` by default. ([@nekketsuuu][])
* [#14215](https://github.com/rubocop/rubocop/pull/14215): Recognize inequation (`!=`) in `Lint/IdentityComparison`. ([@lovro-bikic][])

## 1.75.8 (2025-05-28)

### Bug fixes

* [#14191](https://github.com/rubocop/rubocop/pull/14191): Fix `Lint/FloatComparison` cop to detect floating-point number comparisons in `case` statements. ([@daisuke][])
* [#14209](https://github.com/rubocop/rubocop/pull/14209): Fix an error for `Style/RedundantFormat` with invalid format arguments. ([@earlopain][])
* [#14200](https://github.com/rubocop/rubocop/pull/14200): Fix false positives for `Style/DefWithParentheses` when using endless method definition with empty parentheses and a space before `=`. ([@koic][])
* [#14197](https://github.com/rubocop/rubocop/issues/14197): Fix infinite loop error for `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and `EnforcedStyle: consistent` of `Layout/FirstArgumentIndentation` and `Layout/HashAlignment`. ([@koic][])
* [#14204](https://github.com/rubocop/rubocop/pull/14204): Fix `Layout/EmptyLinesAroundAccessModifier` cop error on trailing access modifier. ([@viralpraxis][])
* [#14198](https://github.com/rubocop/rubocop/pull/14198): Fix `Lint/DuplicateMethods` cop error on `to` option is dynamically generated and `prefix` is enabled. ([@viralpraxis][])
* [#14199](https://github.com/rubocop/rubocop/pull/14199): Fix wrong autocorrection for `Style/MapToHash` with destructuring argument. ([@lovro-bikic][])
* [#14050](https://github.com/rubocop/rubocop/issues/14050): Modify condition for `rubocop:todo` EOL comment. ([@jonas054][])

## 1.75.7 (2025-05-21)

### Bug fixes

* [#14185](https://github.com/rubocop/rubocop/pull/14185): Fix an error for `Style/IfUnlessModifierOfIfUnless` when using nested modifier. ([@koic][])
* [#14192](https://github.com/rubocop/rubocop/pull/14192): Fix negatives for `Layout/SpaceBeforeBrackets` when using space between method argument parentheses and left bracket. ([@koic][])
* [#14189](https://github.com/rubocop/rubocop/issues/14189): Fix incorrect autocorrect for `Layout/SpaceBeforeBrackets` when using space between receiver and left brackets, and a space inside left bracket. ([@koic][])
* [#14170](https://github.com/rubocop/rubocop/pull/14170): Fix `Style/AccessModifierDeclarations` cop error on semicolon after modifier. ([@viralpraxis][])
* [#14195](https://github.com/rubocop/rubocop/pull/14195): Fix `Style/AccessModifierDeclarations` cop error on symbol modifier without surrounding scope. ([@viralpraxis][])
* [#14172](https://github.com/rubocop/rubocop/pull/14172): Fix `Style/AccessModifierDeclarations` cop false positives when there are no method definitions and style is `inline`. ([@viralpraxis][])
* [#14193](https://github.com/rubocop/rubocop/issues/14193): Fix `Lint/UselessAssignment` cop error when using nested assignment with splat. ([@earlopain][])

### Changes

* [#14188](https://github.com/rubocop/rubocop/pull/14188): Enhance `Gemspec/DuplicatedAssignment` cop to detect duplicated indexed assignment. ([@viralpraxis][])
* [#14183](https://github.com/rubocop/rubocop/pull/14183): Recognize `prefix` argument for `delegate` method in `Lint/DuplicateMethods`. ([@lovro-bikic][])

## 1.75.6 (2025-05-15)

### Bug fixes

* [#14176](https://github.com/rubocop/rubocop/pull/14176): Fix an error for `Style/MultilineIfModifier` when using nested modifier. ([@koic][])
* [#14077](https://github.com/rubocop/rubocop/issues/14077): Change `nil` representation in todo file comments. ([@jonas054][])
* [#14164](https://github.com/rubocop/rubocop/pull/14164): Fix an error for `Lint/UselessAssignment` when variables are assigned using unary operator in chained assignment and remain unreferenced. ([@koic][])
* [#14173](https://github.com/rubocop/rubocop/pull/14173): Fix an error for `Style/StringConcatenation` when using implicit concatenation with string interpolation. ([@koic][])
* [#14177](https://github.com/rubocop/rubocop/issues/14177): Fix false positives for `Style/SoleNestedConditional` when using nested `if` and `not` in condition. ([@koic][])
* [#14152](https://github.com/rubocop/rubocop/pull/14152): Fix `Layout/SpaceInsideArrayLiteralBrackets` cop error on array pattern without brackets. ([@viralpraxis][])
* [#14153](https://github.com/rubocop/rubocop/pull/14153): Fix `Style/PercentQLiterals` cop error on Unicode escape sequence. ([@viralpraxis][])

### Changes

* [#14082](https://github.com/rubocop/rubocop/issues/14082): Mark `Style/ComparableBetween` as unsafe. ([@earlopain][])
* [#14181](https://github.com/rubocop/rubocop/issues/14181): Make `Lint/DuplicateMethods` aware of Active Support's `delegate` method. ([@lovro-bikic][])
* [#14156](https://github.com/rubocop/rubocop/issues/14156): Make `Style/IfUnlessModifier` allow endless method definition in the `if` body. ([@koic][])

## 1.75.5 (2025-05-05)

### Bug fixes

* [#14148](https://github.com/rubocop/rubocop/pull/14148): Fix an infinite loop error for `Layout/SpaceAfterSemicolon` with `Layout/SpaceBeforeSemicolon` when a sequence of semicolons appears. ([@koic][])
* [#14145](https://github.com/rubocop/rubocop/pull/14145): Fix `Lint/ArrayLiteralInRegexp` cop error on empty interpolation. ([@viralpraxis][])
* [#14072](https://github.com/rubocop/rubocop/issues/14072): Fix autocorrect issue in `Layout/HashAlignment`. ([@jonas054][])
* [#14131](https://github.com/rubocop/rubocop/issues/14131): Fix false positives for `Style/ArgumentsForwarding` when using anonymous block argument forwarding to a method with a block. ([@koic][])
* [#14140](https://github.com/rubocop/rubocop/pull/14140): Fix `Layout/LeadingCommentSpace` to allow splitting long inline RBS comment signatures across multiple lines. ([@Morriar][])
* [#14147](https://github.com/rubocop/rubocop/pull/14147): Fix `Lint/LiteralAsCondition` cop error on `if` without body. ([@viralpraxis][])
* [#14151](https://github.com/rubocop/rubocop/pull/14151): Fix `Lint/Void` cop error on nested empty `begin`. ([@viralpraxis][])
* [#13547](https://github.com/rubocop/rubocop/pull/13547): Fix `Style/IdenticalConditionalBranches` cop failure in case of `if` node with implicit `then`. ([@viralpraxis][])
* [#14146](https://github.com/rubocop/rubocop/pull/14146): Fix `Style/MethodCallWithArgsParentheses` cop error on complex numbers when `EnforcedStyle` is set to `omit_parentheses`. ([@viralpraxis][])
* [#14137](https://github.com/rubocop/rubocop/issues/14137): Fix `Style/TrailingCommaInArguments` cop error if `EnforcedStyleForMultiline` is set to `comma`. ([@viralpraxis][])

### Changes

* [#14144](https://github.com/rubocop/rubocop/pull/14144): `Layout/SpaceInsideArrayLiteralBrackets` make aware of array pattern matching. ([@koic][])
* [#14142](https://github.com/rubocop/rubocop/issues/14142): `Layout/SpaceInsideHashLiteralBraces` make aware of hash pattern matching. ([@koic][])

## 1.75.4 (2025-04-28)

### Bug fixes

* [#14123](https://github.com/rubocop/rubocop/issues/14123): Fix an infinite loop error for `Lint/BooleanSymbol` when using the rocket hash syntax with a boolean symbol key. ([@koic][])
* [#14134](https://github.com/rubocop/rubocop/pull/14134): Fix an error for `Style/ComparableBetween` when comparing the value with itself. ([@earlopain][])
* [#14111](https://github.com/rubocop/rubocop/issues/14111): Fix an error for `Style/SafeNavigation` when the RHS of `&&` is a complex `||` expression composed of `&&` conditions. ([@koic][])
* [#14129](https://github.com/rubocop/rubocop/issues/14129): Fix false positives for `Style/ArgumentsForwarding` when using default positional arg, keyword arg, and block arg in Ruby 3.1. ([@koic][])
* [#14110](https://github.com/rubocop/rubocop/pull/14110): Fix false positives for `Style/RedundantParentheses` when parens around basic conditional as the second argument of a parenthesized method call. ([@koic][])
* [#14120](https://github.com/rubocop/rubocop/issues/14120): Fix false positives for `Style/RedundantParentheses` when parens around unparenthesized method call as the second argument of a parenthesized method call. ([@koic][])
* [#14133](https://github.com/rubocop/rubocop/pull/14133): Fix `Lint/LiteralAsCondition` autocorrect when a literal is the condition of an elsif followed by an else. ([@zopolis4][])
* [#14116](https://github.com/rubocop/rubocop/issues/14116): Make `Style/TrailingCommaInArguments` cop aware of trailing commas in `[]` method call. ([@viralpraxis][])
* [#14114](https://github.com/rubocop/rubocop/pull/14114): Fix `Style/ClassAndModuleChildren` cop error on tab-intended compactable modules. ([@viralpraxis][])

### Changes

* [#13611](https://github.com/rubocop/rubocop/issues/13611): Enable `Lint/CircularArgumentReference` on Ruby 3.4. ([@earlopain][])

## 1.75.3 (2025-04-22)

### Bug fixes

* [#13676](https://github.com/rubocop/rubocop/issues/13676): Allow RuboCop to inspect hidden directories if they are explicitly provided. ([@viralpraxis][])
* [#14080](https://github.com/rubocop/rubocop/pull/14080): Allow writing RBS::Inline annotation `#:` after end keyword in `Style/CommentedKeyword`. ([@dak2][])
* [#14075](https://github.com/rubocop/rubocop/issues/14075): Fix an error for `Layout/EmptyLineAfterGuardClause` when calling a method on the result of a single-line `if` with `return`. ([@koic][])
* [#14067](https://github.com/rubocop/rubocop/pull/14067): Fix false negatives for `Style/RedundantParentheses` when using parens around singleton method body. ([@koic][])
* [#14070](https://github.com/rubocop/rubocop/issues/14070): Fix false positives for `EnforcedStyleForMultiline: diff_comma` of `Style/TrailingCommaInArrayLiteral` and `Style/TrailingCommaInHashLiteral` when trailing comma with comment. ([@koic][])
* [#14092](https://github.com/rubocop/rubocop/pull/14092): Fix false negative for `Style/RedundantParentheses` when using some operator methods with a parenthesized argument. ([@koic][])
* [#14103](https://github.com/rubocop/rubocop/pull/14103): Fix `Layout/MultilineOperationIndentation` cop error on `indexasgn` node without arguments. ([@viralpraxis][])
* [#14089](https://github.com/rubocop/rubocop/pull/14089): Fix redundant current directory prefix regexp. ([@sferik][])
* [#14099](https://github.com/rubocop/rubocop/pull/14099): Fix `Style/ClassAndModuleChildren` cop error on one-liner class definition and nested enforced style. ([@viralpraxis][])
* [#14083](https://github.com/rubocop/rubocop/pull/14083): Fix `Style/ConditionalAssignment` cop error on one-line if-then-else. ([@viralpraxis][])
* [#14104](https://github.com/rubocop/rubocop/pull/14104): Fix `Style/ConditionalAssignment` cop error on indexed assignment without arguments. ([@viralpraxis][])
* [#14084](https://github.com/rubocop/rubocop/pull/14084): Fix `Style/RedundantLineContinuation` cop error on multiline assignment with line continuation. ([@viralpraxis][])
* [#14096](https://github.com/rubocop/rubocop/pull/14096): Fix error for `Style/SafeNavigation` with longer `&&` chain (e.g. `a && a.b && a.b.c`). ([@lovro-bikic][])
* [#14068](https://github.com/rubocop/rubocop/pull/14068): Fix wrong autocorrection for `Style/MapIntoArray` when using `push` or `append` with hash argument without braces. ([@lovro-bikic][])

### Changes

* [#14093](https://github.com/rubocop/rubocop/pull/14093): Register offenses for redundant parens around method arguments for `Style/RedundantParentheses`. ([@lovro-bikic][])
* [#14064](https://github.com/rubocop/rubocop/pull/14064): Prefer `References` over `Reference` in cop configs. ([@sambostock][])

## 1.75.2 (2025-04-03)

### Changes

* [#14065](https://github.com/rubocop/rubocop/pull/14065): Update `Lint/RedundantTypeConversion` to register an offense for `to_json.to_s`. ([@lovro-bikic][])

### Bug fixes

* [#14041](https://github.com/rubocop/rubocop/issues/14041): Fix an error when using ERB templated config YAML with server mode. ([@koic][])
* [#14048](https://github.com/rubocop/rubocop/pull/14048): Do not emit a warning for a zero-sized file while checking if it is executable. ([@viralpraxis][])
* [#14053](https://github.com/rubocop/rubocop/issues/14053): Fix incorrect autocorrect for `Lint/DeprecatedOpenSSLConstant` cipher constant argument is not `cbc`. ([@koic][])
* [#14051](https://github.com/rubocop/rubocop/issues/14051): Fix incorrect autocorrect for `Style/RedundantCondition` when true is used as the true branch and the condition takes arguments. ([@koic][])
* [#14062](https://github.com/rubocop/rubocop/issues/14062): Fix false positives for `Lint/ReturnInVoidContext` when returning inside `define_method` or a nested singleton method. ([@earlopain][])
* [#14057](https://github.com/rubocop/rubocop/pull/14057): Fix `Style/ConditionalAssignment` cop error on dynamic string node in branch. ([@viralpraxis][])
* [#14047](https://github.com/rubocop/rubocop/pull/14047): Fix `Style/FrozenStringLiteralComment` cop errors on emacs-styled magic comment. ([@viralpraxis][])

## 1.75.1 (2025-03-26)

### Changes

* [#14038](https://github.com/rubocop/rubocop/pull/14038): Rename `EnforcedStyle: allow_named_parameter` to `EnforcedStyle: only_numbered_parameters` in `Style/ItBlockParameter`. ([@koic][])

## 1.75.0 (2025-03-26)

### New features

* [#12049](https://github.com/rubocop/rubocop/issues/12049): Add new `Style/HashFetchChain` cop to detect chained `fetch` calls that can be replaced with a single call to `dig`. ([@dvandersluis][])
* [#13597](https://github.com/rubocop/rubocop/issues/13597): Add new `Style/ItBlockParameter` cop. ([@koic][])
* [#13899](https://github.com/rubocop/rubocop/pull/13899): Enable reusable Prism parse result for Ruby LSP add-on. ([@koic][])
* [#14015](https://github.com/rubocop/rubocop/pull/14015): Support `it` block parameter in `Layout` cops. ([@koic][])
* [#14017](https://github.com/rubocop/rubocop/pull/14017): Support `it` block parameter in `Lint` cops. ([@koic][])
* [#14018](https://github.com/rubocop/rubocop/pull/14018): Support `it` block parameter in `Metrics` cops. ([@koic][])
* [#14013](https://github.com/rubocop/rubocop/pull/14013): Support `it` block parameter in `Style` cops. ([@koic][])
* [#14025](https://github.com/rubocop/rubocop/pull/14025): Support `TargetRubyVersion: 3.5` (experimental). ([@earlopain][])

### Bug fixes

* [#14022](https://github.com/rubocop/rubocop/pull/14022): Fix an error for `Style/HashFetchChain` when no arguments are given to `fetch`. ([@koic][])
* [#14028](https://github.com/rubocop/rubocop/pull/14028): Fix false negative for `Layout/MultilineMethodParameterLineBreaks` when class method definitions are used. ([@vlad-pisanov][])
* [#14027](https://github.com/rubocop/rubocop/pull/14027): Fix false negative for `Layout/LineLength` when autocorrecting class method definitions. ([@vlad-pisanov][])
* [#8099](https://github.com/rubocop/rubocop/issues/8099): Fix infinite loop between `Layout/SpaceAroundOperators` and `Layout/HashAlignment` with `EnforcedHashRocketStyle` being an array containing `table`. ([@dvandersluis][])
* [#14021](https://github.com/rubocop/rubocop/pull/14021): Fix handling of long heredoc lines with SplitStrings enabled. ([@mauro-oto][])
* [#13968](https://github.com/rubocop/rubocop/pull/13968): Fix `InternalAffairs/RedundantDescribedClassAsSubject` cop error on missing `describe`. ([@viralpraxis][])
* [#14036](https://github.com/rubocop/rubocop/pull/14036): Fix false negative for `Lint/ShadowingOuterLocalVariable` when block local variable is used inside a condition. ([@lovro-bikic][])
* [#13990](https://github.com/rubocop/rubocop/issues/13990): Fix a false positive for `Lint/UselessAssignment` when a variable is reassigned in a different branch. ([@eugeneius][])
* [#14012](https://github.com/rubocop/rubocop/pull/14012): Fix incorrect autocorrections for `Style/SoleNestedConditional`. ([@lovro-bikic][])
* [#14020](https://github.com/rubocop/rubocop/pull/14020): Fix comment autocorrection for `Style/IfInsideElse`. ([@lovro-bikic][])

### Changes

* [#12358](https://github.com/rubocop/rubocop/issues/12358): Add `does` as a forbidden prefix to `Naming/PredicateName`. ([@dvandersluis][])
* [#13621](https://github.com/rubocop/rubocop/issues/13621): Add `ForbiddenIdentifiers` and `ForbiddenPatterns` config options to `Naming/MethodName` cop. ([@tejasbubane][])
* [#13986](https://github.com/rubocop/rubocop/issues/13986): Add support for `Array#intersection` to `Style/ArrayIntersect`. ([@dvandersluis][])
* [#14006](https://github.com/rubocop/rubocop/pull/14006): Allow cop renames to trigger warnings instead of fatal errors. ([@dvandersluis][])
* [#13617](https://github.com/rubocop/rubocop/issues/13617): Use the `prism` translation layer to analyze Ruby 3.4+ by default. ([@earlopain][])
* [#14024](https://github.com/rubocop/rubocop/pull/14024): Change `Style/RedundantParentheses` to offend parentheses for chained `&&` expressions. ([@lovro-bikic][])
* [#14029](https://github.com/rubocop/rubocop/pull/14029): Add `AllowConsecutiveConditionals` setting to `Style/Next` to allow consecutive conditional statements. ([@vlad-pisanov][])
* [#14016](https://github.com/rubocop/rubocop/pull/14016): Update `Style/RedundantFormat` to register offenses when the only argument to `format` or `sprintf` is a constant. ([@dvandersluis][])

## 1.74.0 (2025-03-13)

### New features

* [#13936](https://github.com/rubocop/rubocop/pull/13936): Adds new cop `Style/ComparableBetween`. ([@lovro-bikic][])
* [#13943](https://github.com/rubocop/rubocop/pull/13943): Allow writing steep annotation to method definition for `Style/CommentedKeyword`. ([@dak2][])

### Bug fixes

* [#13969](https://github.com/rubocop/rubocop/issues/13969): Fix a false positive for `Lint/SharedMutableDefault` when `capacity` keyword argument is used. ([@koic][])
* [#13945](https://github.com/rubocop/rubocop/pull/13945): Fix a false positive for `Style/DoubleNegation` when calling `define_method`/`define_singleton_method` with a numblock. ([@earlopain][])
* [#13971](https://github.com/rubocop/rubocop/pull/13971): Fix false alarm for config obsoletion. ([@koic][])
* [#13960](https://github.com/rubocop/rubocop/pull/13960): Fix a false negative for `Lint/ReturnInVoidContext` when returning out of a block. ([@earlopain][])
* [#13947](https://github.com/rubocop/rubocop/pull/13947): Fix a false negative for `Lint/UselessConstantScoping` for constants defined in `class << self`. ([@earlopain][])
* [#13949](https://github.com/rubocop/rubocop/pull/13949): Fix a false negative for `Lint/NonLocalExitFromIterator` with numblocks. ([@earlopain][])
* [#13975](https://github.com/rubocop/rubocop/issues/13975): Fix false positives for `Style/RedundantCurrentDirectoryInPath` when using a complex current directory path in `require_relative`. ([@koic][])
* [#13963](https://github.com/rubocop/rubocop/issues/13963): Fix wrong autocorrect for `Lint/LiteralAsCondition` when the literal is followed by `return`, `break`, or `next`. ([@earlopain][])
* [#13946](https://github.com/rubocop/rubocop/pull/13946): Fix some false positives for `Style/MethodCallWithArgsParentheses` with `EnforcedStyle: omit_parentheses` style and numblocks. ([@earlopain][])
* [#13950](https://github.com/rubocop/rubocop/pull/13950): Fix sporadic errors about `rubocop-rails` or `rubocop-performance` extraction, even if they are already part of the Gemfile. ([@earlopain][])
* [#13981](https://github.com/rubocop/rubocop/pull/13981): Prevent redundant plugin loading when a duplicate plugin is specified in an inherited config. ([@koic][])
* [#13965](https://github.com/rubocop/rubocop/issues/13965): Update `Lint/RedundantCopDisableDirective` to register an offense when cop names are given with improper casing. ([@dvandersluis][])
* [#13948](https://github.com/rubocop/rubocop/pull/13948): Fix wrong autocorrect for `Style/RescueModifier` when using parallel assignment and the right-hand-side is not a bracketed array. ([@earlopain][])

### Changes

* [#12851](https://github.com/rubocop/rubocop/issues/12851): Add `EnforcedStyleForClasses` and `EnforcedStyleForModules` configuration options to `Style/ClassAndModuleChildren`. ([@dvandersluis][])
* [#13979](https://github.com/rubocop/rubocop/pull/13979): Add `Mode: conservative` configuration to `Style/FormatStringToken` to make the cop only register offenses for strings given to `printf`, `sprintf`, `format`, and `%`. ([@dvandersluis][])
* [#13977](https://github.com/rubocop/rubocop/issues/13977): Allow `TLS1_1` and `TLS1_2` by default in `Naming/VariableNumber` to accommodate OpenSSL version parameter names. ([@koic][])
* [#13967](https://github.com/rubocop/rubocop/pull/13967): Make `Lint/RedundantTypeConversion` aware of redundant `to_d`. ([@koic][])

## 1.73.2 (2025-03-04)

### Bug fixes

* [#13942](https://github.com/rubocop/rubocop/pull/13942): Fix incorrect disabling of departments when inheriting configuration. ([@koic][])
* [#13766](https://github.com/rubocop/rubocop/issues/13766): Fix false positives for `Style/InverseMethods` when using `any?` or `none?` with safe navigation operator. ([@koic][])
* [#13938](https://github.com/rubocop/rubocop/pull/13938): Fix false positives for `Style/RedundantCondition` when a variable or a constant is used. ([@koic][])
* [#13935](https://github.com/rubocop/rubocop/pull/13935): Fix a false negative for `Style/RedundantFreeze` when calling methods that produce frozen objects with numblocks. ([@earlopain][])
* [#13928](https://github.com/rubocop/rubocop/issues/13928): Fix `end pattern with unmatched parenthesis: / (RegexpError)` on Ruby 3.2.0. ([@dvandersluis][])
* [#13933](https://github.com/rubocop/rubocop/issues/13933): Fix wrong autocorrect for `Style/KeywordParametersOrder` when the arguments are on multiple lines and contain comments. ([@earlopain][])

### Changes

* [#12669](https://github.com/rubocop/rubocop/issues/12669): Update autocorrection for `Lint/EmptyConditionalBody` to be safe. ([@dvandersluis][])

## 1.73.1 (2025-02-27)

### Bug fixes

* [#13920](https://github.com/rubocop/rubocop/issues/13920): Fix an error for `Lint/MixedCaseRange` when `/[[ ]]/` is used. ([@koic][])
* [#13912](https://github.com/rubocop/rubocop/pull/13912): Fix wrong autocorrect for `Lint/EmptyConditionalBody` when assigning to a variable with only a single branch. ([@earlopain][])
* [#13913](https://github.com/rubocop/rubocop/issues/13913): Fix false positives for `Style/RedundantCondition` when using when true is used as the true branch and the condition is not a predicate method. ([@koic][])
* [#13909](https://github.com/rubocop/rubocop/issues/13909): Fix false positive with `Layout/ClosingParenthesisIndentation` when first parameter is a hash. ([@tejasbubane][])
* [#13915](https://github.com/rubocop/rubocop/pull/13915): Fix writing generics type of rbs-inline annotation for nested class in `Style/CommentedKeyword`. ([@dak2][])
* [#13916](https://github.com/rubocop/rubocop/issues/13916): Fix `Lint/LiteralAsCondition` acting on the right hand side of && nodes. ([@zopolis4][])

## 1.73.0 (2025-02-26)

### New features

* [#11024](https://github.com/rubocop/rubocop/issues/11024): Add `require_always` option to `Style/EndlessMethod`. ([@koic][])
* [#11024](https://github.com/rubocop/rubocop/issues/11024): Add `require_single_line` option to `Style/EndlessMethod`. ([@jtannas][])
* [#9935](https://github.com/rubocop/rubocop/issues/9935): Introduce EnforcedStyleForMultiline "diff_comma". ([@flavorjones][])

### Bug fixes

* [#13867](https://github.com/rubocop/rubocop/issues/13867): Fix an error for plugins when not running RuboCop through Bundler. ([@earlopain][])
* [#13902](https://github.com/rubocop/rubocop/pull/13902): Fix false negative for `Style/RedundantSelfAssignment` when the method receives a block. ([@vlad-pisanov][])
* [#13826](https://github.com/rubocop/rubocop/issues/13826): Fix false positives for regex cops when `Lint/MixedCaseRange` is enabled. ([@earlopain][])
* [#13818](https://github.com/rubocop/rubocop/issues/13818): Fix false positives for `Lint/Void` when using operator method call without argument. ([@koic][])
* [#13896](https://github.com/rubocop/rubocop/pull/13896): Fix a false positive for `Style/TrivialAccessors` with `instance_eval` and numblocks. ([@earlopain][])
* [#13910](https://github.com/rubocop/rubocop/pull/13910): Fix false positives for `Style/EndlessMethod` when using setter method definitions. ([@koic][])
* [#13889](https://github.com/rubocop/rubocop/pull/13889): Fix autocorrection for `Layout/LineLength` with interpolated strings when not on the first line. ([@dvandersluis][])
* [#13900](https://github.com/rubocop/rubocop/issues/13900): Fix infinite loop between `Layout/EmptyLinesAroundAccessModifier` and `Layout/EmptyLinesAroundBlockBody` with `EnforcedStyle: no_empty_lines`. ([@dvandersluis][])
* [#12692](https://github.com/rubocop/rubocop/issues/12692): Fix `Style/AccessorGrouping` with constants. ([@tejasbubane][])
* [#13882](https://github.com/rubocop/rubocop/issues/13882): Fix `Style/RedundantFormat` for annotated template strings with missing hash keys. ([@dvandersluis][])
* [#13880](https://github.com/rubocop/rubocop/issues/13880): Fix `Style/RedundantFormat` when given double-splatted arguments. ([@dvandersluis][])
* [#13907](https://github.com/rubocop/rubocop/pull/13907): Don't offer autocorrect for `Style/StringConcatenation` when numblocks are used. ([@earlopain][])
* [#13876](https://github.com/rubocop/rubocop/issues/13876): Don't consider `require 'pp'` to be redundant for `Lint/RedundantRequireStatement`. ([@earlopain][])
* [#13885](https://github.com/rubocop/rubocop/issues/13885): Update `Style/HashExcept` and `Style/HashSlice` to not register an offense if selecting over the hash value. ([@dvandersluis][])

### Changes

* [#12948](https://github.com/rubocop/rubocop/issues/12948): Add `ForbiddenNames` configuration to `Naming/VariableName` to specify names that are forbidden. ([@dvandersluis][])
* [#13117](https://github.com/rubocop/rubocop/issues/13117): Add partial autocorrect support to `Lint/LiteralAsCondition` cop to check for redundant conditions. ([@zopolis4][])
* [#13892](https://github.com/rubocop/rubocop/pull/13892): Allow merging of configured arrays and non-arrays. ([@sambostock][])
* [#13833](https://github.com/rubocop/rubocop/pull/13833): Add `Reference` to common params. ([@sambostock][])
* [#13890](https://github.com/rubocop/rubocop/pull/13890): Update `Lint/RedundantTypeConversion` to not register an offense when given a constructor with `exception: false`. ([@dvandersluis][])
* [#13729](https://github.com/rubocop/rubocop/pull/13729): Update `Style/RedundantCondition` cop to detect conditional expressions where the true branch is `true` and suggest replacing them with a logical OR. ([@datpmt][])

## 1.72.2 (2025-02-17)

### Bug fixes

* [#13853](https://github.com/rubocop/rubocop/pull/13853): Fix exclusion of relative paths in plugin's `AllCops: Exclude` as expected. ([@koic][])
* [#13844](https://github.com/rubocop/rubocop/issues/13844): Fix an error for `Style/RedundantFormat` when a template argument is used without keyword arguments. ([@koic][])
* [#13857](https://github.com/rubocop/rubocop/pull/13857): Fix an error for `Style/RedundantFormat` when numeric placeholders is used in the template argument. ([@koic][])
* [#13861](https://github.com/rubocop/rubocop/issues/13861): Fix `ArgumentError` related to two deprecated `AllowedPattern` APIs. ([@koic][])
* [#13849](https://github.com/rubocop/rubocop/issues/13849): Fix an error for `Lint/UselessConstantScoping` when multiple assigning to constants after `private` access modifier. ([@koic][])
* [#13856](https://github.com/rubocop/rubocop/issues/13856): Fix false positives for `Lint/UselessConstantScoping` when a constant is used after `private` access modifier with arguments. ([@koic][])

### Changes

* [#13846](https://github.com/rubocop/rubocop/issues/13846): Mark `Style/RedundantFormat` as unsafe autocorrect. ([@koic][])

## 1.72.1 (2025-02-15)

### Bug fixes

* [#13836](https://github.com/rubocop/rubocop/issues/13836): Fix an error for `Style/RedundantParentheses` when a different expression appears before a range literal. ([@koic][])
* [#13839](https://github.com/rubocop/rubocop/issues/13839): Fix false positives for `Lint/RedundantTypeConversion` when passing block arguments when generating a Hash or a Set. ([@koic][])

### Changes

* [#13840](https://github.com/rubocop/rubocop/pull/13840): Extension plugin is loaded automatically with `require 'rubocop/rspec/support'. ([@koic][])

## 1.72.0 (2025-02-14)

### New features

* [#13740](https://github.com/rubocop/rubocop/pull/13740): Add new `Lint/CopDirectiveSyntax` cop. ([@kyanagi][])
* [#13800](https://github.com/rubocop/rubocop/issues/13800): Add new `Lint/SuppressedExceptionInNumberConversion` cop. ([@koic][])
* [#13702](https://github.com/rubocop/rubocop/pull/13702): Add new `Lint/RedundantTypeConversion` cop. ([@dvandersluis][])
* [#13831](https://github.com/rubocop/rubocop/pull/13831): Add new `Lint/UselessConstantScoping` cop. ([@koic][])
* [#13793](https://github.com/rubocop/rubocop/pull/13793): Add new `Style/RedundantFormat` cop to check for uses of `format` or `sprintf` with only a single string argument. ([@dvandersluis][])
* [#13581](https://github.com/rubocop/rubocop/pull/13581): Add new `InternalAffairs/LocationExists` cop to check for code that can be replaced with `Node#loc?` or `Node#loc_is?`. ([@dvandersluis][])
* [#13661](https://github.com/rubocop/rubocop/issues/13661): Make server mode detect local paths in .rubocop.yml under `inherit_from` and `require` for automatically restart. ([@koic][])
* [#13721](https://github.com/rubocop/rubocop/pull/13721): `Naming/PredicateName`: Optionally use Sorbet to detect predicate methods. ([@issyl0][])
* [#6012](https://github.com/rubocop/rubocop/issues/6012): Support RuboCop extension plugin. ([@koic][])

### Bug fixes

* [#13807](https://github.com/rubocop/rubocop/issues/13807): Fix false negatives for `Style/RedundantParentheses` when chaining `[]` method calls. ([@koic][])
* [#13788](https://github.com/rubocop/rubocop/issues/13788): Fix false negatives for `Style/RedundantParentheses` when `[]` method is called with variable or constant receivers. ([@koic][])
* [#13811](https://github.com/rubocop/rubocop/issues/13811): Fix false negatives for `Style/RedundantParentheses` when handling range literals with redundant parentheses. ([@koic][])
* [#13796](https://github.com/rubocop/rubocop/pull/13796): Fix crash in `Layout/EmptyLinesAroundMethodBody` for endless methods. ([@dvandersluis][])
* [#13817](https://github.com/rubocop/rubocop/pull/13817): Fix false positive for format specifier with non-numeric precision. ([@dvandersluis][])
* [#12672](https://github.com/rubocop/rubocop/issues/12672): Fix false positives for `Lint/FormatParameterMismatch` when the width value is interpolated. ([@dvandersluis][])
* [#12795](https://github.com/rubocop/rubocop/issues/12795): Fix `Layout/BlockAlignment` for blocks that are the body of an endless method. ([@dvandersluis][])
* [#13822](https://github.com/rubocop/rubocop/pull/13822): Fix undefined method Logger when processing watched file notifications. ([@vinistock][])
* [#13805](https://github.com/rubocop/rubocop/pull/13805): Make the language_server-protocol dependency version stricter. ([@koic][])

## 1.71.2 (2025-02-04)

### Bug fixes

* [#13782](https://github.com/rubocop/rubocop/pull/13782): Fix an error `Layout/ElseAlignment` when `else` is part of a numblock. ([@earlopain][])
* [#13395](https://github.com/rubocop/rubocop/issues/13395): Fix a false positive for `Lint/UselessAssignment` when assigning in branch and block. ([@pCosta99][])
* [#13783](https://github.com/rubocop/rubocop/pull/13783): Fix a false positive for `Lint/Void` when `each` numblock with conditional expressions that has multiple statements. ([@earlopain][])
* [#13787](https://github.com/rubocop/rubocop/issues/13787): Fix incorrect autocorrect for `Style/ExplicitBlockArgument` when using arguments of `zsuper` in method definition. ([@koic][])
* [#13785](https://github.com/rubocop/rubocop/pull/13785): Fix `Style/EachWithObject` cop error in case of single block argument. ([@viralpraxis][])
* [#13781](https://github.com/rubocop/rubocop/pull/13781): Fix a false positive for `Lint/UnmodifiedReduceAccumulator` when omitting the accumulator in a nested numblock. ([@earlopain][])

## 1.71.1 (2025-01-31)

### Bug fixes

* [#10081](https://github.com/rubocop/rubocop/issues/10081): Add the missing `include RuboCop::RSpec::ExpectOffense` in rubocop/rspec/support.rb. ([@d4rky-pl][])
* [#13765](https://github.com/rubocop/rubocop/pull/13765): Fix a false negative for `Lint/AmbiguousBlockAssociation` with numblocks. ([@earlopain][])
* [#13759](https://github.com/rubocop/rubocop/pull/13759): Fix a false negative for `Lint/ConstantDefinitionInBlock` with numblocks. ([@earlopain][])
* [#13741](https://github.com/rubocop/rubocop/pull/13741): Register an offense for `Naming/BlockForwarding` and `Style/ArgumentsForwarding` with Ruby >= 3.4 when the block argument is referenced inside a block. This was previously disabled because of a bug in Ruby 3.3.0. ([@earlopain][])
* [#13777](https://github.com/rubocop/rubocop/pull/13777): Fix a false negative for `Layout/EmptyLineBetweenDefs` with `DefLikeMacros` and numblocks. ([@earlopain][])
* [#13769](https://github.com/rubocop/rubocop/pull/13769): Fix a false negative for `Style/RedundantParentheses` with numblocks. ([@earlopain][])
* [#13780](https://github.com/rubocop/rubocop/pull/13780): Fix a false positive `Style/AccessModifierDeclarations` when using access modifier in a numblock. ([@earlopain][])
* [#13775](https://github.com/rubocop/rubocop/pull/13775): Fix a false positive for `Lint/AssignmentInCondition` when assigning in numblocks. ([@earlopain][])
* [#13773](https://github.com/rubocop/rubocop/pull/13773): Fix false positives for `Layout/RedundantLineBreak` when using numbered block parameter. ([@koic][])
* [#13761](https://github.com/rubocop/rubocop/pull/13761): Fix a false positive for `Style/SuperArguments` when calling super in a numblock. ([@earlopain][])
* [#13768](https://github.com/rubocop/rubocop/pull/13768): Fix a false positive for `Lint/UnreachableCode` with `instance_eval` numblock. ([@earlopain][])
* [#13750](https://github.com/rubocop/rubocop/issues/13750): Fix false positives for `Style/RedundantSelfAssignment` when assigning to attribute of `self`. ([@koic][])
* [#13739](https://github.com/rubocop/rubocop/issues/13739): Fix false positive for `Style/HashExcept` and `Style/HashSlice` when checking for inclusion with a range. ([@dvandersluis][])
* [#13751](https://github.com/rubocop/rubocop/issues/13751): Fix false positive in `Layout/ExtraSpacing` with `ForceEqualSignAlignment: true` for endless methods. ([@dvandersluis][])
* [#13767](https://github.com/rubocop/rubocop/pull/13767): Fix `Style/IdenticalConditionalBranches` autocorrect when condition is inside assignment. ([@dvandersluis][])
* [#13764](https://github.com/rubocop/rubocop/pull/13764): Fix a false negative for `Layout/SingleLineBlockChain` with numblocks. ([@earlopain][])
* [#13771](https://github.com/rubocop/rubocop/pull/13771): Fix wrong autocorrect for `Style/SoleNestedConditional` when using numblocks. ([@earlopain][])

## 1.71.0 (2025-01-22)

### New features

* [#13735](https://github.com/rubocop/rubocop/pull/13735): Add new `Lint/ArrayLiteralInRegexp` cop. ([@dvandersluis][])
* [#13507](https://github.com/rubocop/rubocop/pull/13507): Add new `Style/HashSlice` cop. ([@lovro-bikic][])

### Bug fixes

* [#13684](https://github.com/rubocop/rubocop/issues/13684): Fix a false positive for `Style/FrozenStringLiteralComment` when using the frozen string literal magic comment in Active Admin's arb files. ([@koic][])
* [#13372](https://github.com/rubocop/rubocop/issues/13372): Add `rubocop_cache` to the path given by `--cache-root` when pruning cache. ([@capncavedan][])
* [#13257](https://github.com/rubocop/rubocop/issues/13257): Fix department disable/enable comments enabling the cop for the whole file even if that file is excluded by the cop. ([@earlopain][])
* [#13704](https://github.com/rubocop/rubocop/issues/13704): Fix false positives for `Lint/OutOfRangeRegexpRef` when matching with `match` using safe navigation. ([@koic][])
* [#13720](https://github.com/rubocop/rubocop/issues/13720): Fix false positives for `Style/BlockDelimiters` when using brace blocks as conditions under `EnforcedStyle: semantic`. ([@koic][])
* [#13688](https://github.com/rubocop/rubocop/issues/13688): Fix false negative on `Style/RedundantLineContinuation` when the continuation is preceded by an interpolated string. ([@dvandersluis][])
* [#13677](https://github.com/rubocop/rubocop/issues/13677): Fix false negative on `Style/RedundantLineContinuation` when the continuation is followed by a percent array. ([@dvandersluis][])
* [#13692](https://github.com/rubocop/rubocop/pull/13692): Fix false positive in `Style/RedundantLineContinuation` when the ruby code ends with a commented continuation. ([@dvandersluis][])
* [#13675](https://github.com/rubocop/rubocop/pull/13675): Fix invalid autocorrect for `Style/ArrayFirstLast` when calling `.[]` or `&.[]` with 0 or -1. ([@dvandersluis][])
* [#13685](https://github.com/rubocop/rubocop/issues/13685): Fix syntax error introduced by `Lint/SafeNavigationChain` when adding safe navigation to an operator call inside a hash. ([@dvandersluis][])
* [#13725](https://github.com/rubocop/rubocop/issues/13725): Fix an incorrect autocorrect for `Style/IfUnlessModifier` when using omitted hash values in an assignment. ([@elliottt][])
* [#13667](https://github.com/rubocop/rubocop/issues/13667): Maintain precedence in autocorrect for `Style/SoleNestedConditional`. ([@tejasbubane][])
* [#13679](https://github.com/rubocop/rubocop/issues/13679): Fix false positive for `Style/RedundantLineContinuation` when calling methods with fully qualified constants. ([@earlopain][])
* [#13728](https://github.com/rubocop/rubocop/pull/13728): Fix a RuboCop error on provided glob pattern which matches directory. ([@viralpraxis][])
* [#13693](https://github.com/rubocop/rubocop/pull/13693): Fix `Style/ConditionalAssignment` cop error on `unless` without `else` and `assign_inside_condition` enforced style. ([@viralpraxis][])
* [#13669](https://github.com/rubocop/rubocop/pull/13669): Fix `Style/FrozenStringLiteralComment` cop error on unnormalized magic comment and `never` enforced style. ([@viralpraxis][])
* [#13696](https://github.com/rubocop/rubocop/pull/13696): Update `Metrics/CollectionLiteralLength` to only register for `[]` when called on `Set`. ([@dvandersluis][])

### Changes

* [#13709](https://github.com/rubocop/rubocop/pull/13709): Add support for safe navigation to `Lint/FloatComparison`. ([@dvandersluis][])
* [#13711](https://github.com/rubocop/rubocop/pull/13711): Add support for safe navigation to `Layout/MultilineMethodCallBraceLayout`. ([@dvandersluis][])
* [#13712](https://github.com/rubocop/rubocop/pull/13712): Add support for safe navigation to `Layout/MultilineMethodArgumentLineBreaks`. ([@dvandersluis][])
* [#13714](https://github.com/rubocop/rubocop/pull/13714): Add support for safe navigation to `Security/CompoundHash`. ([@dvandersluis][])
* [#13674](https://github.com/rubocop/rubocop/pull/13674): Add support for safe navigation to `Style/BlockDelimiters`. ([@dvandersluis][])
* [#13673](https://github.com/rubocop/rubocop/pull/13673): Add support for safe navigation to `Style/CollectionMethods`. ([@dvandersluis][])
* [#13672](https://github.com/rubocop/rubocop/pull/13672): Add support for safe navigation to `Style/MapToSet`. ([@dvandersluis][])
* [#13671](https://github.com/rubocop/rubocop/pull/13671): Add support for safe navigation to `Style/MethodCallWithoutArgsParentheses`. ([@dvandersluis][])
* [#13701](https://github.com/rubocop/rubocop/pull/13701): Add support for safe navigation to `Lint/NumericOperationWithConstantResult`. ([@dvandersluis][])
* [#13700](https://github.com/rubocop/rubocop/pull/13700): Add support for safe navigation to `Lint/RedundantStringCoercion`. ([@dvandersluis][])
* [#13698](https://github.com/rubocop/rubocop/pull/13698): Add support for safe navigation to `Lint/UselessNumericOperation`. ([@dvandersluis][])
* [#13686](https://github.com/rubocop/rubocop/pull/13686): Add wildcard support to `--show-cops`. ([@kyanagi][])
* [#13724](https://github.com/rubocop/rubocop/pull/13724): Make `Style/RedundantParentheses` aware of parenthesized assignment. ([@koic][])
* [#13732](https://github.com/rubocop/rubocop/pull/13732): Update `Style/RedundantLineContinuation` to handle required continuations following `super`. ([@dvandersluis][])

## 1.70.0 (2025-01-10)

### New features

* [#13474](https://github.com/rubocop/rubocop/pull/13474): Add new `Style/ItAssignment` cop to detect local assignments to `it` inside blocks. ([@dvandersluis][])
* [#11013](https://github.com/rubocop/rubocop/issues/11013): Add new `Lint/SharedMutableDefault` cop to alert on mutable Hash defaults. ([@corsonknowles][])
* [#13612](https://github.com/rubocop/rubocop/pull/13612): Create new cop `Lint/ConstantReassignment`. ([@lovro-bikic][])
* [#13628](https://github.com/rubocop/rubocop/pull/13628): Make LSP server support quick fix code action. ([@koic][])
* [#13607](https://github.com/rubocop/rubocop/pull/13607): Support passing the target ruby version through an environment variable. ([@elliottt][])
* [#13628](https://github.com/rubocop/rubocop/pull/13628): Add support for Ruby LSP as a built-in add-on. ([@koic][])
* [#13284](https://github.com/rubocop/rubocop/issues/13284): Add new `target_gem_version` API to change behavior of a cop at runtime depending on which gem version is present. ([@earlopain][])

### Bug fixes

* [#13589](https://github.com/rubocop/rubocop/pull/13589): Fix `Lint/NonAtomicFileOperation` to detect offenses with fully qualified constants. ([@viralpraxis][])
* [#13630](https://github.com/rubocop/rubocop/pull/13630): Fix CLI `--format` option to accept fully qualified formatter class names. ([@viralpraxis][])
* [#13624](https://github.com/rubocop/rubocop/pull/13624): Don't show warnings from `Lint/Syntax` when a syntax error occurs. ([@earlopain][])
* [#13605](https://github.com/rubocop/rubocop/pull/13605): Fix `RuboCop::Cop::Util.to_string_literal` to work correctly with frozen strings. ([@viralpraxis][])
* [#12393](https://github.com/rubocop/rubocop/issues/12393): Fix false negatives for `Lint/Void` inside of non-modifier conditionals. ([@GabeIsman][])
* [#13623](https://github.com/rubocop/rubocop/issues/13623): Fix false negatives for `Style/MultipleComparison` when setting `AllowMethodComparison: false` and comparing with simple method calls. ([@koic][])
* [#13644](https://github.com/rubocop/rubocop/pull/13644): Fix a false positive for `Layout/EmptyLinesAroundAccessModifier` when an access modifier and an expression are on the same line. ([@koic][])
* [#13645](https://github.com/rubocop/rubocop/issues/13645): Fix a false positive for `Style/MethodCallWithArgsParentheses` when setting `EnforcedStyle: omit_parentheses` and last argument is an endless range. ([@earlopain][])
* [#13614](https://github.com/rubocop/rubocop/issues/13614): Fix false positives for `Style/RaiseArgs` with anonymous splat and triple dot forwarding. ([@earlopain][])
* [#13591](https://github.com/rubocop/rubocop/pull/13591): Fix false positives for `Lint/NestedMethodDefinition` when defining a method on a constant or a method call. ([@koic][])
* [#13594](https://github.com/rubocop/rubocop/pull/13594): Fix false positives for `Style/MultipleComparison` when using multiple safe navigation method calls. ([@koic][])
* [#13654](https://github.com/rubocop/rubocop/pull/13654): Fix false positives for `Style/RedundantInitialize` when empty initialize method has arguments. ([@marocchino][])
* [#13608](https://github.com/rubocop/rubocop/pull/13608): Fix crash when running `rubocop -d` on a config with a remote `inherit_from` that causes a duplicate setting warning. ([@dvandersluis][])
* [#12430](https://github.com/rubocop/rubocop/issues/12430): Fix false negatives in `Style/RedundantLineContinuation` with multiple line continuations. ([@dvandersluis][])
* [#13638](https://github.com/rubocop/rubocop/pull/13638): Fix false positive for `Naming/BlockForwarding` when method just returns the block argument. ([@mvz][])
* [#13599](https://github.com/rubocop/rubocop/issues/13599): Fix incorrect autocorrect for `Layout/HashAlignment` when there is a multiline positional argument and `Layout/ArgumentAlignment` is configured with `EnforcedStyle: with_fixed_indentation`. ([@dvandersluis][])
* [#13586](https://github.com/rubocop/rubocop/issues/13586): Fix regression in `Layout/SpaceAroundOperators` when different comparison operators were aligned with each other. ([@dvandersluis][])
* [#13603](https://github.com/rubocop/rubocop/pull/13603): Fix `Lint/LiteralInInterpolation` cop error on invalid string literal. ([@viralpraxis][])
* [#13582](https://github.com/rubocop/rubocop/pull/13582): Fix `Lint/NonAtomicFileOperation` cop error on non-constant receiver. ([@viralpraxis][])
* [#13598](https://github.com/rubocop/rubocop/pull/13598): Fix `Lint/Void` cop error on `if` without body. ([@viralpraxis][])
* [#13634](https://github.com/rubocop/rubocop/pull/13634): Fix `Style/ClassAndModuleChildren` cop error on `compact` enforced style and unindented body. ([@viralpraxis][])
* [#13642](https://github.com/rubocop/rubocop/pull/13642): Fix `Style/FloatDivision` cop error if `#to_f` has implicit receiver. ([@viralpraxis][])
* [#13517](https://github.com/rubocop/rubocop/pull/13517): Fixes `Style/HashExcept` to recognize safe navigation when `ActiveSupportExtensionsEnabled` config is enabled. ([@lovro-bikic][])
* [#13585](https://github.com/rubocop/rubocop/pull/13585): Fix `Style/HashSyntax` cop error on implicit `call` method. ([@viralpraxis][])
* [#13632](https://github.com/rubocop/rubocop/pull/13632): Fix `Style/MissingElse` cop error if `Style/EmptyElse`'s `EnforcedStyle` is not `both` and `if` expression contains `elsif`. ([@viralpraxis][])
* [#13659](https://github.com/rubocop/rubocop/pull/13659): Fix `Style/MissingElse` cop error if `Style/EmptyElse`'s `EnforcedStyle` is not `both` and `if` expression contains multiple `elsif`. ([@viralpraxis][])
* [#13596](https://github.com/rubocop/rubocop/pull/13596): Fix `Style/RedundantCondition` cop error on parentheses and modifier `if` in `else`. ([@viralpraxis][])
* [#13616](https://github.com/rubocop/rubocop/pull/13616): Fix incorrect autocorrect for `Style/RedundantRegexpArgument` when the regex contains a single quote. ([@mrzasa][])
* [#13619](https://github.com/rubocop/rubocop/pull/13619): Fix `Style/YodaExpression` cop error in case of suffix form of operator. ([@viralpraxis][])
* [#13578](https://github.com/rubocop/rubocop/issues/13578): Update `Layout/LineContinuationSpacing` to ignore continuations inside a `regexp` or `xstr`. ([@dvandersluis][])
* [#13601](https://github.com/rubocop/rubocop/issues/13601): Update `Style/SuperArguments` to handle `super` with a block or with a chained method with a block. ([@dvandersluis][])
* [#13568](https://github.com/rubocop/rubocop/pull/13568): Fix `NoMethodError` in `ConfigValidator` when a Cop's config is not a `Hash` and raise `ValidationError` instead. ([@amomchilov][])

### Changes

* [#13665](https://github.com/rubocop/rubocop/pull/13665): Add support for safe navigation to `Style/ObjectThen`. ([@dvandersluis][])
* [#13657](https://github.com/rubocop/rubocop/pull/13657): Add support for safe navigation to `Layout/HashAlignment`. ([@dvandersluis][])
* [#13656](https://github.com/rubocop/rubocop/pull/13656): Add support for safe navigation to `Layout/HeredocArgumentClosingParenthesis`. ([@dvandersluis][])
* [#13655](https://github.com/rubocop/rubocop/pull/13655): Add support for safe navigation to `Layout/LineLength`. ([@dvandersluis][])
* [#13662](https://github.com/rubocop/rubocop/pull/13662): Add support for safe navigation to `Style/SendWithLiteralMethodName`. ([@dvandersluis][])
* [#13557](https://github.com/rubocop/rubocop/issues/13557): Fix false positives for `Lint/NumericOperationWithConstantResult`. ([@earlopain][])
* [#13658](https://github.com/rubocop/rubocop/pull/13658): Fix invalid autocorrect for `Style/SlicingWithRange` when calling `.[]` or `&.[]` with a correctable range. ([@dvandersluis][])
* [#13548](https://github.com/rubocop/rubocop/pull/13548): Enhance `Lint/DuplicateSetElement` to detect offences within `SortedSet`. ([@viralpraxis][])
* [#13646](https://github.com/rubocop/rubocop/pull/13646): Update `Layout/TrailingWhitespace` to support blank characters other than space and tab. ([@krororo][])
* [#13652](https://github.com/rubocop/rubocop/pull/13652): Update `Metrics/MethodLength` to make use of `AllowedMethods` and `AllowedPatterns` for methods defined dynamically with `define_method`. ([@dvandersluis][])
* [#13606](https://github.com/rubocop/rubocop/issues/13606): Update `Style/AccessModifierDeclarations` to add `AllowModifiersOnAliasMethod` configuration (default `true`). ([@dvandersluis][])
* [#13663](https://github.com/rubocop/rubocop/pull/13663): Update `Style/RedundantSelfAssignment` to handle safe navigation on the right-hand side of the assignment. ([@dvandersluis][])

## 1.69.2 (2024-12-12)

### Bug fixes

* [#13553](https://github.com/rubocop/rubocop/issues/13553): Fix an incorrect autocorrect for `Style/MultipleComparison` when a variable is compared multiple times after a method call. ([@koic][])
* [#13562](https://github.com/rubocop/rubocop/pull/13562): Fix `Bundler/DuplicatedGem` cop error in case of empty branch. ([@viralpraxis][])
* [#13573](https://github.com/rubocop/rubocop/pull/13573): Fix `Lint/UnescapedBracketInRegexp` cop failure with invalid multibyte escape. ([@earlopain][])
* [#13556](https://github.com/rubocop/rubocop/issues/13556): Fix false positives for `Style/FileNull` when using `'nul'` string. ([@koic][])
* [#12995](https://github.com/rubocop/rubocop/issues/12995): Fix `--disable-uncorrectable` to not insert directives inside a string. ([@dvandersluis][])
* [#13320](https://github.com/rubocop/rubocop/issues/13320): Fix incorrect autocorrect when `Layout/LineContinuationLeadingSpace` and `Style/StringLiterals` autocorrects in the same pass. ([@dvandersluis][])
* [#13299](https://github.com/rubocop/rubocop/issues/13299): Fix `Style/BlockDelimiters` to always accept braces when an operator method argument is chained. ([@dvandersluis][])
* [#13565](https://github.com/rubocop/rubocop/pull/13565): Fix `Style/RedundantLineContinuation` false negatives when a redundant continuation follows a required continuation. ([@dvandersluis][])
* [#13551](https://github.com/rubocop/rubocop/pull/13551): Fix an incorrect autocorrect for `Style/IfWithSemicolon` when using multi value assignment in `if` with a semicolon is used. ([@koic][])
* [#13534](https://github.com/rubocop/rubocop/pull/13534): Fix `Layout/LineLength` cop failure in case of YARD-comment-like string. ([@viralpraxis][])
* [#13558](https://github.com/rubocop/rubocop/pull/13558): Fix `Lint/NonAtomicFileOperation` cop error in case of implicit receiver. ([@viralpraxis][])
* [#13564](https://github.com/rubocop/rubocop/pull/13564): Fix `Metrics/ClassLength` cop error in case of chained assignments. ([@viralpraxis][])
* [#13570](https://github.com/rubocop/rubocop/pull/13570): Fix `Naming/RescuedExceptionsVariableName` cop error when exception is assigned with writer method. ([@viralpraxis][])
* [#13559](https://github.com/rubocop/rubocop/pull/13559): Fix a false positive for `Style/RedundantLineContinuation` when a method definition is used as an argument for a method call. ([@davidrunger][])
* [#13574](https://github.com/rubocop/rubocop/pull/13574): Fix `Style/ExactRegexpMatch` cop error on invalid regular expression literal. ([@viralpraxis][])
* [#13554](https://github.com/rubocop/rubocop/pull/13554): Fix `Style/FrozenStringLiteralComment` false positive in case of non-downcased value literal. ([@viralpraxis][])
* [#13569](https://github.com/rubocop/rubocop/pull/13569): Fix `Style/MethodCallWithoutArgsParentheses` cop error in case of mass hash assignment. ([@viralpraxis][])
* [#13542](https://github.com/rubocop/rubocop/pull/13542): Fix `Style/RedundantCondition` cop failure in case of empty arguments. ([@viralpraxis][])
* [#13509](https://github.com/rubocop/rubocop/issues/13509): Update `Layout/ExtraSpacing` and `Layout/SpaceAroundOperators` to handle preceding operators inside strings. ([@dvandersluis][])

## 1.69.1 (2024-12-03)

### Bug fixes

* [#13502](https://github.com/rubocop/rubocop/issues/13502): Fix an incorrect autocorrect for `Style/DigChain` when using safe navigation method chain with `dig` method. ([@koic][])
* [#13505](https://github.com/rubocop/rubocop/issues/13505): Fix an error for `Style/ParallelAssignment` when using the anonymous splat operator. ([@earlopain][])
* [#13184](https://github.com/rubocop/rubocop/pull/13184): Fix some false positives in  `Lint/UnreachableCode`. ([@isuckatcs][])
* [#13494](https://github.com/rubocop/rubocop/pull/13494): Fix false positives for `Style/HashExcept` cop when using `reject/!include?`, `reject/!in?` or `select/!exclude?` combinations. ([@lovro-bikic][])
* [#13522](https://github.com/rubocop/rubocop/pull/13522): Fix `Lint/UnescapedBracketInRegexp` cop failure with invalid regular expression. ([@viralpraxis][])
* [#13523](https://github.com/rubocop/rubocop/pull/13523): Fix `Style::AccessModifierDeclarations` cop failure in case of `if` node without `else`. ([@viralpraxis][])
* [#13524](https://github.com/rubocop/rubocop/pull/13524): Fix `Style/RedundantArgument` cop failure while inspecting string literal with invalid encoding. ([@viralpraxis][])
* [#13528](https://github.com/rubocop/rubocop/pull/13528): Fix `Style/RedundantParentheses` cop failure in case of splatted `case` node without condition. ([@viralpraxis][])
* [#13521](https://github.com/rubocop/rubocop/pull/13521): Fix `Style/RedundantSelf` cop failure with `kwnilarg` argument node. ([@viralpraxis][])
* [#13526](https://github.com/rubocop/rubocop/pull/13526): Fix `Style/StringConcatenation` cop failure when there are mixed implicit and explicit concatenations. ([@viralpraxis][])
* [#13511](https://github.com/rubocop/rubocop/issues/13511): Fix false positive in `Lint/UnescapedBracketInRegexp` when using regexp_parser 2.9.2 and earlier. ([@dvandersluis][])
* [#13096](https://github.com/rubocop/rubocop/issues/13096): Update `Style/BlockDelimiters` to not change braces when they are required for syntax. ([@dvandersluis][])
* [#13512](https://github.com/rubocop/rubocop/pull/13512): Update `Style/LambdaCall` to be aware of safe navigation. ([@dvandersluis][])

## 1.69.0 (2024-11-26)

### New features

* [#13439](https://github.com/rubocop/rubocop/pull/13439): Add new `Lint/HashNewWithKeywordArgumentsAsDefault` cop. ([@koic][])
* [#11191](https://github.com/rubocop/rubocop/issues/11191): Add new `Lint/NumericOperationWithConstantResult` cop. ([@zopolis4][])
* [#13486](https://github.com/rubocop/rubocop/issues/13486): Add new `Style/DigChain` cop. ([@dvandersluis][])
* [#13490](https://github.com/rubocop/rubocop/issues/13490): Add new `Style/FileNull` cop. ([@dvandersluis][])
* [#13484](https://github.com/rubocop/rubocop/pull/13484): Add new `Style/FileTouch` cop. ([@lovro-bikic][])
* [#13437](https://github.com/rubocop/rubocop/issues/13437): Add a new cop `Lint/UselessDefined` to detect cases such as `defined?('Foo')` when `defined?(Foo)` was intended. ([@earlopain][])

### Bug fixes

* [#13455](https://github.com/rubocop/rubocop/pull/13455): Fix a false positive for `Layout/EmptyLineAfterGuardClause` when using a guard clause outside oneliner block. ([@koic][])
* [#13412](https://github.com/rubocop/rubocop/issues/13412): Fix a false positive for `Style/RedundantLineContinuation` when there is a line continuation at the end of Ruby code followed by `__END__` data. ([@koic][])
* [#13476](https://github.com/rubocop/rubocop/pull/13476): Allow to write generics type of RBS::Inline annotation after subclass definition in `Style/CommentedKeyword`. ([@dak2][])
* [#13441](https://github.com/rubocop/rubocop/pull/13441): Fix an incorrect autocorrect for `Style/IfWithSemicolon` when using `return` with value in `if` with a semicolon is used. ([@koic][])
* [#13448](https://github.com/rubocop/rubocop/pull/13448): Fix an incorrect autocorrect for `Style/IfWithSemicolon` when the then body contains an arithmetic operator method call with an argument. ([@koic][])
* [#13199](https://github.com/rubocop/rubocop/issues/13199): Make `Style/RedundantCondition` skip autocorrection when a branch has a comment. ([@koic][])
* [#13411](https://github.com/rubocop/rubocop/pull/13411): Fix `Style/BitwisePredicate` when having regular method. ([@d4be4st][])
* [#13432](https://github.com/rubocop/rubocop/pull/13432): Fix false positive for `Lint/FloatComparison` against nil. ([@lovro-bikic][])
* [#13461](https://github.com/rubocop/rubocop/pull/13461): Fix false positives for `Lint/InterpolationCheck` when using invalid syntax in interpolation. ([@koic][])
* [#13402](https://github.com/rubocop/rubocop/issues/13402): Fix a false positive for `Lint/SafeNavigationConsistency` when using unsafe navigation with both `&&` and `||`. ([@koic][])
* [#13434](https://github.com/rubocop/rubocop/issues/13434): Fix a false positive for `Naming/MemoizedInstanceVariableName` for assignment methods`. ([@earlopain][])
* [#13415](https://github.com/rubocop/rubocop/issues/13415): Fix false positives for `Naming/MemoizedInstanceVariableName` when using `initialize_clone`, `initialize_copy`, or `initialize_dup`. ([@koic][])
* [#13421](https://github.com/rubocop/rubocop/issues/13421): Fix false positives for `Style/SafeNavigation` when using a method chain that exceeds the `MaxChainLength` value and includes safe navigation operator. ([@koic][])
* [#13433](https://github.com/rubocop/rubocop/issues/13433): Fix autocorrection for `Style/AccessModifierDeclarations` for multiple inline symbols. ([@dvandersluis][])
* [#13430](https://github.com/rubocop/rubocop/issues/13430): Fix EmptyLinesAroundMethodBody for methods with arguments spanning multiple lines. ([@aduth][])
* [#13438](https://github.com/rubocop/rubocop/pull/13438): Fix incorrect correction in `Lint/Void` if an operator is called in a void context using a dot. ([@dvandersluis][])
* [#13419](https://github.com/rubocop/rubocop/pull/13419): Fix `Lint/DeprecatedOpenSSLConstant` false positive when the argument is a safe navigation method call. ([@dvandersluis][])
* [#13404](https://github.com/rubocop/rubocop/pull/13404): Fix `Style/AccessModifierDeclarations` to register (as positive or negative, depending on `AllowModifiersOnSymbols` value) access modifiers with multiple symbols. ([@dvandersluis][])
* [#13436](https://github.com/rubocop/rubocop/pull/13436): Fix incorrect offense and autocorrect for `Lint/RedundantSplatExpansion` when percent literal array is used in a safe navigation method call. ([@lovro-bikic][])
* [#13442](https://github.com/rubocop/rubocop/pull/13442): Fix an incorrect autocorrect for `Style/NestedTernaryOperator` when ternary operators are nested and the inner condition is parenthesized. ([@koic][])
* [#13444](https://github.com/rubocop/rubocop/pull/13444): Fix an incorrect autocorrect for `Style/OneLineConditional` when the else branch of a ternary operator has multiple expressions. ([@koic][])
* [#13483](https://github.com/rubocop/rubocop/issues/13483): Fix an incorrect autocorrect for `Style/RedundantRegexpArgument` when using escaped double quote character. ([@koic][])
* [#13497](https://github.com/rubocop/rubocop/pull/13497): Fix infinite loop error for `Style/IfWithSemicolon` when using nested if/;/end in if body. ([@koic][])
* [#13477](https://github.com/rubocop/rubocop/issues/13477): Update `Layout/LeadingCommentSpace` to accept multiline shebangs at the top of the file. ([@dvandersluis][])
* [#13453](https://github.com/rubocop/rubocop/issues/13453): Update `Style/AccessModifierDeclarations` to handle `attr_*` methods with multiple parameters. ([@dvandersluis][])
* [#12597](https://github.com/rubocop/rubocop/issues/12597): Update `Style/SingleLineDoEndBlock` to not register an offense if it will introduce a conflicting `Layout/RedundantLineBreak` offense. ([@dvandersluis][])

### Changes

* [#11680](https://github.com/rubocop/rubocop/issues/11680): Add autocorrection for strings to `Layout/LineLength` when `SplitStrings` is set to `true`. ([@dvandersluis][])
* [#13470](https://github.com/rubocop/rubocop/pull/13470): Make `Style/ArrayIntersect` aware of `none?`. ([@earlopain][])
* [#13481](https://github.com/rubocop/rubocop/pull/13481): Support unicode-display_width v3. ([@gemmaro][])
* [#13473](https://github.com/rubocop/rubocop/pull/13473): Update `Lint/ItWithoutArgumentsInBlock` to not register offenses in Ruby 3.4. ([@dvandersluis][])
* [#13420](https://github.com/rubocop/rubocop/pull/13420): Update `Lint/RedundantSafeNavigation` to register an offense when the receiver is `self`. ([@dvandersluis][])
* [#11393](https://github.com/rubocop/rubocop/issues/11393): Update `Lint/UnusedMethodArgument` to allow the class names for `IgnoreNotImplementedMethods` to be configured. ([@dvandersluis][])
* [#13058](https://github.com/rubocop/rubocop/issues/13058): Update `Style/AccessModifierDeclarations` to accept modifier with splatted method call. ([@dvandersluis][])

## 1.68.0 (2024-10-31)

### New features

* [#13050](https://github.com/rubocop/rubocop/issues/13050): Add new `Style/BitwisePredicate` cop. ([@koic][])
* [#12140](https://github.com/rubocop/rubocop/issues/12140): Add new `Style/CombinableDefined` cop. ([@dvandersluis][])
* [#12988](https://github.com/rubocop/rubocop/issues/12988): Add new `Style/AmbiguousEndlessMethodDefinition` cop. ([@dvandersluis][])
* [#11514](https://github.com/rubocop/rubocop/issues/11514): Add new `Lint/UnescapedBracketInRegexp` cop. ([@dvandersluis][])
* [#13360](https://github.com/rubocop/rubocop/pull/13360): Add `AllowSteepAnnotation` config option to `Layout/LeadingCommentSpace`. ([@tk0miya][])
* [#13146](https://github.com/rubocop/rubocop/issues/13146): Add new `IgnoreDuplicateElseBranch` option to `Lint/DuplicateBranch`. ([@fatkodima][])
* [#13171](https://github.com/rubocop/rubocop/issues/13171): Add new `Style/SafeNavigationChainLength` cop. ([@fatkodima][])
* [#13252](https://github.com/rubocop/rubocop/pull/13252): Add new `Style/KeywordArgumentsMerging` cop. ([@fatkodima][])

### Bug fixes

* [#13401](https://github.com/rubocop/rubocop/pull/13401): Fix a false negative for `Style/RedundantLineContinuation` when there is a line continuation at the EOF. ([@koic][])
* [#13368](https://github.com/rubocop/rubocop/issues/13368): Fix an incorrect autocorrect for `Naming/BlockForwarding` with `Style/ExplicitBlockArgument`. ([@koic][])
* [#13391](https://github.com/rubocop/rubocop/pull/13391): Fix deserialization of unknown encoding offenses. ([@earlopain][])
* [#13348](https://github.com/rubocop/rubocop/issues/13348): Ensure `Style/BlockDelimiters` autocorrection does not move other code between the block and comment. ([@dvandersluis][])
* [#13382](https://github.com/rubocop/rubocop/pull/13382): Fix an error during error handling for custom ruby extractors when the extractor is a class. ([@earlopain][])
* [#13309](https://github.com/rubocop/rubocop/issues/13309): Fix a false negative for `Lint/UselessAssignment` cop when there is a useless assignment followed by a block. ([@pCosta99][])
* [#13255](https://github.com/rubocop/rubocop/pull/13255): Fix false negatives for `Style/MapIntoArray` when using non-splatted arguments. ([@vlad-pisanov][])
* [#13356](https://github.com/rubocop/rubocop/issues/13356): Fix a false positive for `Layout/SpaceBeforeBrackets` when there is a dot before `[]=`. ([@earlopain][])
* [#13365](https://github.com/rubocop/rubocop/issues/13365): Fix false positives for `Lint/SafeNavigationConsistency` when using safe navigation on the LHS with operator method on the RHS of `&&`. ([@koic][])
* [#13390](https://github.com/rubocop/rubocop/issues/13390): Fix false positives for `Style/GuardClause` when using a local variable assigned in a conditional expression in a branch. ([@koic][])
* [#13337](https://github.com/rubocop/rubocop/issues/13337): Fix false positives for `Style/RedundantLineContinuation` when required line continuations for `&&` is used with an assignment after a line break. ([@koic][])
* [#13387](https://github.com/rubocop/rubocop/issues/13387): Fix false positives in `Style/RedundantParentheses` when parentheses are used around method chain with `do`...`end` block in keyword argument. ([@koic][])
* [#13341](https://github.com/rubocop/rubocop/issues/13341): Fix false positives for `Lint/SafeNavigationChain` when a safe navigation operator is used with a method call as the RHS operand of `&&` for the same receiver. ([@koic][])
* [#13324](https://github.com/rubocop/rubocop/issues/13324): Fix `--disable-uncorrectable` to not insert a comment inside a string continuation. ([@dvandersluis][])
* [#13364](https://github.com/rubocop/rubocop/issues/13364): Fix incorrect autocorrect with `Lint/UselessAssignment` a multiple assignment or `for` contains an inner assignment. ([@dvandersluis][])
* [#13353](https://github.com/rubocop/rubocop/issues/13353): Fix an incorrect autocorrect for `Style/BlockDelimiters` when `EnforcedStyle: semantic` is set and used with `Layout/SpaceInsideBlockBraces`. ([@koic][])
* [#13361](https://github.com/rubocop/rubocop/issues/13361): Fix false positives for `Style/RedundantInterpolationUnfreeze` and `Style/RedundantFreeze` when strings contain interpolated global, instance, and class variables. ([@vlad-pisanov][])
* [#13343](https://github.com/rubocop/rubocop/issues/13343): Prevent `Layout/LineLength` from breaking up a method with arguments chained onto a heredoc delimiter. ([@dvandersluis][])
* [#13374](https://github.com/rubocop/rubocop/issues/13374): Return exit code 0 with `--display-only-correctable` and `--display-only-safe-correctable` when no offenses are displayed. ([@dvandersluis][])
* [#13193](https://github.com/rubocop/rubocop/issues/13193): Fix false positive in `Style/MultipleComparison` when `ComparisonsThreshold` exceeds 2. ([@fatkodima][], [@vlad-pisanov][])
* [#13325](https://github.com/rubocop/rubocop/pull/13325): Fix an incorrect autocorrect for `Lint/NonAtomicFileOperation` when using a postfix `unless` for file existence checks before creating a file, in cases with `Dir.mkdir`. ([@kotaro0522][])
* [#13397](https://github.com/rubocop/rubocop/pull/13397): Update `PercentLiteralCorrector` to be able to write pairs of delimiters without excessive escaping. ([@dvandersluis][])
* [#13336](https://github.com/rubocop/rubocop/issues/13336): Update `Style/SafeNavigation` to not autocorrect if the RHS of an `and` node is an `or` node. ([@dvandersluis][])
* [#13378](https://github.com/rubocop/rubocop/issues/13378): When removing parens in `Style/TernaryParentheses` with a `send` node condition, ensure its arguments are parenthesized. ([@dvandersluis][])

### Changes

* [#13347](https://github.com/rubocop/rubocop/pull/13347): When running `rubocop -V`, show the analysis Ruby version of the current directory. ([@earlopain][])

## 1.67.0 (2024-10-15)

### New features

* [#13259](https://github.com/rubocop/rubocop/issues/13259): Add new `Lint/DuplicateSetElement` cop. ([@koic][])
* [#13223](https://github.com/rubocop/rubocop/pull/13223): Add `AllowRBSInlineAnnotation` config option to `Layout/LeadingCommentSpace` to support RBS::Inline style annotation comments. ([@tk0miya][])
* [#13310](https://github.com/rubocop/rubocop/issues/13310): Display analysis Ruby version in `rubocop -V`. ([@koic][])

### Bug fixes

* [#13314](https://github.com/rubocop/rubocop/pull/13314): Fix a false negative for `Style/Semicolon` when using a semicolon between a closing parenthesis after a line break and a consequent expression. ([@koic][])
* [#13217](https://github.com/rubocop/rubocop/pull/13217): Fix a false positive in `Lint/ParenthesesAsGroupedExpression` with compound ranges. ([@gsamokovarov][])
* [#13268](https://github.com/rubocop/rubocop/pull/13268): Fix a false positive for `Style/BlockDelimiters` when a single line do-end block with an inline `rescue` with a semicolon before `rescue`. ([@koic][])
* [#13298](https://github.com/rubocop/rubocop/pull/13298): Fix an error for `Layout/AccessModifierIndentation` when the access modifier is on the same line as the class definition. ([@koic][])
* [#13198](https://github.com/rubocop/rubocop/pull/13198): Fix an error for `Style/OneLineConditional` when using nested if/then/else/end. ([@koic][])
* [#13316](https://github.com/rubocop/rubocop/issues/13316): Fix an incorrect autocorrect for `Lint/ImplicitStringConcatenation` with `Lint/TripleQuotes` when string literals with triple quotes are used. ([@koic][])
* [#13220](https://github.com/rubocop/rubocop/issues/13220): Fix an incorrect autocorrect for `Style/ArgumentsForwarding` when using only forwarded arguments in brackets. ([@koic][])
* [#13202](https://github.com/rubocop/rubocop/issues/13202): Fix an incorrect autocorrect for `Style/CombinableLoops` when looping over the same data with different block variable names. ([@koic][])
* [#13291](https://github.com/rubocop/rubocop/issues/13291): Fix an incorrect autocorrect for `Style/RescueModifier` when using modifier rescue for method call with heredoc argument. ([@koic][])
* [#13226](https://github.com/rubocop/rubocop/pull/13226): Fix `--auto-gen-config` when passing an absolute config path. ([@earlopain][])
* [#13225](https://github.com/rubocop/rubocop/issues/13225): Avoid syntax error when correcting `Style/OperatorMethodCall` with `/` operations followed by a parenthesized argument. ([@dvandersluis][])
* [#13235](https://github.com/rubocop/rubocop/issues/13235): Fix an error for `Style/IfUnlessModifier` when multiline `if` that fits on one line and using implicit method call with hash value omission syntax. ([@koic][])
* [#13219](https://github.com/rubocop/rubocop/pull/13219): Fix a false positive for `Style/ArgumentsForwarding` with Ruby 3.0 and optional position arguments. ([@earlopain][])
* [#13271](https://github.com/rubocop/rubocop/issues/13271): Fix a false positive for `Lint/AmbiguousRange` when using rational literals. ([@koic][])
* [#13260](https://github.com/rubocop/rubocop/issues/13260): Fix a false positive for `Lint/RedundantSafeNavigation` with namespaced constants. ([@earlopain][])
* [#13224](https://github.com/rubocop/rubocop/pull/13224): Fix false positives for `Style/OperatorMethodCall` with named forwarding. ([@earlopain][])
* [#13213](https://github.com/rubocop/rubocop/issues/13213): Fix false positives for `Style/AccessModifierDeclarations` when `AllowModifiersOnAttrs: true` and using splat with a percent symbol array, or with a constant. ([@koic][])
* [#13145](https://github.com/rubocop/rubocop/issues/13145): Fix false positives for `Style/RedundantLineContinuation` when line continuations with comparison operator and the LHS is wrapped in parentheses. ([@koic][])
* [#12875](https://github.com/rubocop/rubocop/issues/12875): Fix false positive for `Style/ArgumentsForwarding` when argument is used inside a block. ([@dvandersluis][])
* [#13239](https://github.com/rubocop/rubocop/pull/13239): Fix false positive for `Style/CollectionCompact` when using `delete_if`. ([@masato-bkn][])
* [#13210](https://github.com/rubocop/rubocop/pull/13210): Fix omit_parentheses style for pattern match with value omission in single-line branch. ([@gsamokovarov][])
* [#13149](https://github.com/rubocop/rubocop/issues/13149): Handle crashes in custom Ruby extractors more gracefully. ([@earlopain][])
* [#13319](https://github.com/rubocop/rubocop/issues/13319): Handle literal forward slashes inside a `regexp` in `Lint/LiteralInInterpolation`. ([@dvandersluis][])
* [#13208](https://github.com/rubocop/rubocop/pull/13208): Fix an incorrect autocorrect for `Style/IfWithSemicolon` when single-line `if/;/end` when the then body contains a method call with `[]` or `[]=`. ([@koic][])
* [#13318](https://github.com/rubocop/rubocop/issues/13318): Prevent modifying blocks with `Style/HashEachMethods` if the hash is modified within the block. ([@dvandersluis][])
* [#13293](https://github.com/rubocop/rubocop/pull/13293): Fix `TargetRubyVersion` from a gemspec when the gemspec is not named like the folder it is located in. ([@earlopain][])
* [#13211](https://github.com/rubocop/rubocop/pull/13211): Fix wrong autocorrect for `Style/GuardClause` when using heredoc without `else` branch. ([@earlopain][])
* [#13215](https://github.com/rubocop/rubocop/pull/13215): Fix wrong autocorrect for `Lint/BigDecimalNew` when using `::BigDecimal.new`. ([@earlopain][])
* [#13215](https://github.com/rubocop/rubocop/pull/13215): Fix wrong autocorrect for `Style/MethodCallWithArgsParentheses` with `EnforcedStyle: omit_parentheses` and whitespace. ([@earlopain][])
* [#13302](https://github.com/rubocop/rubocop/issues/13302): Fix incompatible autocorrect between `Style/RedundantBegin` and `Style/BlockDelimiters` with `EnforcedStyle: braces_for_chaining`. ([@earlopain][])

### Changes

* [#13221](https://github.com/rubocop/rubocop/pull/13221): Do not group accessors having RBS::Inline annotation comments in `Style/AccessorGrouping`. ([@tk0miya][])
* [#13286](https://github.com/rubocop/rubocop/issues/13286): Add `AllowedMethods` configuration to `Layout/FirstMethodArgumentLineBreak`. ([@dvandersluis][])
* [#13110](https://github.com/rubocop/rubocop/issues/13110): Add support in `Style/ArgumentsForwarding` for detecting forwarding of all anonymous arguments. ([@dvandersluis][])
* [#13222](https://github.com/rubocop/rubocop/pull/13222): Allow to write RBS::Inline annotation comments after method definition in `Style/CommentedKeyword`. ([@tk0miya][])
* [#13253](https://github.com/rubocop/rubocop/pull/13253): Emit a deprecation when custom cops inherit from `RuboCop::Cop::Cop`. ([@earlopain][])
* [#13300](https://github.com/rubocop/rubocop/pull/13300): Set `EnforcedShorthandSyntax: either` by default for `Style/HashSyntax`. ([@koic][])
* [#13254](https://github.com/rubocop/rubocop/pull/13254): Enhance the autocorrect for `Naming/InclusiveLanguage` when a sole suggestion is set. ([@koic][])
* [#13232](https://github.com/rubocop/rubocop/issues/13232): Make server mode aware of auto-restart for local config update. ([@koic][])
* [#13270](https://github.com/rubocop/rubocop/pull/13270): Make `Style/SelectByRegexp` aware of `filter` in Ruby version 2.6 or above. ([@masato-bkn][])
* [#9816](https://github.com/rubocop/rubocop/issues/9816): Refine `Lint/SafeNavigationConsistency` cop to check that the safe navigation operator is applied consistently and without excess or deficiency. ([@koic][])
* [#13256](https://github.com/rubocop/rubocop/issues/13256): Report and correct more `Style/SafeNavigation` offenses. ([@dvandersluis][])
* [#13245](https://github.com/rubocop/rubocop/pull/13245): Support `filter/filter!` in `Style/CollectionCompact`. ([@masato-bkn][])
* [#13281](https://github.com/rubocop/rubocop/pull/13281): Support Ruby 3.4 for `Lint/UriRegexp` to avoid obsolete API. ([@koic][])
* [#13229](https://github.com/rubocop/rubocop/issues/13229): Update `Style/MapIntoArray` to be able to handle arrays created using `[].tap`. ([@dvandersluis][])
* [#13305](https://github.com/rubocop/rubocop/pull/13305): Update `Style/ReturnNilInPredicateMethodDefinition` to detect implicit `nil` returns inside `if`. ([@dvandersluis][])
* [#13327](https://github.com/rubocop/rubocop/pull/13327): Make server mode aware of auto-restart for .rubocop_todo.yml update. ([@koic][])

## 1.66.1 (2024-09-04)

### Bug fixes

* [#13191](https://github.com/rubocop/rubocop/pull/13191): Fix an error for `Style/IfWithSemicolon` when using nested single-line if/;/end in block of if/else branches. ([@koic][])
* [#13178](https://github.com/rubocop/rubocop/pull/13178): Fix false positive for `Style/EmptyLiteral` with `Hash.new([])`. ([@earlopain][])
* [#13176](https://github.com/rubocop/rubocop/issues/13176): Fix crash in `Style/EmptyElse` when `AllowComments: true` and the else clause is missing. ([@vlad-pisanov][])
* [#13185](https://github.com/rubocop/rubocop/pull/13185): Fix false negatives in `Style/MapIntoArray` autocorrection when using `ensure`, `def`, `defs` and `for`. ([@vlad-pisanov][])

## 1.66.0 (2024-08-31)

### New features

* [#13077](https://github.com/rubocop/rubocop/pull/13077): Add new global `StringLiteralsFrozenByDefault` option for correct analysis with `RUBYOPT=--enable=frozen-string-literal`. ([@earlopain][])
* [#13080](https://github.com/rubocop/rubocop/pull/13080): Add new `DocumentationExtension` global option to serve documentation with extensions different than `.html`. ([@earlopain][])
* [#13074](https://github.com/rubocop/rubocop/issues/13074): Add new `Lint/UselessNumericOperation` cop to check for inconsequential numeric operations. ([@zopolis4][])
* [#13061](https://github.com/rubocop/rubocop/issues/13061): Add new `Style/RedundantInterpolationUnfreeze` cop to check for `dup` and `@+` on interpolated strings in Ruby >= 3.0. ([@earlopain][])

### Bug fixes

* [#13093](https://github.com/rubocop/rubocop/issues/13093): Fix an error for `Lint/ImplicitStringConcatenation` when implicitly concatenating a string literal with a line break and string interpolation. ([@koic][])
* [#13098](https://github.com/rubocop/rubocop/issues/13098): Fix an error for `Style/IdenticalConditionalBranches` when handling empty case branches. ([@koic][])
* [#13113](https://github.com/rubocop/rubocop/pull/13113): Fix an error for `Style/IfWithSemicolon` when a nested `if` with a semicolon is used. ([@koic][])
* [#13097](https://github.com/rubocop/rubocop/issues/13097): Fix an error for `Style/InPatternThen` when using alternative pattern matching deeply. ([@koic][])
* [#13159](https://github.com/rubocop/rubocop/pull/13159): Fix an error for `Style/OneLineConditional` when using if/then/else/end with multiple expressions in the `then` body. ([@koic][])
* [#13092](https://github.com/rubocop/rubocop/pull/13092): Fix an incorrect autocorrect for `Layout/EmptyLineBetweenDefs` when two method definitions are on the same line separated by a semicolon. ([@koic][])
* [#13116](https://github.com/rubocop/rubocop/pull/13116): Fix an incorrect autocorrect for `Style/IfWithSemicolon` when a single-line `if/;/end` has an argument in the then body expression. ([@koic][])
* [#13161](https://github.com/rubocop/rubocop/pull/13161): Fix incorrect autocorrect for `Style/IfWithSemicolon` when using multiple expressions in the `else` body. ([@koic][])
* [#13132](https://github.com/rubocop/rubocop/pull/13132): Fix incorrect autocorrect for `Style/TrailingBodyOnMethodDefinition` when an expression precedes a method definition on the same line with a semicolon. ([@koic][])
* [#13164](https://github.com/rubocop/rubocop/pull/13164): Fix incorrect autocorrect behavior for `Layout/BlockAlignment` when `EnforcedStyleAlignWith: either (default)`. ([@koic][])
* [#13087](https://github.com/rubocop/rubocop/pull/13087): Fix an incorrect autocorrect for `Style/MultipleComparison` when expression with more comparisons precedes an expression with less comparisons. ([@fatkodima][])
* [#13172](https://github.com/rubocop/rubocop/pull/13172): Fix an error for `Layout/EmptyLinesAroundExceptionHandlingKeywords` when `ensure` or `else` and `end` are on the same line. ([@koic][])
* [#13107](https://github.com/rubocop/rubocop/issues/13107): Fix an error for `Lint/ImplicitStringConcatenation` when there are multiple adjacent string interpolation literals on the same line. ([@koic][])
* [#13111](https://github.com/rubocop/rubocop/pull/13111): Fix an error for `Style/GuardClause` when if clause is empty and correction would not fit on single line because of `Layout/LineLength`. ([@earlopain][])
* [#13137](https://github.com/rubocop/rubocop/pull/13137): Fix an error for `Style/ParallelAssignment` when using `__FILE__`. ([@earlopain][])
* [#13143](https://github.com/rubocop/rubocop/pull/13143): Fix an error during `TargetRubyVersion` detection if the gemspec is not valid syntax. ([@earlopain][])
* [#13131](https://github.com/rubocop/rubocop/pull/13131): Fix false negatives for `Lint/Void` when using `ensure`, `defs` and `numblock`. ([@vlad-pisanov][])
* [#13174](https://github.com/rubocop/rubocop/pull/13174): Fix false negatives for `Style/MapIntoArray` when initializing the destination using `Array[]`, `Array([])`, or `Array.new([])`. ([@vlad-pisanov][])
* [#13173](https://github.com/rubocop/rubocop/pull/13173): Fix false negatives for `Style/EmptyLiteral` when using `Array[]`, `Hash[]`, `Array.new([])` and `Hash.new([])`. ([@vlad-pisanov][])
* [#13126](https://github.com/rubocop/rubocop/issues/13126): Fix a false positive for `Style/Alias` when using multiple `alias` in `def`. ([@koic][])
* [#13085](https://github.com/rubocop/rubocop/issues/13085): Fix a false positive for `Style/EmptyElse` when a comment-only `else` is used after `elsif` and `AllowComments: true` is set. ([@koic][])
* [#13118](https://github.com/rubocop/rubocop/issues/13118): Fix a false positive for `Style/MapIntoArray` when splatting. ([@earlopain][])
* [#13105](https://github.com/rubocop/rubocop/issues/13105): Fix false positives for `Style/ArgumentsForwarding` when forwarding kwargs/block arg with non-matching additional args. ([@koic][])
* [#13139](https://github.com/rubocop/rubocop/issues/13139): Fix false positives for `Style/RedundantCondition` when using modifier `if` or `unless`. ([@koic][])
* [#13134](https://github.com/rubocop/rubocop/pull/13134): Fix false negative for `Lint/Void` when using using frozen literals. ([@vlad-pisanov][])
* [#13148](https://github.com/rubocop/rubocop/pull/13148): Fix incorrect autocorrect for `Lint/EmptyConditionalBody` when missing `elsif` body with `end` on the same line. ([@koic][])
* [#13109](https://github.com/rubocop/rubocop/pull/13109): Fix an error for the `Lockfile` parser when it contains incompatible `BUNDLED WITH` versions. ([@earlopain][])
* [#13112](https://github.com/rubocop/rubocop/pull/13112): Fix detection of `TargetRubyVersion` through the gemfile if the gemfile ruby version is below 2.7. ([@earlopain][])
* [#13155](https://github.com/rubocop/rubocop/pull/13155): Fixes an error when the server cache directory has too long path, causing rubocop to fail even with caching disabled. ([@protocol7][])

### Changes

* [#13150](https://github.com/rubocop/rubocop/issues/13150): Allow `get_!`, `set_!`, `get_?`, `set_?`, `get_=`, and `set_=` in `Naming/AccessorMethodName`. ([@koic][])
* [#13103](https://github.com/rubocop/rubocop/issues/13103): Make `Lint/UselessAssignment` autocorrection safe. ([@koic][])
* [#13099](https://github.com/rubocop/rubocop/issues/13099): Make `Style/RedundantRegexpArgument` respect the `EnforcedStyle` of `Style/StringLiterals`. ([@koic][])
* [#13165](https://github.com/rubocop/rubocop/pull/13165): Remove dependency on the `rexml` gem. ([@bquorning][])
* [#13090](https://github.com/rubocop/rubocop/pull/13090): Require RuboCop AST 1.32.0+ to use `RuboCop::AST::RationalNode`. ([@koic][])

## 1.65.1 (2024-08-01)

### New features

* [#13068](https://github.com/rubocop/rubocop/pull/13068): Add config validation to `Naming/PredicateName` to check that all `ForbiddenPrefixes` are being checked. ([@maxjacobson][])

### Bug fixes

* [#13051](https://github.com/rubocop/rubocop/issues/13051): Fix an error for `Lint/FloatComparison` when comparing with rational literal. ([@koic][])
* [#13065](https://github.com/rubocop/rubocop/issues/13065): Fix an error for `Lint/UselessAssignment` when same name variables are assigned using chained assignment. ([@koic][])
* [#13062](https://github.com/rubocop/rubocop/pull/13062): Fix an error for `Style/InvertibleUnlessCondition` when using empty parenthesis as condition. ([@earlopain][])
* [#11438](https://github.com/rubocop/rubocop/issues/11438): Explicitly load `fileutils` before calculating `before_us`. ([@r7kamura][])
* [#13044](https://github.com/rubocop/rubocop/issues/13044): Fix false negatives for `Lint/ImplicitStringConcatenation` when using adjacent string interpolation literals on the same line. ([@koic][])
* [#13083](https://github.com/rubocop/rubocop/pull/13083): Fix a false positive for `Style/GlobalStdStream` when using namespaced constants like `Foo::STDOUT`. ([@earlopain][])
* [#13081](https://github.com/rubocop/rubocop/pull/13081): Fix a false positive for `Style/ZeroLengthPredicate` when using safe navigation and non-zero comparison. ([@fatkodima][])
* [#13041](https://github.com/rubocop/rubocop/issues/13041): Fix false positives for `Lint/UselessAssignment` when pattern match variable is assigned and used in a block. ([@koic][])
* [#13076](https://github.com/rubocop/rubocop/issues/13076): Fix an incorrect autocorrect for `Naming/RescuedExceptionsVariableName` when using hash value omission. ([@koic][])

## 1.65.0 (2024-07-10)

### New features

* [#13030](https://github.com/rubocop/rubocop/pull/13030): Add new `Gemspec/AddRuntimeDependency` cop. ([@koic][])

### Bug fixes

* [#12954](https://github.com/rubocop/rubocop/issues/12954): Fix a false negative for `Style/ArgumentsForwarding` when arguments forwarding in `yield`. ([@koic][])
* [#13033](https://github.com/rubocop/rubocop/issues/13033): Fix a false positive for `Layout/SpaceAroundOperators` when using multiple spaces between an operator and a tailing comment. ([@koic][])
* [#12885](https://github.com/rubocop/rubocop/issues/12885): Fix a false positive for `Lint/ToEnumArguments` when enumerator is created for another method. ([@koic][])
* [#13018](https://github.com/rubocop/rubocop/issues/13018): Fix a false positive for `Style/MethodCallWithArgsParentheses` when `EnforcedStyle: omit_parentheses` is set and parenthesized method call is used before constant resolution. ([@koic][])
* [#12986](https://github.com/rubocop/rubocop/issues/12986): Fix a false positive for `Style/RedundantBegin` when endless method definition with `rescue`. ([@koic][])
* [#12985](https://github.com/rubocop/rubocop/issues/12985): Fix an error for `Style/RedundantRegexpCharacterClass` when using regexp_parser gem 2.3.1 or older. ([@koic][])
* [#13010](https://github.com/rubocop/rubocop/issues/13010): Fix an error for `Style/SuperArguments` when the hash argument is or-assigned. ([@koic][])
* [#13023](https://github.com/rubocop/rubocop/issues/13023): Fix an error for `Style/SymbolProc` when using lambda `->` with one argument and multiline `do`...`end` block. ([@koic][])
* [#12989](https://github.com/rubocop/rubocop/issues/12989): Fix an error for the `inherit_gem` config when the Gemfile contains an uninstalled git gem. ([@earlopain][])
* [#12975](https://github.com/rubocop/rubocop/issues/12975): Fix an error for the `inherit_gem` config when running RuboCop without bundler and no Gemfile exists. ([@earlopain][])
* [#12997](https://github.com/rubocop/rubocop/pull/12997): Fix an error for `Lint/UnmodifiedReduceAccumulator` when the block is empty. ([@earlopain][])
* [#12979](https://github.com/rubocop/rubocop/issues/12979): Fix false negatives for `Lint/Void` when void expression with guard clause is not on last line. ([@koic][])
* [#12716](https://github.com/rubocop/rubocop/issues/12716): Fix false negatives for `Lint/Void` when using parenthesized void operators. ([@koic][])
* [#12471](https://github.com/rubocop/rubocop/issues/12471): Fix false negatives for `Style/ZeroLengthPredicate` when using safe navigation operator. ([@koic][])
* [#12960](https://github.com/rubocop/rubocop/issues/12960): Fix false positives for `Lint/NestedMethodDefinition` when definition of method on variable. ([@koic][])
* [#13012](https://github.com/rubocop/rubocop/issues/13012): Fix false positives for `Style/HashExcept` when using `reject` and calling `include?` method with bang. ([@koic][])
* [#12983](https://github.com/rubocop/rubocop/issues/12983): Fix false positives for `Style/SendWithLiteralMethodName` using `send` with writer method name. ([@koic][])
* [#12957](https://github.com/rubocop/rubocop/issues/12957): Fix false positives for `Style/SuperArguments` when calling super in a block. ([@koic][])

### Changes

* [#12970](https://github.com/rubocop/rubocop/issues/12970): Add `CountModifierForms` option to `Metrics/BlockNesting` and set it to `false` by default. ([@koic][])
* [#13032](https://github.com/rubocop/rubocop/pull/13032): Display warning messages for deprecated APIs. ([@koic][])
* [#13031](https://github.com/rubocop/rubocop/pull/13031): Enable YJIT by default in server mode. ([@koic][])
* [#12557](https://github.com/rubocop/rubocop/issues/12557): Make server mode aware of auto-restart for `bundle update`. ([@koic][])
* [#12616](https://github.com/rubocop/rubocop/issues/12616): Make `Style/MapCompactWithConditionalBlock` aware of `filter_map`. ([@koic][])
* [#13035](https://github.com/rubocop/rubocop/issues/13035): Support autocorrect for `Lint/ImplicitStringConcatenation`. ([@koic][])

## 1.64.1 (2024-05-31)

### Bug fixes

* [#12951](https://github.com/rubocop/rubocop/pull/12951): Fix an error for `Style/Copyright` when `AutocorrectNotice` is missing. ([@koic][])
* [#12932](https://github.com/rubocop/rubocop/pull/12932): Fix end position of diagnostic for LSP. ([@ksss][])
* [#12926](https://github.com/rubocop/rubocop/issues/12926): Fix a false positive for `Style/SuperArguments` when the methods block argument is reassigned before `super`. ([@earlopain][])
* [#12931](https://github.com/rubocop/rubocop/issues/12931): Fix false positives for `Style/RedundantLineContinuation` when line continuations involve `break`, `next`, or `yield` with a return value. ([@koic][])
* [#12924](https://github.com/rubocop/rubocop/issues/12924): Fix false positives for `Style/SendWithLiteralMethodName` when `public_send` argument is a method name that cannot be autocorrected. ([@koic][])

## 1.64.0 (2024-05-23)

### New features

* [#12904](https://github.com/rubocop/rubocop/pull/12904): Add new `either_consistent` `SupportedShorthandSyntax` to `Style/HashSyntax`. ([@pawelma][])
* [#12842](https://github.com/rubocop/rubocop/issues/12842): Add new `Style/SendWithLiteralMethodName` cop. ([@koic][])
* [#12309](https://github.com/rubocop/rubocop/issues/12309): Add new `Style/SuperArguments` cop. ([@earlopain][])
* [#12917](https://github.com/rubocop/rubocop/pull/12917): Suggest correct formatter name for `--format` command line option. ([@koic][])
* [#12242](https://github.com/rubocop/rubocop/issues/12242): Support `AllowModifiersOnAttrs` option for `Style/AccessModifierDeclarations`. ([@krororo][])
* [#11585](https://github.com/rubocop/rubocop/issues/11585): Support `AllowedMethods` for `Style/DocumentationMethod`. ([@koic][])

### Bug fixes

* [#7189](https://github.com/rubocop/rubocop/issues/7189): Fix a false positive for `Style/Copyright` when using multiline copyright notice. ([@koic][])
* [#12914](https://github.com/rubocop/rubocop/pull/12914): Fix a false negative for `Layout/EmptyComment` when using an empty comment next to code after comment line. ([@koic][])
* [#12919](https://github.com/rubocop/rubocop/issues/12919): Fix false negatives for `Style/ArgumentsForwarding` when forward target is `super`. ([@koic][])
* [#12923](https://github.com/rubocop/rubocop/pull/12923): Fix false negatives for `Style/ArgumentsForwarding` when forward target is safe navigation method. ([@koic][])
* [#12894](https://github.com/rubocop/rubocop/issues/12894): Fix false positives for `Style/MapIntoArray` when using `each` without receiver with `<<` to build an array. ([@koic][])
* [#12876](https://github.com/rubocop/rubocop/issues/12876): Fix an error for the lockfile parser if a gemfile exists but a lockfile doesn't. ([@earlopain][])
* [#12888](https://github.com/rubocop/rubocop/issues/12888): Fix `--no-exclude-limit` generating a todo with `Max` config instead of listing everything out with `Exclude`. ([@earlopain][])
* [#12898](https://github.com/rubocop/rubocop/issues/12898): Fix an error for `TargetRailsVersion` when parsing from the lockfile with prerelease rails. ([@earlopain][])

### Changes

* [#12908](https://github.com/rubocop/rubocop/pull/12908): Add rubocop-rspec back to suggested extensions when rspec-rails is in use. ([@pirj][])
* [#12884](https://github.com/rubocop/rubocop/issues/12884): Align output from `cop.documentation_url` with `--show-docs-url` when passing a config as argument. ([@earlopain][])
* [#12905](https://github.com/rubocop/rubocop/pull/12905): Support `ActiveSupportExtensionsEnabled` for `Style/SymbolProc`. ([@koic][])
* [#12897](https://github.com/rubocop/rubocop/pull/12897): Respect user's intentions with `workspace/executeCommand` LSP method. ([@koic][])

## 1.63.5 (2024-05-09)

### Bug fixes

* [#12877](https://github.com/rubocop/rubocop/pull/12877): Fix an infinite loop error for `Layout/FirstArgumentIndentation` when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArrayAlignment`. ([@koic][])
* [#12873](https://github.com/rubocop/rubocop/issues/12873): Fix an error for `Metrics/BlockLength` when the `CountAsOne` config is invalid. ([@koic][])
* [#12881](https://github.com/rubocop/rubocop/pull/12881): Fix incorrect autocorrect when `Style/NumericPredicate` is used with negations. ([@fatkodima][])
* [#12882](https://github.com/rubocop/rubocop/pull/12882): Fix `Layout/CommentIndentation` for comment-only pattern matching. ([@nekketsuuu][])

## 1.63.4 (2024-04-28)

### Bug fixes

* [#12871](https://github.com/rubocop/rubocop/pull/12871): Fix an error for `rubocop -V` when `.rubocop.yml` contains ERB. ([@earlopain][])
* [#12862](https://github.com/rubocop/rubocop/issues/12862): Fix a false positive for `Style/RedundantLineContinuation` when line continuations involve `return` with a return value. ([@koic][])
* [#12664](https://github.com/rubocop/rubocop/pull/12664): Fix handling of `textDocument/diagnostic`. ([@muxcmux][])
* [#12865](https://github.com/rubocop/rubocop/issues/12865): Fix Rails Cops, which weren't reporting any violations unless running with `bundle exec`. ([@amomchilov][])

## 1.63.3 (2024-04-22)

### Bug fixes

* [#12857](https://github.com/rubocop/rubocop/pull/12857): Fix false negatives for `Lint/UnreachableCode` when using pattern matching. ([@koic][])
* [#12852](https://github.com/rubocop/rubocop/issues/12852): Fix an error for `Lint/EmptyFile` in formatters when using cache. ([@earlopain][])
* [#12848](https://github.com/rubocop/rubocop/issues/12848): Fix an error that occurs in `RuboCop::Lockfile` when the constant Bundler is uninitialized. ([@koic][])

### Changes

* [#12855](https://github.com/rubocop/rubocop/pull/12855): Set custom program name for the built-in LSP server. ([@koic][])

## 1.63.2 (2024-04-16)

### Bug fixes

* [#12843](https://github.com/rubocop/rubocop/issues/12843): Fix an error for `Lint/MixedCaseRange` when a character between `Z` and `a` is used in the regexp range. ([@koic][])
* [#12846](https://github.com/rubocop/rubocop/issues/12846): Fix an error for `RuboCop::Lockfile` when there is no Bundler environment. ([@koic][])
* [#12832](https://github.com/rubocop/rubocop/issues/12832): Fix an error for `Style/ArgumentsForwarding` when using block arg in nested method definitions. ([@koic][])
* [#12841](https://github.com/rubocop/rubocop/pull/12841): Fix false negatives for `Lint/UnreachableLoop` when using pattern matching. ([@koic][])
* [#12835](https://github.com/rubocop/rubocop/issues/12835): Allow global offenses to be disabled by directive comments. ([@earlopain][])

### Changes

* [#12845](https://github.com/rubocop/rubocop/pull/12845): Exclude `debug/open_nonstop` from `Lint/Debugger` by default. ([@koic][])

## 1.63.1 (2024-04-10)

### Bug fixes

* [#12828](https://github.com/rubocop/rubocop/pull/12828): Fix a false positive for `Lint/AssignmentInCondition` if assigning inside a method call. ([@earlopain][])
* [#12823](https://github.com/rubocop/rubocop/issues/12823): Fixed "uninitialized constant `RuboCop::Lockfile::Bundler`", caused when running RuboCop without `bundler exec` on codebases that use `rubocop-rails`. ([@amomchilov][])

## 1.63.0 (2024-04-08)

### New features

* [#11878](https://github.com/rubocop/rubocop/issues/11878): Add new `Style/MapIntoArray` cop. ([@ymap][])
* [#12186](https://github.com/rubocop/rubocop/pull/12186): Add new `requires_gem` API for declaring which gems a Cop needs. ([@amomchilov][])

### Bug fixes

* [#12769](https://github.com/rubocop/rubocop/issues/12769): Fix a false positive for `Lint/RedundantWithIndex` when calling `with_index` with receiver and a block. ([@koic][])
* [#12547](https://github.com/rubocop/rubocop/issues/12547): Added a comment recommending upgrading to the latest version of Rubocop in the error text when an Infinite loop detected error occurs. ([@Hiroto-Iizuka][])
* [#12782](https://github.com/rubocop/rubocop/pull/12782): Fix an error for `Style/Alias` with `EnforcedStyle: prefer_alias` when calling `alias_method` with fewer than 2 arguments. ([@earlopain][])
* [#12781](https://github.com/rubocop/rubocop/pull/12781): Fix an error for `Style/ExactRegexpMatch` when calling `match` without a receiver. ([@earlopain][])
* [#12780](https://github.com/rubocop/rubocop/issues/12780): Fix an error for `Style/RedundantEach` when using `reverse_each.each` without a block. ([@earlopain][])
* [#12731](https://github.com/rubocop/rubocop/pull/12731): Treat `&.` the same way as `.` for setter methods in `Lint/AssignmentInCondition`. ([@jonas054][])
* [#12793](https://github.com/rubocop/rubocop/issues/12793): Fix false positives for `Style/RedundantLineContinuation` when using line continuation with modifier. ([@koic][])
* [#12807](https://github.com/rubocop/rubocop/issues/12807): Fix false positives for `Naming/BlockForwarding` when using explicit block forwarding in block method and others. ([@koic][])
* [#12796](https://github.com/rubocop/rubocop/pull/12796): Fix false positives for `Style/EvalWithLocation` when using `eval` with a line number from a method call or a variable. ([@koic][])
* [#12794](https://github.com/rubocop/rubocop/issues/12794): Fix false positives for `Style/RedundantArgument` when when single-quoted strings for cntrl character. ([@koic][])
* [#12797](https://github.com/rubocop/rubocop/issues/12797): Fix false positives for `Style/RedundantLineContinuation` when using line continuations with `&&` or `||` operator in assignment. ([@koic][])
* [#12793](https://github.com/rubocop/rubocop/issues/12793): Fix false positives for `Style/RedundantLineContinuation` when multi-line continuations with operators. ([@koic][])
* [#12801](https://github.com/rubocop/rubocop/issues/12801): Fix incorrect autocorrect for `Style/CollectionCompact` when using `delete_if`. ([@koic][])
* [#12789](https://github.com/rubocop/rubocop/pull/12789): Make `Style/RedundantPercentQ` safe on multiline strings. ([@boardfish][])
* [#12802](https://github.com/rubocop/rubocop/pull/12802): Return global offenses for `Naming/FileName` and `Naming/InclusiveLanguage` for empty files. ([@earlopain][])
* [#12804](https://github.com/rubocop/rubocop/pull/12804): Return global offenses for `Style/Copyright` when the file is empty. ([@earlopain][])

### Changes

* [#12813](https://github.com/rubocop/rubocop/pull/12813): Add rubocop-rspec_rails to suggested extensions and extension doc. ([@ydah][])
* [#12820](https://github.com/rubocop/rubocop/pull/12820): Add support more Capybara debugger entry points for `Lint/Debugger`. ([@ydah][])
* [#12676](https://github.com/rubocop/rubocop/issues/12676): Adjust offending range in LSP. ([@koic][])
* [#12815](https://github.com/rubocop/rubocop/issues/12815): Ignore `Rakefile.rb` in `Naming/FileName` in the default config. ([@artur-intech][])
* [#12800](https://github.com/rubocop/rubocop/pull/12800): Handle empty obsoletion config. ([@sambostock][])
* [#12721](https://github.com/rubocop/rubocop/issues/12721): Make `Lint/Debugger` aware of `ruby/debug` requires. ([@earlopain][])
* [#12817](https://github.com/rubocop/rubocop/pull/12817): Make `rubocop -V` display rubocop-rspec_rails version when using it. ([@ydah][])
* [#12180](https://github.com/rubocop/rubocop/pull/12180): Replace regex with `Bundler::LockfileParser`. ([@amomchilov][])

## 1.62.1 (2024-03-11)

### Bug fixes

* [#12761](https://github.com/rubocop/rubocop/issues/12761): Fix a false positive for `Style/HashEachMethods` when the key block argument of `Enumerable#each` method is unused after `chunk`. ([@koic][])
* [#12768](https://github.com/rubocop/rubocop/pull/12768): Fix a false positive for `Style/NilComparison` without receiver and `EnforcedStyle: comparison`. ([@earlopain][])
* [#12752](https://github.com/rubocop/rubocop/pull/12752): Fix an error for `Gemspec/RequiredRubyVersion` when the file is empty. ([@earlopain][])
* [#12770](https://github.com/rubocop/rubocop/pull/12770): Fix an error for `Lint/RedundantWithIndex` when the method has no receiver. ([@earlopain][])
* [#12775](https://github.com/rubocop/rubocop/pull/12775): Fix an error for `Lint/UselessTimes` when no block is present. ([@earlopain][])
* [#12772](https://github.com/rubocop/rubocop/pull/12772): Fix an error for `Style/ClassVars` when calling `class_variable_set` without arguments. ([@earlopain][])
* [#12773](https://github.com/rubocop/rubocop/pull/12773): Fix an error for `Style/For` with `EnforcedStyle: for` when no receiver. ([@earlopain][])
* [#12765](https://github.com/rubocop/rubocop/pull/12765): Fix an error for `Layout/MultilineMethodCallIndentation` with safe navigation and assignment method. ([@earlopain][])
* [#12703](https://github.com/rubocop/rubocop/issues/12703): Fix an error for `Lint/MixedCaseRange` with invalid byte sequence in UTF-8. ([@earlopain][])
* [#12755](https://github.com/rubocop/rubocop/pull/12755): Fix an exception for `RedundantCurrentDirectoryInPath` in case of `require_relative` without arguments. ([@viralpraxis][])
* [#12710](https://github.com/rubocop/rubocop/issues/12710): Fix a false negative for `Layout/EmptyLineAfterMagicComment` when the file is comments only. ([@earlopain][])
* [#12758](https://github.com/rubocop/rubocop/issues/12758): Fix false positives for `Layout/RedundantLineBreak` when using `&&` or `||` after a backslash newline. ([@koic][])
* [#12763](https://github.com/rubocop/rubocop/pull/12763): Fix an infinite loop for `Style/MultilineMethodSignature` when there is a newline directly after the def keyword. ([@earlopain][])
* [#12774](https://github.com/rubocop/rubocop/pull/12774): Fix an infinite loop for `Style/RaiseArgs` with `EnforcedStyle: compact` when passing more than 2 arguments to `raise`. ([@earlopain][])
* [#12663](https://github.com/rubocop/rubocop/issues/12663): Fix `Lint/Syntax` getting disabled by `rubocop:disable Lint/Syntax`. ([@earlopain][])
* [#12756](https://github.com/rubocop/rubocop/pull/12756): Only parse target Ruby from gemspec if array elements are strings. ([@davidrunger][])

### Changes

* [#12730](https://github.com/rubocop/rubocop/pull/12730): Skip `LineLength` phase on `--auto-gen-only-exclude`. ([@sambostock][])

## 1.62.0 (2024-03-06)

### New features

* [#12600](https://github.com/rubocop/rubocop/issues/12600): Support Prism as a Ruby parser (experimental). ([@koic][])
* [#12725](https://github.com/rubocop/rubocop/pull/12725): Support `TargetRubyVersion 3.4` (experimental). ([@koic][])

### Bug fixes

* [#12746](https://github.com/rubocop/rubocop/pull/12746): Fix a false positive for `Lint/ToEnumArguments` when enumerator is created for another method in no arguments method definition. ([@koic][])
* [#12726](https://github.com/rubocop/rubocop/issues/12726): Fix a false positive for `Style/RedundantLineContinuation` when using line concatenation and calling a method with keyword arguments without parentheses. ([@koic][])
* [#12738](https://github.com/rubocop/rubocop/issues/12738): Fix an error for `Style/Encoding` when magic encoding with mixed case present. ([@koic][])
* [#12732](https://github.com/rubocop/rubocop/pull/12732): Fix error determining target Ruby when gemspec `required_ruby_version` is read from another file. ([@davidrunger][])
* [#12736](https://github.com/rubocop/rubocop/issues/12736): Fix invalid autocorrect in `Layout/SpaceInsideHashLiteralBraces`. ([@bquorning][])
* [#12667](https://github.com/rubocop/rubocop/issues/12667): Don't load excluded configuration. ([@jonas054][])

## 1.61.0 (2024-02-29)

### New features

* [#12682](https://github.com/rubocop/rubocop/issues/12682): Add `--editor-mode` CLI option. ([@koic][])
* [#12657](https://github.com/rubocop/rubocop/pull/12657): Support `AutoCorrect: contextual` option for LSP. ([@koic][])
* [#12273](https://github.com/rubocop/rubocop/issues/12273): Make `OffenseCountFormatter` display autocorrection information. ([@koic][])
* [#12679](https://github.com/rubocop/rubocop/pull/12679): Publish `RuboCop::LSP.enable` API to enable LSP mode. ([@koic][])
* [#12699](https://github.com/rubocop/rubocop/issues/12699): Support searching for `.rubocop.yml` and `rubocop/config.yml` in compliance with dot-config. ([@koic][])

### Bug fixes

* [#12720](https://github.com/rubocop/rubocop/issues/12720): Fix a false positive for `Style/ArgumentsForwarding` when using block arg forwarding to within block with Ruby 3.3.0. ([@koic][])
* [#12714](https://github.com/rubocop/rubocop/issues/12714): Fix an error for `Gemspec/RequiredRubyVersion` when `required_ruby_version` is specified with `Gem::Requirement.new` and is higher than `TargetRubyVersion`. ([@koic][])
* [#12690](https://github.com/rubocop/rubocop/issues/12690): Fix an error for `Style/CaseLikeIf` when using `==` with literal and using ternary operator. ([@koic][])
* [#12668](https://github.com/rubocop/rubocop/issues/12668): Fix an incorrect autocorrect for `Lint/EmptyConditionalBody` when missing `if` body with conditional `else` body. ([@koic][])
* [#12683](https://github.com/rubocop/rubocop/issues/12683): Fix an incorrect autocorrect for `Style/MapCompactWithConditionalBlock` when using guard clause with `next` implicitly nil. ([@koic][])
* [#12693](https://github.com/rubocop/rubocop/issues/12693): Fix an incorrect autocorrect for `Style/ObjectThen` when using `yield_self` without receiver. ([@koic][])
* [#12646](https://github.com/rubocop/rubocop/issues/12646): Fix `--auto-gen-config` bug for `Layout/SpaceBeforeBlockBraces`. ([@jonas054][])
* [#12717](https://github.com/rubocop/rubocop/issues/12717): Fix regexp for inline disable comments in `Style/CommentedKeyword`. ([@jonas054][])
* [#12695](https://github.com/rubocop/rubocop/issues/12695): Fix bug in `Include` from inherited file in a parent directory. ([@jonas054][])
* [#12656](https://github.com/rubocop/rubocop/pull/12656): Fix an error for `Layout/RedundantLineBreak` when using index access call chained on multiline hash literal. ([@koic][])
* [#12691](https://github.com/rubocop/rubocop/issues/12691): Fix an error for `Style/MultilineTernaryOperator` when nesting multiline ternary operators. ([@koic][])
* [#12707](https://github.com/rubocop/rubocop/pull/12707): Fix false negative for `Style/RedundantAssignment` when using pattern matching. ([@koic][])
* [#12674](https://github.com/rubocop/rubocop/pull/12674): Fix false negatives for `Style/RedundantReturn` when using pattern matching. ([@koic][])
* [#12673](https://github.com/rubocop/rubocop/pull/12673): Fix false negatives for `Lint/RedundantSafeNavigation` when using safe navigation operator for literal receiver. ([@koic][])
* [#12719](https://github.com/rubocop/rubocop/pull/12719): Fix false negatives for `Style/ArgumentsForwarding` when using forwardable block arguments with Ruby 3.2+. ([@koic][])
* [#12687](https://github.com/rubocop/rubocop/issues/12687): Fix a false positive for `Lint/Void` when `each` block with conditional expressions that has multiple statements. ([@koic][])
* [#12649](https://github.com/rubocop/rubocop/issues/12649): Fix false positives for `Style/InverseMethods` when using relational comparison operator with safe navigation. ([@koic][])
* [#12711](https://github.com/rubocop/rubocop/pull/12711): Handle implicit receivers in `Style/InvertibleUnlessCondition`. ([@sambostock][])
* [#12648](https://github.com/rubocop/rubocop/pull/12648): Fix numblock regressions in `omit_parentheses` `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])

### Changes

* [#12641](https://github.com/rubocop/rubocop/pull/12641): Make error message clearer when the namespace is incorrect. ([@maruth-stripe][])
* [#12637](https://github.com/rubocop/rubocop/pull/12637): Mark `Style/RaiseArgs` as unsafe. ([@r7kamura][])
* [#12645](https://github.com/rubocop/rubocop/pull/12645): Change source order for target ruby to check gemspec after RuboCop configuration. ([@jenshenny][])

## 1.60.2 (2024-01-24)

### Bug fixes

* [#12627](https://github.com/rubocop/rubocop/issues/12627): Fix a false positive for `Layout/RedundantLineBreak` when using index access call chained on multiple lines with backslash. ([@koic][])
* [#12626](https://github.com/rubocop/rubocop/pull/12626): Fix a false positive for `Style/ArgumentsForwarding` when naming a block argument `&`. ([@koic][])
* [#12635](https://github.com/rubocop/rubocop/pull/12635): Fix a false positive for `Style/HashEachMethods` when both arguments are unused. ([@earlopain][])
* [#12636](https://github.com/rubocop/rubocop/pull/12636): Fix an error for `Style/HashEachMethods` when a block with both parameters has no body. ([@earlopain][])
* [#12638](https://github.com/rubocop/rubocop/issues/12638): Fix an `Errno::ENOENT` error when using server mode. ([@koic][])
* [#12628](https://github.com/rubocop/rubocop/pull/12628): Fix a false positive for `Style/ArgumentsForwarding` when using block arg forwarding with positional arguments forwarding to within block. ([@koic][])
* [#12642](https://github.com/rubocop/rubocop/pull/12642): Fix false positives for `Style/HashEachMethods` when using array converter method. ([@koic][])
* [#12632](https://github.com/rubocop/rubocop/issues/12632): Fix an infinite loop error when `EnforcedStyle: explicit` of `Naming/BlockForwarding` with `Style/ArgumentsForwarding`. ([@koic][])

## 1.60.1 (2024-01-17)

### Bug fixes

* [#12625](https://github.com/rubocop/rubocop/pull/12625): Fix an error when server cache dir has read-only file system. ([@Strzesia][])
* [#12618](https://github.com/rubocop/rubocop/issues/12618): Fix false positives for `Style/ArgumentsForwarding` when using block argument forwarding with other arguments. ([@koic][])
* [#12614](https://github.com/rubocop/rubocop/issues/12614): Fix false positiveis for `Style/RedundantParentheses` when parentheses in control flow keyword with multiline style argument. ([@koic][])

### Changes

* [#12617](https://github.com/rubocop/rubocop/issues/12617): Make `Style/CollectionCompact` aware of `grep_v` with nil. ([@koic][])

## 1.60.0 (2024-01-15)

### Bug fixes

* [#12603](https://github.com/rubocop/rubocop/issues/12603): Fix an infinite loop error for `Style/MultilineTernaryOperator` when using a method call as a ternary operator condition with a line break between receiver and method. ([@koic][])
* [#12549](https://github.com/rubocop/rubocop/issues/12549): Fix a false positive for `Style/RedundantLineContinuation` when line continuations for multiline leading dot method chain with a blank line. ([@koic][])
* [#12610](https://github.com/rubocop/rubocop/pull/12610): Accept parentheses in argument calls with blocks for `Style/MethodCallWithArgsParentheses` `omit_parentheses` style. ([@gsamokovarov][])
* [#12580](https://github.com/rubocop/rubocop/pull/12580): Fix an infinite loop error for `Layout/EndAlignment` when misaligned in singleton class assignments with `EnforcedStyleAlignWith: variable`. ([@koic][])
* [#12548](https://github.com/rubocop/rubocop/issues/12548): Fix an infinite loop error for `Layout/FirstArgumentIndentation` when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArrayAlignment`. ([@koic][])
* [#12236](https://github.com/rubocop/rubocop/issues/12236): Fix an error for `Lint/ShadowedArgument` when self assigning to a block argument in `for`. ([@koic][])
* [#12569](https://github.com/rubocop/rubocop/issues/12569): Fix an error for `Style/IdenticalConditionalBranches` when using `if`...`else` with identical leading lines that assign to `self.foo`. ([@koic][])
* [#12437](https://github.com/rubocop/rubocop/issues/12437): Fix an infinite loop error for `EnforcedStyle: omit_parentheses` of `Style/MethodCallWithArgsParentheses` with `Style/SuperWithArgsParentheses`. ([@koic][])
* [#12558](https://github.com/rubocop/rubocop/issues/12558): Fix an incorrect autocorrect for `Style/MapToHash` when using `map.to_h` without receiver. ([@koic][])
* [#12179](https://github.com/rubocop/rubocop/issues/12179): Let `--auto-gen-config` generate `Exclude` when `Max` is overridden. ([@jonas054][])
* [#12574](https://github.com/rubocop/rubocop/issues/12574): Fix bug for unrecognized style in --auto-gen-config. ([@jonas054][])
* [#12542](https://github.com/rubocop/rubocop/issues/12542): Fix false positive for `Lint/MixedRegexpCaptureTypes` when using look-ahead matcher. ([@marocchino][])
* [#12607](https://github.com/rubocop/rubocop/pull/12607): Fix a false positive for `Style/RedundantParentheses` when regexp literal attempts to match against a parenthesized condition. ([@koic][])
* [#12539](https://github.com/rubocop/rubocop/pull/12539): Fix false positives for `Lint/LiteralAssignmentInCondition` when a collection literal contains non-literal elements. ([@koic][])
* [#12571](https://github.com/rubocop/rubocop/issues/12571): Fix false positives for `Naming/BlockForwarding` when using explicit block forwarding in block method. ([@koic][])
* [#12537](https://github.com/rubocop/rubocop/issues/12537): Fix false positives for `Style/RedundantParentheses` when `AllowInMultilineConditions: true` of `Style/ParenthesesAroundCondition`. ([@koic][])
* [#12578](https://github.com/rubocop/rubocop/pull/12578): Fix false positives for `Style/ArgumentsForwarding` when rest arguments forwarding to a method in block. ([@koic][])
* [#12540](https://github.com/rubocop/rubocop/issues/12540): Fix false positives for `Style/HashEachMethods` when rest block argument of `Enumerable#each` method is used. ([@koic][])
* [#12529](https://github.com/rubocop/rubocop/issues/12529): Fix false positives for `Style/ParenthesesAroundCondition`. ([@koic][])
* [#12556](https://github.com/rubocop/rubocop/issues/12556): Fix false positives for `Style/RedundantParentheses` when parentheses are used around a semantic operator in expressions within assignments. ([@koic][])
* [#12541](https://github.com/rubocop/rubocop/pull/12541): Fix false negative in `Style/ArgumentsForwarding` when a block is forwarded but other args aren't. ([@dvandersluis][])
* [#12581](https://github.com/rubocop/rubocop/pull/12581): Handle trailing line continuation in `Layout/LineContinuationLeadingSpace`. ([@eugeneius][])
* [#12601](https://github.com/rubocop/rubocop/issues/12601): Make `Style/EachForSimpleLoop` accept block with no parameters. ([@koic][])

### Changes

* [#12535](https://github.com/rubocop/rubocop/pull/12535): Allow --autocorrect with --display-only-fail-level-offenses. ([@naveg][])
* [#12572](https://github.com/rubocop/rubocop/pull/12572): Follow a Ruby 3.3 warning for `Security/Open` when `open` with a literal string starting with a pipe. ([@koic][])
* [#12453](https://github.com/rubocop/rubocop/issues/12453): Make `Style/RedundantEach` aware of safe navigation operator. ([@koic][])
* [#12233](https://github.com/rubocop/rubocop/issues/12233): Make `Style/SlicingWithRange` aware of redundant and beginless range. ([@koic][])
* [#12388](https://github.com/rubocop/rubocop/pull/12388): Reject additional 'expanded' `EnforcedStyle` options when `--no-auto-gen-enforced-style` is given. ([@kpost][])
* [#12593](https://github.com/rubocop/rubocop/pull/12593): Require Parser 3.3.0.2 or higher. ([@koic][])

## 1.59.0 (2023-12-11)

### New features

* [#12518](https://github.com/rubocop/rubocop/pull/12518): Add new `Lint/ItWithoutArgumentsInBlock` cop. ([@koic][])

### Bug fixes

* [#12434](https://github.com/rubocop/rubocop/issues/12434): Fix a false positive for `Lint/LiteralAssignmentInCondition` when using interpolated string or xstring literals. ([@koic][])
* [#12435](https://github.com/rubocop/rubocop/issues/12435): Fix a false positive for `Lint/SelfAssignment` when using attribute assignment with method call with arguments. ([@koic][])
* [#12444](https://github.com/rubocop/rubocop/issues/12444): Fix false positive for `Style/HashEachMethods` when receiver literal is not a hash literal. ([@koic][])
* [#12524](https://github.com/rubocop/rubocop/issues/12524): Fix a false positive for `Style/MethodCallWithArgsParentheses` when `EnforcedStyle: omit_parentheses` and parens in `when` clause is used to pass an argument. ([@koic][])
* [#12505](https://github.com/rubocop/rubocop/pull/12505): Fix a false positive for `Style/RedundantParentheses` when using parenthesized `lambda` or `proc` with `do`...`end` block. ([@koic][])
* [#12442](https://github.com/rubocop/rubocop/issues/12442): Fix an incorrect autocorrect for `Style/CombinableLoops` when looping over the same data as previous loop in `do`...`end` and `{`...`}` blocks. ([@koic][])
* [#12432](https://github.com/rubocop/rubocop/pull/12432): Fix a false positive for `Lint/LiteralAssignmentInCondition` when using parallel assignment with splat operator in block of guard condition. ([@koic][])
* [#12441](https://github.com/rubocop/rubocop/issues/12441): Fix false positives for `Style/HashEachMethods` when using destructed block arguments. ([@koic][])
* [#12436](https://github.com/rubocop/rubocop/issues/12436): Fix false positives for `Style/RedundantParentheses` when a part of range is a parenthesized condition. ([@koic][])
* [#12429](https://github.com/rubocop/rubocop/issues/12429): Fix incorrect autocorrect for `Style/MapToHash` when using dot method calls for `to_h`. ([@koic][])
* [#12488](https://github.com/rubocop/rubocop/issues/12488): Make `Lint/HashCompareByIdentity` aware of safe navigation operator. ([@koic][])
* [#12489](https://github.com/rubocop/rubocop/issues/12489): Make `Lint/NextWithoutAccumulator` aware of safe navigation operator. ([@koic][])
* [#12490](https://github.com/rubocop/rubocop/issues/12490): Make `Lint/NumberConversion` aware of safe navigation operator. ([@koic][])
* [#12491](https://github.com/rubocop/rubocop/issues/12491): Make `Lint/RedundantWithIndex` aware of safe navigation operator. ([@koic][])
* [#12492](https://github.com/rubocop/rubocop/issues/12492): Make `Lint/RedundantWithObject` aware of safe navigation operator. ([@koic][])
* [#12493](https://github.com/rubocop/rubocop/issues/12493): Make `Lint/UnmodifiedReduceAccumulator` aware of safe navigation operator. ([@koic][])
* [#12473](https://github.com/rubocop/rubocop/issues/12473): Make `Style/ClassCheck` aware of safe navigation operator. ([@koic][])
* [#12445](https://github.com/rubocop/rubocop/issues/12445): Make `Style/CollectionCompact` aware of safe navigation operator. ([@koic][])
* [#12474](https://github.com/rubocop/rubocop/issues/12474): Make `Style/ConcatArrayLiterals` aware of safe navigation operator. ([@koic][])
* [#12476](https://github.com/rubocop/rubocop/issues/12476): Make `Style/DateTime` aware of safe navigation operator. ([@koic][])
* [#12479](https://github.com/rubocop/rubocop/issues/12479): Make `Style/EachWithObject` aware of safe navigation operator. ([@koic][])
* [#12446](https://github.com/rubocop/rubocop/issues/12446): Make `Style/HashExcept` aware of safe navigation operator. ([@koic][])
* [#12447](https://github.com/rubocop/rubocop/issues/12447): Make `Style/MapCompactWithConditionalBlock` aware of safe navigation operator. ([@koic][])
* [#12484](https://github.com/rubocop/rubocop/issues/12484): Make `Style/Next` aware of safe navigation operator. ([@koic][])
* [#12486](https://github.com/rubocop/rubocop/issues/12486): Make `Style/RedundantArgument` aware of safe navigation operator. ([@koic][])
* [#12454](https://github.com/rubocop/rubocop/issues/12454): Make `Style/RedundantFetchBlock` aware of safe navigation operator. ([@koic][])
* [#12495](https://github.com/rubocop/rubocop/issues/12495): Make `Layout/RedundantLineBreak` aware of safe navigation operator. ([@koic][])
* [#12455](https://github.com/rubocop/rubocop/issues/12455): Make `Style/RedundantSortBy` aware of safe navigation operator. ([@koic][])
* [#12456](https://github.com/rubocop/rubocop/issues/12456): Make `Style/RedundantSortBy` aware of safe navigation operator. ([@koic][])
* [#12480](https://github.com/rubocop/rubocop/issues/12480): Make `Style/ExactRegexpMatch` aware of safe navigation operator. ([@koic][])
* [#12457](https://github.com/rubocop/rubocop/issues/12457): Make `Style/Sample` aware of safe navigation operator. ([@koic][])
* [#12458](https://github.com/rubocop/rubocop/issues/12458): Make `Style/SelectByRegexp` cops aware of safe navigation operator. ([@koic][])
* [#12494](https://github.com/rubocop/rubocop/issues/12494): Make `Layout/SingleLineBlockChain` aware of safe navigation operator. ([@koic][])
* [#12461](https://github.com/rubocop/rubocop/issues/12461): Make `Style/StringChars` aware of safe navigation operator. ([@koic][])
* [#12468](https://github.com/rubocop/rubocop/issues/12468): Make `Style/Strip` aware of safe navigation operator. ([@koic][])
* [#12469](https://github.com/rubocop/rubocop/issues/12469): Make `Style/UnpackFirst` aware of safe navigation operator. ([@koic][])

### Changes

* [#12522](https://github.com/rubocop/rubocop/pull/12522): Make `Style/MethodCallWithoutArgsParentheses` allow the parenthesized `it` method in a block. ([@koic][])
* [#12523](https://github.com/rubocop/rubocop/pull/12523): Make `Style/RedundantSelf` allow the `self.it` method in a block. ([@koic][])

## 1.58.0 (2023-12-01)

### New features

* [#12420](https://github.com/rubocop/rubocop/pull/12420): Add new `Lint/LiteralAssignmentInCondition` cop. ([@koic][])
* [#12353](https://github.com/rubocop/rubocop/issues/12353): Add new `Style/SuperWithArgsParentheses` cop. ([@koic][])
* [#12406](https://github.com/rubocop/rubocop/issues/12406): Add new `Style/ArrayFirstLast` cop. ([@fatkodima][])

### Bug fixes

* [#12372](https://github.com/rubocop/rubocop/issues/12372): Fix a false negative for `Lint/Debugger` when used within method arguments a `begin`...`end` block. ([@koic][])
* [#12378](https://github.com/rubocop/rubocop/pull/12378): Fix a false negative for `Style/Semicolon` when a semicolon at the beginning of a lambda block. ([@koic][])
* [#12146](https://github.com/rubocop/rubocop/issues/12146): Fix a false positive for `Lint/FloatComparison` when comparing against zero. ([@earlopain][])
* [#12404](https://github.com/rubocop/rubocop/issues/12404): Fix a false positive for `Layout/RescueEnsureAlignment` when aligned `rescue` in `do`-`end` numbered block in a method. ([@koic][])
* [#12374](https://github.com/rubocop/rubocop/issues/12374): Fix a false positive for `Layout/SpaceBeforeSemicolon` when a space between an opening lambda brace and a semicolon. ([@koic][])
* [#12326](https://github.com/rubocop/rubocop/pull/12326): Fix an error for `Style/RedundantDoubleSplatHashBraces` when method call for parenthesized no hash double double splat. ([@koic][])
* [#12361](https://github.com/rubocop/rubocop/issues/12361): Fix an incorrect autocorrect for `Naming/BlockForwarding` and `Style/ArgumentsForwarding` when autocorrection conflicts for anonymous arguments. ([@koic][])
* [#12324](https://github.com/rubocop/rubocop/issues/12324): Fix an error for `Layout/RescueEnsureAlignment` when using `rescue` in `do`...`end` block assigned to object attribute. ([@koic][])
* [#12322](https://github.com/rubocop/rubocop/issues/12322): Fix an error for `Style/CombinableLoops` when looping over the same data for the third consecutive time or more. ([@koic][])
* [#12366](https://github.com/rubocop/rubocop/pull/12366): Fix a false negative for `Layout/ExtraSpacing` when a file has exactly two comments. ([@eugeneius][])
* [#12373](https://github.com/rubocop/rubocop/issues/12373): Fix a false negative for `Lint/SymbolConversion` when using string interpolation. ([@earlopain][])
* [#12402](https://github.com/rubocop/rubocop/issues/12402): Fix false negatives for `Style/RedundantLineContinuation` when redundant line continuations for a block are used, especially without parentheses around first argument. ([@koic][])
* [#12311](https://github.com/rubocop/rubocop/issues/12311): Fix false negatives for `Style/RedundantParentheses` when parentheses around logical operator keywords in method definition. ([@koic][])
* [#12394](https://github.com/rubocop/rubocop/issues/12394): Fix false negatives for `Style/RedundantReturn` when `lambda` (`->`) ending with `return`. ([@koic][])
* [#12377](https://github.com/rubocop/rubocop/issues/12377): Fix false positives for `Lint/Void` when a collection literal that includes non-literal elements in a method definition. ([@koic][])
* [#12407](https://github.com/rubocop/rubocop/pull/12407): Fix an incorrect autocorrect for `Style/MapToHash` with `Layout/SingleLineBlockChain`. ([@koic][])
* [#12409](https://github.com/rubocop/rubocop/issues/12409): Fix an incorrect autocorrect for `Lint/SafeNavigationChain` when ordinary method chain exists after safe navigation leading dot method call. ([@koic][])
* [#12363](https://github.com/rubocop/rubocop/issues/12363): Fix incorrect rendering of HTML character entities in `HTMLFormatter` formatter. ([@koic][])
* [#12424](https://github.com/rubocop/rubocop/issues/12424): Make `Style/HashEachMethods` aware of safe navigation operator. ([@koic][])
* [#12413](https://github.com/rubocop/rubocop/issues/12413): Make `Style/InverseMethods` aware of safe navigation operator. ([@koic][])
* [#12408](https://github.com/rubocop/rubocop/pull/12408): Make `Style/MapToHash` aware of safe navigation operator. ([@koic][])

### Changes

* [#12328](https://github.com/rubocop/rubocop/issues/12328): Make `Style/AutoResourceCleanup` aware of `Tempfile.open`. ([@koic][])
* [#12412](https://github.com/rubocop/rubocop/issues/12412): Enhance `Lint/RedundantSafeNavigation` to handle conversion methods with defaults. ([@fatkodima][])
* [#12410](https://github.com/rubocop/rubocop/issues/12410): Enhance `Lint/SelfAssignment` to check attribute assignment and key assignment. ([@fatkodima][])
* [#12370](https://github.com/rubocop/rubocop/issues/12370): Make `Style/HashEachMethods` aware of unused block value. ([@koic][])
* [#12380](https://github.com/rubocop/rubocop/issues/12380): Make `Style/RedundantParentheses` aware of lambda or proc. ([@koic][])
* [#12421](https://github.com/rubocop/rubocop/pull/12421): Make `Style/SelfAssignment` aware of `%`, `^`, `<<`, and `>>` operators. ([@koic][])
* [#12305](https://github.com/rubocop/rubocop/pull/12305): Require `rubocop-ast` version 1.30 or greater. ([@sambostock][])
* [#12337](https://github.com/rubocop/rubocop/issues/12337): Supports `EnforcedStyleForRationalLiterals` option for `Layout/SpaceAroundOperators`. ([@koic][])
* [#12296](https://github.com/rubocop/rubocop/issues/12296): Support `RedundantRestArgumentNames`, `RedundantKeywordRestArgumentNames`, and `RedundantBlockArgumentNames` options for `Style/ArgumentsForwarding`. ([@koic][])

## 1.57.2 (2023-10-26)

### Bug fixes

* [#12274](https://github.com/rubocop/rubocop/issues/12274): Fix a false positive for `Lint/Void` when `each`'s receiver is an object of `Enumerator` to which `filter` has been applied. ([@koic][])
* [#12291](https://github.com/rubocop/rubocop/issues/12291): Fix a false positive for `Metrics/ClassLength` when a class with a singleton class definition. ([@koic][])
* [#12293](https://github.com/rubocop/rubocop/issues/12293): Fix a false positive for `Style/RedundantDoubleSplatHashBraces` when using double splat hash braces with `merge` and method chain. ([@koic][])
* [#12298](https://github.com/rubocop/rubocop/issues/12298): Fix a false positive for `Style/RedundantParentheses` when using a parenthesized hash literal as the first argument in a method call without parentheses. ([@koic][])
* [#12283](https://github.com/rubocop/rubocop/pull/12283): Fix an error for `Style/SingleLineDoEndBlock` when using single line `do`...`end` with no body. ([@koic][])
* [#12312](https://github.com/rubocop/rubocop/issues/12312): Fix an incorrect autocorrect for `Style/HashSyntax` when braced hash key and value are the same and it is used in `if`...`else`. ([@koic][])
* [#12307](https://github.com/rubocop/rubocop/issues/12307): Fix an infinite loop error for `Layout/EndAlignment` when `EnforcedStyleAlignWith: variable` and using a conditional statement in a method argument on the same line and `end` with method call is not aligned. ([@koic][])
* [#11652](https://github.com/rubocop/rubocop/issues/11652): Make `--auto-gen-config` generate `inherit_from` correctly inside ERB `if`. ([@jonas054][])
* [#12310](https://github.com/rubocop/rubocop/issues/12310): Drop `base64` gem from runtime dependency. ([@koic][])
* [#12300](https://github.com/rubocop/rubocop/issues/12300): Fix an error for `Style/IdenticalConditionalBranches` when `if`...`else` with identical leading lines and using index assign. ([@koic][])
* [#12286](https://github.com/rubocop/rubocop/issues/12286): Fix false positives for `Style/RedundantDoubleSplatHashBraces` when using double splat with a hash literal enclosed in parenthesized ternary operator. ([@koic][])
* [#12279](https://github.com/rubocop/rubocop/issues/12279): Fix false positives for `Lint/EmptyConditionalBody` when missing 2nd `if` body with a comment. ([@koic][])
* [#12275](https://github.com/rubocop/rubocop/issues/12275): Fix a false positive for `Style/RedundantDoubleSplatHashBraces` when using double splat within block argument containing a hash literal in an array literal. ([@koic][])
* [#12284](https://github.com/rubocop/rubocop/issues/12284): Fix false positives for `Style/SingleArgumentDig` when using some anonymous argument syntax. ([@koic][])
* [#12301](https://github.com/rubocop/rubocop/issues/12301): Make `Style/RedundantFilterChain` aware of safe navigation operator. ([@koic][])

## 1.57.1 (2023-10-13)

### Bug fixes

* [#12271](https://github.com/rubocop/rubocop/issues/12271): Fix a false positive for `Lint/RedundantSafeNavigation` when using snake case constant receiver. ([@koic][])
* [#12265](https://github.com/rubocop/rubocop/issues/12265): Fix an error for `Layout/MultilineMethodCallIndentation` when usingarithmetic operation with block inside a grouped expression. ([@koic][])
* [#12177](https://github.com/rubocop/rubocop/pull/12177): Fix an incorrect autocorrect for `Style/RedundantException`. ([@ydah][])
* [#12261](https://github.com/rubocop/rubocop/issues/12261): Fix an infinite loop for `Layout/MultilineMethodCallIndentation` when multiline method chain with a block argument and method chain. ([@ydah][])
* [#12263](https://github.com/rubocop/rubocop/issues/12263): Fix false positives for `Style/RedundantDoubleSplatHashBraces` when method call for no hash braced double splat receiver. ([@koic][])
* [#12262](https://github.com/rubocop/rubocop/pull/12262): Fix an incorrect autocorrect for `Style/RedundantDoubleSplatHashBraces` when using double splat hash braces with `merge` method call twice. ([@koic][])

## 1.57.0 (2023-10-11)

### New features

* [#12227](https://github.com/rubocop/rubocop/pull/12227): Add new `Style/SingleLineDoEndBlock` cop. ([@koic][])
* [#12246](https://github.com/rubocop/rubocop/pull/12246): Make `Lint/RedundantSafeNavigation` aware of constant receiver. ([@koic][])
* [#12257](https://github.com/rubocop/rubocop/issues/12257): Make `Style/RedundantDoubleSplatHashBraces` aware of `merge` methods. ([@koic][])

### Bug fixes

* [#12244](https://github.com/rubocop/rubocop/issues/12244): Fix a false negative for `Lint/Debugger` when using debugger method inside block. ([@koic][])
* [#12231](https://github.com/rubocop/rubocop/issues/12231): Fix a false negative for `Metrics/ModuleLength` when defining a singleton class in a module. ([@koic][])
* [#12249](https://github.com/rubocop/rubocop/issues/12249): Fix a false positive `Style/IdenticalConditionalBranches` when `if`..`else` with identical leading lines and assign to condition value. ([@koic][])
* [#12253](https://github.com/rubocop/rubocop/pull/12253): Fix `Lint/LiteralInInterpolation` to accept an empty string literal interpolated in words literal. ([@knu][])
* [#12198](https://github.com/rubocop/rubocop/issues/12198): Fix an error for flip-flop with beginless or endless ranges. ([@koic][])
* [#12259](https://github.com/rubocop/rubocop/issues/12259): Fix an error for `Lint/MixedCaseRange` when using nested character class in regexp. ([@koic][])
* [#12237](https://github.com/rubocop/rubocop/issues/12237): Fix an error for `Style/NestedTernaryOperator` when a ternary operator has a nested ternary operator within an `if`. ([@koic][])
* [#12228](https://github.com/rubocop/rubocop/pull/12228): Fix false negatives for `Style/MultilineBlockChain` when using multiline block chain with safe navigation operator. ([@koic][])
* [#12247](https://github.com/rubocop/rubocop/pull/12247): Fix false negatives for `Style/RedundantParentheses` when using logical or comparison expressions with redundant parentheses. ([@koic][])
* [#12226](https://github.com/rubocop/rubocop/issues/12226): Fix false positives for `Layout/MultilineMethodCallIndentation` when aligning methods in multiline block chain. ([@koic][])
* [#12076](https://github.com/rubocop/rubocop/issues/12076): Fixed an issue where the top-level cache folder was named differently during two consecutive rubocop runs. ([@K-S-A][])

### Changes

* [#12235](https://github.com/rubocop/rubocop/pull/12235): Enable auto parallel inspection when config file is specified. ([@aboutNisblee][])
* [#12234](https://github.com/rubocop/rubocop/pull/12234): Enhance `Style/FormatString`'s autocorrection when using known conversion methods whose return value is not an array. ([@koic][])
* [#12128](https://github.com/rubocop/rubocop/issues/12128): Make `Style/GuardClause` aware of `define_method`. ([@koic][])
* [#12126](https://github.com/rubocop/rubocop/pull/12126): Make `Style/RedundantFilterChain` aware of `select.present?` when `ActiveSupportExtensionsEnabled` config is `true`. ([@koic][])
* [#12250](https://github.com/rubocop/rubocop/pull/12250): Mark `Lint/RedundantRequireStatement` as unsafe autocorrect. ([@koic][])
* [#12097](https://github.com/rubocop/rubocop/issues/12097): Mark unsafe autocorrect for `Style/ClassEqualityComparison`. ([@koic][])
* [#12210](https://github.com/rubocop/rubocop/issues/12210): Mark `Style/RedundantFilterChain` as unsafe autocorrect. ([@koic][])

## 1.56.4 (2023-09-28)

### Bug fixes

* [#12221](https://github.com/rubocop/rubocop/issues/12221): Fix a false positive for `Layout/EmptyLineAfterGuardClause` when using `return` before guard condition with heredoc. ([@koic][])
* [#12213](https://github.com/rubocop/rubocop/issues/12213): Fix a false positive for `Lint/OrderedMagicComments` when comment text `# encoding: ISO-8859-1` is embedded within example code as source code comment. ([@koic][])
* [#12205](https://github.com/rubocop/rubocop/issues/12205): Fix an error for `Style/OperatorMethodCall` when using `foo bar./ baz`. ([@koic][])
* [#12208](https://github.com/rubocop/rubocop/issues/12208): Fix an incorrect autocorrect for the `--disable-uncorrectable` command line option when registering an offense is outside a percent array. ([@koic][])
* [#12203](https://github.com/rubocop/rubocop/pull/12203): Fix an incorrect autocorrect for `Lint/SafeNavigationChain` when using safe navigation with comparison operator as an expression of logical operator or comparison operator's operand. ([@koic][])
* [#12206](https://github.com/rubocop/rubocop/pull/12206): Fix an incorrect autocorrect for `Style/OperatorMethodCall` when using `foo./bar`. ([@koic][])
* [#12202](https://github.com/rubocop/rubocop/pull/12202): Fix an incorrect autocorrect for `Style/RedundantConditional` when unless/else with boolean results. ([@ydah][])
* [#12199](https://github.com/rubocop/rubocop/issues/12199): Fix false negatives for `Layout/MultilineMethodCallIndentation` when using safe navigation operator. ([@koic][])

### Changes

* [#12197](https://github.com/rubocop/rubocop/pull/12197): Make `Style/CollectionMethods` aware of `collect_concat`. ([@koic][])

## 1.56.3 (2023-09-11)

### Bug fixes

* [#12151](https://github.com/rubocop/rubocop/issues/12151): Make `Layout/EmptyLineAfterGuardClause` allow `:nocov:` directive after guard clause. ([@koic][])
* [#12195](https://github.com/rubocop/rubocop/issues/12195): Fix a false negative for `Layout/SpaceAfterNot` when a newline is present after `!`. ([@ymap][])
* [#12192](https://github.com/rubocop/rubocop/issues/12192): Fix a false positive for `Layout/RedundantLineBreak` when using quoted symbols with a single newline. ([@ymap][])
* [#12190](https://github.com/rubocop/rubocop/issues/12190): Fix a false positive for `Layout/SpaceAroundOperators` when aligning operators vertically. ([@koic][])
* [#12171](https://github.com/rubocop/rubocop/issues/12171): Fix a false positive for `Style/ArrayIntersect` when using block argument for `Enumerable#any?`. ([@koic][])
* [#12172](https://github.com/rubocop/rubocop/issues/12172): Fix a false positive for `Style/EmptyCaseCondition` when using `return`, `break`, `next` or method call before empty case condition. ([@koic][])
* [#12162](https://github.com/rubocop/rubocop/issues/12162): Fix an error for `Bundler/DuplicatedGroup` when there's a duplicate set of groups and the `group` value contains a splat. ([@koic][])
* [#12182](https://github.com/rubocop/rubocop/issues/12182): Fix an error for `Lint/UselessAssignment` when variables are assigned using chained assignment and remain unreferenced. ([@koic][])
* [#12181](https://github.com/rubocop/rubocop/issues/12181): Fix an incorrect autocorrect for `Lint/UselessAssignment` when variables are assigned with sequential assignment using the comma operator and unreferenced. ([@koic][])
* [#12187](https://github.com/rubocop/rubocop/issues/12187): Fix an incorrect autocorrect for `Style/SoleNestedConditional` when comment is in an empty nested `if` body. ([@ymap][])
* [#12183](https://github.com/rubocop/rubocop/pull/12183): Fix an incorrect autocorrect for `Style/MultilineTernaryOperator` when returning a multiline ternary operator expression with safe navigation method call. ([@koic][])
* [#12168](https://github.com/rubocop/rubocop/issues/12168): Fix bug in `Style/ArgumentsForwarding` when there are repeated send nodes. ([@owst][])
* [#12185](https://github.com/rubocop/rubocop/pull/12185): Set target version for `Layout/HeredocIndentation`. ([@tagliala][])

## 1.56.2 (2023-08-29)

### Bug fixes

* [#12138](https://github.com/rubocop/rubocop/issues/12138): Fix a false positive for `Layout/LineContinuationLeadingSpace` when a backslash is part of a multiline string literal. ([@ymap][])
* [#12155](https://github.com/rubocop/rubocop/pull/12155): Fix false positive for `Layout/RedundantLineBreak` when using a modified singleton method definition. ([@koic][])
* [#12143](https://github.com/rubocop/rubocop/issues/12143): Fix a false positive for `Lint/ToEnumArguments` when using anonymous keyword arguments forwarding. ([@koic][])
* [#12148](https://github.com/rubocop/rubocop/pull/12148): Fix an incorrect autocorrect for `Lint/NonAtomicFileOperation` when using `FileUtils.remove_dir`, `FileUtils.remove_entry`, or `FileUtils.remove_entry_secure`. ([@koic][])
* [#12141](https://github.com/rubocop/rubocop/issues/12141): Fix false positive for `Style/ArgumentsForwarding` when method def includes additional kwargs. ([@owst][])
* [#12154](https://github.com/rubocop/rubocop/issues/12154): Fix incorrect `diagnosticProvider` value of LSP. ([@koic][])

## 1.56.1 (2023-08-21)

### Bug fixes

* [#12136](https://github.com/rubocop/rubocop/pull/12136): Fix a false negative for `Layout/LeadingCommentSpace` when using `#+` or `#-` as they are not RDoc comments. ([@koic][])
* [#12113](https://github.com/rubocop/rubocop/issues/12113): Fix a false positive for `Bundler/DuplicatedGroup` when groups are duplicated but `source`, `git`, `platforms`, or `path` values are different. ([@koic][])
* [#12134](https://github.com/rubocop/rubocop/issues/12134): Fix a false positive for `Style/MethodCallWithArgsParentheses` when parentheses are used in one-line `in` pattern matching. ([@koic][])
* [#12111](https://github.com/rubocop/rubocop/issues/12111): Fix an error for `Bundler/DuplicatedGroup` group declaration has keyword option. ([@koic][])
* [#12109](https://github.com/rubocop/rubocop/issues/12109): Fix an error for `Style/ArgumentsForwarding` cop when forwarding kwargs/block arg and an additional arg. ([@ydah][])
* [#12117](https://github.com/rubocop/rubocop/issues/12117): Fix a false positive for `Style/ArgumentsForwarding` cop when not always forwarding block. ([@owst][])
* [#12115](https://github.com/rubocop/rubocop/pull/12115): Fix an error for `Style/Lambda` when using numbered parameter with a multiline `->` call. ([@koic][])
* [#12124](https://github.com/rubocop/rubocop/issues/12124): Fix false positives for `Style/RedundantParentheses` when parentheses in `super` or `yield` call with multiline style argument. ([@koic][])
* [#12120](https://github.com/rubocop/rubocop/pull/12120): Fix false positives for `Style/SymbolArray` when `%i` array containing unescaped `[`, `]`, `(`, or `)`. ([@koic][])
* [#12133](https://github.com/rubocop/rubocop/pull/12133): Fix `Style/RedundantSelfAssignmentBranch` to handle heredocs. ([@r7kamura][])
* [#12105](https://github.com/rubocop/rubocop/issues/12105): Fix target ruby `Gem::Requirement` matcher and version parsing to support multiple version constraints. ([@ItsEcholot][])

## 1.56.0 (2023-08-09)

### New features

* [#12074](https://github.com/rubocop/rubocop/pull/12074): Add new `Bundler/DuplicatedGroup` cop. ([@OwlKing][])
* [#12078](https://github.com/rubocop/rubocop/pull/12078): Make LSP server support `rubocop.formatAutocorrectsAll` execute command. ([@koic][])

### Bug fixes

* [#12106](https://github.com/rubocop/rubocop/issues/12106): Fix a false negative for `Style/RedundantReturn` when returning value with guard clause and `return` is used. ([@koic][])
* [#12095](https://github.com/rubocop/rubocop/pull/12095): Fix a false positive for `Style/Alias` when `EncforcedStyle: prefer_alias` and using `alias` with interpolated symbol argument. ([@koic][])
* [#12098](https://github.com/rubocop/rubocop/pull/12098): Fix a false positive for `Style/ClassEqualityComparison` when comparing interpolated string class name for equality. ([@koic][])
* [#12102](https://github.com/rubocop/rubocop/pull/12102): Fix an error for `Style/LambdaCall` when using nested lambda call `x.().()`. ([@koic][])
* [#12099](https://github.com/rubocop/rubocop/pull/12099): Fix an incorrect autocorrect for `Style/Alias` when `EncforcedStyle: prefer_alias_method` and using `alias` with interpolated symbol argument. ([@koic][])
* [#12085](https://github.com/rubocop/rubocop/issues/12085): Fix an error for `Lint/SuppressedException` when `AllowNil: true` is set and endless method definition is used. ([@koic][])
* [#12087](https://github.com/rubocop/rubocop/issues/12087): Fix false positives for `Style/ArgumentsForwarding` with additional args/kwargs in def/send nodes. ([@owst][])
* [#12071](https://github.com/rubocop/rubocop/issues/12071): Fix `Style/SymbolArray` false positives when using square brackets or interpolation in a symbol literal in a percent style array. ([@jasondoc3][])
* [#12061](https://github.com/rubocop/rubocop/issues/12061): Support regex in StringLiteralsInInterpolation. ([@jonas054][])
* [#12091](https://github.com/rubocop/rubocop/pull/12091): With `--fail-level A` ignore non-correctable offenses at :info severity. ([@naveg][])

### Changes

* [#12094](https://github.com/rubocop/rubocop/pull/12094): Add `base64` gem to runtime dependency to suppress Ruby 3.3's warning. ([@koic][])

## 1.55.1 (2023-07-31)

### Bug fixes

* [#12068](https://github.com/rubocop/rubocop/pull/12068): Fix a false positive for `Style/ReturnNilInPredicateMethodDefinition` when the last method argument in method definition is `nil`. ([@koic][])
* [#12082](https://github.com/rubocop/rubocop/issues/12082): Fix an error for `Lint/UselessAssignment` when a variable is assigned and unreferenced in `for` with multiple variables. ([@koic][])
* [#12079](https://github.com/rubocop/rubocop/issues/12079): Fix an error for `Style/MixinGrouping` when mixin method has no arguments. ([@koic][])
* [#11637](https://github.com/rubocop/rubocop/pull/11637): Correct Rubocop for `private_class_method` method documentation. ([@bigzed][])
* [#12070](https://github.com/rubocop/rubocop/pull/12070): Fix false positive in `Style/ArgumentsForwarding` when receiver forwards args/kwargs. ([@owst][])

## 1.55.0 (2023-07-25)

### New features

* [#11794](https://github.com/rubocop/rubocop/pull/11794): Add support to `Style/ArgumentsForwarding` for anonymous arg/kwarg forwarding in Ruby 3.2. ([@owst][])
* [#12044](https://github.com/rubocop/rubocop/issues/12044): Make LSP server support `layoutMode` option to run layout cops. ([@koic][])
* [#12056](https://github.com/rubocop/rubocop/pull/12056): Make LSP server support `lintMode` option to run lint cops. ([@koic][])
* [#12046](https://github.com/rubocop/rubocop/issues/12046): Make `ReturnNilInPredicateMethodDefinition` aware of `nil` at the end of predicate method definition. ([@koic][])

### Bug fixes

* [#12055](https://github.com/rubocop/rubocop/pull/12055): Allow parentheses in single-line match patterns when using the `omit_parentheses` style of `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])
* [#12050](https://github.com/rubocop/rubocop/pull/12050): Fix a false positive for `Layout/RedundantLineBreak` when inspecting the `%` form string `%\n\n`. ([@koic][])
* [#12063](https://github.com/rubocop/rubocop/pull/12063): Fix `Style/CombinableLoops` when one of the loops is empty. ([@fatkodima][])
* [#12059](https://github.com/rubocop/rubocop/issues/12059): Fix a false negative for `Style/StringLiteralsInInterpolation` for symbols with interpolation. ([@fatkodima][])
* [#11834](https://github.com/rubocop/rubocop/issues/11834): Fix false positive for when variable in inside conditional branch in nested node. ([@alexeyschepin][])
* [#11802](https://github.com/rubocop/rubocop/issues/11802): Improve handling of `[]` and `()` with percent symbol arrays. ([@jasondoc3][])
* [#12052](https://github.com/rubocop/rubocop/issues/12052): Fix "Subfolders can't include glob special characters". ([@meric426][], [@loveo][])
* [#12062](https://github.com/rubocop/rubocop/pull/12062): Fix `LoadError` when loading RuboCop from a symlinked location on Windows. ([@p0deje][])

### Changes

* [#12064](https://github.com/rubocop/rubocop/pull/12064): Make `Style/RedundantArgument` aware of `exit` and `exit!`. ([@koic][])
* [#12015](https://github.com/rubocop/rubocop/issues/12015): Mark `Style/HashConversion` as unsafe autocorrection. ([@koic][])

## 1.54.2 (2023-07-13)

### Bug fixes

* [#12043](https://github.com/rubocop/rubocop/pull/12043): Fix a false negative for `Layout/ExtraSpacing` when some characters are vertically aligned. ([@koic][])
* [#12040](https://github.com/rubocop/rubocop/pull/12040): Fix a false positive for `Layout/TrailingEmptyLines` to prevent the following incorrect autocorrection when inspecting the `%` form string `%\n\n`. ([@koic][])
* [#1867](https://github.com/rubocop/rubocop/issues/1867): Fix an error when `AllCops:Exclude` is empty in .rubocop.yml. ([@koic][])
* [#12034](https://github.com/rubocop/rubocop/issues/12034): Fix invalid byte sequence in UTF-8 error when using an invalid encoding string. ([@koic][])
* [#12038](https://github.com/rubocop/rubocop/pull/12038): Output the "server restarting" message to stderr. ([@knu][])

## 1.54.1 (2023-07-04)

### Bug fixes

* [#12024](https://github.com/rubocop/rubocop/issues/12024): Fix a false positive for `Lint/RedundantRegexpQuantifiers` when interpolation is used in a regexp literal. ([@koic][])
* [#12020](https://github.com/rubocop/rubocop/issues/12020): This PR fixes an infinite loop error for `Layout/SpaceAfterComma` with `Layout/SpaceBeforeSemicolon` when autocorrection conflicts. ([@koic][])
* [#12014](https://github.com/rubocop/rubocop/pull/12014): Fix an error for `Lint/UselessAssignment` when part of a multiple assignment is enclosed in parentheses. ([@koic][])
* [#12011](https://github.com/rubocop/rubocop/pull/12011): Fix an error for `Metrics/MethodLength` when using a heredoc in a block without block arguments. ([@koic][])
* [#12010](https://github.com/rubocop/rubocop/pull/12010): Fix false negatives for `Style/RedundantRegexpArgument` when using safe navigation operator. ([@koic][])

## 1.54.0 (2023-07-01)

### New features

* [#12000](https://github.com/rubocop/rubocop/pull/12000): Support safe or unsafe autocorrect config for LSP. ([@koic][])

### Bug fixes

* [#12005](https://github.com/rubocop/rubocop/issues/12005): Fix a false negative for `Lint/Debugger` when using debugger method inside lambda. ([@koic][])
* [#11986](https://github.com/rubocop/rubocop/issues/11986): Fix a false positive for `Lint/MixedCaseRange` when the number of characters at the start or end of range is other than 1. ([@koic][])
* [#11992](https://github.com/rubocop/rubocop/issues/11992): Fix an unexpected `NoMethodError` for built-in language server when an internal error occurs. ([@koic][])
* [#11994](https://github.com/rubocop/rubocop/issues/11994): Fix an error for `Layout/LineEndStringConcatenationIndentation` when inspecting the `%` from string `%\n\n`. ([@koic][])
* [#12007](https://github.com/rubocop/rubocop/issues/12007): Fix an error for `Layout/SpaceAroundOperators` when using unary operator with double colon. ([@koic][])
* [#11996](https://github.com/rubocop/rubocop/issues/11996): Fix an error for `Style/IfWithSemicolon` when without branch bodies. ([@koic][])
* [#12009](https://github.com/rubocop/rubocop/pull/12009): Fix an error for `Style/YodaCondition` when equality check method is used without the first argument. ([@koic][])
* [#11998](https://github.com/rubocop/rubocop/issues/11998): Fix an error when inspecting blank heredoc delimiter. ([@koic][])
* [#11989](https://github.com/rubocop/rubocop/issues/11989): Fix an incorrect autocorrect for `Style/RedundantRegexpArgument` when using unicode chars. ([@koic][])
* [#12001](https://github.com/rubocop/rubocop/issues/12001): Fix code length calculator for method calls with heredoc. ([@fatkodima][])
* [#12002](https://github.com/rubocop/rubocop/pull/12002): Fix `Lint/Void` cop for `__ENCODING__` constant. ([@fatkodima][])

### Changes

* [#11983](https://github.com/rubocop/rubocop/pull/11983): Add Ridgepole files to default `Include` list. ([@ydah][])
* [#11738](https://github.com/rubocop/rubocop/issues/11738): Enhances empty_line_between_defs to treat configured macros like defs. ([@catwomey][])

## 1.53.1 (2023-06-26)

### Bug fixes

* [#11974](https://github.com/rubocop/rubocop/issues/11974): Fix an error for `Style/RedundantCurrentDirectoryInPath` when using string interpolation in `require_relative`. ([@koic][])
* [#11981](https://github.com/rubocop/rubocop/issues/11981): Fix an incorrect autocorrect for `Style/RedundantRegexpArgument` when using double quote and single quote characters. ([@koic][])
* [#11836](https://github.com/rubocop/rubocop/issues/11836): Should not offense single-quoted symbol containing double quotes in `Lint/SymbolConversion` . ([@KessaPassa][])

## 1.53.0 (2023-06-23)

### New features

* [#11561](https://github.com/rubocop/rubocop/pull/11561): Add new `Lint/MixedCaseRange` cop. ([@rwstauner][])
* [#11565](https://github.com/rubocop/rubocop/pull/11565): Add new `Lint/RedundantRegexpQuantifiers` cop. ([@jaynetics][])
* [#11925](https://github.com/rubocop/rubocop/issues/11925): Add new `Style/RedundantCurrentDirectoryInPath` cop. ([@koic][])
* [#11595](https://github.com/rubocop/rubocop/pull/11595): Add new `Style/RedundantRegexpArgument` cop. ([@koic][])
* [#11967](https://github.com/rubocop/rubocop/pull/11967): Add new `Style/ReturnNilInPredicateMethodDefinition` cop. ([@koic][])
* [#11745](https://github.com/rubocop/rubocop/pull/11745): Add new `Style/YAMLFileRead` cop. ([@koic][])
* [#11926](https://github.com/rubocop/rubocop/pull/11926): Support built-in LSP server. ([@koic][])

### Bug fixes

* [#11953](https://github.com/rubocop/rubocop/issues/11953): Fix a false negative for `Lint/DuplicateHashKey` when there is a duplicated constant key in the hash literal. ([@koic][])
* [#11945](https://github.com/rubocop/rubocop/issues/11945): Fix a false negative for `Style/RedundantSelfAssignmentBranch` when using method chaining or arguments in ternary branch. ([@koic][])
* [#11949](https://github.com/rubocop/rubocop/issues/11949): Fix a false positive for `Layout/RedundantLineBreak` when using a line broken string. ([@koic][])
* [#11931](https://github.com/rubocop/rubocop/pull/11931): Fix a false positive for `Lint/RedundantRequireStatement` when using `PP.pp`. ([@koic][])
* [#11946](https://github.com/rubocop/rubocop/pull/11946): Fix an error for `Lint/NumberConversion` when using multiple number conversion methods. ([@koic][])
* [#11972](https://github.com/rubocop/rubocop/issues/11972): Fix an error for `Lint/Void` when `CheckForMethodsWithNoSideEffects: true` and using a method definition. ([@koic][])
* [#11958](https://github.com/rubocop/rubocop/pull/11958): Fix error for `Style/IdenticalConditionalBranches` when using empty parentheses in the `if` branch. ([@koic][])
* [#11962](https://github.com/rubocop/rubocop/issues/11962): Fix an error for `Style/RedundantStringEscape` when an escaped double quote precedes interpolation in a symbol literal. ([@koic][])
* [#11947](https://github.com/rubocop/rubocop/issues/11947): Fix an error for `Style/ConditionalAssignment` with an assignment that uses `if` branch bodies, which include a block. ([@koic][])
* [#11959](https://github.com/rubocop/rubocop/pull/11959): Fix false negatives for `Layout/EmptyLinesAroundExceptionHandlingKeywords` when using Ruby 2.5's `rescue` inside block and Ruby 2.7's numbered block. ([@koic][])
* [#10902](https://github.com/rubocop/rubocop/issues/10902): Fix an error for `Style/RedundantRegexpEscape` string with invalid byte sequence in UTF-8. ([@ydah][])
* [#11562](https://github.com/rubocop/rubocop/pull/11562): Fixed escaped octal handling and detection in `Lint/DuplicateRegexpCharacterClassElement`. ([@rwstauner][])

### Changes

* [#11904](https://github.com/rubocop/rubocop/pull/11904): Mark `Layout/ClassStructure` as unsafe to autocorrect. ([@nevans][])
* [#8506](https://github.com/rubocop/rubocop/issues/8506): Add `AllowedParentClasses` config to `Lint/MissingSuper`. ([@iMacTia][])

## 1.52.1 (2023-06-12)

### Bug fixes

* [#11944](https://github.com/rubocop/rubocop/pull/11944): Fix an incorrect autocorrect for `Style/SoleNestedConditional` with `Style/MethodCallWithArgsParentheses`. ([@koic][])
* [#11930](https://github.com/rubocop/rubocop/pull/11930): Fix exception on `Lint/InheritException` when class definition has non-constant siblings. ([@rafaelfranca][])
* [#11919](https://github.com/rubocop/rubocop/issues/11919): Fix an error for `Lint/UselessAssignment` when a variable is assigned and unreferenced in `for`. ([@koic][])
* [#11928](https://github.com/rubocop/rubocop/pull/11928): Fix an incorrect autocorrect for `Lint/AmbiguousBlockAssociation`. ([@koic][])
* [#11915](https://github.com/rubocop/rubocop/pull/11915): Fix a false positive for `Lint/RedundantSafeNavigation` when `&.` is used for `to_s`, `to_i`, `to_d`, and other coercion methods. ([@lucthev][])

### Changes

* [#11942](https://github.com/rubocop/rubocop/pull/11942): Require Parser 3.2.2.3 or higher. ([@koic][])

## 1.52.0 (2023-06-02)

### New features

* [#11873](https://github.com/rubocop/rubocop/pull/11873): Add `ComparisonsThreshold` config option to `Style/MultipleComparison`. ([@fatkodima][])
* [#11886](https://github.com/rubocop/rubocop/pull/11886): Add new `Style/RedundantArrayConstructor` cop. ([@koic][])
* [#11873](https://github.com/rubocop/rubocop/pull/11873): Add new `Style/RedundantRegexpConstructor` cop. ([@koic][])
* [#11841](https://github.com/rubocop/rubocop/pull/11841): Add new `Style/RedundantFilterChain` cop. ([@fatkodima][])
* [#11908](https://github.com/rubocop/rubocop/issues/11908): Support `AllowedReceivers` for `Style/CollectionMethods`. ([@koic][])

### Bug fixes

* [#11890](https://github.com/rubocop/rubocop/pull/11890): Fix a false negative for `Lint/RedundantSafeNavigation` when `&.` is used for `to_d`. ([@koic][])
* [#11880](https://github.com/rubocop/rubocop/issues/11880): Fix a false positive for `Style/ExactRegexpMatch` when using literal with quantifier in regexp. ([@koic][])
* [#11902](https://github.com/rubocop/rubocop/pull/11902): Fix a false positive for `Style/RequireOrder` when single-quoted string and double-quoted string are mixed. ([@koic][])
* [#11879](https://github.com/rubocop/rubocop/pull/11879): Fix a false positive for `Style/SelectByRegexp` when Ruby 2.2 or lower analysis. ([@koic][])
* [#11891](https://github.com/rubocop/rubocop/issues/11891): Fix `Style/AccessorGrouping` to accept macros separated from accessors by space. ([@fatkodima][])
* [#11905](https://github.com/rubocop/rubocop/issues/11905): Fix an error for `Lint/UselessAssignment` when a variable is assigned with rest assignment and unreferenced. ([@koic][])
* [#11899](https://github.com/rubocop/rubocop/issues/11899): Fix an incorrect autocorrect for `Style/SingleLineMethods` when using Ruby 3.0 and `Style/EndlessMethod` is disabled. ([@koic][])
* [#11884](https://github.com/rubocop/rubocop/issues/11884): Make `rubocop -V` display rubocop-factory_bot version when using it. ([@koic][])
* [#11893](https://github.com/rubocop/rubocop/issues/11893): Fix a false positive for `Lint/InheritException` when inheriting `Exception` with omitted namespace. ([@koic][])
* [#11898](https://github.com/rubocop/rubocop/pull/11898): Fix offences in calls inside blocks with braces for `Style/MethodCallWithArgsParentheses` with `omit_parentheses` enforced style. ([@gsamokovarov][])
* [#11857](https://github.com/rubocop/rubocop/pull/11857): Server mode: only read $stdin when -s or --stdin argument provided. ([@naveg][])

## 1.51.0 (2023-05-13)

### New features

* [#11819](https://github.com/rubocop/rubocop/pull/11819): Add autocorrection for `Lint/AmbiguousBlockAssociation`. ([@r7kamura][])
* [#11597](https://github.com/rubocop/rubocop/issues/11597): Add autocorrection for `Lint/UselessAssignment`. ([@r7kamura][])
* [#11848](https://github.com/rubocop/rubocop/pull/11848): Add autocorrection for `Lint/Void`. ([@r7kamura][])
* [#11851](https://github.com/rubocop/rubocop/pull/11851): Add autocorrection for `Naming/MemoizedInstanceVariableName`. ([@r7kamura][])
* [#11856](https://github.com/rubocop/rubocop/pull/11856): Add autocorrection for `Style/CombinableLoops`. ([@r7kamura][])
* [#11824](https://github.com/rubocop/rubocop/pull/11824): Add autocorrection for `Lint/TopLevelReturnWithArgument`. ([@r7kamura][])
* [#11869](https://github.com/rubocop/rubocop/pull/11869): Add new `Style/ExactRegexpMatch` cop. ([@koic][])
* [#11814](https://github.com/rubocop/rubocop/pull/11814): Make `Style/CollectionCompact` aware of `delete_if`. ([@koic][])
* [#11866](https://github.com/rubocop/rubocop/pull/11866): Make `Style/Semicolon` aware of redundant semicolons in string interpolation braces. ([@koic][])

### Bug fixes

* [#11812](https://github.com/rubocop/rubocop/issues/11812): Fix a false negative for `Style/Attr` when using `attr` and method definitions. ([@koic][])
* [#11861](https://github.com/rubocop/rubocop/issues/11861): Fix a false positive for `Layout/SpaceAfterSemicolon` when no space between a semicolon and a closing brace of string interpolation. ([@koic][])
* [#11830](https://github.com/rubocop/rubocop/pull/11830): Fix a false positive for `Lint/IncompatibleIoSelectWithFiberScheduler`. ([@koic][])
* [#11846](https://github.com/rubocop/rubocop/issues/11846): Fix a false positive for `Lint/RedundantStringCoercion` when using `to_s(argument)` in `puts` argument. ([@koic][])
* [#11865](https://github.com/rubocop/rubocop/pull/11865): Fix an error for `Naming/ConstantName` when assigning a constant from an empty branch of `else`. ([@koic][])
* [#11844](https://github.com/rubocop/rubocop/issues/11844): Fix a false positive for `Style/RedundantLineContinuation` when using line concatenation for assigning a return value and without argument parentheses. ([@koic][])
* [#11808](https://github.com/rubocop/rubocop/pull/11808): Fix a false positive for `Style/RegexpLiteral` when using a regexp starts with equal as a method argument. ([@koic][])
* [#11822](https://github.com/rubocop/rubocop/issues/11822): Fix an error for `Layout/SpaceInsideBlockBraces` when a method call with a multiline block is used as an argument. ([@koic][])
* [#11849](https://github.com/rubocop/rubocop/issues/11849): Fix an error for `Style/ConditionalAssignment` when `EnforcedStyle: assign_inside_condition` and using empty `case` condition. ([@koic][])
* [#11967](https://github.com/rubocop/rubocop/pull/11967): Fix error for `Style/IfInsideElse` when a deep nested multiline `if...then...elsif...else...end`. ([@koic][])
* [#11842](https://github.com/rubocop/rubocop/pull/11842): Fix an error for `Style/IfUnlessModifier` when using multiple `if` modifier in the long one line. ([@koic][])
* [#11835](https://github.com/rubocop/rubocop/pull/11835): Fix an error for `Style/RequireOrder` when multiple `require` are not sorted. ([@koic][])
* [#11809](https://github.com/rubocop/rubocop/issues/11809): Fix an incorrect autocorrect for `Naming/RescuedExceptionsVariableName` when exception variable is referenced after `rescue` statement. ([@koic][])
* [#11852](https://github.com/rubocop/rubocop/issues/11852): Fix an incorrect autocorrect for `Style/EvalWithLocation` when using `eval` without line number and with parenthesized method call. ([@koic][])
* [#11862](https://github.com/rubocop/rubocop/issues/11862): Fix an incorrect autocorrect for `Style/GuardClause` when using `raise` in `else` branch in a one-liner with `then`. ([@koic][])
* [#11868](https://github.com/rubocop/rubocop/issues/11868): Fix a false positive for `Style/HashExcept` when method's receiver/argument is not the same as block key argument. ([@fatkodima][])
* [#11858](https://github.com/rubocop/rubocop/pull/11858): Fix false positives when using source comments in blocks. ([@reitermarkus][])
* [#11510](https://github.com/rubocop/rubocop/pull/11510): Fix `Lint/UselessAssignment` false positive when using numbered block parameters. ([@sambostock][])
* [#11872](https://github.com/rubocop/rubocop/pull/11872): Fix `Gemspec/DevelopmentDependencies` not trigger when add_development_dependency has more then one arguments. ([@Bhacaz][])
* [#11820](https://github.com/rubocop/rubocop/issues/11820): Fix `Lint/EmptyConditionalBody` false-positives for commented empty `elsif` body. ([@r7kamura][])

### Changes

* [#11859](https://github.com/rubocop/rubocop/pull/11859): Add rubocop-factory_bot to suggested extensions. ([@ydah][])
* [#11791](https://github.com/rubocop/rubocop/pull/11791): **(Breaking)** Drop runtime support for Ruby 2.6 and JRuby 9.3 (CRuby 2.6 compatible). ([@koic][])
* [#11826](https://github.com/rubocop/rubocop/pull/11826): Exclude `**/*.jb` from `Lint/TopLevelReturnWithArgument`. ([@r7kamura][])
* [#11871](https://github.com/rubocop/rubocop/pull/11871): Mark `Style/DataInheritance` as unsafe autocorrect, `Style/OpenStructUse` as unsafe, and `Security/CompoundHash` as unsafe. ([@koic][])

## 1.50.2 (2023-04-17)

### Bug fixes

* [#11799](https://github.com/rubocop/rubocop/pull/11799): Fix a false positive for `Style/CollectionCompact` when using `reject` on hash to reject nils in Ruby 2.3 analysis. ([@koic][])
* [#11792](https://github.com/rubocop/rubocop/issues/11792): Fix an error for `Lint/DuplicateMatchPattern` when using hash pattern with `if` guard. ([@koic][])
* [#11800](https://github.com/rubocop/rubocop/issues/11800): Mark `Style/InvertibleUnlessCondition` as unsafe. ([@koic][])

## 1.50.1 (2023-04-12)

### Bug fixes

* [#11787](https://github.com/rubocop/rubocop/issues/11787): Fix a false positive for `Lint/DuplicateMatchPattern` when repeated `in` patterns but different `if` guard is used. ([@koic][])
* [#11789](https://github.com/rubocop/rubocop/pull/11789): Fix false negatives for `Style/ParallelAssignment` when Ruby 2.7+. ([@koic][])
* [#11783](https://github.com/rubocop/rubocop/issues/11783): Fix a false positive for `Style/RedundantLineContinuation` using line concatenation for assigning a return value and without argument parentheses. ([@koic][])

## 1.50.0 (2023-04-11)

### New features

* [#11749](https://github.com/rubocop/rubocop/pull/11749): Add new `Lint/DuplicateMatchPattern` cop. ([@koic][])
* [#11773](https://github.com/rubocop/rubocop/pull/11773): Make `Layout/ClassStructure` aware of singleton class. ([@koic][])
* [#11779](https://github.com/rubocop/rubocop/pull/11779): Make `Lint/RedundantStringCoercion` aware of print method arguments. ([@koic][])
* [#11776](https://github.com/rubocop/rubocop/pull/11776): Make `Metrics/ClassLength` aware of singleton class. ([@koic][])
* [#11775](https://github.com/rubocop/rubocop/pull/11775): Make `Style/TrailingBodyOnClass` aware of singleton class. ([@koic][])

### Bug fixes

* [#11758](https://github.com/rubocop/rubocop/issues/11758): Fix a false positive for `Style/RedundantLineContinuation` when line continuations for string. ([@koic][])
* [#11754](https://github.com/rubocop/rubocop/pull/11754): Fix a false positive for `Style/RedundantLineContinuation` when using `&&` and `||` with a multiline condition. ([@ydah][])
* [#11765](https://github.com/rubocop/rubocop/issues/11765): Fix an error for `Style/MultilineMethodSignature` when line break after `def` keyword. ([@koic][])
* [#11762](https://github.com/rubocop/rubocop/issues/11762): Fix an incorrect autocorrect for `Style/ClassEqualityComparison`  when comparing a variable or return value for equality. ([@koic][])
* [#11752](https://github.com/rubocop/rubocop/pull/11752): Fix a false positive for `Style/RedundantLineContinuation` when using line concatenation and calling a method without parentheses. ([@koic][])

## 1.49.0 (2023-04-03)

### New features

* [#11122](https://github.com/rubocop/rubocop/issues/11122): Add new `Style/RedundantLineContinuation` cop. ([@ydah][])
* [#11696](https://github.com/rubocop/rubocop/issues/11696): Add new `Style/DataInheritance` cop. ([@ktopolski][])
* [#11746](https://github.com/rubocop/rubocop/pull/11746): Make `Layout/EndAlignment` aware of pattern matching. ([@koic][])
* [#11750](https://github.com/rubocop/rubocop/pull/11750): Make `Metrics/BlockNesting` aware of numbered parameter. ([@koic][])
* [#11699](https://github.com/rubocop/rubocop/issues/11699): Make `Style/ClassEqualityComparison` aware of `Class#to_s` and `Class#inspect` for class equality comparison. ([@koic][])
* [#11737](https://github.com/rubocop/rubocop/pull/11737): Make `Style/MapToHash` and `Style/MapToSet` aware of numbered parameters. ([@koic][])
* [#11732](https://github.com/rubocop/rubocop/issues/11732): Make `Style/MapToHash` and `Style/MapToSet` aware of symbol proc. ([@koic][])
* [#11703](https://github.com/rubocop/rubocop/pull/11703): Make `Naming/InclusiveLanguage` support autocorrection when there is only one suggestion. ([@koic][])

### Bug fixes

* [#11730](https://github.com/rubocop/rubocop/issues/11730): Fix an error for `Layout/HashAlignment` when using anonymous keyword rest arguments. ([@koic][])
* [#11704](https://github.com/rubocop/rubocop/issues/11704): Fix a false positive for `Lint/UselessMethodDefinition` when method definition with non access modifier containing only `super` call. ([@koic][])
* [#11723](https://github.com/rubocop/rubocop/issues/11723): Fix a false positive for `Style/IfUnlessModifier` when using one-line pattern matching as a `if` condition. ([@koic][])
* [#11725](https://github.com/rubocop/rubocop/issues/11725): Fix an error when insufficient permissions to server cache dir are granted. ([@koic][])
* [#11715](https://github.com/rubocop/rubocop/issues/11715): Ensure default configuration loads. ([@koic][])
* [#11742](https://github.com/rubocop/rubocop/pull/11742): Fix error handling in bundler standalone mode. ([@composerinteralia][])
* [#11712](https://github.com/rubocop/rubocop/pull/11712): Fix a crash in `Lint/EmptyConditionalBody`. ([@gsamokovarov][])
* [#11641](https://github.com/rubocop/rubocop/issues/11641): Fix a false negative for `Layout/ExtraSpacing` when there are many comments with extra spaces. ([@nobuyo][])
* [#11740](https://github.com/rubocop/rubocop/pull/11740): Fix a false positive for `Lint/NestedMethodDefinition` when nested definition inside `*_eval` and `*_exec` method call with a numblock. ([@ydah][])
* [#11685](https://github.com/rubocop/rubocop/issues/11685): Fix incorrect directive comment insertion when percent array violates `Layout/LineLength` cop. ([@nobuyo][])
* [#11706](https://github.com/rubocop/rubocop/issues/11706): Fix infinite loop when `--disable-uncorrectable` option and there is a multi-line percent array violates `Layout/LineLength`. ([@nobuyo][])
* [#11697](https://github.com/rubocop/rubocop/issues/11697): Fix `Lint/Syntax` behavior when `--only` is not given the cop name. ([@koic][])
* [#11709](https://github.com/rubocop/rubocop/pull/11709): Fix value omission false positive in `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])

### Changes

* [#11739](https://github.com/rubocop/rubocop/pull/11739): Make `Style/RedundantParentheses` aware of redundant method argument parentheses. ([@koic][])
* [#10766](https://github.com/rubocop/rubocop/issues/10766): Use the path given by `--cache-root` to be the parent for `rubocop_cache` dir like other ways to specify it. ([@nobuyo][])

## 1.48.1 (2023-03-13)

### Bug fixes

* [#11673](https://github.com/rubocop/rubocop/pull/11673): Fix incorrect `Style/HashSyntax` autocorrection for assignment methods. ([@gsamokovarov][])
* [#11682](https://github.com/rubocop/rubocop/issues/11682): Fix a false positive for `Lint/UselessRescue` when using `Thread#raise` in `rescue` clause. ([@koic][])
* [#11672](https://github.com/rubocop/rubocop/issues/11672): Fix an error for `Layout/BlockEndNewline` when multiline block `}` is not on its own line and it is used as multiple arguments. ([@koic][])
* [#11675](https://github.com/rubocop/rubocop/pull/11675): `Style/AccessorGrouping`: Fix sibling detection for methods with type sigs. ([@issyl0][])
* [#11658](https://github.com/rubocop/rubocop/issues/11658): Fix `Lint/Debugger` should not allow pry. ([@ThHareau][])
* [#11689](https://github.com/rubocop/rubocop/pull/11689): Fix `Lint/Syntax` behavior when `Enabled: false` of `Lint` department. ([@koic][])
* [#11677](https://github.com/rubocop/rubocop/issues/11677): Fix the severity for `Lint/Syntax`. ([@koic][])
* [#11691](https://github.com/rubocop/rubocop/pull/11691): Fix an error for `Gemspec/DependencyVersion` when method called on gem name argument for `add_dependency`. ([@koic][])

## 1.48.0 (2023-03-06)

### New features

* [#11628](https://github.com/rubocop/rubocop/issues/11628): Add new `Style/DirEmpty` cop. ([@ydah][])
* [#11629](https://github.com/rubocop/rubocop/issues/11629): Add new `Style/FileEmpty` cop. ([@ydah][])

### Bug fixes

* [#11654](https://github.com/rubocop/rubocop/pull/11654): Fix a false positive for `Lint/MissingSuper` when no `super` call and when defining some method. ([@koic][])
* [#11661](https://github.com/rubocop/rubocop/pull/11661): Fix an error for `Style/Documentation` when namespace is a variable. ([@koic][])
* [#11647](https://github.com/rubocop/rubocop/pull/11647): Fix an error for `Style/IfWithBooleanLiteralBranches` when using `()` as a condition. ([@koic][])
* [#11646](https://github.com/rubocop/rubocop/pull/11646): Fix an error for `Style/NegatedIfElseCondition` when using `()` as a condition. ([@koic][])
* [#11659](https://github.com/rubocop/rubocop/pull/11659): Fix an incorrect autocorrect for `Lint/OrAssignmentToConstant` when using or-assignment to a constant in method definition. ([@koic][])
* [#11663](https://github.com/rubocop/rubocop/issues/11663): Fix an incorrect autocorrect for `Style/BlockDelimiters` when multi-line blocks to `{` and `}` with arithmetic operation method chain. ([@koic][])
* [#11638](https://github.com/rubocop/rubocop/pull/11638): Fix a false positive for `Lint/UselessAccessModifier` when using same access modifier inside and outside the `included` block. ([@ydah][])
* [#11164](https://github.com/rubocop/rubocop/issues/11164): Suppress server mode message with `-f json`. ([@jasondoc3][])
* [#11643](https://github.com/rubocop/rubocop/pull/11643): Fix incorrect shorthand autocorrections in calls inside parentheses. ([@gsamokovarov][])
* [#11650](https://github.com/rubocop/rubocop/pull/11650): `Style/AccessorGrouping`: Fix detection of Sorbet `sig {}` blocks. ([@issyl0][])
* [#11657](https://github.com/rubocop/rubocop/issues/11657): Use cop name to check if cop inside registry is enabled. Previously, it was able to cause large memory usage during linting. ([@fatkodima][])

### Changes

* [#11482](https://github.com/rubocop/rubocop/issues/11482): Avoid comment deletion by `Style/IfUnlessModifier` when the modifier form expression has long comment. ([@nobuyo][])
* [#11649](https://github.com/rubocop/rubocop/issues/11649): Support `MinBranchesCount` config for `Style/CaseLikeIf` cop. ([@fatkodima][])

## 1.47.0 (2023-03-01)

### New features

* [#11475](https://github.com/rubocop/rubocop/pull/11475): Add autocorrect for hash in `Lint/LiteralInInterpolation`. ([@KessaPassa][])
* [#11584](https://github.com/rubocop/rubocop/pull/11584): Add `Metrics/CollectionLiteralLength` cop. ([@sambostock][])

### Bug fixes

* [#11615](https://github.com/rubocop/rubocop/issues/11615): Fix a false negative for `Lint/MissingSuper` when no `super` call with `Class.new` block. ([@koic][])
* [#11615](https://github.com/rubocop/rubocop/issues/11615): Fix a false negative for `Lint/MissingSuper` when using `Class.new` without parent class argument. ([@koic][])
* [#11040](https://github.com/rubocop/rubocop/issues/11040): Fix a false positive for `Style/IfUnlessModifier` when `defined?`'s argument value is undefined. ([@koic][])
* [#11607](https://github.com/rubocop/rubocop/issues/11607): Fix a false positive for `Style/RedundantRegexpEscape` when an escaped hyphen follows after an escaped opening square bracket within a character class. ([@SparLaimor][])
* [#11626](https://github.com/rubocop/rubocop/issues/11626): Fix a false positive for `Style/ZeroLengthPredicate` when using `File.new(path).size.zero?`. ([@koic][])
* [#11620](https://github.com/rubocop/rubocop/pull/11620): Fix an error for `Lint/ConstantResolution` when using `__ENCODING__`. ([@koic][])
* [#11625](https://github.com/rubocop/rubocop/pull/11625): Fix an error for `Lint/EmptyConditionalBody` when missing `if` body and using method call for return value. ([@koic][])
* [#11631](https://github.com/rubocop/rubocop/issues/11631): Fix an incorrect autocorrect for `Style/ArgumentsForwarding` when using arguments forwarding for `.()` call. ([@koic][])
* [#11621](https://github.com/rubocop/rubocop/issues/11621): Fix an incorrect autocorrect for `Layout/ClassStructure` using heredoc inside method. ([@fatkodima][])
* [#3591](https://github.com/rubocop/rubocop/issues/3591): Handle modifier `while` and `until` expressions in `Lint/UselessAssignment`. ([@bfad][])
* [#11202](https://github.com/rubocop/rubocop/issues/11202): Fixed usage of `--only` flag with `--auto-gen-config`. ([@istvanfazakas][])

### Changes

* [#11623](https://github.com/rubocop/rubocop/pull/11623): Add rubocop-capybara to suggested extensions and extension doc. ([@ydah][])

## 1.46.0 (2023-02-22)

### New features

* [#11569](https://github.com/rubocop/rubocop/pull/11569): Support `TargetRubyVersion 3.3` (experimental). ([@koic][])

### Bug fixes

* [#11574](https://github.com/rubocop/rubocop/pull/11574): Fix a broken shorthand syntax autocorrection. ([@gsamokovarov][])
* [#11599](https://github.com/rubocop/rubocop/pull/11599): Fix a false positive for `Layout/LineContinuationSpacing` when using percent literals. ([@koic][])
* [#11556](https://github.com/rubocop/rubocop/issues/11556): Fix a false positive for `Lint/Debugger` when `p` is an argument of method call. ([@koic][])
* [#11591](https://github.com/rubocop/rubocop/issues/11591): Fix a false positive for `Lint/ToEnumArguments` when enumerator is not created for `__callee__` and `__callee__` methods. ([@koic][])
* [#11603](https://github.com/rubocop/rubocop/pull/11603): Actually run temporarily enabled cops. ([@tdeo][])
* [#11579](https://github.com/rubocop/rubocop/pull/11579): Fix an error for `Layout/HeredocArgumentClosingParenthesis` when heredoc is a method argument in a parenthesized block argument. ([@koic][])
* [#11576](https://github.com/rubocop/rubocop/pull/11576): Fix an error for `Lint/UselessRescue` when `rescue` does not exception variable and `ensure` has empty body. ([@koic][])
* [#11608](https://github.com/rubocop/rubocop/pull/11608): Fix an error for `Lint/RefinementImportMethods` when using `include` on the top level. ([@koic][])
* [#11589](https://github.com/rubocop/rubocop/pull/11589): Fix an error for `Layout/HeredocArgumentClosingParenthesis` when heredoc is a branch body in a method argument of a parenthesized argument. ([@koic][])
* [#11567](https://github.com/rubocop/rubocop/issues/11567): Fix `Layout/EndAlignment` false negative. ([@j-miyake][])
* [#11582](https://github.com/rubocop/rubocop/issues/11582): Fix checking if token with large offset begins its line. ([@fatkodima][])
* [#11412](https://github.com/rubocop/rubocop/issues/11412): Mark `Style/ArrayIntersect` as unsafe. ([@koic][])
* [#11559](https://github.com/rubocop/rubocop/pull/11559): Fixed false positives and negatives in `Style/RedundantRegexpCharacterClass` when using octal escapes (e.g. "\0"). ([@jaynetics][])
* [#11575](https://github.com/rubocop/rubocop/pull/11575): Fix parentheses in value omissions for multiple assignments. ([@gsamokovarov][])

### Changes

* [#11586](https://github.com/rubocop/rubocop/issues/11586): Handle `ruby2_keywords` in `Style/DocumentationMethod` cop. ([@fatkodima][])
* [#11604](https://github.com/rubocop/rubocop/issues/11604): Make `Naming/VariableNumber` to allow `x86_64` CPU architecture name by default. ([@koic][])
* [#11596](https://github.com/rubocop/rubocop/issues/11596): Make `Style/AccessorGrouping` aware of method call before accessor. ([@koic][])
* [#11588](https://github.com/rubocop/rubocop/pull/11588): Optimize `Style/WordArray` complex matrix check. ([@sambostock][])
* [#11573](https://github.com/rubocop/rubocop/pull/11573): Handle hash patterns and pins in `Lint/OutOfRangeRegexpRef` cop. ([@fatkodima][])
* [#11564](https://github.com/rubocop/rubocop/pull/11564): Remove print debug methods from default for `Lint/Debugger`. ([@koic][])

## 1.45.1 (2023-02-08)

### Bug fixes

* [#11552](https://github.com/rubocop/rubocop/pull/11552): Fix a false positive for `Lint/Debugger` when methods containing different method chains. ([@ydah][])
* [#11548](https://github.com/rubocop/rubocop/pull/11548): Fix an error for `Style/AccessModifierDeclarations` when if a non method definition was included. ([@ydah][])
* [#11554](https://github.com/rubocop/rubocop/issues/11554): Fix an error for `Style/RedundantCondition` when the branches contains empty hash literal argument. ([@koic][])
* [#11549](https://github.com/rubocop/rubocop/issues/11549): Fix an error for third party cops when inheriting `RuboCop::Cop::Cop`. ([@koic][])

## 1.45.0 (2023-02-08)

### New features

* [#10839](https://github.com/rubocop/rubocop/pull/10839): Add API for 3rd party template support. ([@r7kamura][])
* [#11528](https://github.com/rubocop/rubocop/pull/11528): Add new `Style/RedundantHeredocDelimiterQuotes` cop. ([@koic][])
* [#11188](https://github.com/rubocop/rubocop/issues/11188): Add a `--no-detach` option for `--start-server`. This will start the server process in the foreground, which can be helpful when running within Docker where detaching the process terminates the container. ([@f1sherman][])
* [#11546](https://github.com/rubocop/rubocop/pull/11546): Make `Lint/UselessAccessModifier` aware of Ruby 3.2's `Data.define`. ([@koic][])
* [#11396](https://github.com/rubocop/rubocop/pull/11396): Add ability to profile rubocop execution via `--profile` and `--memory` options. ([@fatkodima][])

### Bug fixes

* [#11491](https://github.com/rubocop/rubocop/pull/11491): Fix a crash on `Lint/UselessAssignment`. ([@gsamokovarov][])
* [#11515](https://github.com/rubocop/rubocop/pull/11515): Fix a false negative for `Naming/HeredocDelimiterNaming` when using lowercase. ([@koic][])
* [#11511](https://github.com/rubocop/rubocop/issues/11511): Fix a false negative for `Style/YodaCondition` when using constant. ([@koic][])
* [#11520](https://github.com/rubocop/rubocop/pull/11520): Fix a false negative for `Style/YodaExpression` when using constant. ([@koic][])
* [#11521](https://github.com/rubocop/rubocop/issues/11521): Fix a false positive for `Lint/FormatParameterMismatch` when using `Kernel.format` with the interpolated number of decimal places fields match. ([@koic][])
* [#11545](https://github.com/rubocop/rubocop/pull/11545): Fix the following false positive for `Lint/NestedMethodDefinition` when using numbered parameter. ([@koic][])
* [#11535](https://github.com/rubocop/rubocop/issues/11535): Fix a false positive for `Style/NumberedParametersLimit` when only `_2` or higher numbered parameter is used. ([@koic][])
* [#11508](https://github.com/rubocop/rubocop/issues/11508): Fix a false positive for `Style/OperatorMethodCall` when using multiple arguments for operator method. ([@koic][])
* [#11503](https://github.com/rubocop/rubocop/issues/11503): Fix a false positive for `Style/RedundantCondition` when using method argument with operator. ([@koic][])
* [#11529](https://github.com/rubocop/rubocop/pull/11529): Fix an incorrect autocorrect for `Layout/ClassStructure` when definitions that need to be sorted are defined alternately. ([@ydah][])
* [#11530](https://github.com/rubocop/rubocop/pull/11530): Fix an incorrect autocorrect for `Style/AccessModifierDeclarations` when multiple groupable access modifiers are defined. ([@ydah][])
* [#10910](https://github.com/rubocop/rubocop/pull/10910): Fix an incorrect autocorrect for `Style/MultilineTernaryOperator`  when contains a comment. ([@ydah][])
* [#11522](https://github.com/rubocop/rubocop/pull/11522): Don't flag default keyword arguments in `Style/ArgumentsForwarding`. ([@splattael][])
* [#11547](https://github.com/rubocop/rubocop/pull/11547): Fix a false positive for `Lint/NestedMethodDefinition` when using Ruby 3.2's `Data.define`. ([@koic][])
* [#11537](https://github.com/rubocop/rubocop/pull/11537): Fix an infinite loop error for `Layout/ArrayAlignment` when using assigning unbracketed array elements. ([@koic][])
* [#11516](https://github.com/rubocop/rubocop/pull/11516): Fix missing parentheses in shorthand hash syntax as argument calls. ([@gsamokovarov][])

### Changes

* [#11504](https://github.com/rubocop/rubocop/issues/11504): Allow `initialize` method in `Style/DocumentationMethod`. ([@koic][])
* [#11541](https://github.com/rubocop/rubocop/pull/11541): Enable autocorrection for `Layout/LineContinuationLeadingSpace`. ([@eugeneius][])
* [#11542](https://github.com/rubocop/rubocop/pull/11542): Mark `Layout/AssignmentIndentation` as safe and `Lint/AssignmentInCondition` as unsafe for autocorrection. ([@eugeneius][])
* [#11517](https://github.com/rubocop/rubocop/issues/11517): Make `Lint/Debugger` aware of `p`, `PP.pp`, and `pp` methods. ([@koic][])
* [#11539](https://github.com/rubocop/rubocop/pull/11539): Remove `bundler` from default `AllowedGems` of `Gemspec/DevelopmentDependencies`. ([@koic][])

## 1.44.1 (2023-01-25)

### Bug fixes

* [#11492](https://github.com/rubocop/rubocop/issues/11492): Fix an error for `Lint/Void` when configuring `CheckForMethodsWithNoSideEffects: true`. ([@koic][])
* [#11400](https://github.com/rubocop/rubocop/issues/11400): Fix an incorrect autocorrect for `Naming/BlockForwarding` and `Lint/AmbiguousOperator` when autocorrection conflicts for ambiguous splat argument. ([@fatkodima][])
* [#11483](https://github.com/rubocop/rubocop/issues/11483): Fix `Layout/ClosingParenthesisIndentation` for keyword splat arguments. ([@fatkodima][])
* [#11487](https://github.com/rubocop/rubocop/pull/11487): Fix a false positive for `Lint/FormatParameterMismatch` when format string is only interpolated string. ([@ydah][])
* [#11485](https://github.com/rubocop/rubocop/issues/11485): Fix a false positive for `Lint/UselessAssignment` when using numbered block parameter. ([@koic][])

## 1.44.0 (2023-01-23)

### New features

* [#11410](https://github.com/rubocop/rubocop/issues/11410): Add new `Style/InvertibleUnlessCondition` cop. ([@fatkodima][])
* [#11338](https://github.com/rubocop/rubocop/issues/11338): Add new `Style/ComparableClamp` cop. ([@koic][])
* [#11350](https://github.com/rubocop/rubocop/issues/11350): Make `Lint/DeprecatedClassMethods` aware of deprecated `attr` with boolean 2nd argument. ([@koic][])
* [#11457](https://github.com/rubocop/rubocop/pull/11457): Make `Metrics/BlockNesting` aware of pattern matching. ([@koic][])
* [#11458](https://github.com/rubocop/rubocop/pull/11458): Make `Metrics/CyclomaticComplexity` aware of pattern matching. ([@koic][])
* [#11469](https://github.com/rubocop/rubocop/pull/11469): Add `Gemspec/DevelopmentDependencies` cop. ([@sambostock][])

### Bug fixes

* [#11445](https://github.com/rubocop/rubocop/issues/11445): Fix an incorrect autocorrect for `Style/BlockDelimiters` when there is a comment after the closing brace and bracket. ([@koic][])
* [#11428](https://github.com/rubocop/rubocop/pull/11428): Apply value omission exceptions in super invocations. ([@gsamokovarov][])
* [#11420](https://github.com/rubocop/rubocop/issues/11420): Fix a false positive for `Lint/UselessRescue`  when using exception variable in `ensure` clause. ([@koic][])
* [#11460](https://github.com/rubocop/rubocop/issues/11460): Fix an error for `Style/OperatorMethodCall` when using `foo.> 42`. ([@koic][])
* [#11456](https://github.com/rubocop/rubocop/pull/11456): Fix value omissions in `yield` invocations. ([@gsamokovarov][])
* [#11467](https://github.com/rubocop/rubocop/issues/11467): Fix a false negative for `Style/MethodCallWithoutArgsParentheses` when calling method on a receiver and assigning to a variable with the same name. ([@koic][])
* [#11430](https://github.com/rubocop/rubocop/issues/11430): Fix an infinite loop error for `Layout/BlockEndNewline` when multiline blocks with newlines before the `; end`. ([@koic][])
* [#11442](https://github.com/rubocop/rubocop/pull/11442): Fix a crash during anonymous rest argument forwarding. ([@gsamokovarov][])
* [#11447](https://github.com/rubocop/rubocop/pull/11447): Fix an incorrect autocorrect for `Style/RedundantDoubleSplatHashBraces` when using nested double splat hash braces. ([@koic][])
* [#11459](https://github.com/rubocop/rubocop/pull/11459): Make `Lint/UselessRuby2Keywords` aware of conditions. ([@splattael][])
* [#11415](https://github.com/rubocop/rubocop/issues/11415): Fix a false positive for `Lint/UselessMethodDefinition` when method definition contains rest arguments. ([@koic][])
* [#11418](https://github.com/rubocop/rubocop/issues/11418): Fix a false positive for `Style/MethodCallWithArgsParentheses` when using anonymous rest arguments or anonymous keyword rest arguments. ([@koic][])
* [#11431](https://github.com/rubocop/rubocop/pull/11431): Fix a crash in `Style/HashSyntax`. ([@gsamokovarov][])
* [#11444](https://github.com/rubocop/rubocop/issues/11444): Fix a false positive for `Lint/ShadowingOuterLocalVariable` when using numbered block parameter. ([@koic][])
* [#11477](https://github.com/rubocop/rubocop/issues/11477): Fix an error when using YAML alias with server mode. ([@koic][])
* [#11419](https://github.com/rubocop/rubocop/issues/11419): Fix a false positive for `Lint/RedundantRequireStatement` when using `pretty_inspect`. ([@koic][])
* [#11439](https://github.com/rubocop/rubocop/issues/11439): Fix an incorrect autocorrect for `Style/MinMaxComparison` when using `a < b a : b` with `elsif/else`. ([@ydah][])
* [#11464](https://github.com/rubocop/rubocop/pull/11464): Fix a false negative for `Lint/FormatParameterMismatch` when include interpolated string. ([@ydah][])
* [#11425](https://github.com/rubocop/rubocop/pull/11425): Fix a false negative for `Lint/Void` when using methods that takes blocks. ([@krishanbhasin-shopify][])
* [#11437](https://github.com/rubocop/rubocop/pull/11437): Fix an error for `Style/AccessModifierDeclarations` when access modifier is inlined with a method on the top level. ([@koic][])
* [#11455](https://github.com/rubocop/rubocop/pull/11455): Fix crash with `super value_omission:` followed by a method call. ([@gsamokovarov][])

### Changes

* [#11465](https://github.com/rubocop/rubocop/pull/11465): Make `Style/Semicolon` aware of redundant semicolon in block. ([@koic][])
* [#11471](https://github.com/rubocop/rubocop/pull/11471): Change to not output not configured warning when renamed and pending cop. ([@ydah][])

## 1.43.0 (2023-01-10)

### New features

* [#11359](https://github.com/rubocop/rubocop/issues/11359): Add new `Lint/UselessRescue` cop. ([@fatkodima][])
* [#11389](https://github.com/rubocop/rubocop/pull/11389): Add autocorrect for `Style/MissingElse`. ([@FnControlOption][])

### Bug fixes

* [#11386](https://github.com/rubocop/rubocop/pull/11386): Fix a false positive for `Style/OperatorMethodCall` when using anonymous forwarding. ([@koic][])
* [#11409](https://github.com/rubocop/rubocop/issues/11409): Fix an incorrect autocorrect for `Style/HashSyntax` when using hash value omission and `EnforcedStyle: no_mixed_keys`. ([@koic][])
* [#11405](https://github.com/rubocop/rubocop/issues/11405): Fix undefined method `range_between' for `Style/WhileUntilModifier`. ([@such][])
* [#11374](https://github.com/rubocop/rubocop/pull/11374): Fix an error for `Style/StringHashKeys` when using invalid symbol in encoding UTF-8 as keys. ([@koic][])
* [#11392](https://github.com/rubocop/rubocop/pull/11392): Fix an incorrect autocorrect for `Style/RedundantDoubleSplatHashBraces` using double splat in double splat hash braces. ([@koic][])
* [#8990](https://github.com/rubocop/rubocop/issues/8990): Make `Style/HashEachMethods` aware of built-in `Thread.current`. ([@koic][])
* [#11390](https://github.com/rubocop/rubocop/issues/11390): Fix an incorrect autocorrect for `Style/HashSyntax` when hash first argument key and hash value only are the same which has a method call on the next line. ([@koic][])
* [#11379](https://github.com/rubocop/rubocop/pull/11379): Fix a false negative for `Style/OperatorMethodCall` when using `a.+ b.something`. ([@koic][])
* [#11180](https://github.com/rubocop/rubocop/issues/11180): Fix an error for `Style/RedundantRegexpEscape` when using `%r` to provide regexp expressions. ([@si-lens][])
* [#11403](https://github.com/rubocop/rubocop/pull/11403): Fix bad offense for parenthesised calls in literals for `omit_parentheses` style in `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])
* [#11407](https://github.com/rubocop/rubocop/pull/11407): Fix an error for `Style/HashSyntax` when expression follows hash key assignment. ([@fatkodima][])
* [#11377](https://github.com/rubocop/rubocop/issues/11377): Fix `Style/OperatorMethodCall` when forwarding arguments. ([@sambostock][])

### Changes

* [#11382](https://github.com/rubocop/rubocop/pull/11382): Require `unicode-display_width` 2.4.0 or higher. ([@fatkodima][])
* [#11381](https://github.com/rubocop/rubocop/pull/11381): Require Parser 3.2.0.0 or higher. ([@koic][])
* [#11380](https://github.com/rubocop/rubocop/pull/11380): Disable `Style/YodaExpression` by default. ([@koic][])
* [#11303](https://github.com/rubocop/rubocop/issues/11303): Make `Metrics/ParameterLists` aware of `Struct.new` and `Data.define` blocks. ([@koic][])

## 1.42.0 (2023-01-01)

### New features

* [#11339](https://github.com/rubocop/rubocop/issues/11339): Add new `Style/MapToSet` cop. ([@koic][])
* [#11341](https://github.com/rubocop/rubocop/pull/11341): Add new `Style/MinMaxComparison` cop. ([@koic][])
* [#9222](https://github.com/rubocop/rubocop/issues/9222): Add new `Style/YodaExpression` cop. ([@fatkodima][])
* [#11261](https://github.com/rubocop/rubocop/pull/11261): Allow inherit_from to accept a glob. ([@alexevanczuk][])

### Bug fixes

* [#11204](https://github.com/rubocop/rubocop/issues/11204): Fix a false negative for `Lint/RedundantCopDisableDirective` when using `--except` command line option. ([@koic][])
* [#11369](https://github.com/rubocop/rubocop/pull/11369): Fix an error for `Lint/UselessRuby2Keywords` when using `Proc#ruby2_keywords`. ([@koic][])
* [#11351](https://github.com/rubocop/rubocop/pull/11351): Fix an incorrect autocorrect for `Lint/RegexpAsCondition` when using regexp literal with bang. ([@koic][])
* [#11329](https://github.com/rubocop/rubocop/pull/11329): Accept simple freezed constants in `Layout/ClassStructure` and correctly handle class methods. ([@fatkodima][])
* [#11344](https://github.com/rubocop/rubocop/pull/11344): Fix an error for `Style/GuardClause` when using heredoc as an argument of raise in `then` branch and it does not have `else` branch. ([@koic][])
* [#11335](https://github.com/rubocop/rubocop/pull/11335): Fix an error for `Style/RequireOrder` when only one `require`. ([@koic][])
* [#11348](https://github.com/rubocop/rubocop/pull/11348): Fix an error for `Style/SelectByRegexp` when block body is empty. ([@koic][])
* [#11320](https://github.com/rubocop/rubocop/issues/11320): Fix a false positive for `Lint/RequireParentheses` when assigning ternary operator. ([@koic][])
* [#11361](https://github.com/rubocop/rubocop/issues/11361): Make `Style/MethodDefParentheses` aware of Ruby 3.2's anonymous rest and keyword rest arguments. ([@koic][])
* [#11346](https://github.com/rubocop/rubocop/issues/11346): Fix a false positive for `Style/RedundantStringEscape` when using escaped space in heredoc. ([@koic][])
* [#10858](https://github.com/rubocop/rubocop/issues/10858): Fix `Style/IdenticalConditionalBranches` to ignore identical leading lines when branch has single child and is used in return context. ([@fatkodima][])
* [#11237](https://github.com/rubocop/rubocop/issues/11237): Fix `Layout/CommentIndentation` comment aligned with access modifier indentation when EnforcedStyle is outdent. ([@soroktree][])
* [#11330](https://github.com/rubocop/rubocop/pull/11330): Fix an error for `Style/RequireOrder` when using `require` inside `rescue` body. ([@fatkodima][])
* [#8751](https://github.com/rubocop/rubocop/issues/8751): Accept `super` within ranges for `Layout/SpaceAroundKeyword` cop. ([@fatkodima][])
* [#10194](https://github.com/rubocop/rubocop/issues/10194): Accept bracketed arrays within 2d arrays containing subarrays with complex content for `Style/WordArray` cop. ([@fatkodima][])

### Changes

* [#8366](https://github.com/rubocop/rubocop/issues/8366): Ignore private constants in `Layout/ClassStructure` cop. ([@fatkodima][])
* [#11325](https://github.com/rubocop/rubocop/issues/11325): Support autocorrection for percent literals in `Style/ConcatArrayLiterals`. ([@fatkodima][])
* [#11327](https://github.com/rubocop/rubocop/pull/11327): Make `Style/ZeroLengthPredicate` aware of `array.length.zero?`. ([@koic][])
* [#10976](https://github.com/rubocop/rubocop/issues/10976): Support pattern matching for `Lint/OutOfRangeRegexpRef` cop. ([@fatkodima][])

## 1.41.1 (2022-12-22)

### Bug fixes

* [#11293](https://github.com/rubocop/rubocop/issues/11293): Fix a false negative for `Style/Documentation` when using macro. ([@koic][])
* [#11313](https://github.com/rubocop/rubocop/issues/11313): Fix a false positive for `Naming/BlockForwarding` when the block argument is reassigned. ([@fatkodima][])
* [#11014](https://github.com/rubocop/rubocop/pull/11014): Fix a false positive for `Style/Alias`cop when alias in a method def. ([@ydah][])
* [#11309](https://github.com/rubocop/rubocop/issues/11309): Fix a false positive for `Style/RedundantStringEscape` when using a redundant escaped string interpolation `\#\{foo}`. ([@koic][])
* [#11307](https://github.com/rubocop/rubocop/pull/11307): Fix an error for `Style/GuardClause` when using lvar as an argument of raise in `else` branch. ([@ydah][])
* [#11308](https://github.com/rubocop/rubocop/issues/11308): Fix disabling departments via comment. ([@fatkodima][])

### Changes

* [#11312](https://github.com/rubocop/rubocop/issues/11312): Mark `Style/ConcatArrayLiterals` as unsafe. ([@koic][])

## 1.41.0 (2022-12-20)

### New features

* [#11305](https://github.com/rubocop/rubocop/pull/11305): Add new `Style/RedundantDoubleSplatHashBraces` cop. ([@koic][])
* [#10812](https://github.com/rubocop/rubocop/pull/10812): New AllowMultilineFinalElement option for all LineBreaks cops. ([@Korri][])
* [#11277](https://github.com/rubocop/rubocop/issues/11277): Add new `Style/ConcatArrayLiterals` cop. ([@koic][])

### Bug fixes

* [#11255](https://github.com/rubocop/rubocop/pull/11255): Fix an error for `Style/RequireOrder` when `require` with no arguments is put between `require`. ([@ydah][])
* [#11273](https://github.com/rubocop/rubocop/issues/11273): Fix a false positive for `Lint/DuplicateMethods` when there are same `alias_method` name outside `rescue` or `ensure` scopes. ([@koic][])
* [#11267](https://github.com/rubocop/rubocop/issues/11267): Fix an error for `Style/RequireOrder` when modifier conditional is used between `require`. ([@ydah][])
* [#11254](https://github.com/rubocop/rubocop/pull/11254): Fix an error for `Style/RequireOrder` when `require` is a method argument. ([@koic][])
* [#11266](https://github.com/rubocop/rubocop/issues/11266): Fix a false positive for `Style/RedundantConstantBase` when enabling `Lint/ConstantResolution`. ([@koic][])
* [#11296](https://github.com/rubocop/rubocop/pull/11296): Fix an error for `Lint/NonAtomicFileOperation` when use file existence checks line break `unless` by postfix before creating file. ([@koic][])
* [#11284](https://github.com/rubocop/rubocop/issues/11284): Fix an incorrect autocorrect for `Style/WordArray` when assigning `%w()` array. ([@koic][])
* [#11299](https://github.com/rubocop/rubocop/pull/11299): Fix `base_dir` in `TargetFinder#find_files()`. ([@dukaev][])
* [#11250](https://github.com/rubocop/rubocop/pull/11250): Fix an error for `Style/GuardClause` when a method call whose last argument is not a string is in the condition body. ([@ydah][])
* [#11298](https://github.com/rubocop/rubocop/issues/11298): Fix `Lint/SafeNavigationChain` to correctly handle `[]` operator followed by save navigation and method chain. ([@fatkodima][])
* [#11256](https://github.com/rubocop/rubocop/issues/11256): Fix an incorrect autocorrect for `Style/HashSyntax` when without parentheses call expr follows after multiple keyword arguments method call. ([@koic][])
* [#11289](https://github.com/rubocop/rubocop/pull/11289): Correctly detect Rails version when using only parts of the framework, instead of the "rails" gem. ([@bdewater][])
* [#11262](https://github.com/rubocop/rubocop/pull/11262): Fix an error for `Style/IfUnlessModifier` when the body is a method call with hash splat. ([@fatkodima][])
* [#11281](https://github.com/rubocop/rubocop/pull/11281): Fix `NoMethodError` for `Style/Documentation` when a class nested under non-constant values. ([@arika][])

### Changes

* [#11306](https://github.com/rubocop/rubocop/pull/11306): Make `Style/IfWithSemicolon` aware of one line without `else` body. ([@koic][])

## 1.40.0 (2022-12-08)

### New features

* [#11179](https://github.com/rubocop/rubocop/pull/11179): Add `Style/RedundantConstantBase` cop. ([@r7kamura][])
* [#11205](https://github.com/rubocop/rubocop/pull/11205): Add `--[no-]auto-gen-enforced-style` CLI option. ([@ydah][])
* [#11235](https://github.com/rubocop/rubocop/pull/11235): Add `Style/RequireOrder` cop. ([@r7kamura][])
* [#11219](https://github.com/rubocop/rubocop/issues/11219): Make `Style/SelectByRegexp` aware of `!~` method. ([@koic][])
* [#11224](https://github.com/rubocop/rubocop/pull/11224): Add new cop `Style/ArrayIntersect` which replaces `(array1 & array2).any?` with `array1.intersect?(array2)`, method `Array#intersect?` was added in ruby 3.1. ([@KirIgor][])
* [#11211](https://github.com/rubocop/rubocop/pull/11211): Add autocorrect for `Lint/AssignmentInCondition`. ([@r7kamura][])

### Bug fixes

* [#5251](https://github.com/rubocop/rubocop/issues/5251): Fix loading of configuration in multi-file edge case. ([@NobodysNightmare][])
* [#11192](https://github.com/rubocop/rubocop/issues/11192): Fix a false positive for `Lint/ParenthesesAsGroupedExpression` when using a block argument. ([@ydah][])
* [#11143](https://github.com/rubocop/rubocop/issues/11143): Fix RedundantCopDisableDirective errors when encountering several department comments. ([@isarcasm][])
* [#11230](https://github.com/rubocop/rubocop/issues/11230): Fix an incorrect autocorrect for `Lint/SafeNavigationChain` when using safe navigation with `[]` operator followed by method chain. ([@koic][])
* [#11181](https://github.com/rubocop/rubocop/pull/11181): Fix pattern to match .tool-versions files that specify multiple runtimes. ([@noelblaschke][])
* [#11239](https://github.com/rubocop/rubocop/issues/11239): Fix an incorrect autocorrect for `Style/GuardClause` when using heredoc as an argument of raise in branch body. ([@koic][])
* [#11182](https://github.com/rubocop/rubocop/issues/11182): Fix an incorrect autocorrect for `EnforcedShorthandSyntax: always` of `Style/HashSyntax` with `Style/IfUnlessModifier` when using Ruby 3.1. ([@koic][])
* [#11184](https://github.com/rubocop/rubocop/issues/11184): Fix an error for `Lint/ShadowingOuterLocalVariable` when a block local variable has same name as an outer `until` scope variable. ([@koic][])
* [#11198](https://github.com/rubocop/rubocop/pull/11198): Fix an error for `Lint/EmptyConditionalBody` when one using line if/;/end without then body. ([@koic][])
* [#11196](https://github.com/rubocop/rubocop/issues/11196): Fix a false positive for `Style/GuardClause` when using `raise` in `then` body of `if..elsif..end` form. ([@koic][])
* [#11213](https://github.com/rubocop/rubocop/pull/11213): Support redundant department disable in scope of `Lint/RedundantCopDisableDirective` cop. ([@isarcasm][])
* [#11200](https://github.com/rubocop/rubocop/issues/11200): Fix an incorrect autocorrect for `Layout/MultilineMethodCallBraceLayout` when using method chain for heredoc argument in multiline literal brace layout. ([@koic][])
* [#11190](https://github.com/rubocop/rubocop/pull/11190): Fix an error for `Style/IfWithSemicolon` when using one line if/;/end without then body. ([@koic][])
* [#11244](https://github.com/rubocop/rubocop/pull/11244): Fix a false negative for `Style/RedundantReturn` when dynamic define methods. ([@ydah][])

### Changes

* [#11218](https://github.com/rubocop/rubocop/pull/11218): Update severity of `Bundler/DuplicatedGem`, `Bundler/InsecureProtocolSource`, `Gemspec/DeprecatedAttributeAssignment`, `Gemspec/DuplicatedAssignment`, `Gemspec/RequireMFA`, `Gemspec/RequiredRubyVersion`, and `Gemspec/RubyVersionGlobalsUsage` cops to warning. ([@koic][])
* [#11222](https://github.com/rubocop/rubocop/pull/11222): Make `Style/RedundantArgument` aware of `Array#sum`. ([@koic][])
* [#11070](https://github.com/rubocop/rubocop/issues/11070): Add ability to count method calls as one line to code length related `Metric` cops. ([@fatkodima][])
* [#11226](https://github.com/rubocop/rubocop/pull/11226): Make `Lint/Void` aware of used lambda and proc in void context. ([@koic][])
* [#11206](https://github.com/rubocop/rubocop/pull/11206): Change `Lint/InterpolationCheck` from `Safe: false` to `SafeAutoCorrect: false`. ([@r7kamura][])
* [#11212](https://github.com/rubocop/rubocop/issues/11212): Make `Lint/DeprecatedConstants` aware of deprecated `Struct::Group` and `Struct::Passwd` classes. ([@koic][])
* [#11236](https://github.com/rubocop/rubocop/pull/11236): Remove `respond_to` from default value of `AllowedMethods` for `Style/SymbolProc`. ([@koic][])
* [#11185](https://github.com/rubocop/rubocop/pull/11185): Make `Style/HashSyntax` aware of without parentheses call expr follows. ([@koic][])
* [#11203](https://github.com/rubocop/rubocop/pull/11203): Support multiple arguments on `Lint/SendWithMixinArgument`. ([@r7kamura][])
* [#11229](https://github.com/rubocop/rubocop/pull/11229): Add `cc` to `AllowedNames` of `MethodParameterName` cop. ([@tjschuck][])
* [#11116](https://github.com/rubocop/rubocop/issues/11116): Handle ternaries in `Style/SafeNavigation`. ([@fatkodima][])

## 1.39.0 (2022-11-14)

### New features

* [#11091](https://github.com/rubocop/rubocop/pull/11091): Add autocorrect for `Layout/LineContinuationLeadingSpace`. ([@FnControlOption][])

### Bug fixes

* [#11150](https://github.com/rubocop/rubocop/issues/11150): Improve `Style/RedundantRegexpEscape` to catch unnecessarily escaped hyphens within a character class. ([@si-lens][])
* [#11168](https://github.com/rubocop/rubocop/issues/11168): Fix an incorrect autocorrect for `Style/ClassEqualityComparison` when using instance variable comparison in module. ([@koic][])
* [#11176](https://github.com/rubocop/rubocop/pull/11176): Fix a false positive cases for `Lint/DuplicateMethods` when using duplicate nested method. ([@koic][])
* [#11164](https://github.com/rubocop/rubocop/issues/11164): Suppress "RuboCop server starting..." message with `--server --format json`. ([@koic][])
* [#11156](https://github.com/rubocop/rubocop/pull/11156): Fix `Style/OperatorMethodCall` autocorrection when operators are chained. ([@gsamokovarov][])
* [#11139](https://github.com/rubocop/rubocop/issues/11139): Fix a false negative for `Style/HashEachMethods` when using each with a symbol proc argument. ([@ydah][])
* [#11161](https://github.com/rubocop/rubocop/issues/11161): Fix a false positive for `Style/HashAsLastArrayItem` when using double splat operator. ([@koic][])
* [#11151](https://github.com/rubocop/rubocop/pull/11151): Fix a false positive for `Lint/SuppressedException`. ([@akihikodaki][])
* [#11123](https://github.com/rubocop/rubocop/issues/11123): Fix autocorrection bug for `Style/StringLiterals` when using multiple escape characters. ([@si-lens][])
* [#11165](https://github.com/rubocop/rubocop/issues/11165): Fix a false positive for `Style/RedundantEach` when any method is used between methods containing `each` in the method name. ([@koic][])
* [#11177](https://github.com/rubocop/rubocop/pull/11177): Fix a false positive for `Style/ObjectThen` cop with TargetRubyVersion < 2.6. ([@epaew][])
* [#11173](https://github.com/rubocop/rubocop/issues/11173): Fix an incorrect autocorrect for `Style/CollectionCompact` when using `reject` with block pass arg and no parentheses. ([@koic][])
* [#11137](https://github.com/rubocop/rubocop/issues/11137): Fix a false positive for `Style/RedundantEach` when using a symbol proc argument. ([@ydah][])
* [#11142](https://github.com/rubocop/rubocop/pull/11142): Fix `Style/RedundantEach` for non-chained `each_` calls. ([@fatkodima][])

### Changes

* [#11130](https://github.com/rubocop/rubocop/pull/11130): Check blank percent literal by `Layout/SpaceInsidePercentLiteralDelimiters`. ([@r7kamura][])
* [#11163](https://github.com/rubocop/rubocop/pull/11163): Mark `Style/HashExcept` as unsafe. ([@r7kamura][])
* [#11171](https://github.com/rubocop/rubocop/pull/11171): Support inline visibility definition on checking visibility. ([@r7kamura][])
* [#11158](https://github.com/rubocop/rubocop/pull/11158): Add `if` to allowed names list for MethodParameterName. ([@okuramasafumi][])

## 1.38.0 (2022-11-01)

### New features

* [#11110](https://github.com/rubocop/rubocop/pull/11110): Add new `Style/RedundantEach` cop. ([@koic][])
* [#10255](https://github.com/rubocop/rubocop/pull/10255): Add simple autocorrect for `Style/GuardClause`. ([@FnControlOption][])
* [#11126](https://github.com/rubocop/rubocop/pull/11126): Have `Lint/RedundantRequireStatement` mark `set` as a redundant require in Ruby 3.2+. ([@drenmi][])
* [#11001](https://github.com/rubocop/rubocop/pull/11001): Add option to raise cop errors `--raise-cop-error`. ([@wildmaples][])
* [#10987](https://github.com/rubocop/rubocop/pull/10987): Opt-in cop compatibility in redundant directives. ([@tdeo][])

### Bug fixes

* [#11125](https://github.com/rubocop/rubocop/pull/11125): Fix an error for `Layout/SpaceInsideHashLiteralBraces` when using method argument that both key and value are hash literals. ([@koic][])
* [#11132](https://github.com/rubocop/rubocop/issues/11132): Fix clobbering error on `Lint/EmptyConditionalBody`. ([@r7kamura][])
* [#11117](https://github.com/rubocop/rubocop/issues/11117): Fix a false positive for `Style/BlockDelimiters` when specifying `EnforcedStyle: semantic` and using a single line block with {} followed by a safe navigation method call. ([@koic][])
* [#11120](https://github.com/rubocop/rubocop/issues/11120): Fix an incorrect autocorrect for `Lint/RedundantRequireStatement` when using redundant `require` with modifier form. ([@koic][])

### Changes

* [#11131](https://github.com/rubocop/rubocop/pull/11131): Check newline in empty reference bracket on `Layout/SpaceInsideReferenceBrackets`. ([@r7kamura][])
* [#11045](https://github.com/rubocop/rubocop/pull/11045): Update the `Style/ModuleFunction` documentation to suggest `class << self` as an alternative. ([@rdeckard][])
* [#11006](https://github.com/rubocop/rubocop/issues/11006): Allow multiple `elsif` for `Style/IfWithBooleanLiteralBranches`. ([@koic][])
* [#11113](https://github.com/rubocop/rubocop/pull/11113): Report the count of files in the Worst and the Offense Count formatters. ([@hosamaly][])

## 1.37.1 (2022-10-24)

### Bug fixes

* [#11102](https://github.com/rubocop/rubocop/issues/11102): Fix an error for `Style/AccessModifierDeclarations` when using access modifier in a block. ([@koic][])
* [#11107](https://github.com/rubocop/rubocop/issues/11107): Fix a false positive for `Style/OperatorMethodCall` when a constant receiver uses an operator method. ([@koic][])
* [#11104](https://github.com/rubocop/rubocop/issues/11104): Fix an error for `Style/CollectionCompact` when using `reject` method and receiver is a variable. ([@koic][])
* [#11114](https://github.com/rubocop/rubocop/issues/11114): Fix an error for `Style/OperatorMethodCall` when using `obj.!`. ([@koic][])
* [#11088](https://github.com/rubocop/rubocop/issues/11088): Fix an error when specifying `SuggestExtensions: true`. ([@koic][])
* [#11089](https://github.com/rubocop/rubocop/issues/11089): Fix an error for `Style/RedundantStringEscape` when using character literals (e.g. `?a`). ([@ydah][])
* [#11098](https://github.com/rubocop/rubocop/issues/11098): Fix false positive for `Style/RedundantStringEscape`. ([@tdeo][])
* [#11095](https://github.com/rubocop/rubocop/pull/11095): Fix an error for `Style/RedundantStringEscape` cop when using `?\n` string character literal. ([@koic][])

## 1.37.0 (2022-10-20)

### New features

* [#11043](https://github.com/rubocop/rubocop/issues/11043): Add new `Lint/DuplicateMagicComment` cop. ([@koic][])
* [#10409](https://github.com/rubocop/rubocop/issues/10409): Add `--no-exclude-limit` CLI option. ([@r7kamura][])
* [#10986](https://github.com/rubocop/rubocop/pull/10986): Add autocorrect for `Style/StaticClass`. ([@FnControlOption][])
* [#11018](https://github.com/rubocop/rubocop/issues/11018): Add `AllowedMethods` and `AllowedPatterns` for `Lint/NestedMethodDefinition`. ([@koic][])
* [#11055](https://github.com/rubocop/rubocop/pull/11055): Implement `Lint/DuplicateMethods` for object singleton class. ([@tdeo][])
* [#10997](https://github.com/rubocop/rubocop/pull/10997): Make `rubocop` command aware of `--server` option from .rubocop and RUBOCOP_OPTS. ([@koic][])
* [#11079](https://github.com/rubocop/rubocop/issues/11079): Add new `Style/OperatorMethodCall` cop. ([@koic][])
* [#10439](https://github.com/rubocop/rubocop/issues/10439): Add new `Style/RedundantStringEscape` cop. ([@owst][])

### Bug fixes

* [#11034](https://github.com/rubocop/rubocop/issues/11034): Fix server mode behavior when using `--stderr`. ([@tdeo][])
* [#11028](https://github.com/rubocop/rubocop/issues/11028): Fix a false positive for `Lint/RequireParentheses` when using ternary operator in square brackets. ([@koic][])
* [#11051](https://github.com/rubocop/rubocop/issues/11051): Preserve comments on `Style/AccessModifierDeclarations` autocorrection. ([@r7kamura][])
* [#9116](https://github.com/rubocop/rubocop/issues/9116): Support `super` method in `Layout/FirstArgumentIndentation`. ([@tdeo][])
* [#11068](https://github.com/rubocop/rubocop/pull/11068): Fix a false positive for `Style/RedundantRegexpCharacterClass` when using starting with "\0" number. ([@koic][])
* [#11082](https://github.com/rubocop/rubocop/pull/11082): Fix an incorrect autocorrect for `Lint/SafeNavigationChain` when safe navigation on the right-hand side of the arithmetic operator. ([@ydah][])
* [#10982](https://github.com/rubocop/rubocop/pull/10982): Do not autocorrect parentheses for calls in assignments in conditional branches for `Style/MethodCallWithArgsParentheses` with `omit_parentheses`. ([@gsamokovarov][])
* [#11084](https://github.com/rubocop/rubocop/issues/11084): Fix an error for `Style/ParallelAssignment` when using parallel assignment in singleton method. ([@koic][])
* [#11078](https://github.com/rubocop/rubocop/pull/11078): Fix a false positive for `Style/RedundantBegin` when using endless method definition for `begin` with multiple statements. ([@koic][])
* [#11074](https://github.com/rubocop/rubocop/issues/11074): Fix a false positive for `Lint/RedundantDirGlobSort` when using `Dir.glob` with multiple arguments. ([@koic][])
* [#11025](https://github.com/rubocop/rubocop/issues/11025): Check comments for disables in `RedundantInitialize` cop. ([@HeroProtagonist][])
* [#11003](https://github.com/rubocop/rubocop/issues/11003): Fix clobbering exception in EmptyConditionalBody cop when if branch is empty but else is not. ([@srcoley][])
* [#11026](https://github.com/rubocop/rubocop/issues/11026): Fix an error occurred for `Style/SymbolArray` and `Style/WordArray` when empty percent array. ([@ydah][])
* [#11022](https://github.com/rubocop/rubocop/issues/11022): Fix an incorrect autocorrect for `Style/RedundantCondition`  when using redundant brackets access condition. ([@koic][])
* [#11037](https://github.com/rubocop/rubocop/issues/11037): Fix a false positive for `Style/CollectionCompact` when using `to_enum.reject` or `lazy.reject` methods with Ruby 3.0 or lower. ([@koic][])
* [#11017](https://github.com/rubocop/rubocop/pull/11017): Fix an autocorrect for `Lint/EmptyConditionalBody` that causes a SyntaxError when missing `if` and `else` body. ([@ydah][])
* [#11047](https://github.com/rubocop/rubocop/issues/11047): Fix an incorrect autocorrect for `Lint/SafeNavigationChain` when using `+@` and `-@` methods. ([@koic][])
* [#11015](https://github.com/rubocop/rubocop/pull/11015): Fix a false positive for `Style/HashSyntax` when without parentheses call expr follows after nested method call. ([@koic][])
* [#11067](https://github.com/rubocop/rubocop/issues/11067): Fix a false positive for `Lint/DuplicateRegexpCharacterClassElement` when using regexp character starts with escaped zero number. ([@koic][])
* [#11030](https://github.com/rubocop/rubocop/issues/11030): Fix an incorrect autocorrect for `Lint/UnusedMethodArgument` and `Style::ExplicitBlockArgument` when autocorrection conflicts for `&block` argument. ([@koic][])
* [#11069](https://github.com/rubocop/rubocop/issues/11069): Fix an incorrect autocorrect for `Lint/RedundantCopDisableDirective` when disable directive contains free comment. ([@koic][])
* [#11063](https://github.com/rubocop/rubocop/pull/11063): Preserve comments on `Style/AccessorGrouping` autocorrection. ([@r7kamura][])
* [#10994](https://github.com/rubocop/rubocop/issues/10994): Fix an error when running 3rd party gem that does not require server. ([@koic][])

### Changes

* [#11054](https://github.com/rubocop/rubocop/pull/11054): Implement correct behavior for compact mode for `Layout/SpaceInsideArrayLiteralBrackets`. ([@tdeo][])
* [#10924](https://github.com/rubocop/rubocop/issues/10924): `Style/NegatedIfElseCondition` also checks negative conditions inside parentheses. ([@tsugimoto][])
* [#11042](https://github.com/rubocop/rubocop/pull/11042): Mark `Lint/OrderedMagicComments` as unsafe autocorrection. ([@koic][])
* [#11057](https://github.com/rubocop/rubocop/pull/11057): Make `Lint/RedundantRequireStatement` aware of `pp`, `ruby2_keywords`, and `fiber`. ([@koic][])
* [#10988](https://github.com/rubocop/rubocop/pull/10988): Raise error when both safe and unsafe autocorrect options are specified. ([@koic][])
* [#11032](https://github.com/rubocop/rubocop/pull/11032): Detect empty Hash literal braces containing only newlines and spaces on `Layout/SpaceInsideHashLiteralBraces`. ([@r7kamura][])

## 1.36.0 (2022-09-01)

### New features

* [#10931](https://github.com/rubocop/rubocop/pull/10931): Add `AllowOnSelfClass` option to `Style/CaseEquality`. ([@sambostock][])

### Bug fixes

* [#10958](https://github.com/rubocop/rubocop/issues/10958): Fix an infinite loop for `Layout/SpaceInsideBlockBraces` when `EnforcedStyle` is `no_space` and using multiline block. ([@ydah][])
* [#10903](https://github.com/rubocop/rubocop/pull/10903): Skip forking off extra processes for parallel inspection when only a single file needs to be inspected. ([@wjwh][])
* [#10919](https://github.com/rubocop/rubocop/issues/10919): Fix a huge performance regression between 1.32.0 and 1.33.0. ([@ydah][])
* [#10951](https://github.com/rubocop/rubocop/issues/10951): Fix an autocorrection error for `Lint/EmptyConditionalBody` when some conditional branch is empty. ([@ydah][])
* [#10927](https://github.com/rubocop/rubocop/issues/10927): Fix a false positive for `Style/HashTransformKeys` and `Style/HashTransformValues` when not using transformed block argument. ([@koic][])
* [#10979](https://github.com/rubocop/rubocop/issues/10979): Fix a false positive for `Style/RedundantParentheses` when using parentheses with pin operator except for variables. ([@Tietew][])
* [#10962](https://github.com/rubocop/rubocop/pull/10962): Fix a false positive for `Lint/ShadowingOuterLocalVariable` when conditional with if/elsif/else branches. ([@ydah][])
* [#10969](https://github.com/rubocop/rubocop/issues/10969): Fix a false negative for `AllowedPatterns` of `Lint/AmbiguousBlockAssociation` when using a method chain. ([@jcalvert][])
* [#10963](https://github.com/rubocop/rubocop/issues/10963): Fix a false positive for `Layout/IndentationWidth` when using aligned empty `else` in pattern matching. ([@koic][])
* [#10975](https://github.com/rubocop/rubocop/pull/10975): Fix possible wrong autocorrection in namespace on `Style/PerlBackrefs`. ([@r7kamura][])

### Changes

* [#10928](https://github.com/rubocop/rubocop/pull/10928): Add more autocorrect support on `Style/EachForSimpleLoop`. ([@r7kamura][])
* [#10960](https://github.com/rubocop/rubocop/issues/10960): Add `as` to `AllowedNames` in default configuration for `Naming/MethodParameterName` cop. ([@koic][])
* [#10966](https://github.com/rubocop/rubocop/pull/10966): Add autocorrect support to `Style/AccessModifierDeclarations`. ([@r7kamura][])
* [#10940](https://github.com/rubocop/rubocop/pull/10940): Add server mode status to `-V` option. ([@koic][])

## 1.35.1 (2022-08-22)

### Bug fixes

* [#10926](https://github.com/rubocop/rubocop/issues/10926): Make `Style/SafeNavigation` aware of a redundant nil check. ([@koic][])
* [#10944](https://github.com/rubocop/rubocop/issues/10944): Fix an incorrect autocorrect for `Lint/LiteralInInterpolation` when using `"#{nil}"`. ([@koic][])
* [#10921](https://github.com/rubocop/rubocop/issues/10921): Fix an error when ERB pre-processing of the configuration file. ([@koic][])
* [#10936](https://github.com/rubocop/rubocop/issues/10936): Fix an error for `Lint/NonAtomicFileOperation` when using `FileTest.exist?` as a condition for `elsif`. ([@koic][])
* [#10920](https://github.com/rubocop/rubocop/issues/10920): Fix an incorrect autocorrect for `Style/SoleNestedConditional` when using nested conditional and branch contains a comment. ([@koic][])
* [#10939](https://github.com/rubocop/rubocop/issues/10939): Fix an error for `Style/Next` when line break before condition. ([@koic][])

## 1.35.0 (2022-08-12)

### New features

* [#9364](https://github.com/rubocop/rubocop/pull/9364): Add `Style/MagicCommentFormat` cop. ([@dvandersluis][], [@mattbearman][])
* [#10776](https://github.com/rubocop/rubocop/pull/10776): New option (`consistent`) for `EnforcedShorthandSyntax` in `Style/HashSyntax` to avoid mixing shorthand and non-shorthand hash keys in ruby 3.1. ([@h-lame][])

### Bug fixes

* [#10899](https://github.com/rubocop/rubocop/issues/10899): Fix an error for `Lint/ShadowingOuterLocalVariable` when the same variable name as a block variable is used in return value assignment of `if`. ([@koic][])
* [#10916](https://github.com/rubocop/rubocop/pull/10916): Fix an error when .rubocop.yml is empty. ([@koic][])
* [#10915](https://github.com/rubocop/rubocop/pull/10915): Fix numblock support to `Layout/BlockAlignment`, `Layout/BlockEndNewline`, `Layout/EmptyLinesAroundAccessModifier`, `Layout/EmptyLinesAroundBlockBody`, `Layout/IndentationWidth`, `Layout/LineLength`, `Layout/MultilineBlockLayout`, `Layout/SpaceBeforeBlockBraces`, `Lint/NextWithoutAccumulator`, `Lint/NonDeterministicRequireOrder`, `Lint/RedundantWithIndex`, `Lint/RedundantWithObject`, `Lint/UnreachableLoop`, `Lint/UselessAccessModifier`, `Lint/Void`, `Metrics/AbcSize`, `Metrics/CyclomaticComplexity`, `Style/CollectionMethods`, `Style/CombinableLoops`, `Style/EachWithObject`, `Style/For`, `Style/HashEachMethods`, `Style/InverseMethods`, `Style/MethodCalledOnDoEndBlock`, `Style/MultilineBlockChain`, `Style/Next`, `Style/ObjectThen`, `Style/Proc`, `Style/RedundantBegin`, `Style/RedundantSelf`, `Style/RedundantSortBy` and `Style/TopLevelMethodDefinition`. ([@gsamokovarov][])
* [#10895](https://github.com/rubocop/rubocop/issues/10895): Fix incorrect autocomplete in `Style/RedundantParentheses` when a heredoc is used in an array. ([@dvandersluis][])
* [#10909](https://github.com/rubocop/rubocop/pull/10909): Fix loading behavior on running without `bundle exec`. ([@r7kamura][])
* [#10913](https://github.com/rubocop/rubocop/issues/10913): Make `Style/ArgumentsForwarding` aware of anonymous block argument. ([@koic][])
* [#10911](https://github.com/rubocop/rubocop/pull/10911): Fix `Style/ClassMethodsDefinitions` for non-self receivers. ([@sambostock][])

### Changes

* [#10915](https://github.com/rubocop/rubocop/pull/10915): Depend on rubocop-ast 1.20.1 for numblocks support in #macro?. ([@gsamokovarov][])

## 1.34.1 (2022-08-09)

### Bug fixes

* [#10893](https://github.com/rubocop/rubocop/issues/10893): Fix an error when running `rubocop` without `bundle exec`. ([@koic][])

## 1.34.0 (2022-08-09)

### New features

* [#10170](https://github.com/rubocop/rubocop/pull/10170): Add new `InternalAffairs/SingleLineComparison` cop. ([@dvandersluis][])

### Bug fixes

* [#10552](https://github.com/rubocop/rubocop/issues/10552): Require RuboCop AST 1.20.0+ to fix a false positive for `Lint/OutOfRangeRegexpRef` when using fixed-encoding regopt. ([@koic][])
* [#10512](https://github.com/rubocop/rubocop/issues/10512): Fix a false positive for `Lint/ShadowingOuterLocalVariable` conditional statement and block variable. ([@ydah][])
* [#10864](https://github.com/rubocop/rubocop/pull/10864): `min` and `max` results in false positives for `Style/SymbolProc` similarly to `select` and `reject`. ([@mollerhoj][])
* [#10846](https://github.com/rubocop/rubocop/issues/10846): Fix a false negative for `Style/DoubleNegation` when there is a hash or an array at return location of method. ([@nobuyo][])
* [#10875](https://github.com/rubocop/rubocop/pull/10875): Fix an obsolete option configuration values are duplicated when generating `.rubocop_todo.yml`. ([@ydah][])
* [#10877](https://github.com/rubocop/rubocop/issues/10877): Fix crash with `Layout/BlockEndNewline` heredoc detection. ([@dvandersluis][])
* [#10859](https://github.com/rubocop/rubocop/issues/10859): Fix `Lint/Debugger` to be able to handle method chains correctly. ([@dvandersluis][])
* [#10883](https://github.com/rubocop/rubocop/issues/10883): Fix `Style/RedundantParentheses` to be able to detect offenses and properly correct when the end parentheses and comma are on their own line. ([@dvandersluis][])
* [#10881](https://github.com/rubocop/rubocop/issues/10881): Fix `Style/SoleNestedConditional` to properly wrap `block` and `csend` nodes when necessary. ([@dvandersluis][])
* [#10867](https://github.com/rubocop/rubocop/pull/10867): Mark autocorrection for `Lint/EmptyConditionalBody` as unsafe. ([@dvandersluis][])
* [#10871](https://github.com/rubocop/rubocop/issues/10871): Restore `RuboCop::ConfigLoader.project_root` as deprecated. ([@koic][])

### Changes

* [#10857](https://github.com/rubocop/rubocop/issues/10857): Add `AllowedPatterns` to `Style/NumericLiterals`. ([@dvandersluis][])
* [#10648](https://github.com/rubocop/rubocop/issues/10648): Allow `Style/TernaryParentheses` to take priority over `Style/RedundantParentheses` when parentheses are enforced. ([@dvandersluis][])
* [#10731](https://github.com/rubocop/rubocop/issues/10731): Show tip for suggested extensions that are installed but not loaded in .rubocop.yml. ([@nobuyo][])
* [#10845](https://github.com/rubocop/rubocop/pull/10845): Support Bundler-like namespaced feature on require config. ([@r7kamura][])
* [#10773](https://github.com/rubocop/rubocop/issues/10773): Require Parser 3.1.2.1 or higher. ([@dvandersluis][])

## 1.33.0 (2022-08-04)

### Bug fixes

* [#10830](https://github.com/rubocop/rubocop/issues/10830): Fix an incorrect autocorrect for `Layout/FirstArgumentIndentation` when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and `EnforcedStyle: consistent` of `Layout/FirstArgumentIndentation` and enabling `Layout/FirstMethodArgumentLineBreak`. ([@koic][])
* [#10825](https://github.com/rubocop/rubocop/issues/10825): Fix an incorrect autocorrect for `Style/ClassAndModuleChildren` when using nested one-liner class. ([@koic][])
* [#10843](https://github.com/rubocop/rubocop/issues/10843): Fix a false positive for `Style/HashExcept` when using `reject` and calling `include?` method with symbol array and second block value. ([@koic][])
* [#10853](https://github.com/rubocop/rubocop/pull/10853): Fix an autocorrect for `Style/RedundantSort` with logical operator. ([@ydah][])
* [#10842](https://github.com/rubocop/rubocop/issues/10842): Make server mode aware of `CacheRootDirectory` config option value, `RUBOCOP_CACHE_ROOT`, and `XDG_CACHE_HOME` environment variables. ([@koic][])
* [#10833](https://github.com/rubocop/rubocop/issues/10833): Fix an incorrect autocorrect for `Style/RedundantCondition` when branches contains arithmetic operation. ([@koic][])
* [#10864](https://github.com/rubocop/rubocop/issues/10864): Fix a false positive for `Style/SymbolProc` when using `Hash#reject`. ([@koic][])
* [#10771](https://github.com/rubocop/rubocop/issues/10771): Make server mode aware of `--cache-root` command line option. ([@koic][])
* [#10831](https://github.com/rubocop/rubocop/pull/10831): Fix an error when using `changed_parameters` in obsoletion.yml by external library. ([@koic][])
* [#10850](https://github.com/rubocop/rubocop/pull/10850): Fix `Style/ClassEqualityComparison` autocorrection within module. ([@r7kamura][])
* [#10832](https://github.com/rubocop/rubocop/issues/10832): Fix an incorrect autocorrect for `Layout/BlockEndNewline` when multiline block `}` is not on its own line and using heredoc argument. ([@koic][])

### Changes

* [#10841](https://github.com/rubocop/rubocop/pull/10841): Don't hash shared libraries for cache key. ([@ChrisBr][])
* [#10862](https://github.com/rubocop/rubocop/pull/10862): Add autocorrection to `Lint/EmptyConditionalBody`. ([@dvandersluis][])
* [#10829](https://github.com/rubocop/rubocop/pull/10829): Deprecate `IgnoredMethods` option in favor of the `AllowedMethods` and `AllowedPatterns` options. ([@ydah][])

## 1.32.0 (2022-07-21)

### New features

* [#10820](https://github.com/rubocop/rubocop/pull/10820): Add new `Style/EmptyHeredoc` cop. ([@koic][])
* [#10691](https://github.com/rubocop/rubocop/pull/10691): Add new `Layout/MultilineMethodParameterLineBreaks` cop. ([@Korri][])
* [#10790](https://github.com/rubocop/rubocop/pull/10790): Support `AllowComments` option for `Style/EmptyElse`. ([@ydah][])
* [#10792](https://github.com/rubocop/rubocop/pull/10792): Add new `Lint/RequireRangeParentheses` cop. ([@koic][])
* [#10692](https://github.com/rubocop/rubocop/pull/10692): Break long method definitions when auto-correcting. ([@Korri][])

### Bug fixes

* [#10824](https://github.com/rubocop/rubocop/pull/10824): Make `Lint/DeprecatedClassMethods` aware of `ENV.clone` and `ENV.dup`. ([@koic][])
* [#10788](https://github.com/rubocop/rubocop/issues/10788): Relax `Style/FetchEnvVar` to allow `ENV[]` in LHS of `||`. ([@j-miyake][])
* [#10813](https://github.com/rubocop/rubocop/issues/10813): Fix recursive deletion to suppression in `Lint/NonAtomicFileOperation`. ([@ydah][])
* [#10791](https://github.com/rubocop/rubocop/issues/10791): Fix an incorrect autocorrect for `Style/Semicolon` when using endless range before semicolon. ([@koic][])
* [#10781](https://github.com/rubocop/rubocop/pull/10781): Fix a suggestions for safer conversions for `Lint/NonAtomicFileOperation`. ([@ydah][])
* [#10263](https://github.com/rubocop/rubocop/pull/10263): Fix the value of `Enabled` leaking between configurations. ([@jonas054][])

### Changes

* [#10613](https://github.com/rubocop/rubocop/issues/10613): Allow autocorrecting with -P/--parallel and make it the default. ([@jonas054][])
* Add EnforcedStyle (leading/trailing) configuration to `Layout::LineContinuationLeadingSpace`. ([@bquorning][])
* [#10784](https://github.com/rubocop/rubocop/pull/10784): Preserve multiline semantics on `Style/SymbolArray` and `Style/WordArray`. ([@r7kamura][])
* [#10814](https://github.com/rubocop/rubocop/pull/10814): Avoid buffering stdout when running in server mode. ([@ccutrer][])
* [#10817](https://github.com/rubocop/rubocop/pull/10817): Add autocorrect support for `Lint/SafeNavigationChain`. ([@r7kamura][])
* [#10810](https://github.com/rubocop/rubocop/pull/10810): Support safe navigation operator on `Style/SymbolProc`. ([@r7kamura][])
* [#10803](https://github.com/rubocop/rubocop/pull/10803): Require RuboCop AST 1.9.1 or higher. ([@koic][])

## 1.31.2 (2022-07-07)

### Bug fixes

* [#10774](https://github.com/rubocop/rubocop/pull/10774): Fix false negatives in `Style/DocumentationMethod` when a public method is defined after a private one. ([@Darhazer][])
* [#10764](https://github.com/rubocop/rubocop/issues/10764): Fix performance issue for `Layout/FirstHashElementIndentation` and `Layout/FirstArrayElementIndentation`. ([@j-miyake][])
* [#10780](https://github.com/rubocop/rubocop/issues/10780): Fix an error when using `rubocop:auto_correct` deprecated custom rake task. ([@koic][])
* [#10786](https://github.com/rubocop/rubocop/issues/10786): Fix a false positive for `Lint/NonAtomicFileOperation` when using complex conditional. ([@koic][])
* [#10785](https://github.com/rubocop/rubocop/pull/10785): Fix a false negative for `Style/RedundantParentheses` when parens around a receiver of a method call with an argument. ([@koic][])
* [#10026](https://github.com/rubocop/rubocop/issues/10026): Fix merging of array parameters in either parent of default config. ([@jonas054][])

## 1.31.1 (2022-06-29)

### Bug fixes

* [#10763](https://github.com/rubocop/rubocop/issues/10763): Fix a false positive for `Layout/LineContinuationSpacing` when using continuation keyword `\` after `__END__`. ([@koic][])
* [#10755](https://github.com/rubocop/rubocop/issues/10755): Fix a false positive for `Lint/LiteralAsCondition` when using a literal in `case-in` condition where the match variable is used in `in` are accepted as a pattern matching. ([@koic][])
* [#10760](https://github.com/rubocop/rubocop/issues/10760): Fix a false positive for `Lint/NonAtomicFileOperation` when using `FileTest.exist?` with `if` condition that has `else` branch. ([@koic][])
* [#10745](https://github.com/rubocop/rubocop/issues/10745): Require JSON 2.3 or higher to fix an incompatible JSON API error. ([@koic][])
* [#10754](https://github.com/rubocop/rubocop/issues/10754): Fix an incorrect autocorrect for `Style/HashExcept` when using a non-literal collection receiver for `include?`. ([@koic][])
* [#10751](https://github.com/rubocop/rubocop/issues/10751): Fix autocorrect for `Layout/FirstHashElementIndentation`. ([@j-miyake][])
* [#10750](https://github.com/rubocop/rubocop/pull/10750): Recover 7x slow running `rubocop`. ([@koic][])

## 1.31.0 (2022-06-27)

### New features

* [#10699](https://github.com/rubocop/rubocop/pull/10699): Add new global `ActiveSupportExtensionsEnabled` option. ([@nobuyo][])
* [#10245](https://github.com/rubocop/rubocop/pull/10245): Add specification_version and rubygems_version to `Gemspec/DeprecatedAttributeAssignment`. ([@kaitielth][])
* [#10696](https://github.com/rubocop/rubocop/pull/10696): Add new `Lint/NonAtomicFileOperation` cop. ([@ydah][])
* [#6420](https://github.com/rubocop/rubocop/issues/6420): Add new `Layout/LineContinuationLeadingSpace` cop. ([@bquorning][])
* [#6420](https://github.com/rubocop/rubocop/issues/6420): Add new `Layout/LineContinuationSpacing` cop. ([@bquorning][])
* [#10706](https://github.com/rubocop/rubocop/pull/10706): Integrate rubocop-daemon to add server options. ([@koic][])
* [#10722](https://github.com/rubocop/rubocop/pull/10722): Add new `Lint/ConstantOverwrittenInRescue` cop. ([@ydah][])

### Bug fixes

* [#10700](https://github.com/rubocop/rubocop/issues/10700): Update `Style/EmptyMethod` to not correct if the correction would exceed the configuration for `Layout/LineLength`. ([@dvandersluis][])
* [#10698](https://github.com/rubocop/rubocop/issues/10698): Enhance `Style/HashExcept` to support array inclusion checks. ([@nobuyo][])
* [#10734](https://github.com/rubocop/rubocop/issues/10734): Handle `ClobberingError` in `Style/NestedTernaryOperator` when there are multiple nested ternaries. ([@dvandersluis][])
* [#10689](https://github.com/rubocop/rubocop/issues/10689): Fix autocorrect for `Layout/FirstHashElementIndentation` and `Layout/FirstArrayElementIndentation`. ([@j-miyake][])
* Fix `rubocop -V` not displaying the version information for rubocop-graphql, rubocop-md and rubocop-thread_safety. ([@Darhazer][])
* [#10711](https://github.com/rubocop/rubocop/issues/10711): Fix an error for `Style/MultilineTernaryOperator` when the false branch is on a separate line. ([@koic][])
* [#10719](https://github.com/rubocop/rubocop/issues/10719): Fix a false positive for `Lint/ParenthesesAsGroupedExpression` when using safe navigation operator. ([@koic][])
* [#10736](https://github.com/rubocop/rubocop/pull/10736): Fix `Layout/SpaceInsideBlockBraces` for blocks with numbered arguments. ([@gsamokovarov][])
* [#10749](https://github.com/rubocop/rubocop/pull/10749): Fix `Style/BlockDelimiters` for blocks with numbered arguments. ([@gsamokovarov][])
* [#10737](https://github.com/rubocop/rubocop/issues/10737): Fix crash in `Style/ConditionalAssignment` with `EnforcedStyle: assign_inside_condition` when op-assigning a variable inside a `resbody`. ([@dvandersluis][])
* [#7900](https://github.com/rubocop/rubocop/issues/7900): Fix `Style/FormatStringToken` false positive with formatted input and `template` style enforced, and add autocorrection. ([@FnControlOption][])

### Changes

* [#10730](https://github.com/rubocop/rubocop/pull/10730): Change output timing of GitHubActionsFormatter. ([@r7kamura][])
* [#10709](https://github.com/rubocop/rubocop/pull/10709): Deprecate `rubocop:auto_correct` custom rake task and newly split `rubocop:autocorrect` and `rubocop:autocorrect-all` custom rake tasks. ([@koic][])
* [#9760](https://github.com/rubocop/rubocop/issues/9760): Change RangeHelp#range_with_surrounding_space to allow passing the range as a positional argument. ([@pirj][])
* [#10693](https://github.com/rubocop/rubocop/issues/10693): Add ignore case for `Layout/EmptyLinesAroundAttributeAccessor` when there is a comment line on the next line. ([@ydah][])
* [#10245](https://github.com/rubocop/rubocop/pull/10245): **(Breaking)** integrate `Gemspec/DateAssignment` into `Gemspec/DeprecatedAttributeAssignment`. ([@kaitielth][])
* [#10697](https://github.com/rubocop/rubocop/pull/10697): Restore `Lint/UselessElseWithoutRescue` cop. ([@koic][])
* [#10740](https://github.com/rubocop/rubocop/pull/10740): Make `Style/GuardClause` a bit more lenient when the replacement would make the code more verbose. ([@dvandersluis][])

## 1.30.1 (2022-06-06)

### Bug fixes

* [#10685](https://github.com/rubocop/rubocop/issues/10685): Fix a false positive for `Style/StringConcatenation` when `Mode: conservative` and first operand is not string literal. ([@koic][])
* [#10670](https://github.com/rubocop/rubocop/pull/10670): Fix a false positive for `Style/FetchEnvVar` in the body with assignment method. ([@ydah][])
* [#10671](https://github.com/rubocop/rubocop/issues/10671): Fix an incorrect autocorrect for `EnforcedStyle: with_first_argument` of `Layout/ArgumentAlignment` and `EnforcedColonStyle: separator` of `Layout/HashAlignment`. ([@koic][])
* [#10676](https://github.com/rubocop/rubocop/pull/10676): Fix `--ignore-unrecognized-cops` option always showing empty warning even if there was no problem. ([@nobuyo][])
* [#10674](https://github.com/rubocop/rubocop/issues/10674): Fix a false positive for `Naming/AccessorMethodName` with type of the first argument is other than `arg`. ([@ydah][])
* [#10679](https://github.com/rubocop/rubocop/issues/10679): Fix a false positive for `Style/SafeNavigation` when `TargetRubyVersion: 2.2` or lower. ([@koic][])

### Changes

* [#10673](https://github.com/rubocop/rubocop/pull/10673): Update auto-gen-config's comment re auto-correct for `SafeAutoCorrect: false`. ([@ydah][])

## 1.30.0 (2022-05-26)

### New features

* [#10065](https://github.com/rubocop/rubocop/issues/10065): Add new `Gemspec/DeprecatedAttributeAssignment` cop. ([@koic][])
* [#10608](https://github.com/rubocop/rubocop/pull/10608): Add new `Style/MapCompactWithConditionalBlock` cop. ([@nobuyo][])
* [#10627](https://github.com/rubocop/rubocop/issues/10627): Add command-line option `--ignore-unrecognized-cops` to ignore any unknown cops or departments in .rubocop.yml. ([@nobuyo][])
* [#10620](https://github.com/rubocop/rubocop/pull/10620): Add Sorbet's `typed` sigil as a magic comment. ([@zachahn][])

### Bug fixes

* [#10662](https://github.com/rubocop/rubocop/pull/10662): Recover Ruby 2.1 code analysis using `TargetRubyVersion: 2.1`. ([@koic][])
* [#10396](https://github.com/rubocop/rubocop/issues/10396): Fix autocorrect for `Layout/IndentationWidth` to leave module/class body unchanged to avoid infinite autocorrect loop with `Layout/IndentationConsistency` when body trails after class/module definition. ([@johnny-miyake][])
* [#10636](https://github.com/rubocop/rubocop/issues/10636): Fix false positive in `Style/RedundantCondition` when the branches call the same method on different receivers. ([@dvandersluis][])
* [#10651](https://github.com/rubocop/rubocop/issues/10651): Fix autocorrect for `Style/For` when using array with operator methods as collection. ([@nobuyo][])
* [#10629](https://github.com/rubocop/rubocop/pull/10629): Fix default Ruby version from 2.5 to 2.6. ([@koic][])
* [#10661](https://github.com/rubocop/rubocop/pull/10661): Fix a false negative for `Style/SymbolProc` when method has no arguments and `AllowMethodsWithArguments: true`. ([@koic][])
* [#10631](https://github.com/rubocop/rubocop/issues/10631): Fix autocorrect for `Style/RedundantBegin`. ([@johnny-miyake][])
* [#10652](https://github.com/rubocop/rubocop/issues/10652): Fix a false positive for `Style/FetchEnvVar` in conditions. ([@ydah][])
* [#10665](https://github.com/rubocop/rubocop/issues/10665): Fix an incorrect autocorrect for `EnforcedStyle: with_first_argument` of `Layout/ArgumentAlignment` and `EnforcedColonStyle: separator` of `Layout/HashAlignment`. ([@koic][])
* [#10258](https://github.com/rubocop/rubocop/issues/10258): Recover Ruby 2.4 code analysis using `TargetRubyVersion: 2.4`. ([@koic][])
* [#10668](https://github.com/rubocop/rubocop/pull/10668): Recover Ruby 2.0 code analysis using `TargetRubyVersion: 2.0`. ([@koic][])
* [#10644](https://github.com/rubocop/rubocop/pull/10644): Recover Ruby 2.2 code analysis using `TargetRubyVersion: 2.2`. ([@koic][])
* [#10639](https://github.com/rubocop/rubocop/issues/10639): Fix `Style/HashSyntax` to exclude files that violate it with `EnforceHashShorthandSyntax` when running `auto-gen-config`. ([@nobuyo][])
* [#10633](https://github.com/rubocop/rubocop/issues/10633): Fix infinite autocorrection loop in `Style/AccessorGrouping` when combining multiple of the same accessor. ([@dvandersluis][])
* [#10618](https://github.com/rubocop/rubocop/issues/10618): Fix `LineBreakCorrector` so that it won't remove a semicolon in the class/module body. ([@johnny-miyake][])
* [#10646](https://github.com/rubocop/rubocop/issues/10646): Fix an incorrect autocorrect for `Style/SoleNestedConditional` when using `unless` and `&&` without parens in the outer condition and nested modifier condition. ([@koic][])
* [#10659](https://github.com/rubocop/rubocop/issues/10659): Fix automatically appended path for `inherit_from` by `auto-gen-config` is incorrect if specified config file in a subdirectory as an option. ([@nobuyo][])
* [#10640](https://github.com/rubocop/rubocop/pull/10640): Recover Ruby 2.3 code analysis using `TargetRubyVersion: 2.3`. ([@koic][])
* [#10657](https://github.com/rubocop/rubocop/issues/10657): Fix `--auto-gen-config` command option ignores specified config file by option. ([@nobuyo][])

### Changes

* [#10095](https://github.com/rubocop/rubocop/issues/10095): Change "auto-correct" to "autocorrect" in arguments, documentation, messages, comments, and specs. ([@chris-hewitt][])
* [#10656](https://github.com/rubocop/rubocop/issues/10656): Mark `Style/RedundantInterpolation` as unsafe autocorrection. ([@koic][])
* [#10616](https://github.com/rubocop/rubocop/pull/10616): Markdown formatter: skip files with no offenses. ([@rickselby][])

## 1.29.1 (2022-05-12)

### Bug fixes

* [#10625](https://github.com/rubocop/rubocop/issues/10625): Restore the specification to `TargetRubyVersion: 2.5`. ([@koic][])
* [#10569](https://github.com/rubocop/rubocop/issues/10569): Fix a false positive for `Style/FetchEnvVar` when using the same `ENV` var as `if` condition in the body. ([@koic][])
* [#10614](https://github.com/rubocop/rubocop/issues/10614): Make `Lint/NonDeterministicRequireOrder` aware of `require_relative`. ([@koic][])
* [#10607](https://github.com/rubocop/rubocop/issues/10607): Fix autocorrect for `Style/RedundantCondition` when there are parenthesized method calls in each branch. ([@nobuyo][])
* [#10622](https://github.com/rubocop/rubocop/issues/10622): Fix a false positive for `Style/RaiseArgs` when error type class constructor with keyword arguments and message argument. ([@koic][])
* [#10610](https://github.com/rubocop/rubocop/pull/10610): Fix an error for `Naming/InclusiveLanguage` string with invalid byte sequence in UTF-8. ([@ydah][])
* [#10605](https://github.com/rubocop/rubocop/issues/10605): Fix autocorrect for `Style/RedundantCondition` if argument for method in else branch is hash without braces. ([@nobuyo][])

## 1.29.0 (2022-05-06)

### New features

* [#10570](https://github.com/rubocop/rubocop/issues/10570): Add new `Gemspec/DependencyVersion` cop. ([@nobuyo][])
* [#10542](https://github.com/rubocop/rubocop/pull/10542): Add markdown formatter. ([@joe-sharp][])
* [#10539](https://github.com/rubocop/rubocop/issues/10539): Add `AllowedPatterns` configuration option to `Naming/VariableNumber` and `Naming/VariableName`. ([@henrahmagix][])
* [#10568](https://github.com/rubocop/rubocop/issues/10568): Add new `Style/EnvHome` cop. ([@koic][])

### Bug fixes

* [#10586](https://github.com/rubocop/rubocop/issues/10586): Fix a false positive for `Style/DoubleNegation` when using `define_method` or `define_singleton_method`. ([@ydah][])
* [#10579](https://github.com/rubocop/rubocop/issues/10579): Fix a false positive for `Style/FetchEnvVar` when calling a method with safe navigation. ([@koic][])
* [#10581](https://github.com/rubocop/rubocop/issues/10581): Fix a false positive for `Style/FetchEnvVar` when comparing with `ENV['TERM']`. ([@koic][])
* [#10589](https://github.com/rubocop/rubocop/issues/10589): Fix autocorrect for `Style/RaiseArgs` with `EnforcedStyle: compact` and exception object is assigned to a local variable. ([@nobuyo][])
* [#10325](https://github.com/rubocop/rubocop/issues/10325): Enhance `Style/RedundantCondition` by considering the case that variable assignments in each branch. ([@nobuyo][])
* [#10592](https://github.com/rubocop/rubocop/issues/10592): Fix infinite loop on `Style/MultilineTernaryOperator` if using assignment method and condition/branch is multiline. ([@nobuyo][])
* [#10536](https://github.com/rubocop/rubocop/issues/10536): Fix validation for command-line options combination of `--display-only-fail-level-offenses` and `--auto-correct`. ([@nobuyo][])

### Changes

* [#10577](https://github.com/rubocop/rubocop/pull/10577): **(Compatibility)** Drop support for Ruby 2.5 and JRuby 9.2 (CRuby 2.5 compatible). ([@koic][])
* [#10585](https://github.com/rubocop/rubocop/pull/10585): Enhance the autocorrect for `Style/FetchEnvVar`. ([@johnny-miyake][])
* [#10577](https://github.com/rubocop/rubocop/pull/10577): **(Breaking)** Retire `Lint/UselessElseWithoutRescue` cop. ([@koic][])

## 1.28.2 (2022-04-25)

### Bug fixes

* [#10566](https://github.com/rubocop/rubocop/issues/10566): Fix a false positive for `Lint/AmbiguousBlockAssociation` when using proc is used as a last argument. ([@koic][])
* [#10573](https://github.com/rubocop/rubocop/issues/10573): Fix a false positive for `Layout/SpaceBeforeBrackets` when there is a dot before brackets. ([@nobuyo][])
* [#10563](https://github.com/rubocop/rubocop/issues/10563): Fix `Style/BlockDelimiters` unexpectedly deletes block on moving comment if methods with block are chained. ([@nobuyo][])
* [#10574](https://github.com/rubocop/rubocop/issues/10574): Fix a false positive for `Style/SingleArgumentDig` when using dig with arguments forwarding. ([@ydah][])
* [#10565](https://github.com/rubocop/rubocop/pull/10565): Fix a false positive and a true negative for `Style/FetchEnvVar`. ([@koic][])

## 1.28.1 (2022-04-21)

### Bug fixes

* [#10559](https://github.com/rubocop/rubocop/issues/10559): Fix crash on CodeLengthCalculator if method call is not parenthesized. ([@nobuyo][])
* [#10557](https://github.com/rubocop/rubocop/issues/10557): Fix a false positive for `Style/FetchEnvVar` when `ENV['key']` is a receiver of `||=`. ([@koic][])

## 1.28.0 (2022-04-21)

### New features

* [#10551](https://github.com/rubocop/rubocop/pull/10551): Add `AllowComments` option to `Style/RedundantInitialize` is true by default. ([@koic][])
* [#10552](https://github.com/rubocop/rubocop/pull/10552): Support autocorrection for `Style/RedundantInitialize`. ([@koic][])
* [#10441](https://github.com/rubocop/rubocop/pull/10441): Add `Security/CompoundHash` cop. ([@sambostock][], [@chrisseaton][])
* [#10521](https://github.com/rubocop/rubocop/pull/10521): Add `use_builtin_english_names` style to `Style/SpecialGlobalVars`. ([@splattael][])
* [#10522](https://github.com/rubocop/rubocop/issues/10522): Add new `Style/ObjectThen` cop. ([@ydah][])
* [#10502](https://github.com/rubocop/rubocop/pull/10502): Add new `Style/FetchEnvVar` cop. ([@johnny-miyake][])
* [#10544](https://github.com/rubocop/rubocop/pull/10544): Support auto-correction for `Lint/DuplicateRequire`. ([@koic][])
* [#10481](https://github.com/rubocop/rubocop/issues/10481): Add command line options `--display-only-correctable` and `--display-only-safe-correctable`. ([@nobuyo][])

### Bug fixes

* [#10528](https://github.com/rubocop/rubocop/issues/10528): Fix an infinite loop at autocorrect for `Layout/CaseIndentation`. ([@ydah][])
* [#10537](https://github.com/rubocop/rubocop/pull/10537): Fix an incorrect auto-correct for `Style/MultilineTernaryOperator` when returning a multiline ternary operator expression with `break`, `next`, or method call. ([@koic][])
* [#10529](https://github.com/rubocop/rubocop/issues/10529): Fix autocorrect for `Style/SoleNestedConditional` causes logical error when using a outer condition of method call by omitting parentheses for method arguments. ([@nobuyo][])
* [#10530](https://github.com/rubocop/rubocop/issues/10530): Fix a false positive for `Style/RedundantRegexpCharacterClass` when using regexp character class with a character class containing multiple unicode code-points. ([@koic][])
* [#10518](https://github.com/rubocop/rubocop/pull/10518): Fix a false positive for `Style/DoubleNegation` when inside returned conditional clauses with Ruby 2.7's pattern matching. ([@koic][])
* [#10510](https://github.com/rubocop/rubocop/issues/10510): Fix an error for `Style/SingleArgumentDig` when using multiple `dig` in a method chain. ([@koic][])
* [#10553](https://github.com/rubocop/rubocop/issues/10553): Fix crash with trailing tabs in heredocs for `Layout/TrailingWhitespace`. ([@dvandersluis][])
* [#10488](https://github.com/rubocop/rubocop/issues/10488): Fix autocorrection for `Layout/MultilineMethodCallIndentation` breaks indentation for nesting of method calls. ([@nobuyo][])
* [#10543](https://github.com/rubocop/rubocop/pull/10543): Fix incorrect code length calculation for few more patterns of hash folding asked. ([@nobuyo][])
* [#10541](https://github.com/rubocop/rubocop/pull/10541): Fix an incorrect autocorrect for `Style/SpecialGlobalVars` when global variable as Perl name is used multiple times. ([@koic][])
* [#10514](https://github.com/rubocop/rubocop/issues/10514): Fix an error for `Lint/EmptyConditionalBody` when missing second `elsif` body. ([@koic][])
* [#10469](https://github.com/rubocop/rubocop/issues/10469): Fix code length calculation when kwargs written in single line. ([@nobuyo][])

### Changes

* [#10555](https://github.com/rubocop/rubocop/pull/10555): Deprecate `IgnoredPatterns` in favour of `AllowedPatterns`. ([@dvandersluis][])
* [#10356](https://github.com/rubocop/rubocop/issues/10356): Add `AllowConsecutiveConditionals` option to `Style/GuardClause` and the option is false by default. ([@ydah][])
* [#10524](https://github.com/rubocop/rubocop/issues/10524): Mark `Style/RedundantInitialize` as unsafe. ([@koic][])
* [#10280](https://github.com/rubocop/rubocop/issues/10280): Add `AllowComments` option to `Style/SymbolProc` and the option is false by default. ([@ydah][])

## 1.27.0 (2022-04-08)

### New features

* [#10500](https://github.com/rubocop/rubocop/pull/10500): Add new `Lint/RefinementImportMethods` cop. ([@koic][])
* [#10438](https://github.com/rubocop/rubocop/issues/10438): Add new `Style/RedundantInitialize` cop to check for unnecessary `initialize` methods. ([@dvandersluis][])

### Bug fixes

* [#10464](https://github.com/rubocop/rubocop/issues/10464): Fix an incorrect autocorrect for `Lint/IncompatibleIoSelectWithFiberScheduler` when using `IO.select` with read (or write) argument and using return value. ([@koic][])
* [#10506](https://github.com/rubocop/rubocop/issues/10506): Fix an error for `Style/RaiseArgs` when `raise` with `new` method without receiver. ([@koic][])
* [#10479](https://github.com/rubocop/rubocop/issues/10479): Fix a false positive for `Lint/ShadowingOuterLocalVariable` conditional statement and block variable. ([@ydah][])
* [#10189](https://github.com/rubocop/rubocop/issues/10189): Fix `--display-style-guide` so it works together with `--format offenses`. ([@jonas054][])
* [#10465](https://github.com/rubocop/rubocop/issues/10465): Fix false positive for `Naming/BlockForwarding` when the block argument is assigned. ([@dvandersluis][])
* [#10491](https://github.com/rubocop/rubocop/pull/10491): Improve the handling of comments in `Lint/EmptyConditionalBody`, `Lint/EmptyInPattern` and `Lint/EmptyWhen` when `AllowComments` is set to `true`. ([@Darhazer][])
* [#10504](https://github.com/rubocop/rubocop/issues/10504): Fix a false positive for `Lint/UnusedMethodArgument` when using `raise NotImplementedError` with optional arguments. ([@koic][])
* [#10494](https://github.com/rubocop/rubocop/issues/10494): Fix a false positive for `Style/HashSyntax` when `return` with one line `if` condition follows (without parentheses). ([@koic][])
* [#10311](https://github.com/rubocop/rubocop/issues/10311): Fix false negative inside `do`..`end` for `Layout/RedundantLineBreak`. ([@jonas054][])
* [#10468](https://github.com/rubocop/rubocop/issues/10468): Fix a false positive for `Style/FileWrite` when a splat argument is passed to `f.write`. ([@koic][])
* [#10474](https://github.com/rubocop/rubocop/issues/10474): Fix a false positive for `Style/DoubleNegation` with `EnforcedStyle: allowed_in_returns` when inside returned conditional clauses. ([@ydah][])
* [#10388](https://github.com/rubocop/rubocop/issues/10388): Fix an incorrectly adds a disable statement for `Layout/SpaceInsideArrayLiteralBrackets` with `--disable-uncorrectable`. ([@ydah][])
* [#10489](https://github.com/rubocop/rubocop/issues/10489): Fix a false positive for `Lint/LambdaWithoutLiteralBlock` when using lambda with a symbol proc. ([@koic][])

### Changes

* [#10191](https://github.com/rubocop/rubocop/issues/10191): Add `MaxChainLength` option to `Style/SafeNavigation` and the option is 2 by default. ([@ydah][])

## 1.26.1 (2022-03-22)

### Bug fixes

* [#10375](https://github.com/rubocop/rubocop/pull/10375): Fix error for auto-correction of `unless`/`else` nested inside each other. ([@jonas054][])
* [#10457](https://github.com/rubocop/rubocop/pull/10457): Make `Style/SelectByRegexp` aware of `ENV` const. ([@koic][])
* [#10462](https://github.com/rubocop/rubocop/issues/10462): Fix an incorrect autocorrect for `Lint/SymbolConversion` when using a quoted symbol key with hash rocket. ([@koic][])
* [#10456](https://github.com/rubocop/rubocop/issues/10456): Fix a false positive for `Layout/MultilineMethodCallIndentation` when using `EnforcedStyle: indented` with indented assignment method. ([@koic][])
* [#10459](https://github.com/rubocop/rubocop/pull/10459): Fix a false positive for `Layout/LineLength` when long URIs in yardoc comments to have titles. ([@ydah][])
* [#10447](https://github.com/rubocop/rubocop/pull/10447): Fix an error for `Style/SoleNestedConditional` raises exception when inspecting `if ... end if ...`. ([@ydah][])

## 1.26.0 (2022-03-09)

### New features

* [#10419](https://github.com/rubocop/rubocop/pull/10419): Add new `Style/NestedFileDirname` cop. ([@koic][])
* [#10433](https://github.com/rubocop/rubocop/pull/10433): Support `TargetRubyVersion 3.2` (experimental). ([@koic][])

### Bug fixes

* [#10406](https://github.com/rubocop/rubocop/pull/10406): Fix a false positive for `Lint/InheritException` when inheriting a standard lib exception class that is not a subclass of `StandardError`. ([@koic][])
* [#10421](https://github.com/rubocop/rubocop/issues/10421): Make `Style/DefWithParentheses` aware of endless method definition. ([@koic][])
* [#10401](https://github.com/rubocop/rubocop/issues/10401): Fix a false positive for `Style/HashSyntax` when local variable hash key and hash value are the same. ([@koic][])
* [#10424](https://github.com/rubocop/rubocop/pull/10424): Fix a false positive for `Security/YAMLLoad` when using Ruby 3.1+ (Psych 4). ([@koic][])
* [#10446](https://github.com/rubocop/rubocop/pull/10446): `Lint/RedundantDirGlobSort` unset SafeAutoCorrect. ([@friendlyantz][])
* [#10403](https://github.com/rubocop/rubocop/issues/10403): Fix an error for `Style/StringConcatenation` when string concatenation with multiline heredoc text. ([@koic][])
* [#10432](https://github.com/rubocop/rubocop/pull/10432): Fix an error when using regexp with non-encoding option. ([@koic][])
* [#10415](https://github.com/rubocop/rubocop/issues/10415): Fix an error for `Lint/UselessTimes` when using `1.times` with method chain. ([@koic][])

### Changes

* [#10408](https://github.com/rubocop/rubocop/pull/10408): Mark `Lint/InheritException` as unsafe auto-correction. ([@koic][])
* [#10407](https://github.com/rubocop/rubocop/pull/10407): Change `EnforcedStyle` from `runtime_error` to `standard_error` for `Lint/InheritException`. ([@koic][])
* [#10414](https://github.com/rubocop/rubocop/pull/10414): Update auto-gen-config's auto-correction comments to be more clear. ([@maxjacobson][])
* [#10427](https://github.com/rubocop/rubocop/issues/10427): Mark `Style/For` as unsafe auto-correction. ([@issyl0][])
* [#10410](https://github.com/rubocop/rubocop/issues/10410): Improve help string for `--fail-level` CLI option. ([@tejasbubane][])

## 1.25.1 (2022-02-03)

### Bug fixes

* [#10359](https://github.com/rubocop/rubocop/issues/10359): Fix a false positive and negative for `Style/HashSyntax` when using hash value omission. ([@koic][])
* [#10387](https://github.com/rubocop/rubocop/issues/10387): Fix an error for `Style/RedundantBegin` when assigning nested `begin` blocks. ([@koic][])
* [#10366](https://github.com/rubocop/rubocop/issues/10366): Fix a false positive for `Style/MethodCallWithArgsParentheses` when setting `EnforcedStyle: omit_parentheses` and using hash value omission with modifier from. ([@koic][])
* [#10376](https://github.com/rubocop/rubocop/issues/10376): Fix an error for `Layout/RescueEnsureAlignment` when using `.()` call with block. ([@koic][])
* [#10364](https://github.com/rubocop/rubocop/issues/10364): Fix an infinite loop error for `Layout/HashAlignment` when `EnforcedStyle: with_fixed_indentation` is specified for `Layout/ArgumentAlignment`. ([@koic][])
* [#10371](https://github.com/rubocop/rubocop/pull/10371): Fix a false negative for `Style/HashSyntax` when `Hash[foo: foo]` or `{foo: foo}` is followed by a next expression. ([@koic][])
* [#10394](https://github.com/rubocop/rubocop/issues/10394): Fix an error for `Style/SwapValues` when assigning receiver object at `def`. ([@koic][])
* [#10379](https://github.com/rubocop/rubocop/issues/10379): Fix an error for `Layout/EmptyLinesAroundExceptionHandlingKeywords` when `rescue` and `end` are on the same line. ([@koic][])

## 1.25.0 (2022-01-18)

### New features

* [#10351](https://github.com/rubocop/rubocop/pull/10351): Support `EnforcedShorthandSyntax: either` option for `Style/HashSyntax`. ([@koic][])
* [#10339](https://github.com/rubocop/rubocop/issues/10339): Support auto-correction for `EnforcedStyle: explicit` of `Naming/BlockForwarding`. ([@koic][])

### Bug fixes

* [#10344](https://github.com/rubocop/rubocop/pull/10344): Fix a false positive for `Style/CollectionCompact` when without receiver for bad methods. ([@koic][])
* [#10353](https://github.com/rubocop/rubocop/pull/10353): Use `:ambiguous_regexp` to detect ambiguous Regexp in Ruby 3. ([@danieldiekmeier][], [@joergschiller][])
* [#10336](https://github.com/rubocop/rubocop/issues/10336): Fix a false positive for `Style/TernaryParentheses` when using `in` keyword pattern matching as a ternary condition. ([@koic][])
* [#10317](https://github.com/rubocop/rubocop/issues/10317): Fix a false positive for `Style/MethodCallWithArgsParentheses` when using hash value omission. ([@koic][])
* [#8032](https://github.com/rubocop/rubocop/issues/8032): Improve ArgumentAlignment detection and correction for keyword arguments. ([@mvz][])
* [#10331](https://github.com/rubocop/rubocop/pull/10331): Fix cop generator for nested departments. ([@fatkodima][])
* [#10357](https://github.com/rubocop/rubocop/pull/10357): Fix a false positive for `Style/HashSyntax` when omitting the value. ([@berkos][])
* [#10335](https://github.com/rubocop/rubocop/issues/10335): Fix a false positive for `Naming/BlockForwarding` when using multiple proc arguments. ([@koic][])
* [#10350](https://github.com/rubocop/rubocop/pull/10350): Fix a false negative for `Lint/IncompatibleIoSelectWithFiberScheduler` when using `IO.select` with the first argument only. ([@koic][])
* [#10358](https://github.com/rubocop/rubocop/pull/10358): Fix `Style/Sample` crash on beginless and endless range shuffle indexes. ([@gsamokovarov][])
* [#10354](https://github.com/rubocop/rubocop/pull/10354): Fix `Gemspec/RequiredRubyVersion` version matcher when Gem::Requirement.new is used and initialised with multiple requirements. ([@nickpellant][])

### Changes

* [#10343](https://github.com/rubocop/rubocop/pull/10343): Require Parser 3.1.0.0 or higher. ([@koic][])

## 1.24.1 (2021-12-31)

### Bug fixes

* [#10313](https://github.com/rubocop/rubocop/issues/10313): Fix autocorrect `Style/MapToHash` with multiline code. ([@tejasbubane][])
* [#10251](https://github.com/rubocop/rubocop/issues/10251): Fix an incorrect autocorrect for `Gemspec/RequireMFA` when .gemspec file contains `metadata` keys assignments. ([@fatkodima][])
* [#10329](https://github.com/rubocop/rubocop/issues/10329): Fix a false positive for `Lint/ParenthesesAsGroupedExpression` and an incorrect autocorrect for the cop with `Style/TernaryParentheses` when using ternary expression as a first argument. ([@koic][])
* [#10317](https://github.com/rubocop/rubocop/issues/10317): Fix a false positive for `Style/MethodCallWithArgsParentheses` when using hash value omission. ([@koic][])
* [#10333](https://github.com/rubocop/rubocop/pull/10333): Fix an incorrect autocorrect for `Naming/BlockForwarding` using explicit block forwarding without method definition parentheses. ([@koic][])
* [#10321](https://github.com/rubocop/rubocop/issues/10321): Make `Style/MethodDefParentheses` aware of Ruby 3.1's anonymous block forwarding. ([@koic][])
* [#10320](https://github.com/rubocop/rubocop/issues/10320): Fix an incorrect autocorrect for `Style/FileWrite` when using heredoc argument. ([@koic][])
* [#10319](https://github.com/rubocop/rubocop/issues/10319): Require rubocop-ast 1.15.1 to fix a false positive for `Style/CombinableLoops` when the same method with different arguments and safe navigation. ([@koic][])

## 1.24.0 (2021-12-23)

### New features

* [#10279](https://github.com/rubocop/rubocop/pull/10279): Support Ruby 3.1's anonymous block forwarding syntax. ([@koic][])
* [#10295](https://github.com/rubocop/rubocop/pull/10295): Support Ruby 3.1's hash value omission syntax for `Layout/HashAlignment`. ([@koic][])
* [#10303](https://github.com/rubocop/rubocop/issues/10303): Add `AllowedNumbers` option to `Style/NumericLiterals`. ([@koic][])
* [#10290](https://github.com/rubocop/rubocop/pull/10290): Add new `Naming/BlockForwarding` cop. ([@koic][])
* [#10289](https://github.com/rubocop/rubocop/pull/10289): Add `EnforcedShorthandSyntax` option to `Style/HashSyntax` cop to support Ruby 3.1's hash value omission syntax by default. ([@koic][])
* [#10257](https://github.com/rubocop/rubocop/pull/10257): Add new `Style/MapToHash` cop. ([@dvandersluis][])
* [#10261](https://github.com/rubocop/rubocop/pull/10261): Add new `Style/FileRead` cop. ([@leoarnold][])
* [#10291](https://github.com/rubocop/rubocop/pull/10291): Support Ruby 3.1's hash value omission syntax for `Layout/SpaceAfterColon`. ([@koic][])
* [#10260](https://github.com/rubocop/rubocop/pull/10260): Add new `Style/FileWrite` cop. ([@leoarnold][])
* [#10307](https://github.com/rubocop/rubocop/pull/10307): Support Ruby 2.7's numbered parameter for `Metrics/BlockLength`, `Metrics/ClassLength`, `Metrics/MethodLength`, and `Metrics/ModuleLength` cops. ([@koic][])
* [#7671](https://github.com/rubocop/rubocop/issues/7671): Add cli option `--show-docs-url` to print out documentation url for given cops. ([@HeroProtagonist][])
* [#10308](https://github.com/rubocop/rubocop/pull/10308): Make `Style/CollectionCompact` aware of block pass argument. ([@koic][])

### Bug fixes

* [#10285](https://github.com/rubocop/rubocop/issues/10285): Fix an incorrect autocorrect for `Style/SoleNestedConditional` when using nested `if` within `if foo = bar`. ([@koic][])
* [#10309](https://github.com/rubocop/rubocop/pull/10309): Fix a false positive for `Bundler/DuplicatedGem` when a gem conditionally duplicated within multi-statement bodies. ([@fatkodima][])
* [#10300](https://github.com/rubocop/rubocop/issues/10300): Fix an incorrect autocorrect for `Layout/DotPosition` and `Style/RedundantSelf` when auto-correction conflicts. ([@koic][])
* [#10284](https://github.com/rubocop/rubocop/issues/10284): Fix an incorrect autocorrect for `Style/RedundantRegexpCharacterClass` when regexp containing an unescaped `#`. ([@koic][])
* [#10265](https://github.com/rubocop/rubocop/issues/10265): Fix `Style/IfInsideElse` to be able to handle `if-then` nested inside an `else` without clobbering. ([@dvandersluis][])
* [#10297](https://github.com/rubocop/rubocop/issues/10297): Fix a false positive for `Lint/DeprecatedOpenSSLConstant` when building digest using an algorithm string and nested digest constants. ([@koic][])
* [#10282](https://github.com/rubocop/rubocop/issues/10282): Fix an incorrect autocorrect for `Style/EmptyCaseCondition` when using `when ... then` in `case` in a method call. ([@koic][])
* [#10273](https://github.com/rubocop/rubocop/issues/10273): Fix a false positive for `InternalAffairs/UndefinedConfig` to suppress a false wrong namespace warning. ([@koic][])
* [#10305](https://github.com/rubocop/rubocop/issues/10305): Fix an incorrect autocorrect for `Style/HashConversion` when using `Hash[a || b]`. ([@koic][])
* [#10264](https://github.com/rubocop/rubocop/pull/10264): Fix the following incorrect auto-correct for `Style/MethodCallWithArgsParentheses` with `Layout/SpaceBeforeFirstArg`. ([@koic][])
* [#10276](https://github.com/rubocop/rubocop/issues/10276): Fix an incorrect autocorrect for `Style/RedundantInterpolation` when using a method call without parentheses in string interpolation. ([@koic][])

### Changes

* [#10253](https://github.com/rubocop/rubocop/pull/10253): Deprecate `RuboCop::Cop::EnforceSuperclass` module. ([@koic][])
* [#10248](https://github.com/rubocop/rubocop/pull/10248): Make `Lint/DeprecatedClassMethods` aware of `ENV.freeze`. ([@koic][])
* [#10269](https://github.com/rubocop/rubocop/issues/10269): Mark `Lint/IncompatibleIoSelectWithFiberScheduler` as unsafe auto-correction. ([@koic][])
* [#8586](https://github.com/rubocop/rubocop/issues/8586): Add configuration parameter `AllowForAlignment` in `Layout/CommentIndentation`. ([@jonas054][])

## 1.23.0 (2021-11-15)

### New features

* [#10202](https://github.com/rubocop/rubocop/issues/10202): Add new `Lint/UselessRuby2Keywords` cop. ([@dvandersluis][])
* [#10217](https://github.com/rubocop/rubocop/pull/10217): Add new `Style/OpenStructUse` cop. ([@mttkay][])
* [#10243](https://github.com/rubocop/rubocop/pull/10243): Add new `Gemspec/RequireMFA` cop. ([@dvandersluis][])

### Bug fixes

* [#10203](https://github.com/rubocop/rubocop/issues/10203): Fix `Style/FormatStringToken` to respect `IgnoredMethods` with nested structures. ([@tejasbubane][])
* [#10242](https://github.com/rubocop/rubocop/pull/10242): Fix `last_column` value for `JSONFormatter`. ([@koic][])
* [#10229](https://github.com/rubocop/rubocop/pull/10229): Fix a false positive for `Style/StringLiterals` when `EnforcedStyle: double_quotes` and using single quoted string with backslash. ([@koic][])
* [#10174](https://github.com/rubocop/rubocop/issues/10174): Fix inherit_from_remote should follow remote includes path starting with `./`. ([@hirasawayuki][])
* [#10234](https://github.com/rubocop/rubocop/pull/10234): Fix an error for `Style/Documentation` when using a cbase class. ([@koic][])
* [#10227](https://github.com/rubocop/rubocop/issues/10227): Fix a false positive for `Style/ParenthesesAroundCondition` when parentheses in multiple expressions separated by semicolon. ([@koic][])
* [#10230](https://github.com/rubocop/rubocop/issues/10230): Fix a false positive for `Lint/AmbiguousRange` when a range is composed of all literals except basic literals. ([@koic][])

### Changes

* [#10221](https://github.com/rubocop/rubocop/issues/10221): Update `Naming::FileName` to recognize `Struct`s as classes that satisfy the `ExpectMatchingDefinition` requirement. ([@dvandersluis][])
* [#10220](https://github.com/rubocop/rubocop/issues/10220): Update `Naming/FileName` to make `CheckDefinitionPathHierarchy` roots configurable. ([@grosser][])
* [#10199](https://github.com/rubocop/rubocop/pull/10199): Change `AllowAdjacentOneLineDefs` config parameter of `Layout/EmptyLineBetweenDefs` to `true` by default . ([@koic][])
* [#10236](https://github.com/rubocop/rubocop/pull/10236): Make `Lint/NumberConversion` aware of `to_r`. ([@koic][])

## 1.22.3 (2021-10-27)

### Bug fixes

* [#10166](https://github.com/rubocop/rubocop/pull/10166): Fix a false positive for `Style/StringLiterals` when using some meta characters (e.g. `'\s'`, `'\z'`) with `EnforcedStyle: double_quotes`. ([@koic][])
* [#10216](https://github.com/rubocop/rubocop/issues/10216): Fix an incorrect autocorrect for `Style/SelectByRegexp` when using `lvar =~ blockvar` in a block. ([@koic][])
* [#10207](https://github.com/rubocop/rubocop/pull/10207): Fix false positive in `Layout/DotPosition` when the selector is on the same line as the closing bracket of the receiver. ([@mvz][])

### Changes

* [#10209](https://github.com/rubocop/rubocop/pull/10209): Make `Lint/DeprecatedConstants` aware of `Net::HTTPServerException`. ([@koic][])

## 1.22.2 (2021-10-22)

### Bug fixes

* [#10165](https://github.com/rubocop/rubocop/issues/10165): Fix `Layout/DotPosition` false positives when the selector and receiver are on the same line. ([@dvandersluis][])
* [#10171](https://github.com/rubocop/rubocop/pull/10171): Fix `Style/HashTransformKeys` and `Style/HashTransformValues` incorrect auto-correction when inside block body. ([@franzliedke][])
* [#10180](https://github.com/rubocop/rubocop/issues/10180): Fix an error for `Style/SelectByRegexp` when using `match?` without a receiver. ([@koic][])
* [#10193](https://github.com/rubocop/rubocop/pull/10193): Fix an error for `Layout/EmptyLinesAroundExceptionHandlingKeywords` when `begin` and `rescue` are on the same line. ([@koic][])
* [#10185](https://github.com/rubocop/rubocop/issues/10185): Fix a false positive for `Lint/AmbiguousRange` when using `self` in a range literal. ([@koic][])
* [#10200](https://github.com/rubocop/rubocop/issues/10200): Fix an error when inspecting a directory named `*`. ([@koic][])
* [#10149](https://github.com/rubocop/rubocop/pull/10149): Fix `Bundler/GemComment` where it would not detect an offense in some cases when `OnlyFor` is set to `restrictive_version_specifiers`. ([@Drowze][])

### Changes

* [#10157](https://github.com/rubocop/rubocop/pull/10157): Updated `Gemspec/RequiredRubyVersion` handle being set to blank values. ([@dvandersluis][])
* [#10176](https://github.com/rubocop/rubocop/pull/10176): Unmark `AutoCorrect: false` from `Security/JSONLoad`. ([@koic][])
* [#10186](https://github.com/rubocop/rubocop/issues/10186): Explicit block arg is not counted for `Metrics/ParameterLists`. ([@koic][])

## 1.22.1 (2021-10-04)

### Bug fixes

* [#10143](https://github.com/rubocop/rubocop/issues/10143): Fix an error for `Lint/RequireRelativeSelfPath` when using a variable as an argument of `require_relative`. ([@koic][])
* [#10140](https://github.com/rubocop/rubocop/issues/10140): Fix false positive for `Layout/DotPosition` when a heredoc receives a method on the same line as the start sigil in `trailing` style. ([@dvandersluis][])
* [#10148](https://github.com/rubocop/rubocop/issues/10148): Fix `Style/QuotedSymbols` handling escaped characters incorrectly. ([@dvandersluis][])
* [#10145](https://github.com/rubocop/rubocop/issues/10145): Update `Style/SelectByRegexp` to ignore cases where the receiver appears to be a hash. ([@dvandersluis][])

## 1.22.0 (2021-09-29)

### New features

* [#8431](https://github.com/rubocop/rubocop/issues/8431): Add `Safety` section to documentation for all cops that are `Safe: false` or `SafeAutoCorrect: false`. ([@dvandersluis][])
* [#10132](https://github.com/rubocop/rubocop/issues/10132): Reorganize output of `rubocop --help` for better clarity. ([@dvandersluis][])
* [#10111](https://github.com/rubocop/rubocop/pull/10111): Add new `Style/NumberedParametersLimit` cop. ([@dvandersluis][])
* [#10025](https://github.com/rubocop/rubocop/pull/10025): Changed cop `SpaceInsideParens` to include a `compact` style. ([@itay-grudev][])
* [#10084](https://github.com/rubocop/rubocop/issues/10084): Add new `Lint/RequireRelativeSelfPath` cop. ([@koic][])
* [#8327](https://github.com/rubocop/rubocop/issues/8327): Add new cop `Style/SelectByRegexp`. ([@dvandersluis][])
* [#10100](https://github.com/rubocop/rubocop/pull/10100): Add new `Style/NumberedParameters` cop. ([@Hugo-Hache][])
* [#10103](https://github.com/rubocop/rubocop/issues/10103): Add `AllowHttpProtocol` option to `Bundler/InsecureProtocolSource`. ([@koic][])
* [#10102](https://github.com/rubocop/rubocop/pull/10102): Add new `Security/IoMethods` cop. ([@koic][])

### Bug fixes

* [#10110](https://github.com/rubocop/rubocop/issues/10110): Update `Layout/DotPosition` to be able to handle heredocs. ([@dvandersluis][])
* [#10134](https://github.com/rubocop/rubocop/issues/10134): Update `Style/MutableConstant` to not consider multiline uninterpolated strings as unfrozen in ruby 3.0. ([@dvandersluis][])
* [#10124](https://github.com/rubocop/rubocop/pull/10124): Fix `Layout/RedundantLineBreak` adding extra space within method chains. ([@dvandersluis][])
* [#10118](https://github.com/rubocop/rubocop/issues/10118): Fix crash with `Style/RedundantSort` when the block doesn't only contain a single `send` node. ([@dvandersluis][])
* [#10135](https://github.com/rubocop/rubocop/issues/10135): Fix `Style/WordArray` to exclude files in `--auto-gen-config` when `percent` style is given but brackets are required. ([@dvandersluis][])
* [#10090](https://github.com/rubocop/rubocop/issues/10090): Fix a false negative for `Style/ArgumentsForwarding` when using only kwrest arg. ([@koic][])
* [#10099](https://github.com/rubocop/rubocop/pull/10099): Update`Style/RedundantFreeze` to stop considering `ENV` values as immutable. ([@byroot][])
* [#10078](https://github.com/rubocop/rubocop/pull/10078): Fix `Layout/LineLength` reported length when ignoring directive comments. ([@dvandersluis][])
* [#9934](https://github.com/rubocop/rubocop/issues/9934): Fix configuration loading to not raise an error for an obsolete ruby version that is subsequently overridden. ([@dvandersluis][])
* [#10136](https://github.com/rubocop/rubocop/issues/10136): Update `Lint/AssignmentInCondition` to not consider assignments within blocks in conditions. ([@dvandersluis][])
* [#9588](https://github.com/rubocop/rubocop/issues/9588): Fix causing a variable to be shadowed from outside the rescue block in the logic of `Naming/RescuedExceptionsVariableName`. ([@lilisako][])
* [#10096](https://github.com/rubocop/rubocop/issues/10096): Fix `Lint/AmbiguousOperatorPrecedence` with `and`/`or` operators. ([@dvandersluis][])
* [#10106](https://github.com/rubocop/rubocop/issues/10106): Fix `Style/RedundantSelf` for pattern matching. ([@dvandersluis][])
* [#10066](https://github.com/rubocop/rubocop/issues/10066): Fix how `MinDigits` is calculated for `Style/NumericLiterals` when generating a configuration file. ([@dvandersluis][])

### Changes

* [#10088](https://github.com/rubocop/rubocop/pull/10088): Update `Lint/BooleanSymbol` to be `SafeAutoCorrect: false` rather than `Safe: false`. ([@dvandersluis][])
* [#10122](https://github.com/rubocop/rubocop/pull/10122): Update `Style/RedundantSort` to be unsafe, and revert the special case for `size` from [#10061](https://github.com/rubocop/rubocop/pull/10061). ([@dvandersluis][])
* [#10130](https://github.com/rubocop/rubocop/issues/10130): Update `Lint/ElseLayout` to be able to handle an `else` with only a single line. ([@dvandersluis][])

## 1.21.0 (2021-09-13)

### New features

* [#7849](https://github.com/rubocop/rubocop/issues/7849): Add new `Lint/AmbiguousOperatorPrecedence` cop. ([@dvandersluis][])
* [#9061](https://github.com/rubocop/rubocop/issues/9061): Add new `Lint/IncompatibleIoSelectWithFiberScheduler` cop. ([@koic][])

### Bug fixes

* [#10067](https://github.com/rubocop/rubocop/pull/10067): Fix an error for `Lint/NumberConversion` when using nested number conversion methods. ([@koic][])
* [#10054](https://github.com/rubocop/rubocop/pull/10054): Fix a false positive for `Layout/SpaceAroundOperators` when match operators between `<<` and `+=`. ([@koic][])
* [#10061](https://github.com/rubocop/rubocop/issues/10061): Fix a false positive for `Style/RedundantSort` when using `size` method in the block. ([@koic][])
* [#10063](https://github.com/rubocop/rubocop/pull/10063): Fix a false positive for `Layout/SingleLineBlockChain` when method call chained on a new line after a single line block with trailing dot. ([@koic][])
* [#10064](https://github.com/rubocop/rubocop/pull/10064): Fix `Style/ExplicitBlockArgument` corrector assuming any existing block argument was named `block`. ([@byroot][])
* [#10070](https://github.com/rubocop/rubocop/issues/10070): Fix a false positive for `Style/MutableConstant` when using non-interpolated heredoc in Ruby 3.0. ([@koic][])

### Changes

* [#9674](https://github.com/rubocop/rubocop/issues/9674): Disable `Style/AsciiComments` by default. ([@dvandersluis][])
* [#10051](https://github.com/rubocop/rubocop/pull/10051): Improve the messaging for `Style/Documentation` to be more clear about what class/module needs documentation. ([@dvandersluis][])
* [#10074](https://github.com/rubocop/rubocop/pull/10074): Update `Naming/InclusiveLanguage` to be disabled by default. ([@dvandersluis][])
* [#10068](https://github.com/rubocop/rubocop/pull/10068): Mark `Style/AndOr` as unsafe auto-correction. ([@koic][])

## 1.20.0 (2021-08-26)

### New features

* [#10040](https://github.com/rubocop/rubocop/pull/10040): Make `Lint/Debugger` aware of debug.rb. ([@koic][])
* [#9580](https://github.com/rubocop/rubocop/issues/9580): Add a new cop that enforces which bundler gem file to use. ([@gregfletch][])

### Bug fixes

* [#10033](https://github.com/rubocop/rubocop/issues/10033): Fix an incorrect auto-correct for `Style/BlockDelimiters` when there is a comment after the closing brace and using method chaining. ([@koic][])
* [#6630](https://github.com/rubocop/rubocop/issues/6630): Updated `Style/CommentAnnotation` to be able to handle multiword keyword phrases. ([@dvandersluis][])
* [#7836](https://github.com/rubocop/rubocop/issues/7836): Update `Style/BlockDelimiters` to add `begin`...`end` when converting a block containing `rescue` or `ensure` to braces. ([@dvandersluis][])
* [#10031](https://github.com/rubocop/rubocop/issues/10031): Fix a false positive for `Style/HashExcept` when comparing with hash value. ([@koic][])

### Changes

* [#10034](https://github.com/rubocop/rubocop/pull/10034): Add `RubyJard` debugger calls to `DebuggerMethods` of `Lint/Debugger`. ([@DanielVartanov][])
* [#10006](https://github.com/rubocop/rubocop/pull/10006): Interpolated string literals are no longer frozen since Ruby 3.0. ([@splattael][])
* [#9328](https://github.com/rubocop/rubocop/issues/9328): Recognize shareable_constant_value magic comment. ([@thearjunmdas][], [@caalberts][])
* [#10036](https://github.com/rubocop/rubocop/issues/10036): Mark `Style/StructInheritance` as unsafe auto-correction. ([@koic][])

## 1.19.1 (2021-08-19)

### Bug fixes

* [#10017](https://github.com/rubocop/rubocop/pull/10017): Fix an error for `Layout/RescueEnsureAlignment` when using zsuper with block. ([@koic][])
* [#10011](https://github.com/rubocop/rubocop/issues/10011): Fix a false positive for `Style/RedundantSelfAssignmentBranch` when using instance variable, class variable, and global variable. ([@koic][])
* [#10010](https://github.com/rubocop/rubocop/issues/10010): Fix a false positive for `Style/DoubleNegation` when `!!` is used at return location and before `rescue` keyword. ([@koic][])
* [#10014](https://github.com/rubocop/rubocop/issues/10014): Fix `Style/Encoding` to handle more situations properly. ([@dvandersluis][])
* [#10016](https://github.com/rubocop/rubocop/issues/10016): Fix conflict between `Style/SoleNestedConditional` and `Style/NegatedIf`/`Style/NegatedUnless`. ([@dvandersluis][])
* [#10024](https://github.com/rubocop/rubocop/issues/10024): Fix an incorrect auto-correct for `Style/RedundantSelfAssignmentBranch` when using multiline `if` / `else` conditional assignment. ([@koic][])
* [#10004](https://github.com/rubocop/rubocop/issues/10004): Fix a false positive for `Style/RedundantBegin` when using one-liner with semicolon. ([@koic][])

## 1.19.0 (2021-08-12)

### New features

* [#4182](https://github.com/rubocop/rubocop/issues/4182): Add `Lint/AmbiguousRange` cop to check for ranges with ambiguous boundaries. ([@dvandersluis][])
* [#10000](https://github.com/rubocop/rubocop/pull/10000): Parallel static analysis by default. ([@koic][])
* [#9948](https://github.com/rubocop/rubocop/pull/9948): Support Ruby 2.7's pattern matching for `Style/ConditionalAssignment` cop. ([@koic][])
* [#9999](https://github.com/rubocop/rubocop/pull/9999): Add new `Style/RedundantSelfAssignmentBranch` cop. ([@koic][])

### Bug fixes

* [#9927](https://github.com/rubocop/rubocop/issues/9927): Indent hash values in `Layout/LineEndStringConcatenationIndentation`. ([@jonas054][])
* [#9959](https://github.com/rubocop/rubocop/issues/9959): Make `Style/IdenticalConditionalBranches` able to handle ternary `if`s. ([@dvandersluis][])
* [#9946](https://github.com/rubocop/rubocop/issues/9946): Avoid slow regexp matches in `Style/CommentedKeyword`. ([@jonas054][])
* [#7422](https://github.com/rubocop/rubocop/issues/7422): Treat constant assignment like other assignment in `Layout/SpaceAroundOperators`. ([@dvandersluis][])
* [#9953](https://github.com/rubocop/rubocop/issues/9953): Fix an infinite loop error and a false auto-correction behavior for `Layout/EndAlignment` when using a conditional statement in a method argument. ([@koic][])
* [#9958](https://github.com/rubocop/rubocop/issues/9958): Prevent an infinite loop when a detected method has fewer arguments than expected. ([@dvandersluis][])
* [#9977](https://github.com/rubocop/rubocop/issues/9977): Update `Layout/EmptyLineAfterGuardClause` to not register an offense if there is another expression following the guard clause on the same line. ([@dvandersluis][])
* [#9980](https://github.com/rubocop/rubocop/issues/9980): Fix a false positive for `Style/IdenticalConditionalBranches` when assigning to a variable used in a condition. ([@koic][])
* [#9975](https://github.com/rubocop/rubocop/issues/9975): Parentheses are always required for `Style/MethodDefParentheses` when a forwarding argument (`...`) is used. ([@dvandersluis][])
* [#9984](https://github.com/rubocop/rubocop/pull/9984): Fix false negatives involving heredocs for `Layout/SpaceBeforeComma`, `Layout/SpaceBeforeComment`, `Layout/SpaceBeforeSemicolon` and `Layout/SpaceInsideParens`. ([@dvandersluis][])
* [#9954](https://github.com/rubocop/rubocop/issues/9954): Fix infinite loop error for `Layout/HashAlignment` when `EnforcedStyle: with_fixed_indentation` is specified for `Layout/ArgumentAlignment`. ([@koic][])
* [#10002](https://github.com/rubocop/rubocop/issues/10002): Fix an incorrect auto-correct for `Lint/AmbiguousRegexpLiteral` when using nested method arguments without parentheses. ([@koic][])
* [#9952](https://github.com/rubocop/rubocop/pull/9952) [rubocop-rspec#1126](https://github.com/rubocop/rubocop-rspec/issues/1126): Fix `inherit_mode` for deeply nested configuration defined in extensions' default configuration. ([@pirj][])
* [#9957](https://github.com/rubocop/rubocop/issues/9957): Add `WholeWord` configuration to `Naming/InclusiveLanguage`'s `FlaggedTerms` config. ([@dvandersluis][])
* [#9970](https://github.com/rubocop/rubocop/pull/9970): Don't register an offense when sort method has arguments for `Style/RedundantSort` cop. ([@mtsmfm][])
* [#4097](https://github.com/rubocop/rubocop/issues/4097): Add require English for special globals. ([@biinari][])
* [#9955](https://github.com/rubocop/rubocop/issues/9955): Fix `Style/ExplicitBlockArgument` adding a second set of parentheses. ([@dvandersluis][])
* [#9973](https://github.com/rubocop/rubocop/issues/9973): Fix a false positive for `Layout/RescueEnsureAlignment` when aligned `rescue` keyword and leading dot. ([@koic][])
* [#9945](https://github.com/rubocop/rubocop/issues/9945): Fix auto-correction of lines in heredocs with only spaces in `Layout/TrailingWhitespace`. ([@jonas054][])

### Changes

* [#9989](https://github.com/rubocop/rubocop/issues/9989): Mark `Style/CommentedKeyword` as unsafe auto-correction. ([@koic][])
* [#9964](https://github.com/rubocop/rubocop/pull/9964): Make `Layout/LeadingCommentSpace` aware of `#:nodoc`. ([@koic][])
* [#9985](https://github.com/rubocop/rubocop/pull/9985): Mark `Style/IdenticalConditionalBranches` as unsafe auto-correction. ([@koic][])
* [#9962](https://github.com/rubocop/rubocop/issues/9962): Update `Style/WordArray` to register an offense in `percent` style if any values contain spaces. ([@dvandersluis][])
* [#9979](https://github.com/rubocop/rubocop/pull/9979): Enable basic autocorrection for `Style/Semicolon`. ([@dvandersluis][])

## 1.18.4 (2021-07-23)

### New features

* [#9930](https://github.com/rubocop/rubocop/pull/9930): Support Ruby 2.7's pattern matching for `Lint/DuplicateBranch` cop. ([@koic][])

### Bug fixes

* [#9938](https://github.com/rubocop/rubocop/pull/9938): Fix an incorrect auto-correct for `Layout/LineLength` when a heredoc is used as the first element of an array. ([@koic][])
* [#9940](https://github.com/rubocop/rubocop/issues/9940): Fix an incorrect auto-correct for `Style/HashTransformValues` when value is a hash literal for `_.to_h{...}`. ([@koic][])
* [#9752](https://github.com/rubocop/rubocop/issues/9752): Improve error message for top level department used in configuration. ([@jonas054][])
* [#9933](https://github.com/rubocop/rubocop/pull/9933): Fix GitHub Actions formatter when running in non-default directory. ([@ojab][])
* [#9922](https://github.com/rubocop/rubocop/issues/9922): Make better auto-corrections in `Style/DoubleCopDisableDirective`. ([@jonas054][])
* [#9848](https://github.com/rubocop/rubocop/issues/9848): Fix handling of comments in `Layout/ClassStructure` auto-correct. ([@jonas054][])
* [#9926](https://github.com/rubocop/rubocop/pull/9926): Fix an incorrect auto-correct for `Style/SingleLineMethods` when method body is enclosed in parentheses. ([@koic][])
* [#9928](https://github.com/rubocop/rubocop/issues/9928): Fix an infinite loop error and a false auto-correction behavior for `Layout/EndAlignment` when using operator methods and `EnforcedStyleAlignWith: variable`. ([@koic][])
* [#9434](https://github.com/rubocop/rubocop/issues/9434): Fix false positive for setter calls in `Layout/FirstArgumentIndentation`. ([@jonas054][])

## 1.18.3 (2021-07-06)

### Bug fixes

* [#9891](https://github.com/rubocop/rubocop/issues/9891): Fix `--auto-gen-config` bug for `Style/HashSyntax`. ([@jonas054][])
* [#9905](https://github.com/rubocop/rubocop/issues/9905): Fix false positive for single line concatenation in `Layout/LineEndStringConcatenationIndentation`. ([@jonas054][])
* [#9907](https://github.com/rubocop/rubocop/issues/9907): Fix an incorrect auto-correct for `Lint/UselessTimes` when using block argument for `1.times`. ([@koic][])
* [#9869](https://github.com/rubocop/rubocop/issues/9869): Fix reference to file in configuration override warning. ([@jonas054][])
* [#9902](https://github.com/rubocop/rubocop/issues/9902): Fix an incorrect auto-correct for `Style/BlockDelimiters` when there is a comment after the closing brace. ([@koic][])
* [#8469](https://github.com/rubocop/rubocop/issues/8469): Add inspection of `class <<` to `Layout/SpaceAroundOperators`. ([@jonas054][])
* [#9909](https://github.com/rubocop/rubocop/pull/9909): This PR fixes an incorrect auto-correct for `Style/SingleLineMethods` when using `return`, `break`, or `next` for one line method body in Ruby 3.0. ([@koic][])
* [#9914](https://github.com/rubocop/rubocop/issues/9914): Fix an error for `Layout/HashAlignment` when using aligned hash argument for `proc.()`. ([@koic][])

## 1.18.2 (2021-07-02)

### Bug fixes

* [#9894](https://github.com/rubocop/rubocop/issues/9894): Handle multiline string literals in `Layout/LineEndStringConcatenationIndentation`. ([@jonas054][])
* [#9890](https://github.com/rubocop/rubocop/issues/9890): Make colon after comment annotation configurable. ([@gregfletch][])

## 1.18.1 (2021-06-30)

### Bug fixes

* [#9897](https://github.com/rubocop/rubocop/pull/9897): Fix an incorrect auto-correct for `Layout/HashAlignment` when setting `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and using misaligned keyword arguments. ([@koic][])

### Changes

* [#9895](https://github.com/rubocop/rubocop/issues/9895): Set `CheckStrings: false` and Remove `master` from `FlaggedTerms` for `Naming/InclusiveLanguage`. ([@koic][])

## 1.18.0 (2021-06-29)

### New features

* [#9842](https://github.com/rubocop/rubocop/pull/9842): Add new `Naming/InclusiveLanguage` cop. ([@tjwp][])

### Bug fixes

* [#9803](https://github.com/rubocop/rubocop/pull/9803): Fix `Bundler/GemVersion` cop not respecting git tags. ([@tejasbubane][], [@timlkelly][])
* [#9882](https://github.com/rubocop/rubocop/pull/9882): Fix an incorrect auto-correct for `Layout/LineLength` when using heredoc as the first method argument and omitting parentheses. ([@koic][])
* [#7592](https://github.com/rubocop/rubocop/pull/7592): Add cop `Layout/LineEndStringConcatenationIndentation`. ([@jonas054][])
* [#9880](https://github.com/rubocop/rubocop/pull/9880): Fix a false positive for `Style/RegexpLiteral` when using a regexp starts with a blank as a method argument. ([@koic][])
* [#9888](https://github.com/rubocop/rubocop/pull/9888): Fix a false positive for `Layout/ClosingParenthesisIndentation` when using keyword arguments. ([@koic][])
* [#9886](https://github.com/rubocop/rubocop/pull/9886): Fix indentation in `Style/ClassAndModuleChildren`. ([@markburns][])

### Changes

* [#9144](https://github.com/rubocop/rubocop/issues/9144): Add `aggressive` and `conservative` modes of operation for `Style/StringConcatenation` cop. ([@tejasbubane][])

## 1.17.0 (2021-06-15)

### New features

* [#9626](https://github.com/rubocop/rubocop/pull/9626): Disable all cop department with directive comment. ([@AndreiEres][])
* [#9827](https://github.com/rubocop/rubocop/issues/9827): Add basic auth support to download raw yml config from private repo. ([@AirWick219][])
* [#9873](https://github.com/rubocop/rubocop/pull/9873): Support one-line pattern matching syntax for `Layout/SpaceAroundKeyword` and `Layout/SpaceAroundOperators`. ([@koic][])
* [#9857](https://github.com/rubocop/rubocop/pull/9857): Support Ruby 2.7's pattern matching for `Layout/IndentationWidth` cop. ([@koic][])
* [#9877](https://github.com/rubocop/rubocop/pull/9877): Support Ruby 2.7's `in` pattern syntax for `Lint/LiteralAsCondition`. ([@koic][])
* [#9855](https://github.com/rubocop/rubocop/pull/9855): Support Ruby 2.7's pattern matching for `Style/IdenticalConditionalBranches` cop. ([@koic][])

### Bug fixes

* [#9874](https://github.com/rubocop/rubocop/issues/9874): Fix a false positive for `Style/RegexpLiteral` when using `%r` regexp literal with `EnforcedStyle: omit_parentheses` of `Style/MethodCallWithArgsParentheses`. ([@koic][])
* [#9876](https://github.com/rubocop/rubocop/pull/9876): Fix empty line after guard clause with `and return` and heredoc. ([@AndreiEres][])
* [#9861](https://github.com/rubocop/rubocop/issues/9861): Fix error in `Layout/HashAlignment` with an empty hash literal. ([@dvandersluis][])
* [#9867](https://github.com/rubocop/rubocop/pull/9867): Fix an incorrect auto-correct for `Layout/DotPosition` when using only dot line. ([@koic][])

## 1.16.1 (2021-06-09)

### Bug fixes

* [#9843](https://github.com/rubocop/rubocop/issues/9843): Fix `Style/RedundantSelf` to allow conditional nodes to use `self` in the condition when a variable named is shadowed inside. ([@dvandersluis][])
* [#9845](https://github.com/rubocop/rubocop/issues/9845): Fix `Style/QuotedSymbols` for hash-rocket hashes. ([@dvandersluis][])
* [#9849](https://github.com/rubocop/rubocop/pull/9849): Fix a false negative for `Layout/HashAlignment` when setting `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and using misaligned keyword arguments. ([@koic][])
* [#9854](https://github.com/rubocop/rubocop/pull/9854): Allow braced numeric blocks in `omit_parentheses` style of `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])
* [#9850](https://github.com/rubocop/rubocop/issues/9850): Fix missing `AllowComments` option for `Lint/EmptyInPattern`. ([@koic][])

## 1.16.0 (2021-06-01)

### New features

* [#9841](https://github.com/rubocop/rubocop/pull/9841): Support guard `if` and `unless` syntax keywords of Ruby 2.7's pattern matching for `Layout/SpaceAroundKeyword`. ([@koic][])
* [#9812](https://github.com/rubocop/rubocop/pull/9812): Support auto-correction for `Style/IdenticalConditionalBranches`. ([@koic][])
* [#9833](https://github.com/rubocop/rubocop/pull/9833): Add new `Style/InPatternThen` cop. ([@koic][])
* [#9840](https://github.com/rubocop/rubocop/issues/9840): Adds `AllowedReceivers` option for `Style/HashEachMethods`. ([@koic][])
* [#9818](https://github.com/rubocop/rubocop/pull/9818): Support Ruby 2.7's `in` pattern syntax for `Layout/CaseIndentation`. ([@koic][])
* [#9838](https://github.com/rubocop/rubocop/pull/9838): Support Ruby 2.7's pattern matching syntax for `Layout/SpaceAroundKeyword`. ([@koic][])
* [#9793](https://github.com/rubocop/rubocop/issues/9793): Add `Style/QuotedSymbols` to enforce consistency in quoted symbols. ([@dvandersluis][])
* [#9825](https://github.com/rubocop/rubocop/pull/9825): Add new `Lint/EmptyInPattern` cop. ([@koic][])
* [#9834](https://github.com/rubocop/rubocop/pull/9834): Add new `Style/MultilineInPatternThen` cop. ([@koic][])

### Bug fixes

* [#9822](https://github.com/rubocop/rubocop/issues/9822): Fix a false directive comment range for `Lint/RedundantCopDisableDirective`. ([@koic][])
* [#9819](https://github.com/rubocop/rubocop/issues/9819): Fix a false negative for `Style/TopLevelMethodDefinition` when defining a top-level method after a class definition. ([@koic][])
* [#9836](https://github.com/rubocop/rubocop/issues/9836): Fix incorrect corrections for `Layout/HashAlignment` when a `kwsplat` node is on the same line as a `pair` node with table style. ([@dvandersluis][])
* [#9805](https://github.com/rubocop/rubocop/pull/9805): Fix a false negative for `Layout/HashAlignment` when set `EnforcedStyle: with_fixed_indentation` of `ArgumentAlignment`. ([@koic][])
* [#9811](https://github.com/rubocop/rubocop/issues/9811): Fix an error for `Layout/ArgumentAlignment` with `Layout/FirstHashElementIndentation` when setting `EnforcedStyle: with_fixed_indentation`. ([@koic][])

### Changes

* [#9809](https://github.com/rubocop/rubocop/pull/9809): Change `Lint/SymbolConversion` to only quote with double quotes, since `Style/QuotedSymbols` can now correct those to the correct quotes as per configuration. ([@dvandersluis][])

## 1.15.0 (2021-05-17)

### New features

* [#9734](https://github.com/rubocop/rubocop/pull/9734): Add `Style/TopLevelMethodDefinition` cop. ([@tejasbubane][])
* [#9780](https://github.com/rubocop/rubocop/issues/9780): Support summary report for `JUnitFormatter`. ([@koic][])
* [#9798](https://github.com/rubocop/rubocop/pull/9798): Make `Layout/ArgumentAlignment` aware of kwargs. ([@koic][])

### Bug fixes

* [#9749](https://github.com/rubocop/rubocop/issues/9749): Fix autocorrection for `Layout/LineLength` to not move the first argument of an unparenthesized `send` node to the next line, which changes behaviour. ([@dvandersluis][])
* [#9799](https://github.com/rubocop/rubocop/issues/9799): Fix invalid line splitting by `Layout/LineLength` for `send` nodes with heredoc arguments. ([@dvandersluis][])
* [#9773](https://github.com/rubocop/rubocop/issues/9773): Fix `Style/EmptyLiteral` to not register offenses for `String.new` when `Style/FrozenStringLiteralComment` is enabled. ([@dvandersluis][])
* [#9771](https://github.com/rubocop/rubocop/issues/9771): Change `AllowDSLWriters` to true by default for `Style/TrivialAccessors`. ([@koic][])
* [#9777](https://github.com/rubocop/rubocop/pull/9777): Fix an incorrect auto-correct for `Style/RedundantBegin` when using multi-line `if` in `begin` block. ([@koic][])
* [#9791](https://github.com/rubocop/rubocop/pull/9791): Fix a false negative for `Layout/IndentationWidth` when using `ensure` in `do` ... `end` block. ([@koic][])
* [#9766](https://github.com/rubocop/rubocop/pull/9766): Fix a clobbering error for `Style/ClassAndModuleChildren` cop with compact style. ([@tejasbubane][])
* [#9767](https://github.com/rubocop/rubocop/issues/9767): Fix `Style/ClassAndModuleChildren` cop to preserve comments. ([@tejasbubane][])
* [#9792](https://github.com/rubocop/rubocop/issues/9792): Fix false positive for `Lint/Void` cop with ranges. ([@tejasbubane][])

### Changes

* [#9770](https://github.com/rubocop/rubocop/issues/9770): Update `Lint/EmptyBlock` to handle procs the same way as lambdas. ([@dvandersluis][])
* [#9776](https://github.com/rubocop/rubocop/pull/9776): Update `Style/NilLambda` to handle procs as well. ([@dvandersluis][])
* [#9744](https://github.com/rubocop/rubocop/pull/9744): The parallel flag will now be automatically ignored when combined with `--cache false`. Previously, an error was raised and execution stopped. ([@rrosenblum][])

## 1.14.0 (2021-05-05)

### New features

* [#7669](https://github.com/rubocop/rubocop/issues/7669): New cop `Bundler/GemVersion` requires or forbids specifying gem versions. ([@timlkelly][])
* [#9758](https://github.com/rubocop/rubocop/pull/9758): Support `TargetRubyVersion 3.1` (experimental). ([@koic][])
* [#9733](https://github.com/rubocop/rubocop/issues/9733): Add cop `Layout/SingleLineBlockChain`. ([@jonas054][])

### Bug fixes

* [#9751](https://github.com/rubocop/rubocop/pull/9751): `Style/StringLiterals` doesn't autocorrect global variable interpolation. ([@etiennebarrie][])
* [#9731](https://github.com/rubocop/rubocop/issues/9731): Fix two autocorrection issues for `Style/NegatedIfElseCondition`. ([@dvandersluis][])
* [#9740](https://github.com/rubocop/rubocop/pull/9740): Fix an incorrect auto-correct for `Style/SingleLineMethods` when defining setter method. ([@koic][])
* [#9757](https://github.com/rubocop/rubocop/pull/9757): Fix a false positive for `Lint/NumberConversion` when `:to_f` is one of multiple method arguments. ([@koic][])
* [#9761](https://github.com/rubocop/rubocop/issues/9761): Fix `Style/ClassAndModuleChildren` false negative for `compact` style when a class/module is partially nested. ([@dvandersluis][])
* [#9748](https://github.com/rubocop/rubocop/pull/9748): Prevent infinite loops during symlink traversal. ([@Tonkpils][])
* [#9762](https://github.com/rubocop/rubocop/issues/9762): Update `VariableForce` to be able to handle `case-match` nodes. ([@dvandersluis][])
* [#9729](https://github.com/rubocop/rubocop/issues/9729): Fix an error for `Style/IfUnlessModifier` when variable assignment is used in the branch body of if modifier. ([@koic][])
* [#9750](https://github.com/rubocop/rubocop/issues/9750): Fix an incorrect auto-correct for `Style/SoleNestedConditional` when using nested `if` within `unless foo == bar`. ([@koic][])
* [#9751](https://github.com/rubocop/rubocop/pull/9751): `Style/StringLiterals` autocorrects `'\\'` into `"\\"`. ([@etiennebarrie][])
* [#9732](https://github.com/rubocop/rubocop/pull/9732): Support deprecated Socket.gethostbyaddr and Socket.gethostbyname. ([@AndreiEres][])
* [#9713](https://github.com/rubocop/rubocop/issues/9713): Fix autocorrection for block local variables in `Lint/UnusedBlockArgument`. ([@tejasbubane][])
* [#9746](https://github.com/rubocop/rubocop/pull/9746): Fix a false positive for `Lint/UnreachableLoop` when using conditional `next` in a loop. ([@koic][])

## 1.13.0 (2021-04-20)

### New features

* [#7977](https://github.com/rubocop/rubocop/issues/7977): Add `Layout/RedundantLineBreak` cop. ([@jonas054][])
* [#9691](https://github.com/rubocop/rubocop/issues/9691): Add configuration parameter `InspectBlocks` to `Layout/RedundantLineBreak`. ([@jonas054][])
* [#9684](https://github.com/rubocop/rubocop/issues/9684): Support `IgnoredMethods` option for `Lint/AmbiguousBlockAssociation`. ([@gprado][])
* [#9358](https://github.com/rubocop/rubocop/pull/9358): Support `restrictive_version_specifiers` option in `Bundler/GemComment` cop. ([@RobinDaugherty][])

### Bug fixes

* [#5576](https://github.com/rubocop/rubocop/issues/5576): Fix problem with inherited `Include` parameters. ([@jonas054][])
* [#9690](https://github.com/rubocop/rubocop/pull/9690): Fix an incorrect auto-correct for `Style/IfUnlessModifier` when using a method with heredoc argument. ([@koic][])
* [#9681](https://github.com/rubocop/rubocop/issues/9681): Fix an incorrect auto-correct for `Style/RedundantBegin` when using modifier `if` single statement in `begin` block. ([@koic][])
* [#9698](https://github.com/rubocop/rubocop/issues/9698): Fix an error for `Style/StructInheritance` when extending instance of `Struct` without `do` ... `end` and class body is empty and single line definition. ([@koic][])
* [#9700](https://github.com/rubocop/rubocop/issues/9700): Avoid warning about Ruby version mismatch. ([@marcandre][])
* [#9636](https://github.com/rubocop/rubocop/issues/9636): Resolve symlinks when excluding directories. ([@ob-stripe][])
* [#9707](https://github.com/rubocop/rubocop/issues/9707): Fix false positive for `Style/MethodCallWithArgsParentheses` with `omit_parentheses` style on an endless `defs` node. ([@dvandersluis][])
* [#9689](https://github.com/rubocop/rubocop/issues/9689): Treat parens around array items the same for children and deeper descendants. ([@dvandersluis][])
* [#9676](https://github.com/rubocop/rubocop/issues/9676): Fix an error for `Style/StringChars` when using `split` without parentheses. ([@koic][])
* [#9712](https://github.com/rubocop/rubocop/pull/9712): Fix an incorrect auto-correct for `Style/HashConversion` when `Hash[]` as a method argument without parentheses. ([@koic][])
* [#9704](https://github.com/rubocop/rubocop/pull/9704): Fix an incorrect auto-correct for `Style/SingleLineMethods` when single line method call without parentheses. ([@koic][])
* [#9683](https://github.com/rubocop/rubocop/issues/9683): Fix an incorrect auto-correct for `Style/HashConversion` when using `zip` method without argument in `Hash[]`. ([@koic][])
* [#9715](https://github.com/rubocop/rubocop/pull/9715): Fix an incorrect auto-correct for `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with `Style/RescueModifier`. ([@koic][])

### Changes

* [#7544](https://github.com/rubocop/rubocop/pull/7544): Add --no-parallel (-P/--parallel cannot be combined with --auto-correct). ([@kwerle][])
* [#9648](https://github.com/rubocop/rubocop/pull/9648): **(Compatibility)** Drop support for Ruby 2.4. ([@koic][])
* [#9647](https://github.com/rubocop/rubocop/pull/9647): The parallel flag will now be automatically ignored when combined with `--auto-correct`, `--auto-gen-config`, or `-F/--fail-fast`. Previously, an error was raised and execution stopped. ([@rrosenblum][])

## 1.12.1 (2021-04-04)

### Bug fixes

* [#9649](https://github.com/rubocop/rubocop/pull/9649): Fix when highlights contain multibyte characters. ([@osyo-manga][])
* [#9646](https://github.com/rubocop/rubocop/pull/9646): Fix an incorrect auto-correct for `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with `EnforcedStyle: conditionals` of `Style/AndOr`. ([@koic][])
* [#9608](https://github.com/rubocop/rubocop/issues/9608): Fix a false positive for `Layout/EmptyLineAfterGuardClause` when using guard clause is after `rubocop:enable` comment. ([@koic][])
* [#9637](https://github.com/rubocop/rubocop/issues/9637): Allow parentheses for forwarded args in `Style/MethodCallWithArgsParentheses`'s `omit_parentheses` style to avoid endless range ambiguity. ([@gsamokovarov][])
* [#9641](https://github.com/rubocop/rubocop/issues/9641): Fix `Layout/MultilineMethodCallIndentation` triggering on method calls that look like operators. ([@dvandersluis][])
* [#9638](https://github.com/rubocop/rubocop/pull/9638): Fix an error for `Layout/LineLength` when over limit at right hand side of multiple assignment. ([@koic][])
* [#9639](https://github.com/rubocop/rubocop/pull/9639): Fix `Style/RedundantBegin` removing comments on assignment statement correction. ([@marcotc][])
* [#9671](https://github.com/rubocop/rubocop/pull/9671): Fix an incorrect auto-correct for `Lint/AmbiguousOperator` with `Style/MethodCallWithArgsParentheses`. ([@koic][])
* [#9645](https://github.com/rubocop/rubocop/pull/9645): Fix an incorrect auto-correct for `Style/SingleLineMethods` when using single line class method definition. ([@koic][])
* [#9644](https://github.com/rubocop/rubocop/pull/9644): Fix an error and an incorrect auto-correct for `Style/MultilineMethodSignature` when line break after opening parenthesis. ([@koic][])
* [#9672](https://github.com/rubocop/rubocop/issues/9672): Fix an incorrect auto-correct for `Style/HashConversion` when using  multi-argument `Hash[]` as a method argument. ([@koic][])

## 1.12.0 (2021-03-24)

### New features

* [#9615](https://github.com/rubocop/rubocop/pull/9615): Add new `Style/StringChars` cop. ([@koic][])
* [#9629](https://github.com/rubocop/rubocop/issues/9629): Add `AllowParenthesesInStringInterpolation` configuration to `Style/MethodCallWithArgsParentheses` to allow parenthesized calls in string interpolation. ([@gsamokovarov][])
* [#9219](https://github.com/rubocop/rubocop/pull/9219): Allow excluding some constants from `Style/Documentation`. ([@fsateler][])
* Add `AllowNil` option for `Lint/SuppressedException` to allow/disallow `rescue nil`. ([@corroded][])

### Bug fixes

* [#9560](https://github.com/rubocop/rubocop/pull/9560): Fix an error for `Style/ClassMethodsDefinitions` when defining class methods with `class << self` with comment only body. ([@koic][])
* [#9551](https://github.com/rubocop/rubocop/issues/9551): Fix a false positive for `Style/UnlessLogicalOperators` when using `||` operator and invoked method name includes "or" in the conditional branch. ([@koic][])
* [#9620](https://github.com/rubocop/rubocop/pull/9620): Allow parentheses in operator methods calls for `Style/MethodCallWithArgsParentheses` `EnforcedStyle: omit_parentheses`. ([@gsamokovarov][])
* [#9622](https://github.com/rubocop/rubocop/issues/9622): Fixed `Style/BisectedAttrAccessor` autocorrection to handle multiple bisected attrs in the same macro. ([@dvandersluis][])
* [#9606](https://github.com/rubocop/rubocop/issues/9606): Fix an error for `Layout/IndentationConsistency` when using access modifier at the top level. ([@koic][])
* [#9619](https://github.com/rubocop/rubocop/pull/9619): Fix infinite loop between `Layout/IndentationWidth` and `Layout/RescueEnsureAlignment` autocorrection. ([@dvandersluis][])
* [#9633](https://github.com/rubocop/rubocop/pull/9633): Fix an incorrect auto-correct for `Lint/NumberConversion` when `to_i` method in symbol form. ([@koic][])
* [#9616](https://github.com/rubocop/rubocop/pull/9616): Fix an incorrect auto-correct for `Style/EvalWithLocation` when using `#instance_eval` with a string argument in parentheses. ([@koic][])
* [#9429](https://github.com/rubocop/rubocop/issues/9429): Fix `Style/NegatedIfElseCondition` autocorrect to keep comments in correct branch. ([@tejasbubane][])
* [#9631](https://github.com/rubocop/rubocop/issues/9631): Fix an incorrect auto-correct for `Style/RedundantReturn` when using `return` with splat argument. ([@koic][])
* [#9627](https://github.com/rubocop/rubocop/issues/9627): Fix an incorrect auto-correct for `Style/StructInheritance` when extending instance of Struct without `do` ... `end` and class body is empty. ([@koic][])
* [#5953](https://github.com/rubocop/rubocop/issues/5953): Fix a false positive for `Style/AccessModifierDeclarations` when using `module_function` with symbol. ([@koic][])
* [#9593](https://github.com/rubocop/rubocop/issues/9593): Fix an error when processing a directory is named `{}`. ([@koic][])
* [#9599](https://github.com/rubocop/rubocop/issues/9599): Fix an error for `Style/CaseLikeIf` when using `include?` without a receiver. ([@koic][])
* [#9582](https://github.com/rubocop/rubocop/issues/9582): Fix incorrect auto-correct for `Style/ClassEqualityComparison` when comparing `Module#name` for equality. ([@koic][])
* [#9603](https://github.com/rubocop/rubocop/issues/9603): Fix a false positive for `Style/SoleNestedConditional` when using nested modifier on value assigned in condition. ([@koic][])
* [#9598](https://github.com/rubocop/rubocop/pull/9598): Fix RuboCop::MagicComment#valid_shareable_constant_value?. ([@kachick][])
* [#9625](https://github.com/rubocop/rubocop/pull/9625): Allow parentheses in yield arguments with `Style/MethodCallWithArgsParentheses` `EnforcedStyle: omit_parentheses` to fix invalid Ruby auto-correction. ([@gsamokovarov][])
* [#9558](https://github.com/rubocop/rubocop/issues/9558): Fix inconsistency when dealing with URIs that are wrapped in single quotes vs double quotes. ([@dvandersluis][])
* [#9613](https://github.com/rubocop/rubocop/issues/9613): Fix a false positive for `Style/RedundantSelf` when a self receiver on an lvalue of mlhs arguments. ([@koic][])
* [#9586](https://github.com/rubocop/rubocop/issues/9586): Update `Naming/RescuedExceptionsVariableName` to not register on inner rescues when nested. ([@dvandersluis][])

### Changes

* [#9487](https://github.com/rubocop/rubocop/issues/9487): Mark `Naming/MemoizedInstanceVariableName` as unsafe. ([@marcandre][])
* [#9601](https://github.com/rubocop/rubocop/issues/9601): Make `Style/RedundantBegin` aware of redundant `begin`/`end` blocks around memoization. ([@koic][])
* [#9617](https://github.com/rubocop/rubocop/issues/9617): Disable suggested extensions when using the `--stdin` option. ([@dvandersluis][])

## 1.11.0 (2021-03-01)

### New features

* [#5388](https://github.com/rubocop/rubocop/issues/5388): Add new `Style/UnlessLogicalOperators` cop. ([@caalberts][])
* [#9525](https://github.com/rubocop/rubocop/issues/9525): Add `AllowMethodsWithArguments` option to `Style/SymbolProc`. ([@koic][])

### Bug fixes

* [#9520](https://github.com/rubocop/rubocop/issues/9520): Fix an incorrect auto-correct for `Style/MultipleComparison` when comparing a variable with multiple items in `if` and `elsif` conditions. ([@koic][])
* [#9548](https://github.com/rubocop/rubocop/pull/9548): Fix a false positive for `Style/TrailingBodyOnMethodDefinition` when endless method definition body is after newline in opening parenthesis. ([@koic][])
* [#9541](https://github.com/rubocop/rubocop/issues/9541): Fix `Style/HashConversion` when the correction needs to be wrapped in parens. ([@dvandersluis][])
* [#9533](https://github.com/rubocop/rubocop/issues/9533): Make metrics length cops aware of multi-line kwargs. ([@koic][])
* [#9523](https://github.com/rubocop/rubocop/issues/9523): Fix an error for `Style/TrailingMethodEndStatement` when endless method definition signature and body are on different lines. ([@koic][])
* [#9482](https://github.com/rubocop/rubocop/issues/9482): Return minimal known ruby version from gemspecs `required_ruby_version`. ([@HeroProtagonist][])
* [#9539](https://github.com/rubocop/rubocop/issues/9539): Fix an error for `Style/RedundantBegin` when using body of `begin` is empty. ([@koic][])
* [#9542](https://github.com/rubocop/rubocop/pull/9542): Fix `Layout/FirstArgumentIndentation` for operator methods not called as operators. ([@dvandersluis][], [@TSMMark][])

### Changes

* [#9526](https://github.com/rubocop/rubocop/issues/9526): Add `AllowSplatArgument` option to `Style/HashConversion` and the option is true by default. ([@koic][])

## 1.10.0 (2021-02-15)

### New features

* [#9478](https://github.com/rubocop/rubocop/pull/9478): Add new `Style/HashConversion` cop. ([@zverok][])
* [#9496](https://github.com/rubocop/rubocop/pull/9496): Add new `Gemspec/DateAssignment` cop. ([@koic][])
* [#8724](https://github.com/rubocop/rubocop/issues/8724): Add `IgnoreModules` configuration to `Style/ConstantVisibility` to not register offense for module definitions. ([@tejasbubane][])
* [#9403](https://github.com/rubocop/rubocop/issues/9403): Add autocorrect for `Style/EvalWithLocation` cop. ([@cteece][])

### Bug fixes

* [#9500](https://github.com/rubocop/rubocop/issues/9500): Update `Lint/Debugger` so that only specific receivers for debug methods lead to offenses. ([@dvandersluis][])
* [#9499](https://github.com/rubocop/rubocop/issues/9499): Fix a false positive for `Layout/SpaceBeforeBrackets` when multiple spaces are inserted inside the left bracket. ([@koic][])
* [#9507](https://github.com/rubocop/rubocop/issues/9507): Fix an incorrect auto-correct for `Lint/RedundantSplatExpansion` when expanding `Array.new` call on method argument. ([@koic][])
* [#9490](https://github.com/rubocop/rubocop/issues/9490): Fix incorrect auto-correct for `Layout/FirstArgumentIndentation` when specifying `EnforcedStyle: with_fixed_indentation` of `Layout/ArgumentAlignment` and `EnforcedStyle: consistent` of `Layout/FirstArgumentIndentation`. ([@koic][])
* [#9497](https://github.com/rubocop/rubocop/issues/9497): Fix an error for `Style/ExplicitBlockArgument` when `yield` is inside block of `super`. ([@koic][])
* [#9349](https://github.com/rubocop/rubocop/issues/9349): Fix a false positive for `Lint/MultipleComparison` when using `&`, `|`, and `^` set operation operators in multiple comparison. ([@koic][])
* [#9511](https://github.com/rubocop/rubocop/pull/9511): Fix a false negative for `Lint/ElseLayout` when using multiple `elsif`s. ([@koic][])
* [#9513](https://github.com/rubocop/rubocop/issues/9513): Fix an incorrect auto-correct for `Style/HashConversion` when using hash argument `Hash[]`. ([@koic][])
* [#9492](https://github.com/rubocop/rubocop/issues/9492): Fix an incorrect auto-correct for `Lint/DeprecatedOpenSSLConstant` when using no argument algorithm. ([@koic][])

### Changes

* [#9405](https://github.com/rubocop/rubocop/pull/9405): Improve documentation for `Style/EvalWithLocation` cop. ([@taichi-ishitani][])

## 1.9.1 (2021-02-01)

### New features

* [#9459](https://github.com/rubocop/rubocop/issues/9459): Add `AllowedMethods` option to `Style/IfWithBooleanLiteralBranches` and set `nonzero?` as default value. ([@koic][])

### Bug fixes

* [#9431](https://github.com/rubocop/rubocop/issues/9431): Fix an error for `Style/DisableCopsWithinSourceCodeDirective` when using leading source comment. ([@koic][])
* [#9444](https://github.com/rubocop/rubocop/issues/9444): Fix error on colorization for offenses with `Severity: info`. ([@tejasbubane][])
* [#9448](https://github.com/rubocop/rubocop/issues/9448): Fix an error for `Style/SoleNestedConditional` when using nested `unless` modifier with a single expression condition. ([@koic][])
* [#9449](https://github.com/rubocop/rubocop/issues/9449): Fix an error for `Style/NilComparison` when using `x == nil` as a guard condition'. ([@koic][])
* [#9440](https://github.com/rubocop/rubocop/issues/9440): Fix `Lint/SymbolConversion` for implicit `to_sym` without a receiver. ([@dvandersluis][])
* [#9453](https://github.com/rubocop/rubocop/issues/9453): Fix infinite loop error for `Layout/FirstParameterIndentation` when `EnforcedStyle: with_fixed_indentation` is specified for `Layout/ArgumentAlignment`. ([@koic][])
* [#9466](https://github.com/rubocop/rubocop/issues/9466): Don't correct `Style/SingleLineMethods` using endless methods if the target ruby is < 3.0. ([@dvandersluis][])
* [#9455](https://github.com/rubocop/rubocop/issues/9455): Fix a false positive for `Lint/SymbolConversion` when hash keys that contain `":"`. ([@koic][])
* [#9454](https://github.com/rubocop/rubocop/issues/9454): Fix an incorrect auto-correct for `Style/IfWithBooleanLiteralBranches` when using `elsif do_something?` with boolean literal branches. ([@koic][])
* [#9438](https://github.com/rubocop/rubocop/issues/9438): Fix a false positive for `Layout/SpaceBeforeBrackets` when space is used in left bracket. ([@koic][])
* [#9457](https://github.com/rubocop/rubocop/issues/9457): Fix a false positive for `Lint/SymbolConversion` when hash keys that end with `=`. ([@koic][])
* [#9473](https://github.com/rubocop/rubocop/issues/9473): Fix an error for `Lint/DeprecatedConstants` when using `__ENCODING__`. ([@koic][])
* [#9452](https://github.com/rubocop/rubocop/pull/9452): Fix `StyleGuideBaseURL` not functioning with nested departments. ([@tas50][])
* [#9465](https://github.com/rubocop/rubocop/issues/9465): Update `Metrics/ParameterLists` to be able to write `MaxOptionalParameters` in rubocop_todo.yml. ([@dvandersluis][])
* [#9433](https://github.com/rubocop/rubocop/issues/9433): Fix an error for `Style/EvalWithLocation` when using eval with block argument. ([@koic][])

### Changes

* [#9437](https://github.com/rubocop/rubocop/issues/9437): Improve offense message when there is an allowed range of empty lines. ([@dvandersluis][])
* [#9476](https://github.com/rubocop/rubocop/pull/9476): Mark `Style/IfWithBooleanLiteralBranches` as unsafe auto-correction. ([@koic][])

## 1.9.0 (2021-01-28)

### New features

* [#9396](https://github.com/rubocop/rubocop/pull/9396): Add new `Style/IfWithBooleanLiteralBranches` cop. ([@koic][])
* [#9402](https://github.com/rubocop/rubocop/pull/9402): Add new `Lint/TripleQuotes` cop. ([@dvandersluis][])
* [#7827](https://github.com/rubocop/rubocop/pull/7827): Add pre-commit hook. ([@jdufresne][], [@adithyabsk][])
* [#7452](https://github.com/rubocop/rubocop/issues/7452): Support `IgnoredMethods` option for `Style/FormatStringToken`. ([@koic][])
* [#9340](https://github.com/rubocop/rubocop/pull/9340): Added `info` Severity level to allow offenses to be listed but not return a non-zero error code. ([@dvandersluis][])
* [#9353](https://github.com/rubocop/rubocop/issues/9353): Add new `Lint/SymbolConversion` cop. ([@dvandersluis][])
* [#9363](https://github.com/rubocop/rubocop/pull/9363): Add new cop `Lint/OrAssignmentToConstant`. ([@uplus][])
* [#9326](https://github.com/rubocop/rubocop/pull/9326): Add new `Lint/NumberedParameterAssignment` cop. ([@koic][])

### Bug fixes

* [#9366](https://github.com/rubocop/rubocop/issues/9366): Fix an incorrect auto-correct for `Style/SoleNestedConditional` when using method arguments without parentheses for outer condition. ([@koic][])
* [#9372](https://github.com/rubocop/rubocop/issues/9372): Fix an error for `Style/IfInsideElse` when nested `if` branch code is empty. ([@koic][])
* [#9374](https://github.com/rubocop/rubocop/issues/9374): Fix autocorrection for `Layout/LineLength` when the first argument to a send node is a overly long hash pair. ([@dvandersluis][])
* [#9387](https://github.com/rubocop/rubocop/issues/9387): Fix incorrect auto-correct for `Style/NilComparison` when using `!x.nil?` and `EnforcedStyle: comparison`. ([@koic][])
* [#9411](https://github.com/rubocop/rubocop/pull/9411): Fix false negatives for `Style/EvalWithLocation` for `Kernel.eval` and when given improper arguments. ([@dvandersluis][])
* [#7766](https://github.com/rubocop/rubocop/issues/7766): Fix `Naming/RescuedExceptionsVariableName` autocorrection when the rescue body returns the exception variable. ([@asterite][])
* [#7766](https://github.com/rubocop/rubocop/issues/7766): Fix `Naming/RescuedExceptionsVariableName` autocorrection to not change variables if the exception variable has been reassigned. ([@dvandersluis][])
* [#9389](https://github.com/rubocop/rubocop/pull/9389): Fix an infinite loop error for `IncludeSemanticChanges: false` of `Style/NonNilCheck` with `EnforcedStyle: comparison` of `Style/NilComparison`. ([@koic][])
* [#9384](https://github.com/rubocop/rubocop/pull/9384): Fix a suggestion message when not auto-correctable. ([@koic][])
* [#9424](https://github.com/rubocop/rubocop/pull/9424): Fix an incorrect auto-correct for `Style/ClassMethodsDefinitions` when defining class methods with `class << self` and there is no blank line between method definition and attribute accessor. ([@koic][])
* [#9370](https://github.com/rubocop/rubocop/issues/9370): Fix an incorrect auto-correct for `Style/SoleNestedConditional` when using nested `unless` modifier multiple conditional. ([@koic][])
* [#9406](https://github.com/rubocop/rubocop/pull/9406): Fix rubocop_todo link injection when YAML doc start sigil exists. ([@dduugg][])
* [#9229](https://github.com/rubocop/rubocop/pull/9229): Fix errors being reported with `rubocop -V` with an invalid config. ([@dvandersluis][])
* [#9425](https://github.com/rubocop/rubocop/issues/9425): Fix error in `Layout/ClassStructure` when initializer comes after private attribute macro. ([@tejasbubane][])

### Changes

* [#9415](https://github.com/rubocop/rubocop/issues/9415): Change `Layout/ClassStructure` to detect inline modifiers. ([@AndreiEres][])
* [#9380](https://github.com/rubocop/rubocop/issues/9380): Mark `Style/FloatDivision` as unsafe. ([@koic][])
* [#9345](https://github.com/rubocop/rubocop/issues/9345): Make `Style/AsciiComments` allow copyright notice by default. ([@koic][])
* [#9399](https://github.com/rubocop/rubocop/issues/9399): Added `AllowedCops` configuration to `Style/DisableCopsWithinSourceCodeDirective`. ([@dvandersluis][])
* [#9327](https://github.com/rubocop/rubocop/issues/9327): Change `Layout/EmptyLineAfterMagicComment` to accept top-level `shareable_constant_values` directive. ([@tejasbubane][])
* [#7902](https://github.com/rubocop/rubocop/issues/7902): Change `Lint/NumberConversion` to detect symbol form of conversion methods. ([@tejasbubane][])

## 1.8.1 (2021-01-11)

### Bug fixes

* [#9342](https://github.com/rubocop/rubocop/issues/9342): Fix an error for `Lint/RedundantDirGlobSort` when using `collection.sort`. ([@koic][])
* [#9304](https://github.com/rubocop/rubocop/issues/9304): Do not register an offense for `Style/ExplicitBlockArgument` when the `yield` arguments are not an exact match with the block arguments. ([@dvandersluis][])
* [#8281](https://github.com/rubocop/rubocop/issues/8281): Fix `Style/WhileUntilModifier` handling comments and assignment when correcting to modifier form. ([@Darhazer][])
* [#8229](https://github.com/rubocop/rubocop/issues/8229): Fix faulty calculation in UncommunicativeName. ([@ohbarye][])
* [#9350](https://github.com/rubocop/rubocop/pull/9350): Wrap in parens before replacing `unless` with `if` and `!`. ([@magneland][])
* [#9356](https://github.com/rubocop/rubocop/pull/9356): Fix duplicate extension cop versions when using `rubocop -V`. ([@koic][])
* [#9355](https://github.com/rubocop/rubocop/issues/9355): Fix `Style/SingleLineMethods` autocorrection to endless method when the original code had parens. ([@dvandersluis][])
* [#9346](https://github.com/rubocop/rubocop/pull/9346): Fix an incorrect auto-correct for `Style/StringConcatenation` when concat string include double quotes and interpolation. ([@k-karen][])

## 1.8.0 (2021-01-07)

### New features

* [#9324](https://github.com/rubocop/rubocop/pull/9324): Add new `Lint/DeprecatedConstants` cop. ([@koic][])
* [#9319](https://github.com/rubocop/rubocop/pull/9319): Support asdf's .tool-versions file. ([@noon-ng][])
* [#9301](https://github.com/rubocop/rubocop/pull/9301): Add new `Lint/RedundantDirGlobSort` cop. ([@koic][])
* [#9281](https://github.com/rubocop/rubocop/pull/9281): Add new cop `Style/EndlessMethod`. ([@dvandersluis][])
* [#9321](https://github.com/rubocop/rubocop/pull/9321): Add new `Lint/LambdaWithoutLiteralBlock` cop. ([@koic][])

### Bug fixes

* [#9298](https://github.com/rubocop/rubocop/issues/9298): Fix an incorrect auto-correct for `Lint/RedundantCopDisableDirective` when there is a blank line before inline comment. ([@koic][])
* [#9233](https://github.com/rubocop/rubocop/issues/9233): Fix `Style/SoleNestedConditional` copying non-relevant comments during auto-correction. ([@Darhazer][])
* [#9312](https://github.com/rubocop/rubocop/issues/9312): Fix `Layout/FirstHashElementLineBreak` to apply to multi-line hashes with only a single element. ([@muirdm][])
* [#9316](https://github.com/rubocop/rubocop/issues/9316): Fix `Style/EmptyLiteral` registering wrong offense when using a numbered block for Hash.new, i.e. `Hash.new { _1[_2] = [] }`. ([@agargiulo][])
* [#9308](https://github.com/rubocop/rubocop/issues/9308): Fix an error for `Layout/EmptyLineBetweenDefs` when using endless class method. ([@koic][])
* [#9314](https://github.com/rubocop/rubocop/issues/9314): Fix an incorrect auto-correct for `Style/RedundantReturn` when multiple return values have a parenthesized return value. ([@koic][])
* [#9335](https://github.com/rubocop/rubocop/issues/9335): Fix an incorrect auto-correct for `EnforcedStyle: require_parentheses` of `Style/MethodCallWithArgsParentheses` with `Style/NestedParenthesizedCalls`. ([@koic][])
* [#9290](https://github.com/rubocop/rubocop/issues/9290): Fix a false positive for `Layout/SpaceBeforeBrackets` when using array literal method argument. ([@koic][])
* [#9333](https://github.com/rubocop/rubocop/issues/9333): Fix an error for `Style/IfInsideElse` when using a modifier `if` nested inside an `else` after `elsif`. ([@koic][])
* [#9303](https://github.com/rubocop/rubocop/issues/9303): Fix an incorrect auto-correct for `Style/RaiseArgs` with `EnforcedStyle: compact` when using exception instantiation argument. ([@koic][])

### Changes

* [#9300](https://github.com/rubocop/rubocop/pull/9300): Make `Lint/NonDeterministicRequireOrder` not to register offense when using Ruby 3.0 or higher. ([@koic][])
* [#9320](https://github.com/rubocop/rubocop/pull/9320): Support unicode-display_width v2. ([@dduugg][])
* [#9288](https://github.com/rubocop/rubocop/pull/9288): Require Parser 3.0.0.0 or higher. ([@koic][])
* [#9337](https://github.com/rubocop/rubocop/issues/9337): Add `AllowedIdentifiers` to `Naming/VariableName`. ([@dvandersluis][])
* [#9295](https://github.com/rubocop/rubocop/pull/9295): Update `Style/SingleLineMethods` to correct to an endless method definition if they are allowed. ([@dvandersluis][])
* [#9331](https://github.com/rubocop/rubocop/pull/9331): Mark `Style/MutableConstant` as unsafe. ([@koic][])

## 1.7.0 (2020-12-25)

### New features

* [#9260](https://github.com/rubocop/rubocop/pull/9260): Support auto-correction for `Style/MultilineMethodSignature`. ([@koic][])
* [#9282](https://github.com/rubocop/rubocop/pull/9282): Make `Style/RedundantFreeze` and `Style/MutableConstant` cops aware of frozen regexp and range literals when using Ruby 3.0. ([@koic][])
* [#9223](https://github.com/rubocop/rubocop/issues/9223): Add new `Lint/AmbiguousAssignment` cop. ([@fatkodima][])
* [#9243](https://github.com/rubocop/rubocop/pull/9243): Support auto-correction for `Style/CommentedKeyword`. ([@koic][])
* [#9283](https://github.com/rubocop/rubocop/pull/9283): Add new `Style/HashExcept` cop. ([@koic][])
* [#9231](https://github.com/rubocop/rubocop/pull/9231): Add new `Layout/SpaceBeforeBrackets` cop. ([@koic][])

### Bug fixes

* [#9232](https://github.com/rubocop/rubocop/pull/9232): Fix `Style/SymbolProc` registering wrong offense when using a symbol numbered block argument greater than 1, i.e. `[[1, 2]].map { _2.succ }`. ([@tdeo][])
* [#9274](https://github.com/rubocop/rubocop/issues/9274): Fix error in `Metrics/ClassLength` when the class only contains comments. ([@dvandersluis][])
* [#9213](https://github.com/rubocop/rubocop/issues/9213): Fix a false positive for `Style/RedundantFreeze` when using `Array#*`. ([@koic][])
* [#9279](https://github.com/rubocop/rubocop/pull/9279): Add support for endless methods to `Style/MethodCallWithArgsParentheses`. ([@dvandersluis][])
* [#9245](https://github.com/rubocop/rubocop/issues/9245): Fix `Lint/AmbiguousRegexpLiteral` when given a `match_with_lvasgn` node. ([@dvandersluis][])
* [#9276](https://github.com/rubocop/rubocop/pull/9276): Add support for endless methods to `Style/SingleLineMethods`. ([@dvandersluis][])
* [#9225](https://github.com/rubocop/rubocop/issues/9225): Fix `Style/LambdaCall` ignoring further offenses after opposite style is detected. ([@sswander][])
* [#9234](https://github.com/rubocop/rubocop/issues/9234): Fix the error for `Style/KeywordParametersOrder` and make it aware of block keyword parameters. ([@koic][])
* [#8938](https://github.com/rubocop/rubocop/pull/8938): Fix some ConfigurableEnforcedStyle cops to output `Exclude` file lists in `--auto-gen-config` runs. ([@h-lame][])
* [#9257](https://github.com/rubocop/rubocop/issues/9257): Fix false positive for `Style/SymbolProc` when the block uses a variable from outside the block. ([@dvandersluis][])
* [#9251](https://github.com/rubocop/rubocop/issues/9251): Fix extracted cop warning when the extension is loaded using `--require`. ([@dvandersluis][])
* [#9244](https://github.com/rubocop/rubocop/issues/9244): When a cop defined in an extension is explicitly enabled, ensure that it remains enabled. ([@dvandersluis][])
* [#8046](https://github.com/rubocop/rubocop/issues/8046): Fix an error for `Layout/HeredocArgumentClosingParenthesis` when there is an argument between a heredoc argument and the closing parentheses. ([@koic][])
* [#9261](https://github.com/rubocop/rubocop/pull/9261): Fix an incorrect auto-correct for `Style/MultilineWhenThen` when one line for multiple candidate values of `when` statement. ([@makicamel][])
* [#9258](https://github.com/rubocop/rubocop/pull/9258): Fix calculation of cop department for nested departments. ([@mvz][])
* [#9277](https://github.com/rubocop/rubocop/pull/9277): Fix `Layout/EmptyLineBetweenDefs` error with endless method definitions. ([@dvandersluis][])
* [#9278](https://github.com/rubocop/rubocop/pull/9278): Update `Style/MethodDefParentheses` to ignore endless method definitions since parentheses are always required. ([@dvandersluis][])

### Changes

* [#9212](https://github.com/rubocop/rubocop/pull/9212): Make `Style/RedundantArgument` aware of `String#chomp` and `String#chomp!`. ([@koic][])
* [#8482](https://github.com/rubocop/rubocop/issues/8482): Allow simple math for `Lint/BinaryOperatorWithIdenticalOperands` cop. ([@fatkodima][])
* [#9237](https://github.com/rubocop/rubocop/issues/9237): Add `IgnoredPatterns` configuration to `Lint/UnreachableLoop` to allow for block methods that share a name with an `Enumerable` method. ([@dvandersluis][])
* [#9206](https://github.com/rubocop/rubocop/pull/9206): Allow extensions to disable cop obsoletions. ([@dvandersluis][])
* [#9262](https://github.com/rubocop/rubocop/issues/9262): Update `Style/CollectionMethods` to be handle additional arguments and methods that accept a symbol instead of a block. ([@dvandersluis][])
* [#9235](https://github.com/rubocop/rubocop/issues/9235): Allow `--only` and `--except` to be able to properly qualify cops added by require. ([@dvandersluis][])
* [#9205](https://github.com/rubocop/rubocop/issues/9205): Update `Naming/MemoizedInstanceVariableName` to handle dynamically defined methods. ([@dvandersluis][])
* [#9285](https://github.com/rubocop/rubocop/pull/9285): Add `AllowPercentLiteralArrayArgument` option for `Lint/RedundantSplatExpansion` to enable the option by default. ([@koic][])
* [#9208](https://github.com/rubocop/rubocop/issues/9208): Use Array#bsearch instead of Array#include? to detect hidden files. ([@dark-panda][])
* [#9228](https://github.com/rubocop/rubocop/pull/9228): Suppress any config warnings for `rubocop -V`. ([@dvandersluis][])
* [#9193](https://github.com/rubocop/rubocop/pull/9193): Add `IgnoreLiteralBranches` and `IgnoreConstantBranches` options to `Lint/DuplicateBranch`. ([@dvandersluis][])

## 1.6.1 (2020-12-10)

### Bug fixes

* [#9196](https://github.com/rubocop/rubocop/issues/9196): Fix `ConfigObsoletion::ExtractedCop` raising errors for loaded features when bundler is not activated. ([@dvandersluis][])

## 1.6.0 (2020-12-09)

### New features

* [#9125](https://github.com/rubocop/rubocop/issues/9125): Allow ConfigObsoletion to be extended by other RuboCop libraries. ([@dvandersluis][])
* [#9182](https://github.com/rubocop/rubocop/pull/9182): Support auto-correction for `Style/RedundantArgument`. ([@koic][])
* [#9186](https://github.com/rubocop/rubocop/pull/9186): Support auto-correction for `Style/FloatDivision`. ([@koic][])
* [#9167](https://github.com/rubocop/rubocop/pull/9167): Support auto-correct for `StyleSingleLineBlockParams`. ([@koic][])

### Bug fixes

* [#9177](https://github.com/rubocop/rubocop/pull/9177): Remove back-ref related code from `Style/SpecialGlobalVars`. ([@r7kamura][])
* [#9160](https://github.com/rubocop/rubocop/issues/9160): Fix an incorrect auto-correct for `Style/IfUnlessModifier` and `Style/SoleNestedConditional` when auto-correction conflicts for guard condition. ([@koic][])
* [#9174](https://github.com/rubocop/rubocop/issues/9174): Handle send nodes with unparenthesized arguments in `Style/SoleNestedConditional`. ([@dvandersluis][])
* [#9184](https://github.com/rubocop/rubocop/issues/9184): `Layout/EmptyLinesAroundAttributeAccessor` fails if the attr_accessor is the last line of the file. ([@tas50][])

### Changes

* [#9171](https://github.com/rubocop/rubocop/pull/9171): Add "did you mean" message when failing due to invalid cops in configuration. ([@dvandersluis][])
* [#8897](https://github.com/rubocop/rubocop/issues/8897): Change `Style/StringConcatenation` to accept line-end concatenation between two strings so that `Style/LineEndConcatenation` can handle it instead. ([@dvandersluis][])
* [#9172](https://github.com/rubocop/rubocop/pull/9172): Add `Style/PerlBackrefs` targets and change message more detailed. ([@r7kamura][])
* [#9187](https://github.com/rubocop/rubocop/pull/9187): Update formatters to output `[Correctable]` for correctable offenses. ([@dvandersluis][])
* [#9169](https://github.com/rubocop/rubocop/pull/9169): Add obsoletion warnings for `Performance/*` and `Rails/*` which are in separate gems now. ([@dvandersluis][])

## 1.5.2 (2020-12-04)

### Bug fixes

* [#9152](https://github.com/rubocop/rubocop/issues/9152): Fix an incorrect auto-correct for `Style/SoleNestedConditional` when nested `||` operator modifier condition. ([@koic][])
* [#9161](https://github.com/rubocop/rubocop/issues/9161): Fix a false positive for `Layout/HeredocArgumentClosingParenthesis` when using subsequence closing parentheses in the same line. ([@koic][])
* [#9151](https://github.com/rubocop/rubocop/issues/9151): Fix `SuggestExtensions` to not suggest extensions that are installed but not direct dependencies. ([@dvandersluis][])
* [#8985](https://github.com/rubocop/rubocop/issues/8985): Fix `Style/StringConcatenation` autocorrect generating invalid ruby. ([@tejasbubane][])
* [#9155](https://github.com/rubocop/rubocop/issues/9155): Fix a false positive for `Layout/MultilineMethodCallIndentation` when multiline method chain has expected indent width and the method is preceded by splat for `EnforcedStyle: indented_relative_to_receiver`. ([@koic][])

### Changes

* [#9080](https://github.com/rubocop/rubocop/issues/9080): Make `Lint/ShadowingOuterLocalVariable` aware of `Ractor`. ([@tejasbubane][])
* [#9102](https://github.com/rubocop/rubocop/pull/9102): Relax regexp_parser requirement. ([@marcandre][])

## 1.5.1 (2020-12-02)

### Bug fixes

* [#8684](https://github.com/rubocop/rubocop/issues/8684): Fix an error for `Lint/InterpolationCheck` cop. ([@tejasbubane][])
* [#9145](https://github.com/rubocop/rubocop/issues/9145): Fix issues with SuggestExtensions when bundler is not available, or when there is no gemfile. ([@dvandersluis][])
* [#9140](https://github.com/rubocop/rubocop/issues/9140): Fix an error for `Layout/EmptyLinesAroundArguments` when multiline style argument for method call without selector. ([@koic][])
* [#9136](https://github.com/rubocop/rubocop/pull/9136): Fix `AllowedIdentifiers` in `Naming/VariableNumber` to include variable assignments. ([@PhilCoggins][])

## 1.5.0 (2020-12-01)

### New features

* [#9112](https://github.com/rubocop/rubocop/pull/9112): Add new cop `Lint/UnexpectedBlockArity`. ([@dvandersluis][])
* [#9010](https://github.com/rubocop/rubocop/pull/9010): `Metrics/ParameterLists` supports `MaxOptionalParameters` config parameter. ([@fatkodima][])
* [#9114](https://github.com/rubocop/rubocop/pull/9114): Support auto-correction for `Style/SoleNestedConditional`. ([@koic][])
* [#8564](https://github.com/rubocop/rubocop/issues/8564): `Metrics/AbcSize`: Add optional discount for repeated "attributes". ([@marcandre][])

### Bug fixes

* [#8820](https://github.com/rubocop/rubocop/issues/8820): Fixes `IfWithSemicolon` autocorrection when `elsif` is present. ([@adrian-rivera][], [@dvandersluis][])
* [#9113](https://github.com/rubocop/rubocop/pull/9113): Fix a false positive for `Style/MethodCallWithoutArgsParentheses` when assigning to a default argument with the same name. ([@koic][])
* [#9115](https://github.com/rubocop/rubocop/issues/9115): Fix a false positive for `Layout/FirstArgumentIndentation` when argument has expected indent width and the method is preceded by splat for `EnforcedStyle: consistent_relative_to_receiver`. ([@koic][])
* [#9128](https://github.com/rubocop/rubocop/issues/9128): Fix an incorrect auto-correct for `Style/ClassAndModuleChildren` when namespace is defined as a class in the same file. ([@koic][])
* [#9105](https://github.com/rubocop/rubocop/issues/9105): Fix an incorrect auto-correct for `Style/RedundantCondition` when using operator method in `else`. ([@koic][])
* [#9096](https://github.com/rubocop/rubocop/pull/9096): Fix #9095 use merged_config instead of config for pending new cop check. ([@ThomasKoppensteiner][])
* [#8053](https://github.com/rubocop/rubocop/issues/8053): Fix an incorrect auto-correct for `Style/AndOr` when `or` precedes `and`. ([@koic][])
* [#9097](https://github.com/rubocop/rubocop/issues/9097): Fix a false positive for `Layout/EmptyLinesAroundArguments` when blank line is inserted between method with arguments and receiver. ([@koic][])

### Changes

* [#9122](https://github.com/rubocop/rubocop/issues/9122): Added tip message if any gems are loaded that have RuboCop extensions. ([@dvandersluis][])
* [#9104](https://github.com/rubocop/rubocop/issues/9104): Preset some stdlib method names for `Naming/VariableNumber`. ([@koic][])
* [#9127](https://github.com/rubocop/rubocop/pull/9127): Update `Style/SymbolProc` to be aware of numblocks. ([@dvandersluis][])
* [#9102](https://github.com/rubocop/rubocop/pull/9102): Upgrade regexp_parser to 2.0. ([@knu][])
* [#9100](https://github.com/rubocop/rubocop/pull/9100): Update `ConfigObsoletion` so that parameters can be deprecated but still accepted. ([@dvandersluis][])
* [#9108](https://github.com/rubocop/rubocop/pull/9108): Update `Lint/UnmodifiedReduceAccumulator` to handle numblocks and more than 2 arguments. ([@dvandersluis][])
* [#9098](https://github.com/rubocop/rubocop/pull/9098): Update `Metrics/BlockLength` and `Metrics/MethodLength` to use `IgnoredMethods` instead of `ExcludedMethods` in configuration. The previous key is retained for backwards compatibility. ([@dvandersluis][])
* [#9098](https://github.com/rubocop/rubocop/pull/9098): Update `IgnoredMethods` so that every cop that uses it will accept both strings and regexes in the configuration. ([@dvandersluis][])

## 1.4.2 (2020-11-25)

### Bug fixes

* [#9083](https://github.com/rubocop/rubocop/pull/9083): Fix `Style/RedundantArgument` cop raising offense for more than one argument. ([@tejasbubane][])
* [#9089](https://github.com/rubocop/rubocop/issues/9089): Fix an incorrect auto-correct for `Style/FormatString` when using sprintf with second argument that uses an operator. ([@koic][])
* [#7670](https://github.com/rubocop/rubocop/issues/7670): Handle offenses inside heredocs for `-a --disable-uncorrectable`. ([@jonas054][])
* [#9070](https://github.com/rubocop/rubocop/issues/9070): Fix `Lint/UnmodifiedReduceAccumulator` error when the block does not have enough arguments. ([@dvandersluis][])

### Changes

* [#9091](https://github.com/rubocop/rubocop/pull/9091): Have `Naming/VariableNumber` accept _1, _2, ... ([@marcandre][])
* [#9087](https://github.com/rubocop/rubocop/pull/9087): Deprecate `EnforceSuperclass` module. ([@koic][])

## 1.4.1 (2020-11-23)

### Bug fixes

* [#9082](https://github.com/rubocop/rubocop/pull/9082): Fix gemspec to include assets directory. ([@javierav][])

## 1.4.0 (2020-11-23)

### New features

* [#7737](https://github.com/rubocop/rubocop/issues/7737): Add new `Style/RedundantArgument` cop. ([@tejasbubane][])
* [#9064](https://github.com/rubocop/rubocop/issues/9064): Add `EmptyLineBetweenMethodDefs`, `EmptyLineBetweenClassDefs` and `EmptyLineBetweenModuleDefs` config options for `Layout/EmptyLineBetweenDefs` cop. ([@tejasbubane][])
* [#9043](https://github.com/rubocop/rubocop/pull/9043): Add `--stderr` to write all output to stderr except for the autocorrected source. ([@knu][])

### Bug fixes

* [#9067](https://github.com/rubocop/rubocop/pull/9067): Fix an incorrect auto-correct for `Lint::AmbiguousRegexpLiteral` when passing in a regexp to a method with no receiver. ([@amatsuda][])
* [#9060](https://github.com/rubocop/rubocop/issues/9060): Fix an error for `Layout/SpaceAroundMethodCallOperator` when using `__ENCODING__`. ([@koic][])
* [#7338](https://github.com/rubocop/rubocop/issues/7338): Handle assignment with `[]=` in `MultilineMethodCallIndentation`. ([@jonas054][])
* [#7726](https://github.com/rubocop/rubocop/issues/7726): Fix `MultilineMethodCallIndentation` indentation inside square brackets. ([@jonas054][])
* [#8857](https://github.com/rubocop/rubocop/issues/8857): Improve how `Exclude` properties are generated by `--auto-gen-config`. ([@jonas054][])

### Changes

* [#8788](https://github.com/rubocop/rubocop/issues/8788): Change `Style/Documentation` to not trigger offense with only macros. ([@tejasbubane][])
* [#8993](https://github.com/rubocop/rubocop/issues/8993): Allow `ExcludedMethods` config of `Metrics/MethodLength` cop to contain regex. ([@tejasbubane][])
* [#9073](https://github.com/rubocop/rubocop/issues/9073): Enable `Layout/LineLength`'s auto-correct by default. ([@bbatsov][])
* [#9079](https://github.com/rubocop/rubocop/pull/9079): Improve the gemspec to load only the necessary files without the git utility. ([@piotrmurach][])
* [#9059](https://github.com/rubocop/rubocop/pull/9059): Update `Lint/UnmodifiedReduceAccumulator` to accept blocks which return in the form `accumulator[element]`. ([@dvandersluis][])
* [#9072](https://github.com/rubocop/rubocop/pull/9072): `Lint/MissingSuper`: exclude `method_missing` and `respond_to_missing?`. ([@marcandre][])
* [#9074](https://github.com/rubocop/rubocop/pull/9074): Allow specifying a pull request ID when calling `rake changelog:*`. ([@marcandre][])

## 1.3.1 (2020-11-16)

### Bug fixes

* [#9037](https://github.com/rubocop/rubocop/pull/9037): Fix `required_ruby_version` issue when using `Gem::Requirement`. ([@cetinajero][])
* [#9039](https://github.com/rubocop/rubocop/pull/9039): Fix stack level too deep error if target directory contains `**`. ([@unasuke][])
* [#6962](https://github.com/rubocop/rubocop/issues/6962): Limit `Layout/ClassStructure` constant order autocorrect to literal constants. ([@tejasbubane][])
* [#9032](https://github.com/rubocop/rubocop/issues/9032): Fix an error for `Style/DocumentDynamicEvalDefinition` when using eval-type method with interpolated string that is not heredoc without comment doc. ([@koic][])
* [#9049](https://github.com/rubocop/rubocop/issues/9049): Have `Lint/ToEnumArguments` accept `__callee__`. ([@marcandre][])
* [#9050](https://github.com/rubocop/rubocop/issues/9050): Fix a false positive for `Style/NegatedIfElseCondition` when `if` with `!!` condition. ([@koic][])
* [#9041](https://github.com/rubocop/rubocop/issues/9041): Fix a false positive for `Naming/VariableNumber` when using integer symbols. ([@koic][])

### Changes

* [#9045](https://github.com/rubocop/rubocop/pull/9045): Have `cut_release` handle "config/default" and generate cops doc. ([@marcandre][])
* [#9036](https://github.com/rubocop/rubocop/pull/9036): Allow `enums` method by default for `Lint/ConstantDefinitionInBlock`. ([@koic][])
* [#9035](https://github.com/rubocop/rubocop/issues/9035): Only complain about `SafeYAML` if it causes issues. ([@marcandre][])

## 1.3.0 (2020-11-12)

### New features

* [#8761](https://github.com/rubocop/rubocop/issues/8761): Read `required_ruby_version` from gemspec file if it exists. ([@HeroProtagonist][])
* [#9001](https://github.com/rubocop/rubocop/pull/9001): Add new `Lint/EmptyClass` cop. ([@fatkodima][])
* [#9025](https://github.com/rubocop/rubocop/issues/9025): Add `AllowedMethods` option to `Lint/ConstantDefinitionInBlock`. ([@koic][])
* [#9014](https://github.com/rubocop/rubocop/pull/9014): Support auto-correction for `Style/IfInsideElse`. ([@koic][])
* [#8483](https://github.com/rubocop/rubocop/pull/8483): Add new `Style/StaticClass` cop. ([@fatkodima][])
* [#9020](https://github.com/rubocop/rubocop/pull/9020): Add new `Style/NilLambda` cop to check for lambdas that always return nil. ([@dvandersluis][])
* [#8404](https://github.com/rubocop/rubocop/pull/8404): Add new `Lint/DuplicateBranch` cop. ([@fatkodima][])

### Bug fixes

* [#8499](https://github.com/rubocop/rubocop/issues/8499): Fix `Style/IfUnlessModifier` and `Style/WhileUntilModifier` to prevent an offense if there are both first-line comment and code after `end` block. ([@dsavochkin][])
* [#8996](https://github.com/rubocop/rubocop/issues/8996): Fix a false positive for `Style/MultipleComparison` when comparing two sides of the disjunction is unrelated. ([@koic][])
* [#8975](https://github.com/rubocop/rubocop/issues/8975): Fix an infinite loop when autocorrecting `Layout/TrailingWhitespace` + `Lint/LiteralInInterpolation`. ([@fatkodima][])
* [#8998](https://github.com/rubocop/rubocop/issues/8998): Fix an error for `Style/NegatedIfElseCondition` when using negated condition and `if` branch body is empty. ([@koic][])
* [#9008](https://github.com/rubocop/rubocop/pull/9008): Mark `Style/InfiniteLoop` as unsafe. ([@marcandre][])

### Changes

* [#8978](https://github.com/rubocop/rubocop/issues/8978): Update `Layout/LineLength` autocorrection to be able to handle method calls with long argument lists. ([@dvandersluis][])
* [#9015](https://github.com/rubocop/rubocop/issues/9015): Update `Lint/EmptyBlock` to allow for empty lambdas. ([@dvandersluis][])
* [#9022](https://github.com/rubocop/rubocop/issues/9022): Add `NOTE` to keywords of `Style/CommentAnnotation`. ([@koic][])
* [#9011](https://github.com/rubocop/rubocop/issues/9011): Mark autocorrection for `Lint/Loop` as unsafe. ([@dvandersluis][])
* [#9026](https://github.com/rubocop/rubocop/issues/9026): Update `Style/DocumentDynamicEvalDefinition` to detect comment blocks that document the evaluation. ([@dvandersluis][])
* [#9004](https://github.com/rubocop/rubocop/pull/9004): Remove obsolete gem `SafeYAML` compatibility. ([@marcandre][])
* [#9023](https://github.com/rubocop/rubocop/issues/9023): Mark unsafe for `Style/CollectionCompact`. ([@koic][])
* [#9012](https://github.com/rubocop/rubocop/issues/9012): Allow `AllowedIdentifiers` to be specified for `Naming/VariableNumber`. ([@dvandersluis][])

## 1.2.0 (2020-11-05)

### New features

* [#8983](https://github.com/rubocop/rubocop/pull/8983): Support auto-correction for `Naming/HeredocDelimiterCase`. ([@koic][])
* [#8004](https://github.com/rubocop/rubocop/issues/8004): Add new `GitHubActionsFormatter` formatter. ([@lautis][])
* [#8175](https://github.com/rubocop/rubocop/pull/8175): Add new `AllowedCompactTypes` option for `Style/RaiseArgs`. ([@pdobb][])
* [#8566](https://github.com/rubocop/rubocop/issues/8566): Add new `Style/CollectionCompact` cop. ([@fatkodima][])
* [#8925](https://github.com/rubocop/rubocop/issues/8925): Add `--display-time` option for displaying elapsed time of `rubocop` command. ([@joshuapinter][])
* [#8967](https://github.com/rubocop/rubocop/pull/8967): Add new `Style/NegatedIfElseCondition` cop. ([@fatkodima][])
* [#8984](https://github.com/rubocop/rubocop/pull/8984): Support auto-correction for `Style/DoubleNegation`. ([@koic][])
* [#8992](https://github.com/rubocop/rubocop/pull/8992): Support auto-correction for `Lint/ElseLayout`. ([@koic][])
* [#8988](https://github.com/rubocop/rubocop/pull/8988): Support auto-correction for `Lint/UselessSetterCall`. ([@koic][])
* [#8982](https://github.com/rubocop/rubocop/pull/8982): Support auto-correction for `Naming/BinaryOperatorParameterName`. ([@koic][])

### Bug fixes

* [#8989](https://github.com/rubocop/rubocop/pull/8989): Fix multibyte support in the regexp node handler that led `Style/RedundantRegexpEscape` to malfunction and corrupt a program in auto-correction. ([@knu][])
* [#8912](https://github.com/rubocop/rubocop/pull/8912): Fix `Layout/ElseAlignment` for `rescue/else/ensure` inside `do/end` blocks with assignment. ([@miry][])
* [#8971](https://github.com/rubocop/rubocop/issues/8971): Fix a false alarm for `# rubocop:disable Lint/EmptyBlock` inline comment with `Lint/RedundantCopDisableDirective`. ([@koic][])
* [#8976](https://github.com/rubocop/rubocop/issues/8976): Fix an incorrect auto-correct for `Style/KeywordParametersOrder` when `kwoptarg` is before `kwarg` and argument parentheses omitted. ([@koic][])
* [#8084](https://github.com/rubocop/rubocop/pull/8084): Fix a bug in how `Layout/SpaceAroundBlockParameters` handles block parameters with a trailing comma. ([@bquorning][])
* [#8966](https://github.com/rubocop/rubocop/issues/8966): Fix `Layout/SpaceInsideParens` to enforce no spaces in empty parens for all styles. ([@joshuapinter][])

### Changes

* [#5717](https://github.com/rubocop/rubocop/issues/5717): Support `defined?`-based memoization for `Naming/MemoizedInstanceVariableName` cop. ([@fatkodima][])
* [#8964](https://github.com/rubocop/rubocop/pull/8964): Extend `Naming/VariableNumber` cop to handle method names and symbols. ([@fatkodima][])

## 1.1.0 (2020-10-29)

### New features

* [#8896](https://github.com/rubocop/rubocop/pull/8896): Add new `Lint/DuplicateRegexpCharacterClassElement` cop. ([@owst][])
* [#8895](https://github.com/rubocop/rubocop/pull/8895): Add new `Lint/EmptyBlock` cop. ([@fatkodima][])
* [#8934](https://github.com/rubocop/rubocop/pull/8934): Add new `Style/SwapValues` cop. ([@fatkodima][])
* [#7549](https://github.com/rubocop/rubocop/issues/7549): Add new `Style/ArgumentsForwarding` cop. ([@koic][])
* [#8859](https://github.com/rubocop/rubocop/issues/8859): Add new `Lint/UnmodifiedReduceAccumulator` cop. ([@dvandersluis][])
* [#8951](https://github.com/rubocop/rubocop/pull/8951): Support auto-correction for `Style/MultipleComparison`. ([@koic][])
* [#8953](https://github.com/rubocop/rubocop/pull/8953): Add `AllowMethodComparison` option for `Lint/MultipleComparison`. ([@koic][])
* [#8960](https://github.com/rubocop/rubocop/pull/8960): Add `Regexp::Expression#loc` and `#expression` to replace `parsed_tree_expr_loc`. ([@marcandre][])
* [#8930](https://github.com/rubocop/rubocop/pull/8930): Add rake tasks for alternative way to specify Changelog entries. ([@marcandre][])
* [#8940](https://github.com/rubocop/rubocop/pull/8940): Add new `Style/DocumentDynamicEvalDefinition` cop. ([@fatkodima][])
* [#7753](https://github.com/rubocop/rubocop/issues/7753): Add new `Lint/ToEnumArguments` cop. ([@fatkodima][])

### Bug fixes

* [#8921](https://github.com/rubocop/rubocop/pull/8921): Prevent `Lint/LiteralInInterpolation` from removing necessary interpolation in `%W[]` and `%I[]` literals. ([@knu][])
* [#8708](https://github.com/rubocop/rubocop/pull/8708): Fix bad regexp recognition in `Lint/OutOfRangeRegexpRef` when there are multiple regexps. ([@dvandersluis][])
* [#8945](https://github.com/rubocop/rubocop/pull/8945): Fix changelog task to build a correct changelog item when `Fix #123` is encountered. ([@dvandersluis][])
* [#8914](https://github.com/rubocop/rubocop/pull/8914): Fix autocorrection for `Layout/TrailingWhitespace` in heredocs. ([@marcandre][])
* [#8913](https://github.com/rubocop/rubocop/pull/8913): Fix an incorrect auto-correct for `Style/RedundantRegexpCharacterClass` due to quantifier. ([@ysakasin][])
* [#8917](https://github.com/rubocop/rubocop/issues/8917): Fix rubocop comment directives handling of cops with multiple levels in department name. ([@fatkodima][])
* [#8918](https://github.com/rubocop/rubocop/issues/8918): Fix a false positives for `Bundler/DuplicatedGem` when a gem conditionally duplicated within `if-elsif` or `case-when` statements. ([@fatkodima][])
* [#8933](https://github.com/rubocop/rubocop/pull/8933): Fix an error for `Layout/EmptyLinesAroundAccessModifier` when the first line is a comment. ([@matthieugendreau][])
* [#8954](https://github.com/rubocop/rubocop/pull/8954): Fix autocorrection for `Style/RedundantRegexpCharacterClass` with %r. ([@ysakasin][])

### Changes

* [#8920](https://github.com/rubocop/rubocop/pull/8920): Remove Capybara's `save_screenshot` from `Lint/Debugger`. ([@ybiquitous][])
* [#8919](https://github.com/rubocop/rubocop/issues/8919): Require RuboCop AST 1.0.1 or higher. ([@koic][])
* [#8939](https://github.com/rubocop/rubocop/pull/8939): Accept comparisons of multiple method calls for `Style/MultipleComparison`. ([@koic][])
* [#8950](https://github.com/rubocop/rubocop/issues/8950): Add `IgnoredMethods` and `IgnoredClasses` to `Lint/NumberConversion`. ([@dvandersluis][])

## 1.0.0 (2020-10-21)

### New features

* [#7944](https://github.com/rubocop/rubocop/issues/7944): Add `MaxUnannotatedPlaceholdersAllowed` option to `Style/FormatStringToken` cop. ([@Tietew][])
* [#8379](https://github.com/rubocop/rubocop/issues/8379): Handle redundant parentheses around an interpolated expression for `Style/RedundantParentheses` cop. ([@fatkodima][])

### Bug fixes

* [#8892](https://github.com/rubocop/rubocop/issues/8892): Fix an error for `Style/StringConcatenation` when correcting nested concatenatable parts. ([@fatkodima][])
* [#8781](https://github.com/rubocop/rubocop/issues/8781): Fix handling of comments in `Style/SafeNavigation` autocorrection. ([@dvandersluis][])
* [#8907](https://github.com/rubocop/rubocop/pull/8907): Fix an incorrect auto-correct for `Layout/ClassStructure` when heredoc constant is defined after public method. ([@koic][])
* [#8889](https://github.com/rubocop/rubocop/pull/8889): Cops can use new `after_<type>` callbacks (only for nodes that may have children nodes, like `:send` and unlike `:sym`). ([@marcandre][])
* [#8906](https://github.com/rubocop/rubocop/pull/8906): Fix a false positive for `Layout/SpaceAroundOperators` when upward alignment. ([@koic][])
* [#8585](https://github.com/rubocop/rubocop/pull/8585): Fix false positive in `Style/RedundantSelf` cop with nested `self` access. ([@marcotc][])
* [#8692](https://github.com/rubocop/rubocop/pull/8692): Fix `Layout/TrailingWhitespace` auto-correction in heredoc. ([@marcandre][])

### Changes

* [#8882](https://github.com/rubocop/rubocop/pull/8882): **(Potentially breaking)** RuboCop assumes that Cop classes do not define new `on_<type>` methods at runtime (e.g. via `extend` in `initialize`). ([@marcandre][])
* [#7966](https://github.com/rubocop/rubocop/issues/7966): **(Breaking)** Enable all pending cops for RuboCop 1.0. ([@koic][])
* [#8490](https://github.com/rubocop/rubocop/pull/8490): **(Breaking)** Change logic for cop department name computation. Cops inside deep namespaces (5 or more levels deep) now belong to departments with names that are calculated by joining module names starting from the third one with slashes as separators. For example, cop `RuboCop::Cop::Foo::Bar::Baz` now belongs to `Foo/Bar` department (previously it was `Bar`). ([@dsavochkin][])
* [#8692](https://github.com/rubocop/rubocop/pull/8692): Default changed to disallow `Layout/TrailingWhitespace` in heredoc. ([@marcandre][])
* [#8894](https://github.com/rubocop/rubocop/issues/8894): Make `Security/Open` aware of `URI.open`. ([@koic][])
* [#8901](https://github.com/rubocop/rubocop/issues/8901): Fix false positive for `Naming/BinaryOperatorParameterName` when defining `=~`. ([@zajn][])
* [#8908](https://github.com/rubocop/rubocop/pull/8908): Show extension cop versions when using `--verbose-version` option. ([@koic][])

## [v0 CHANGELOG](https://github.com/rubocop/rubocop/blob/master/relnotes/CHANGELOG_v0.md)

[@bbatsov]: https://github.com/bbatsov
[@jonas054]: https://github.com/jonas054
[@yujinakayama]: https://github.com/yujinakayama
[@dblock]: https://github.com/dblock
[@nevir]: https://github.com/nevir
[@daviddavis]: https://github.com/daviddavis
[@sds]: https://github.com/sds
[@fancyremarker]: https://github.com/fancyremarker
[@sinisterchipmunk]: https://github.com/sinisterchipmunk
[@vonTronje]: https://github.com/vonTronje
[@agrimm]: https://github.com/agrimm
[@pmenglund]: https://github.com/pmenglund
[@chulkilee]: https://github.com/chulkilee
[@codez]: https://github.com/codez
[@cyberdelia]: https://github.com/cyberdelia
[@emou]: https://github.com/emou
[@skanev]: https://github.com/skanev
[@claco]: https://github.com/claco
[@rifraf]: https://github.com/rifraf
[@scottmatthewman]: https://github.com/scottmatthewman
[@ma2gedev]: https://github.com/ma2gedev
[@jeremyolliver]: https://github.com/jeremyolliver
[@hannestyden]: https://github.com/hannestyden
[@geniou]: https://github.com/geniou
[@jkogara]: https://github.com/jkogara
[@tmorris-fiksu]: https://github.com/tmorris-fiksu
[@mockdeep]: https://github.com/mockdeep
[@hiroponz]: https://github.com/hiroponz
[@tamird]: https://github.com/tamird
[@fshowalter]: https://github.com/fshowalter
[@cschramm]: https://github.com/cschramm
[@bquorning]: https://github.com/bquorning
[@bcobb]: https://github.com/bcobb
[@irrationalfab]: https://github.com/irrationalfab
[@tommeier]: https://github.com/tommeier
[@sfeldon]: https://github.com/sfeldon
[@biinari]: https://github.com/biinari
[@barunio]: https://github.com/barunio
[@molawson]: https://github.com/molawson
[@wndhydrnt]: https://github.com/wndhydrnt
[@ggilder]: https://github.com/ggilder
[@salbertson]: https://github.com/salbertson
[@camilleldn]: https://github.com/camilleldn
[@mcls]: https://github.com/mcls
[@yous]: https://github.com/yous
[@vrthra]: https://github.com/vrthra
[@SkuliOskarsson]: https://github.com/SkuliOskarsson
[@jspanjers]: https://github.com/jspanjers
[@sch1zo]: https://github.com/sch1zo
[@smangelsdorf]: https://github.com/smangelsdorf
[@mvz]: https://github.com/mvz
[@jfelchner]: https://github.com/jfelchner
[@janraasch]: https://github.com/janraasch
[@jcarbo]: https://github.com/jcarbo
[@oneamtu]: https://github.com/oneamtu
[@toy]: https://github.com/toy
[@Koronen]: https://github.com/Koronen
[@blainesch]: https://github.com/blainesch
[@marxarelli]: https://github.com/marxarelli
[@katieschilling]: https://github.com/katieschilling
[@kakutani]: https://github.com/kakutani
[@rrosenblum]: https://github.com/rrosenblum
[@mattjmcnaughton]: https://github.com/mattjmcnaughton
[@huerlisi]: https://github.com/huerlisi
[@volkert]: https://github.com/volkert
[@lumeet]: https://github.com/lumeet
[@mmozuras]: https://github.com/mmozuras
[@d4rk5eed]: https://github.com/d4rk5eed
[@cshaffer]: https://github.com/cshaffer
[@eitoball]: https://github.com/eitoball
[@iainbeeston]: https://github.com/iainbeeston
[@pimterry]: https://github.com/pimterry
[@palkan]: https://github.com/palkan
[@jdoconnor]: https://github.com/jdoconnor
[@meganemura]: https://github.com/meganemura
[@zvkemp]: https://github.com/zvkemp
[@vassilevsky]: https://github.com/vassilevsky
[@gerry3]: https://github.com/gerry3
[@ypresto]: https://github.com/ypresto
[@clowder]: https://github.com/clowder
[@mudge]: https://github.com/mudge
[@mzp]: https://github.com/mzp
[@bankair]: https://github.com/bankair
[@crimsonknave]: https://github.com/crimsonknave
[@renuo]: https://github.com/renuo
[@sdeframond]: https://github.com/sdeframond
[@til]: https://github.com/til
[@carhartl]: https://github.com/carhartl
[@dylandavidson]: https://github.com/dylandavidson
[@tmr08c]: https://github.com/tmr08c
[@hbd225]: https://github.com/hbd225
[@l8nite]: https://github.com/l8nite
[@sumeet]: https://github.com/sumeet
[@ojab]: https://github.com/ojab
[@chastell]: https://github.com/chastell
[@glasnt]: https://github.com/glasnt
[@crazydog115]: https://github.com/crazydog115
[@RGBD]: https://github.com/RGBD
[@panthomakos]: https://github.com/panthomakos
[@matugm]: https://github.com/matugm
[@m1foley]: https://github.com/m1foley
[@tejasbubane]: https://github.com/tejasbubane
[@bmorrall]: https://github.com/bmorrall
[@fphilipe]: https://github.com/fphilipe
[@gotrevor]: https://github.com/gotrevor
[@awwaiid]: https://github.com/awwaiid
[@segiddins]: https://github.com/segiddins
[@urbanautomaton]: https://github.com/urbanautomaton.com
[@unmanbearpig]: https://github.com/unmanbearpig
[@maxjacobson]: https://github.com/maxjacobson
[@sliuu]: https://github.com/sliuu
[@edmz]: https://github.com/edmz
[@syndbg]: https://github.com/syndbg
[@wli]: https://github.com/wli
[@caseywebdev]: https://github.com/caseywebdev
[@MGerrior]: https://github.com/MGerrior
[@imtayadeway]: https://github.com/imtayadeway
[@mrfoto]: https://github.com/mrfoto
[@karreiro]: https://github.com/karreiro
[@dreyks]: https://github.com/dreyks
[@hmadison]: https://github.com/hmadison
[@miquella]: https://github.com/miquella
[@jhansche]: https://github.com/jhansche
[@cornelius]: https://github.com/cornelius
[@eagletmt]: https://github.com/eagletmt
[@apiology]: https://github.com/apiology
[@alexdowad]: https://github.com/alexdowad
[@minustehbare]: https://github.com/minustehbare
[@tansaku]: https://github.com/tansaku
[@ptrippett]: https://github.com/ptrippett
[@br3nda]: https://github.com/br3nda
[@jujugrrr]: https://github.com/jujugrrr
[@sometimesfood]: https://github.com/sometimesfood
[@cgriego]: https://github.com/cgriego
[@savef]: https://github.com/savef
[@volmer]: https://github.com/volmer
[@domcleal]: https://github.com/domcleal
[@codebeige]: https://github.com/codebeige
[@weh]: https://github.com/weh
[@bfontaine]: https://github.com/bfontaine
[@jawshooah]: https://github.com/jawshooah
[@DNNX]: https://github.com/DNNX
[@mvidner]: https://github.com/mvidner
[@mattparlane]: https://github.com/mattparlane
[@drenmi]: https://github.com/drenmi
[@georgyangelov]: https://github.com/georgyangelov
[@owst]: https://github.com/owst
[@seikichi]: https://github.com/seikichi
[@madwort]: https://github.com/madwort
[@annih]: https://github.com/annih
[@mmcguinn]: https://github.com/mmcguinn
[@pocke]: https://github.com/pocke
[@prsimp]: https://github.com/prsimp
[@ptarjan]: https://github.com/ptarjan
[@jweir]: https://github.com/jweir
[@Fryguy]: https://github.com/Fryguy
[@mikegee]: https://github.com/mikegee
[@tbrisker]: https://github.com/tbrisker
[@necojackarc]: https://github.com/necojackarc
[@laurelfan]: https://github.com/laurelfan
[@amuino]: https://github.com/amuino
[@dylanahsmith]: https://github.com/dylanahsmith
[@gerrywastaken]: https://github.com/gerrywastaken
[@bolshakov]: https://github.com/bolshakov
[@jastkand]: https://github.com/jastkand
[@graemeboy]: https://github.com/graemeboy
[@akihiro17]: https://github.com/akihiro17
[@magni-]: https://github.com/magni-
[@NobodysNightmare]: https://github.com/NobodysNightmare
[@gylaz]: https://github.com/gylaz
[@tjwp]: https://github.com/tjwp
[@neodelf]: https://github.com/neodelf
[@josh]: https://github.com/josh
[@natalzia-paperless]: https://github.com/natalzia-paperless
[@jules2689]: https://github.com/jules2689
[@giannileggio]: https://github.com/giannileggio
[@deivid-rodriguez]: https://github.com/deivid-rodriguez
[@pclalv]: https://github.com/pclalv
[@flexoid]: https://github.com/flexoid
[@sgringwe]: https://github.com/sgringwe
[@Tei]: https://github.com/Tei
[@haziqhafizuddin]: https://github.com/haziqhafizuddin
[@dvandersluis]: https://github.com/dvandersluis
[@QuinnHarris]: https://github.com/QuinnHarris
[@sooyang]: https://github.com/sooyang
[@metcalf]: https://github.com/metcalf
[@annaswims]: https://github.com/annaswims
[@soutaro]: https://github.com/soutaro
[@nicklamuro]: https://github.com/nicklamuro
[@mikezter]: https://github.com/mikezter
[@joejuzl]: https://github.com/joejuzl
[@hedgesky]: https://github.com/hedgesky
[@tjwallace]: https://github.com/tjwallace
[@scottohara]: https://github.com/scottohara
[@koic]: https://github.com/koic
[@groddeck]: https://github.com/groddeck
[@b-t-g]: https://github.com/b-t-g
[@coorasse]: https://github.com/coorasse
[@tcdowney]: https://github.com/tcdowney
[@logicminds]: https://github.com/logicminds
[@abrom]: https://github.com/abrom
[@thegedge]: https://github.com/thegedge
[@jmks]: https://github.com/jmks/
[@connorjacobsen]: https://github.com/connorjacobsen
[@legendetm]: https://github.com/legendetm
[@bronson]: https://github.com/bronson
[@albus522]: https://github.com/albus522
[@sihu]: https://github.com/sihu
[@kamaradclimber]: https://github.com/kamaradclimber
[@swcraig]: https://github.com/swcraig
[@jessieay]: https://github.com/jessieay
[@tiagocasanovapt]: https://github.com/tiagocasanovapt
[@iGEL]: https://github.com/iGEL
[@tessi]: https://github.com/tessi
[@ivanovaleksey]: https://github.com/ivanovaleksey
[@Ana06]: https://github.com/Ana06
[@aroben]: https://github.com/aroben
[@olliebennett]: https://github.com/olliebennett
[@aesthetikx]: https://github.com/aesthetikx
[@tdeo]: https://github.com/tdeo
[@AlexWayfer]: https://github.com/AlexWayfer
[@amogil]: https://github.com/amogil
[@kevindew]: https://github.com/kevindew
[@lucasuyezu]: https://github.com/lucasuyezu
[@breckenedge]: https://github.com/breckenedge
[@enriikke]: https://github.com/enriikke
[@iguchi1124]: https://github.com/iguchi1124
[@vergenzt]: https://github.com/vergenzt
[@rahulcs]: https://github.com/rahulcs
[@dominh]: https://github.com/dominh
[@sue445]: https://github.com/sue445
[@zverok]: https://github.com/zverok
[@backus]: https://github.com/backus
[@AdrienSldy]: https://github.com/adriensldy
[@pat]: https://github.com/pat
[@sinsoku]: https://github.com/sinsoku
[@nodo]: https://github.com/nodo
[@onk]: https://github.com/onk
[@dabroz]: https://github.com/dabroz
[@buenaventure]: https://github.com/buenaventure
[@dorian]: https://github.com/dorian
[@attilahorvath]: https://github.com/attilahorvath
[@droptheplot]: https://github.com/droptheplot
[@wkurniawan07]: https://github.com/wkurniawan07
[@kddeisz]: https://github.com/kddeisz
[@ota42y]: https://github.com/ota42y
[@smakagon]: https://github.com/smakagon
[@musialik]: https://github.com/musialik
[@twe4ked]: https://github.com/twe4ked
[@maxbeizer]: https://github.com/maxbeizer
[@andriymosin]: https://github.com/andriymosin
[@brandonweiss]: https://github.com/brandonweiss
[@betesh]: https://github.com/betesh
[@dpostorivo]: https://github.com/dpostorivo
[@konto-andrzeja]: https://github.com/konto-andrzeja
[@sadovnik]: https://github.com/sadovnik
[@cjlarose]: https://github.com/cjlarose
[@alpaca-tc]: https://github.com/alpaca-tc
[@ilansh]: https://github.com/ilansh
[@mclark]: https://github.com/mclark
[@klesse413]: https://github.com/klesse413
[@gprado]: https://github.com/gprado
[@yhirano55]: https://github.com/yhirano55
[@hoshinotsuyoshi]: https://github.com/hoshinotsuyoshi
[@timrogers]: https://github.com/timrogers
[@harold-s]: https://github.com/harold-s
[@daniloisr]: https://github.com/daniloisr
[@promisedlandt]: https://github.com/promisedlandt
[@oboxodo]: https://github.com/oboxodo
[@gohdaniel15]: https://github.com/gohdaniel15
[@barthez]: https://github.com/barthez
[@Envek]: https://github.com/Envek
[@petehamilton]: https://github.com/petehamilton
[@donjar]: https://github.com/donjar
[@highb]: https://github.com/highb
[@JoeCohen]: https://github.com/JoeCohen
[@theRealNG]: https://github.com/theRealNG
[@akhramov]: https://github.com/akhramov
[@jekuta]: https://github.com/jekuta
[@fujimura]: https://github.com/fujimura
[@kristjan]: https://github.com/kristjan
[@frodsan]: https://github.com/frodsan
[@erikdstock]: https://github.com/erikdstock
[@GauthamGoli]: https://github.com/GauthamGoli
[@nelsonjr]: https://github.com/nelsonjr
[@jonatas]: https://github.com/jonatas
[@jaredbeck]: https://www.jaredbeck.com
[@michniewicz]: https://github.com/michniewicz
[@bgeuken]: https://github.com/bgeuken
[@mtsmfm]: https://github.com/mtsmfm
[@bdewater]: https://github.com/bdewater
[@garettarrowood]: https://github.com/garettarrowood
[@sambostock]: https://github.com/sambostock
[@asherkach]: https://github.com/asherkach
[@tiagotex]: https://github.com/tiagotex
[@wata727]: https://github.com/wata727
[@marcandre]: https://github.com/marcandre
[@walf443]: https://github.com/walf443
[@reitermarkus]: https://github.com/reitermarkus
[@chrishulton]: https://github.com/chrishulton
[@siegfault]: https://github.com/siegfault
[@melch]: https://github.com/melch
[@nattfodd]: https://github.com/nattfodd
[@flyerhzm]: https://github.com/flyerhzm
[@ybiquitous]: https://github.com/ybiquitous
[@mame]: https://github.com/mame
[@dominicsayers]: https://github.com/dominicsayers
[@albertpaulp]: https://github.com/albertpaulp
[@orgads]: https://github.com/orgads
[@leklund]: https://github.com/leklund
[@untitaker]: https://github.com/untitaker
[@walinga]: https://github.com/walinga
[@georf]: https://github.com/georf
[@Edouard-chin]: https://github.com/Edouard-chin
[@eostrom]: https://github.com/eostrom
[@roberts1000]: https://github.com/roberts1000
[@satyap]: https://github.com/satyap
[@unkmas]: https://github.com/unkmas
[@elebow]: https://github.com/elebow
[@colorbox]: https://github.com/colorbox
[@mmyoji]: https://github.com/mmyoji
[@unused]: https://github.com/unused
[@htwroclau]: https://github.com/htwroclau
[@hamada14]: https://github.com/hamada14
[@anthony-robin]: https://github.com/anthony-robin
[@YukiJikumaru]: https://github.com/YukiJikumaru
[@jlfaber]: https://github.com/jlfaber
[@drewpterry]: https://github.com/drewpterry
[@mcfisch]: https://github.com/mcfisch
[@istateside]: https://github.com/istateside
[@parkerfinch]: https://github.com/parkerfinch
[@joshuapinter]: https://github.com/joshuapinter
[@Darhazer]: https://github.com/Darhazer
[@Wei-LiangChew]: https://github.com/Wei-LiangChew
[@svendittmer]: https://github.com/svendittmer
[@composerinteralia]: https://github.com/composerinteralia
[@PointlessOne]: https://github.com/PointlessOne
[@JacobEvelyn]: https://github.com/JacobEvelyn
[@shanecav84]: https://github.com/shanecav84
[@thomasbrus]: https://github.com/thomasbrus
[@balbesina]: https://github.com/balbesina
[@cupakromer]: https://github.com/cupakromer
[@TikiTDO]: https://github.com/TikiTDO
[@EiNSTeiN-]: https://github.com/EiNSTeiN-
[@nroman-stripe]: https://github.com/nroman-stripe
[@sunny]: https://github.com/sunny
[@tatsuyafw]: https://github.com/tatsuyafw
[@alexander-lazarov]: https://github.com/alexander-lazarov
[@r7kamura]: https://github.com/r7kamura
[@Vasfed]: https://github.com/Vasfed
[@drn]: https://github.com/drn
[@maxh]: https://github.com/maxh
[@kenman345]: https://github.com/kenman345
[@nijikon]: https://github.com/nijikon
[@mikeyhew]: https://github.com/mikeyhew
[@mkenyon]: https://github.com/mkenyon
[@repinel]: https://github.com/repinel
[@gmalette]: https://github.com/gmalette
[@MagedMilad]: https://github.com/MagedMilad
[@robotdana]: https://github.com/robotdana
[@bacchir]: https://github.com/bacchir
[@khiav223577]: https://github.com/khiav223577
[@schneems]: https://github.com/schneems
[@ShockwaveNN]: https://github.com/ShockwaveNN
[@Knack]: https://github.com/Knack
[@akanoi]: https://github.com/akanoi
[@yensaki]: https://github.com/yensaki
[@ryanhageman]: https://github.com/ryanhageman
[@autopp]: https://github.com/autopp
[@lukasz-wojcik]: https://github.com/lukasz-wojcik
[@albaer]: https://github.com/albaer
[@Kevinrob]: https://github.com/Kevinrob
[@andrew-aladev]: https://github.com/andrew-aladev
[@y-yagi]: https://github.com/y-yagi
[@DiscoStarslayer]: https://github.com/DiscoStarslayer
[@davearonson]: https://github.com/davearonson
[@timon]: https://github.com/timon
[@gsamokovarov]: https://github.com/gsamokovarov
[@itsWill]: https://github.com/itsWill
[@xlts]: https://github.com/xlts
[@takaram]: https://github.com/takaram
[@gmcgibbon]: https://github.com/gmcgibbon
[@dduugg]: https://github.com/dduugg
[@mmedal]: https://github.com/mmedal
[@timmcanty]: https://github.com/timmcanty
[@tom-lord]: https://github.com/tom-lord
[@bayandin]: https://github.com/bayandin
[@rspeicher]: https://github.com/rspeicher
[@nadiyaka]: https://github.com/nadiyaka
[@allcentury]: https://github.com/allcentury
[@antonzaytsev]: https://github.com/antonzaytsev
[@amatsuda]: https://github.com/amatsuda
[@Intrepidd]: https://github.com/Intrepidd
[@Ruffeng]: https://github.com/Ruffeng
[@roooodcastro]: https://github.com/roooodcastro
[@rmm5t]: https://github.com/rmm5t
[@marcotc]: https://github.com/marcotc
[@dazuma]: https://github.com/dazuma
[@dischorde]: https://github.com/dischorde
[@mhelmetag]: https://github.com/mhelmetag
[@Bhacaz]: https://github.com/bhacaz
[@enkessler]: https://github.com/enkessler
[@dcluna]: https://github.com/dcluna
[@tagliala]: https://github.com/tagliala
[@unasuke]: https://github.com/unasuke
[@elmasantos]: https://github.com/elmasantos
[@luciamo]: https://github.com/luciamo
[@dirtyharrycallahan]: https://github.com/dirtyharrycallahan
[@ericsullivan]: https://github.com/ericsullivan
[@aeroastro]: https://github.com/aeroastro
[@anuja-joshi]: https://github.com/anuja-joshi
[@XrXr]: https://github.com/XrXr
[@thomthom]: https://github.com/thomthom
[@Blue-Pix]: https://github.com/Blue-Pix
[@diachini]: https://github.com/diachini
[@Mange]: https://github.com/Mange
[@jmanian]: https://github.com/jmanian
[@vfonic]: https://github.com/vfonic
[@andreaseger]: https://github.com/andreaseger
[@yakout]: https://github.com/yakout
[@RicardoTrindade]: https://github.com/RicardoTrindade
[@att14]: https://github.com/att14
[@houli]: https://github.com/houli
[@lavoiesl]: https://github.com/lavoiesl
[@fwininger]: https://github.com/fwininger
[@stoivo]: https://github.com/stoivo
[@eugeneius]: https://github.com/eugeneius
[@malyshkosergey]: https://github.com/malyshkosergey
[@fwitzke]: https://github.com/fwitzke
[@okuramasafumi]: https://github.com/okuramasafumi
[@buehmann]: https://github.com/buehmann
[@halfwhole]: https://github.com/halfwhole
[@riley-klingler]: https://github.com/riley-klingler
[@prathamesh-sonpatki]: https://github.com/prathamesh-sonpatki
[@raymondfallon]: https://github.com/raymondfallon
[@crojasaragonez]: https://github.com/crojasaragonez
[@desheikh]: https://github.com/desheikh
[@laurenball]: https://github.com/laurenball
[@jfhinchcliffe]: https://github.com/jfhinchcliffe
[@jdkaplan]: https://github.com/jdkaplan
[@cstyles]: https://github.com/cstyles
[@avmnu-sng]: https://github.com/avmnu-sng
[@denys281]: https://github.com/denys281
[@tyler-ball]: https://github.com/tyler-ball
[@ayacai115]: https://github.com/ayacai115
[@ozydingo]: https://github.com/ozydingo
[@movermeyer]: https://github.com/movermeyer
[@jethroo]: https://github.com/jethroo
[@mangara]: https://github.com/mangara
[@pirj]: https://github.com/pirj
[@pawptart]: https://github.com/pawptart
[@cetinajero]: https://github.com/cetinajero
[@gfyoung]: https://github.com/gfyoung
[@Tietew]: https://github.com/Tietew
[@hanachin]: https://github.com/hanachin
[@masarakki]: https://github.com/masarakki
[@djudd]: https://github.com/djudd
[@jemmaissroff]: https://github.com/jemmaissroff
[@nikitasakov]: https://github.com/nikitasakov
[@dmolesUC]: https://github.com/dmolesUC
[@yuritomanek]: https://github.com/yuritomanek
[@egze]: https://github.com/egze
[@rafaelfranca]: https://github.com/rafaelfranca
[@knu]: https://github.com/knu
[@saurabhmaurya15]: https://github.com/saurabhmaurya15
[@DracoAter]: https://github.com/DracoAter
[@diogoosorio]: https://github.com/diogoosorio
[@jeffcarbs]: https://github.com/jeffcarbs
[@jcfausto]: https://github.com/jcfausto
[@laurmurclar]: https://github.com/laurmurclar
[@jethrodaniel]: https://github.com/jethrodaniel
[@CvX]: https://github.com/CvX
[@jschneid]: https://github.com/jschneid
[@ric2b]: https://github.com/ric2b
[@burnettk]: https://github.com/burnettk
[@andrykonchin]: https://github.com/andrykonchin
[@avrusanov]: https://github.com/avrusanov
[@mauro-oto]: https://github.com/mauro-oto
[@fatkodima]: https://github.com/fatkodima
[@karlwithak]: https://github.com/karlwithak
[@CamilleDrapier]: https://github.com/CamilleDrapier
[@shekhar-patil]: https://github.com/shekhar-patil
[@knejad]: https://github.com/knejad
[@iamravitejag]: https://github.com/iamravitejag
[@volfgox]: https://github.com/volfgox
[@colszowka]: https://github.com/colszowka
[@dsavochkin]: https://github.com/dmytro-savochkin
[@sonalinavlakhe]: https://github.com/sonalinavlakhe
[@wcmonty]: https://github.com/wcmonty
[@nguyenquangminh0711]: https://github.com/nguyenquangminh0711
[@chocolateboy]: https://github.com/chocolateboy
[@Lykos]: https://github.com/Lykos
[@jaimerave]: https://github.com/jaimerave
[@Skipants]: https://github.com/Skipants
[@sascha-wolf]: https://github.com/sascha-wolf
[@fsateler]: https://github.com/fsateler
[@iSarCasm]: https://github.com/iSarCasm
[@em-gazelle]: https://github.com/em-gazelle
[@tleish]: https://github.com/tleish
[@pbernays]: https://github.com/pbernays
[@rdunlop]: https://github.com/rdunlop
[@ghiculescu]: https://github.com/ghiculescu
[@hatkyinc2]: https://github.com/hatkyinc2
[@AllanSiqueira]: https://github.com/allansiqueira
[@zajn]: https://github.com/zajn
[@ysakasin]: https://github.com/ysakasin
[@matthieugendreau]: https://github.com/matthieugendreau
[@miry]: https://github.com/miry
[@lautis]: https://github.com/lautis
[@pdobb]: https://github.com/pdobb
[@HeroProtagonist]: https://github.com/HeroProtagonist
[@piotrmurach]: https://github.com/piotrmurach
[@javierav]: https://github.com/javierav
[@adrian-rivera]: https://github.com/adrian-rivera
[@ThomasKoppensteiner]: https://github.com/ThomasKoppensteiner
[@PhilCoggins]: https://github.com/PhilCoggins
[@tas50]: https://github.com/tas50
[@dark-panda]: https://github.com/dark-panda
[@sswander]: https://github.com/sswander
[@makicamel]: https://github.com/makicamel
[@h-lame]: https://github.com/h-lame
[@agargiulo]: https://github.com/agargiulo
[@muirdm]: https://github.com/muirdm
[@noon-ng]: https://github.com/noon-ng
[@ohbarye]: https://github.com/ohbarye
[@magneland]: https://github.com/magneland
[@k-karen]: https://github.com/k-karen
[@uplus]: https://github.com/uplus
[@asterite]: https://github.com/asterite
[@AndreiEres]: https://github.com/AndreiEres
[@jdufresne]: https://github.com/jdufresne
[@adithyabsk]: https://github.com/adithyabsk
[@cteece]: https://github.com/ceteece
[@taichi-ishitani]: https://github.com/taichi-ishitani
[@cteece]: https://github.com/cteece
[@TSMMark]: https://github.com/TSMMark
[@caalberts]: https://github.com/caalberts
[@kachick]: https://github.com/kachick
[@corroded]: https://github.com/corroded
[@osyo-manga]: https://github.com/osyo-manga
[@ob-stripe]: https://github.com/ob-stripe
[@kwerle]: https://github.com/kwerle
[@RobinDaugherty]: https://github.com/RobinDaugherty
[@etiennebarrie]: https://github.com/etiennebarrie
[@Tonkpils]: https://github.com/Tonkpils
[@timlkelly]: https://github.com/timlkelly
[@AirWick219]: https://github.com/AirWick219
[@markburns]: https://github.com/markburns
[@gregfletch]: https://github.com/gregfletch
[@thearjunmdas]: https://github.com/thearjunmdas
[@DanielVartanov]: https://github.com/DanielVartanov
[@splattael]: https://github.com/splattael
[@byroot]: https://github.com/byroot
[@itay-grudev]: https://github.com/itay-grudev
[@lilisako]: https://github.com/lilisako
[@Hugo-Hache]: https://github.com/Hugo-Hache
[@franzliedke]: https://github.com/franzliedke
[@Drowze]: https://github.com/Drowze
[@hirasawayuki]: https://github.com/hirasawayuki
[@grosser]: https://github.com/grosser
[@mttkay]: https://github.com/mttkay
[@leoarnold]: https://github.com/leoarnold
[@danieldiekmeier]: https://github.com/danieldiekmeier
[@joergschiller]: https://github.com/joergschiller
[@berkos]: https://github.com/berkos
[@nickpellant]: https://github.com/nickpellant
[@friendlyantz]: https://github.com/friendlyantz
[@issyl0]: https://github.com/issyl0
[@ydah]: https://github.com/ydah
[@chrisseaton]: https://github.com/chrisseaton
[@nobuyo]: https://github.com/nobuyo
[@johnny-miyake]: https://github.com/johnny-miyake
[@joe-sharp]: https://github.com/joe-sharp
[@henrahmagix]: https://github.com/henrahmagix
[@chris-hewitt]: https://github.com/chris-hewitt
[@rickselby]: https://github.com/rickselby
[@zachahn]: https://github.com/zachahn
[@kaitielth]: https://github.com/kaitielth
[@j-miyake]: https://github.com/j-miyake
[@FnControlOption]: https://github.com/FnControlOption
[@ccutrer]: https://github.com/ccutrer
[@Korri]: https://github.com/Korri
[@ChrisBr]: https://github.com/ChrisBr
[@mollerhoj]: https://github.com/mollerhoj
[@mattbearman]: https://github.com/mattbearman
[@wjwh]: https://github.com/wjwh
[@jcalvert]: https://github.com/jcalvert
[@tsugimoto]: https://github.com/tsugimoto
[@srcoley]: https://github.com/srcoley
[@rdeckard]: https://github.com/rdeckard
[@wildmaples]: https://github.com/wildmaples
[@hosamaly]: https://github.com/hosamaly
[@si-lens]: https://github.com/si-lens
[@akihikodaki]: https://github.com/akihikodaki
[@epaew]: https://github.com/epaew
[@isarcasm]: https://github.com/isarcasm
[@noelblaschke]: https://github.com/noelblaschke
[@KirIgor]: https://github.com/KirIgor
[@tjschuck]: https://github.com/tjschuck
[@dukaev]: https://github.com/dukaev
[@arika]: https://github.com/arika
[@soroktree]: https://github.com/soroktree
[@alexevanczuk]: https://github.com/alexevanczuk
[@such]: https://github.com/such
[@krishanbhasin-shopify]: https://github.com/krishanbhasin-shopify
[@f1sherman]: https://github.com/f1sherman
[@jaynetics]: https://github.com/jaynetics
[@SparLaimor]: https://github.com/SparLaimor
[@bfad]: https://github.com/bfad
[@istvanfazakas]: https://github.com/istvanfazakas
[@KessaPassa]: https://github.com/KessaPassa
[@jasondoc3]: https://github.com/jasondoc3
[@ThHareau]: https://github.com/ThHareau
[@ktopolski]: https://github.com/ktopolski
[@Bhacaz]: https://github.com/Bhacaz
[@naveg]: https://github.com/naveg
[@lucthev]: https://github.com/lucthev
[@nevans]: https://github.com/nevans
[@iMacTia]: https://github.com/iMacTia
[@rwstauner]: https://github.com/rwstauner
[@catwomey]: https://github.com/catwomey
[@alexeyschepin]: https://github.com/alexeyschepin
[@meric426]: https://github.com/meric426
[@loveo]: https://github.com/loveo
[@p0deje]: https://github.com/p0deje
[@bigzed]: https://github.com/bigzed
[@OwlKing]: https://github.com/OwlKing
[@ItsEcholot]: https://github.com/ItsEcholot
[@ymap]: https://github.com/ymap
[@aboutNisblee]: https://github.com/aboutNisblee
[@K-S-A]: https://github.com/K-S-A
[@earlopain]: https://github.com/earlopain
[@kpost]: https://github.com/kpost
[@marocchino]: https://github.com/marocchino
[@Strzesia]: https://github.com/Strzesia
[@maruth-stripe]: https://github.com/maruth-stripe
[@jenshenny]: https://github.com/jenshenny
[@davidrunger]: https://github.com/davidrunger
[@viralpraxis]: https://github.com/viralpraxis
[@artur-intech]: https://github.com/artur-intech
[@amomchilov]: https://github.com/amomchilov
[@Hiroto-Iizuka]: https://github.com/Hiroto-Iizuka
[@boardfish]: https://github.com/boardfish
[@muxcmux]: https://github.com/muxcmux
[@nekketsuuu]: https://github.com/nekketsuuu
[@pawelma]: https://github.com/pawelma
[@krororo]: https://github.com/krororo
[@ksss]: https://github.com/ksss
[@vlad-pisanov]: https://github.com/vlad-pisanov
[@protocol7]: https://github.com/protocol7
[@zopolis4]: https://github.com/zopolis4
[@tk0miya]: https://github.com/tk0miya
[@masato-bkn]: https://github.com/masato-bkn
[@pCosta99]: https://github.com/pCosta99
[@kotaro0522]: https://github.com/kotaro0522
[@gemmaro]: https://github.com/gemmaro
[@dak2]: https://github.com/dak2
[@d4be4st]: https://github.com/d4be4st
[@lovro-bikic]: https://github.com/lovro-bikic
[@aduth]: https://github.com/aduth
[@isuckatcs]: https://github.com/isuckatcs
[@GabeIsman]: https://github.com/GabeIsman
[@mrzasa]: https://github.com/mrzasa
[@corsonknowles]: https://github.com/corsonknowles
[@elliottt]: https://github.com/elliottt
[@kyanagi]: https://github.com/kyanagi
[@capncavedan]: https://github.com/capncavedan
[@d4rky-pl]: https://github.com/d4rky-pl
[@vinistock]: https://github.com/vinistock
[@datpmt]: https://github.com/datpmt
[@jtannas]: https://github.com/jtannas
[@flavorjones]: https://github.com/flavorjones
[@sferik]: https://github.com/sferik
[@Morriar]: https://github.com/Morriar
[@daisuke]: https://github.com/daisuke
[@steiley]: https://github.com/steiley
[@ka8725]: https://github.com/ka8725
[@ssagara00]: https://github.com/ssagara00
[@niranjan-patil]: https://github.com/niranjan-patil
[@Yuhi-Sato]: https://github.com/Yuhi-Sato
[@5hun-s]: https://github.com/5hun-s
[@girasquid]: https://github.com/girasquid
[@hakanensari]: https://github.com/hakanensari
[@jvlara]: https://github.com/jvlara
[@tmtm]: https://github.com/tmtm
[@martinemde]: https://github.com/martinemde
[@sudoremo]: https://github.com/sudoremo
[@akouryy]: https://github.com/akouryy
[@Jack12816]: https://github.com/Jack12816
[@rscq]: https://github.com/rscq
[@mmenanno]: https://github.com/mmenanno
