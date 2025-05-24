# Change log

<!---
  Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.

  Please add an entry file to the https://github.com/rubocop/rubocop/blob/master/changelog/
  named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.

  See https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
-->

See current entries: https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md

## 0.93.1 (2020-10-12)

### Bug fixes

* [#8782](https://github.com/rubocop/rubocop/issues/8782): Fix incorrect autocorrection for `Style/TernaryParentheses` with `defined?`. ([@dvandersluis][])
* [#8867](https://github.com/rubocop/rubocop/issues/8867): Rework `Lint/RedundantSafeNavigation` to be more safe. ([@fatkodima][])
* [#8864](https://github.com/rubocop/rubocop/issues/8864): Fix false positive for `Style/RedundantBegin` with a postfix `while` or `until`. ([@dvandersluis][])
* [#8869](https://github.com/rubocop/rubocop/issues/8869): Fix a false positive for `Style/RedundantBegin` when using `begin` for or assignment and method call. ([@koic][])
* [#8862](https://github.com/rubocop/rubocop/issues/8862): Fix an error for `Lint/AmbiguousRegexpLiteral` when using regexp without method calls in nested structure. ([@koic][])
* [#8872](https://github.com/rubocop/rubocop/issues/8872): Fix an error for `Metrics/ClassLength` when multiple assignments to constants. ([@koic][])
* [#8871](https://github.com/rubocop/rubocop/issues/8871): Fix a false positive for `Style/RedundantBegin` when using `begin` for method argument or part of conditions. ([@koic][])
* [#8875](https://github.com/rubocop/rubocop/issues/8875): Fix an incorrect auto-correct for `Style/ClassEqualityComparison` when comparing class name. ([@koic][])
* [#8880](https://github.com/rubocop/rubocop/issues/8880): Fix an error for `Style/ClassLength` when overlapping constant assignments. ([@koic][])

## 0.93.0 (2020-10-08)

### New features

* [#8796](https://github.com/rubocop/rubocop/pull/8796): Add new `Lint/HashCompareByIdentity` cop. ([@fatkodima][])
* [#8833](https://github.com/rubocop/rubocop/pull/8833): Add new `Style/ClassEqualityComparison` cop. ([@fatkodima][])
* [#8668](https://github.com/rubocop/rubocop/pull/8668): Add new `Lint/RedundantSafeNavigation` cop. ([@fatkodima][])
* [#8842](https://github.com/rubocop/rubocop/issues/8842): Add notification about cache being used to debug mode. ([@hatkyinc2][])
* [#8822](https://github.com/rubocop/rubocop/pull/8822): Make `Style/RedundantBegin` aware of `begin` without `rescue` or `ensure`. ([@koic][])
* [#7940](https://github.com/rubocop/rubocop/pull/7940): Add new `Lint/NoReturnInBeginEndBlocks` cop. ([@jcfausto][])

### Bug fixes

* [#8810](https://github.com/rubocop/rubocop/pull/8810): Fix multiple offense detection for `Style/RaiseArgs`. ([@pbernays][])
* [#8151](https://github.com/rubocop/rubocop/issues/8151): Fix a false positive for `Lint/BooleanSymbol` when used within `%i[...]`. ([@fatkodima][])
* [#8809](https://github.com/rubocop/rubocop/pull/8809): Fix multiple offense detection for `Style/For`. ([@pbernays][])
* [#8801](https://github.com/rubocop/rubocop/issues/8801): Fix `Layout/SpaceAroundEqualsInParameterDefault` only registered once in a line. ([@rdunlop][])
* [#8514](https://github.com/rubocop/rubocop/issues/8514): Correct multiple `Style/MethodDefParentheses` per file. ([@rdunlop][])
* [#8825](https://github.com/rubocop/rubocop/issues/8825): Fix crash in `Style/ExplicitBlockArgument` when code is called outside of a method. ([@ghiculescu][])
* [#8718](https://github.com/rubocop/rubocop/issues/8718): Fix undefined methods of pseudo location. ([@ybiquitous][])
* [#8354](https://github.com/rubocop/rubocop/issues/8354): Detect regexp named captures in `Style/CaseLikeIf` cop. ([@dsavochkin][])
* [#8821](https://github.com/rubocop/rubocop/issues/8821): Fix an incorrect autocorrect for `Style/NestedTernaryOperator` when using a nested ternary operator expression with no parentheses on the outside. ([@koic][])
* [#8834](https://github.com/rubocop/rubocop/issues/8834): Fix a false positive for `Style/ParenthesesAsGroupedExpression` when method argument parentheses are omitted and hash argument key is enclosed in parentheses. ([@koic][])
* [#8830](https://github.com/rubocop/rubocop/issues/8830): Fix bad autocorrect of `Style/StringConcatenation` when string includes double quotes. ([@tleish][])
* [#8807](https://github.com/rubocop/rubocop/pull/8807): Fix a false positive for `Style/RedundantCondition` when using assignment by hash key access. ([@koic][])
* [#8848](https://github.com/rubocop/rubocop/issues/8848): Fix a false positive for `Style/CombinableLoops` when using the same method with different arguments. ([@dvandersluis][])
* [#8843](https://github.com/rubocop/rubocop/issues/8843): Fix an incorrect autocorrect for `Lint/AmbiguousRegexpLiteral` when sending method to regexp literal receiver. ([@koic][])
* [#8842](https://github.com/rubocop/rubocop/issues/8842): Save actual status to cache, except corrected. ([@hatkyinc2][])
* [#8835](https://github.com/rubocop/rubocop/issues/8835): Fix an incorrect autocorrect for `Style/RedundantInterpolation` when using string interpolation for non-operator methods. ([@koic][])
* [#7495](https://github.com/rubocop/rubocop/issues/7495): Example for `Lint/AmbiguousBlockAssociation` cop. ([@AllanSiqueira][])
* [#8855](https://github.com/rubocop/rubocop/issues/8855): Fix an error for `Layout/EmptyLinesAroundAccessModifier` and `Style/AccessModifierDeclarations` when using only access modifier. ([@koic][])

### Changes

* [#8803](https://github.com/rubocop/rubocop/pull/8803): **(Breaking)** `RegexpNode#parsed_tree` now processes regexps including interpolation (by blanking the interpolation before parsing, rather than skipping). ([@owst][])
* [#8625](https://github.com/rubocop/rubocop/pull/8625): Improve `Style/RedundantRegexpCharacterClass` and `Style/RedundantRegexpEscape` by using `regexp_parser` gem. ([@owst][])
* [#8646](https://github.com/rubocop/rubocop/issues/8646): Faster find of all files in `TargetFinder` class which improves initial startup speed. ([@tleish][])
* [#8102](https://github.com/rubocop/rubocop/issues/8102): Consider class length instead of block length for `Struct.new`. ([@tejasbubane][])
* [#7408](https://github.com/rubocop/rubocop/issues/7408): Make `Gemspec/RequiredRubyVersion` cop aware of `Gem::Requirement`. ([@tejasbubane][])

## 0.92.0 (2020-09-25)

### New features

* [#8778](https://github.com/rubocop/rubocop/pull/8778): Add command line option `--regenerate-todo`. ([@dvandersluis][])
* [#8790](https://github.com/rubocop/rubocop/pull/8790): Add `AllowedMethods` option to `Style/OptionalBooleanParameter` cop. ([@fatkodima][])
* [#8738](https://github.com/rubocop/rubocop/issues/8738): Add autocorrection to `Style/DateTime`. ([@dvandersluis][])

### Bug fixes

* [#8774](https://github.com/rubocop/rubocop/issues/8774): Fix a false positive for `Layout/ArrayAlignment` with parallel assignment. ([@dvandersluis][])

### Changes

* [#8785](https://github.com/rubocop/rubocop/pull/8785): Update TargetRubyVersion 2.8 to 3.0 (experimental). ([@koic][])
* [#8650](https://github.com/rubocop/rubocop/issues/8650): Faster find of hidden files in `TargetFinder` class which improves rubocop initial startup speed. ([@tleish][])
* [#8783](https://github.com/rubocop/rubocop/pull/8783): Disable `Style/ArrayCoercion` cop by default. ([@koic][])

## 0.91.1 (2020-09-23)

### Bug fixes

* [#8720](https://github.com/rubocop/rubocop/issues/8720): Fix an error for `Lint/IdentityComparison` when calling `object_id` method without receiver in LHS or RHS. ([@koic][])
* [#8767](https://github.com/rubocop/rubocop/issues/8767): Fix a false positive for `Style/RedundantReturn` when a rescue has an else clause. ([@fatkodima][])
* [#8710](https://github.com/rubocop/rubocop/issues/8710): Fix a false positive for `Layout/RescueEnsureAlignment` when `Layout/BeginEndAlignment` cop is not enabled status. ([@koic][])
* [#8726](https://github.com/rubocop/rubocop/issues/8726): Fix a false positive for `Naming/VariableNumber` when naming multibyte character variable name. ([@koic][])
* [#8730](https://github.com/rubocop/rubocop/issues/8730): Fix an error for `Lint/UselessTimes` when there is a blank line in the method definition. ([@koic][])
* [#8740](https://github.com/rubocop/rubocop/issues/8740): Fix a false positive for `Style/HashAsLastArrayItem` when the hash is in an implicit array. ([@dvandersluis][])
* [#8739](https://github.com/rubocop/rubocop/issues/8739): Fix an error for `Lint/UselessTimes` when using empty block argument. ([@koic][])
* [#8742](https://github.com/rubocop/rubocop/issues/8742): Fix some assignment counts for `Metrics/AbcSize`. ([@marcandre][])
* [#8750](https://github.com/rubocop/rubocop/pull/8750): Fix an incorrect auto-correct for `Style/MultilineWhenThen` when line break for multiple candidate values of `when` statement. ([@koic][])
* [#8754](https://github.com/rubocop/rubocop/pull/8754): Fix an error for `Style/RandomWithOffset` when using a range with non-integer bounds. ([@eugeneius][])
* [#8756](https://github.com/rubocop/rubocop/issues/8756): Fix an infinite loop error for `Layout/EmptyLinesAroundAccessModifier` with `Layout/EmptyLinesAroundBlockBody` when using access modifier with block argument. ([@koic][])
* [#8372](https://github.com/rubocop/rubocop/issues/8372): Fix `Lint/RedundantCopEnableDirective` autocorrection to not leave orphaned empty `# rubocop:enable` comments. ([@dvandersluis][])
* [#8372](https://github.com/rubocop/rubocop/issues/8372): Fix `Lint/RedundantCopDisableDirective` autocorrection. ([@dvandersluis][])
* [#8764](https://github.com/rubocop/rubocop/issues/8764): Fix `Layout/CaseIndentation` not showing the cop name in output messages. ([@dvandersluis][])
* [#8771](https://github.com/rubocop/rubocop/issues/8771): Fix an error for `Style/OneLineConditional` when using `if-then-elsif-then-end`. ([@koic][])
* [#8576](https://github.com/rubocop/rubocop/issues/8576): Fix `Style/IfUnlessModifier` to ignore cop disable comment directives when considering conversion to the modifier form. ([@dsavochkin][])

### Changes

* [#8489](https://github.com/rubocop/rubocop/issues/8489): Exclude method `respond_to_missing?` from `OptionalBooleanParameter` cop. ([@em-gazelle][])
* [#7914](https://github.com/rubocop/rubocop/issues/7914): `Style/SafeNavigation` marked as having unsafe auto-correction. ([@marcandre][])
* [#8749](https://github.com/rubocop/rubocop/issues/8749): Disable `Style/IpAddresses` by default in `Gemfile` and gemspec files. ([@dvandersluis][])

## 0.91.0 (2020-09-15)

### New features

* New option `--cache-root` and support for the `RUBOCOP_CACHE_ROOT` environment variable. Both can be used to override the `AllCops: CacheRootDirectory` config, especially in a CI setting. ([@sascha-wolf][])
* [#8582](https://github.com/rubocop/rubocop/issues/8582): Add new `Layout/BeginEndAlignment` cop. ([@koic][])
* [#8699](https://github.com/rubocop/rubocop/pull/8699): Add new `Lint/IdentityComparison` cop. ([@koic][])
* Add new `Lint/UselessTimes` cop. ([@dvandersluis][])
* [#8707](https://github.com/rubocop/rubocop/pull/8707): Add new `Lint/ConstantDefinitionInBlock` cop. ([@eugeneius][])

### Bug fixes

* [#8627](https://github.com/rubocop/rubocop/issues/8627): Fix a false positive for `Lint/DuplicateRequire` when same feature argument but different require method. ([@koic][])
* [#8674](https://github.com/rubocop/rubocop/issues/8674): Fix an error for `Layout/EmptyLineAfterMultilineCondition` when conditional is at the top level. ([@fatkodima][])
* [#8658](https://github.com/rubocop/rubocop/pull/8658): Fix a false positive for `Style/RedundantSelfAssignment` when calling coercion methods. ([@fatkodima][])
* [#8669](https://github.com/rubocop/rubocop/issues/8669): Fix an offense creation for `Lint/EmptyFile`. ([@fatkodima][])
* [#8607](https://github.com/rubocop/rubocop/issues/8607): Fix a false positive for `Lint/UnreachableLoop` when conditional branch includes continue statement preceding break statement. ([@fatkodima][])
* [#8572](https://github.com/rubocop/rubocop/issues/8572): Fix a false positive for `Style/RedundantParentheses` when parentheses are used like method argument parentheses. ([@koic][])
* [#8630](https://github.com/rubocop/rubocop/issues/8630): Fix some false positives for `Style/HashTransformKeys` and `Style/HashTransformValues` when the receiver is an array. ([@eugeneius][])
* [#8653](https://github.com/rubocop/rubocop/pull/8653): Fix a false positive for `Layout/DefEndAlignment` when using refinements and `private def`. ([@koic][])
* [#8655](https://github.com/rubocop/rubocop/pull/8655): Fix a false positive for `Style/ClassAndModuleChildren` when using cbase class name. ([@koic][])
* [#8654](https://github.com/rubocop/rubocop/pull/8654): Fix a false positive for `Style/SafeNavigation` when checking `foo&.empty?` in a conditional. ([@koic][])
* [#8660](https://github.com/rubocop/rubocop/pull/8660): Fix a false positive for `Style/ClassAndModuleChildren` when using cbase module name. ([@koic][])
* [#8664](https://github.com/rubocop/rubocop/issues/8664): Fix a false positive for `Naming/BinaryOperatorParameterName` when naming multibyte character method name. ([@koic][])
* [#8604](https://github.com/rubocop/rubocop/issues/8604): Fix a false positive for `Bundler/DuplicatedGem` when gem is duplicated in condition. ([@tejasbubane][])
* [#8671](https://github.com/rubocop/rubocop/issues/8671): Fix an error for `Style/ExplicitBlockArgument` when using safe navigation method call. ([@koic][])
* [#8681](https://github.com/rubocop/rubocop/pull/8681): Fix an error for `Style/HashAsLastArrayItem` with `no_braces` for empty hash. ([@fsateler][])
* [#8682](https://github.com/rubocop/rubocop/pull/8682): Fix a positive for `Style/HashTransformKeys` and `Style/HashTransformValues` when the `each_with_object` hash is used in the transformed key or value. ([@eugeneius][])
* [#8688](https://github.com/rubocop/rubocop/issues/8688): Mark `Style/GlobalStdStream` as unsafe autocorrection. ([@marcandre][])
* [#8642](https://github.com/rubocop/rubocop/issues/8642): Fix a false negative for `Style/SpaceInsideHashLiteralBraces` when a correct empty hash precedes the incorrect hash. ([@dvandersluis][])
* [#8683](https://github.com/rubocop/rubocop/issues/8683): Make naming cops work with non-ascii characters. ([@tejasbubane][])
* [#8626](https://github.com/rubocop/rubocop/issues/8626): Fix false negatives for `Lint/UselessMethodDefinition`. ([@marcandre][])
* [#8698](https://github.com/rubocop/rubocop/pull/8698): Fix cache to avoid encoding exception. ([@marcandre][])
* [#8704](https://github.com/rubocop/rubocop/issues/8704): Fix an error for `Lint/AmbiguousOperator` when using safe navigation operator with a unary operator. ([@koic][])
* [#8661](https://github.com/rubocop/rubocop/pull/8661): Fix an incorrect auto-correct for `Style/MultilineTernaryOperator` when returning a multiline ternary operator expression. ([@koic][])
* [#8526](https://github.com/rubocop/rubocop/pull/8526): Fix a false positive for `Style/CaseEquality` cop when the receiver is not a camel cased constant. ([@koic][])
* [#8673](https://github.com/rubocop/rubocop/issues/8673): Fix the JSON parse error when specifying `--format=json` and `--stdin` options. ([@koic][])

### Changes

* [#8470](https://github.com/rubocop/rubocop/issues/8470): Do not autocorrect `Style/StringConcatenation` when parts of the expression are too complex. ([@dvandersluis][])
* [#8561](https://github.com/rubocop/rubocop/issues/8561): Fix `Lint/UselessMethodDefinition` to not register an offense when method definition includes optional arguments. ([@fatkodima][])
* [#8617](https://github.com/rubocop/rubocop/issues/8617): Fix `Style/HashAsLastArrayItem` to not register an offense when all items in an array are hashes. ([@dvandersluis][])
* [#8500](https://github.com/rubocop/rubocop/issues/8500): Add `in?` to AllowedMethods for `Lint/SafeNavigationChain` cop. ([@tejasbubane][])
* [#8629](https://github.com/rubocop/rubocop/pull/8629): Fix the cache being reusable in CI by using crc32 to calculate file hashes rather than `mtime`, which changes each CI build. ([@dvandersluis][])
* [#8663](https://github.com/rubocop/rubocop/issues/8663): Fix multiple autocorrection bugs with `Style/ClassMethodsDefinitions`. ([@dvandersluis][])
* [#8621](https://github.com/rubocop/rubocop/issues/8621): Add helpful Infinite Loop error message. ([@iSarCasm][])

## 0.90.0 (2020-09-01)

### New features

* [#8451](https://github.com/rubocop/rubocop/issues/8451): Add new `Style/RedundantSelfAssignment` cop. ([@fatkodima][])
* [#8384](https://github.com/rubocop/rubocop/issues/8384): Add new `Layout/EmptyLineAfterMultilineCondition` cop. ([@fatkodima][])
* [#8390](https://github.com/rubocop/rubocop/pull/8390): Add new `Style/SoleNestedConditional` cop. ([@fatkodima][])
* [#8563](https://github.com/rubocop/rubocop/pull/8563): Add new `Style/KeywordParametersOrder` cop. ([@fatkodima][])
* [#8486](https://github.com/rubocop/rubocop/pull/8486): Add new `Style/CombinableLoops` cop. ([@fatkodima][])
* [#8381](https://github.com/rubocop/rubocop/pull/8381): Add new `Style/ClassMethodsDefinitions` cop. ([@fatkodima][])
* [#8474](https://github.com/rubocop/rubocop/pull/8474): Add new `Lint/DuplicateRequire` cop. ([@fatkodima][])
* [#8472](https://github.com/rubocop/rubocop/issues/8472): Add new `Lint/UselessMethodDefinition` cop. ([@fatkodima][])
* [#8531](https://github.com/rubocop/rubocop/issues/8531): Add new `Lint/EmptyFile` cop. ([@fatkodima][])
* Add new `Lint/TrailingCommaInAttributeDeclaration` cop. ([@drenmi][])
* [#8578](https://github.com/rubocop/rubocop/pull/8578): Add `:restore_registry` context and `stub_cop_class` helper class. ([@marcandre][])
* [#8579](https://github.com/rubocop/rubocop/pull/8579): Add `Cop.documentation_url`. ([@marcandre][])
* [#8510](https://github.com/rubocop/rubocop/pull/8510):  Add `RegexpNode#each_capture` and `parsed_tree`. ([@marcandre][])
* [#8365](https://github.com/rubocop/rubocop/pull/8365): Cops defining `on_send` can be optimized by defining the constant `RESTRICT_ON_SEND` with a list of acceptable method names. ([@marcandre][])

### Bug fixes

* [#8508](https://github.com/rubocop/rubocop/pull/8508): Fix a false positive for `Style/CaseLikeIf` when conditional contains comparison with a class. Mark `Style/CaseLikeIf` as not safe. ([@fatkodima][])
* [#8618](https://github.com/rubocop/rubocop/issues/8618): Fix an infinite loop error for `Layout/EmptyLineBetweenDefs`. ([@fatkodima][])
* [#8534](https://github.com/rubocop/rubocop/issues/8534): Fix `Lint/BinaryOperatorWithIdenticalOperands` for binary operators used as unary operators. ([@marcandre][])
* [#8537](https://github.com/rubocop/rubocop/pull/8537): Allow a trailing comment as a description comment for `Bundler/GemComment`. ([@pocke][])
* [#8507](https://github.com/rubocop/rubocop/issues/8507): Fix `Style/RescueModifier` to handle parentheses around rescue modifiers. ([@dsavochkin][])
* [#8527](https://github.com/rubocop/rubocop/pull/8527): Prevent an incorrect auto-correction for `Style/CaseEquality` cop when comparing with `===` against a regular expression receiver. ([@koic][])
* [#8524](https://github.com/rubocop/rubocop/issues/8524): Fix `Layout/EmptyLinesAroundClassBody`  and `Layout/EmptyLinesAroundModuleBody` to correctly handle an access modifier as a first child. ([@dsavochkin][])
* [#8518](https://github.com/rubocop/rubocop/issues/8518): Fix `Lint/ConstantResolution` cop reporting offense for `module` and `class` definitions. ([@tejasbubane][])
* [#8158](https://github.com/rubocop/rubocop/issues/8158): Fix `Style/MultilineWhenThen` cop to correctly handle cases with multiline body. ([@dsavochkin][])
* [#7705](https://github.com/rubocop/rubocop/issues/7705): Fix `Style/OneLineConditional` cop to handle if/then/elsif/then/else/end cases. Add `AlwaysCorrectToMultiline` config option to this cop to always convert offenses to the multi-line form (false by default). ([@Lykos][], [@dsavochkin][])
* [#8590](https://github.com/rubocop/rubocop/issues/8590): Fix an error when auto-correcting encoding mismatch file. ([@koic][])
* [#8321](https://github.com/rubocop/rubocop/issues/8321): Enable auto-correction for `Layout/{Def}EndAlignment`, `Lint/EmptyEnsure`, `Style/ClassAndModuleChildren`. ([@marcandre][])
* [#8583](https://github.com/rubocop/rubocop/issues/8583): Fix `Style/RedundantRegexpEscape` false positive for line continuations. ([@owst][])
* [#8593](https://github.com/rubocop/rubocop/issues/8593): Fix `Style/RedundantRegexpCharacterClass` false positive for interpolated multi-line expressions. ([@owst][])
* [#8624](https://github.com/rubocop/rubocop/pull/8624): Fix an error with the `Style/CaseLikeIf` cop where it does not properly handle overridden equality methods with no arguments. ([@Skipants][])

### Changes

* [#8413](https://github.com/rubocop/rubocop/issues/8413): Pending cops warning now contains snippet that can be directly copied into `.rubocop.yml` as well as a notice about `NewCops: enable` config option. ([@colszowka][])
* [#8362](https://github.com/rubocop/rubocop/issues/8362): Add numbers of correctable offenses to summary. ([@nguyenquangminh0711][])
* [#8513](https://github.com/rubocop/rubocop/pull/8513): Clarify the ruby warning mentioned in the `Lint/ShadowingOuterLocalVariable` documentation. ([@chocolateboy][])
* [#8517](https://github.com/rubocop/rubocop/pull/8517): Make `Style/HashTransformKeys` and `Style/HashTransformValues` aware of `to_h` with block. ([@eugeneius][])
* [#8529](https://github.com/rubocop/rubocop/pull/8529): Mark `Style/FrozenStringLiteralComment` as `Safe`, but with unsafe auto-correction. ([@marcandre][])
* [#8602](https://github.com/rubocop/rubocop/pull/8602): Fix usage of `to_enum(:scan, regexp)` to work on TruffleRuby. ([@jaimerave][])

## 0.89.1 (2020-08-10)

### Bug fixes

* [#8463](https://github.com/rubocop/rubocop/pull/8463): Fix false positives for `Lint/OutOfRangeRegexpRef` when a regexp is defined and matched in separate steps. ([@eugeneius][])
* [#8464](https://github.com/rubocop/rubocop/pull/8464): Handle regexps matched with `when`, `grep`, `gsub`, `gsub!`, `sub`, `sub!`, `[]`, `slice`, `slice!`, `scan`, `index`, `rindex`, `partition`, `rpartition`, `start_with?`, and `end_with?` in `Lint/OutOfRangeRegexpRef`. ([@eugeneius][])
* [#8466](https://github.com/rubocop/rubocop/issues/8466): Fix a false positive for `Lint/UriRegexp` when using `regexp` method without receiver. ([@koic][])
* [#8478](https://github.com/rubocop/rubocop/issues/8478): Relax `Lint/BinaryOperatorWithIdenticalOperands` for mathematical operations. ([@marcandre][])
* [#8480](https://github.com/rubocop/rubocop/issues/8480): Tweak callback list of `Lint/MissingSuper`. ([@marcandre][])
* [#8481](https://github.com/rubocop/rubocop/pull/8481): Fix autocorrect for elements with newlines in `Style/SymbolArray` and `Style/WordArray`. ([@biinari][])
* [#8475](https://github.com/rubocop/rubocop/issues/8475): Fix a false positive for `Style/HashAsLastArrayItem` when there are duplicate hashes in the array. ([@wcmonty][])
* [#8497](https://github.com/rubocop/rubocop/issues/8497): Fix `Style/IfUnlessModifier` to add parentheses when converting if-end condition inside a parenthesized method argument list. ([@dsavochkin][])

### Changes

* [#8487](https://github.com/rubocop/rubocop/pull/8487): Detect `<` and `>` as comparison operators in `Style/ConditionalAssignment` cop. ([@biinari][])

## 0.89.0 (2020-08-05)

### New features

* [#8322](https://github.com/rubocop/rubocop/pull/8322): Support autocorrect for `Style/CaseEquality` cop. ([@fatkodima][])
* [#7876](https://github.com/rubocop/rubocop/issues/7876): Enhance `Gemspec/RequiredRubyVersion` cop with check that `required_ruby_version` is specified. ([@fatkodima][])
* [#8291](https://github.com/rubocop/rubocop/pull/8291): Add new `Lint/SelfAssignment` cop. ([@fatkodima][])
* [#8389](https://github.com/rubocop/rubocop/pull/8389): Add new `Lint/DuplicateRescueException` cop. ([@fatkodima][])
* [#8433](https://github.com/rubocop/rubocop/pull/8433): Add new `Lint/BinaryOperatorWithIdenticalOperands` cop. ([@fatkodima][])
* [#8430](https://github.com/rubocop/rubocop/pull/8430): Add new `Lint/UnreachableLoop` cop. ([@fatkodima][])
* [#8412](https://github.com/rubocop/rubocop/pull/8412): Add new `Style/OptionalBooleanParameter` cop. ([@fatkodima][])
* [#8432](https://github.com/rubocop/rubocop/pull/8432): Add new `Lint/FloatComparison` cop. ([@fatkodima][])
* [#8376](https://github.com/rubocop/rubocop/pull/8376): Add new `Lint/MissingSuper` cop. ([@fatkodima][])
* [#8415](https://github.com/rubocop/rubocop/pull/8415): Add new `Style/ExplicitBlockArgument` cop. ([@fatkodima][])
* [#8383](https://github.com/rubocop/rubocop/pull/8383): Support autocorrect for `Lint/Loop` cop. ([@fatkodima][])
* [#8339](https://github.com/rubocop/rubocop/pull/8339): Add `Config#for_badge` as an efficient way to get a cop's config merged with its department's. ([@marcandre][])
* [#5067](https://github.com/rubocop/rubocop/issues/5067): Add new `Style/StringConcatenation` cop. ([@fatkodima][])
* [#7425](https://github.com/rubocop/rubocop/pull/7425): Add new `Lint/TopLevelReturnWithArgument` cop. ([@iamravitejag][])
* [#8417](https://github.com/rubocop/rubocop/pull/8417): Add new `Style/GlobalStdStream` cop. ([@fatkodima][])
* [#7949](https://github.com/rubocop/rubocop/issues/7949): Add new `Style/SingleArgumentDig` cop. ([@volfgox][])
* [#8341](https://github.com/rubocop/rubocop/pull/8341): Add new `Lint/EmptyConditionalBody` cop. ([@fatkodima][])
* [#7755](https://github.com/rubocop/rubocop/issues/7755):  Add new `Lint/OutOfRangeRegexpRef` cop. ([@sonalinavlakhe][])

### Bug fixes

* [#8346](https://github.com/rubocop/rubocop/pull/8346): Allow parentheses in single-line inheritance with `Style/MethodCallWithArgsParentheses` `EnforcedStyle: omit_parentheses` to fix invalid Ruby auto-correction. ([@gsamokovarov][])
* [#8324](https://github.com/rubocop/rubocop/issues/8324): Fix crash for `Layout/SpaceAroundMethodCallOperator` when using `Proc#call` shorthand syntax. ([@fatkodima][])
* [#8332](https://github.com/rubocop/rubocop/pull/8332): Fix auto-correct in `Style/ConditionalAssignment` to preserve constant namespace. ([@biinari][])
* [#8344](https://github.com/rubocop/rubocop/issues/8344): Fix crash for `Style/CaseLikeIf` when checking against `equal?` and `match?` without a receiver. ([@fatkodima][])
* [#8323](https://github.com/rubocop/rubocop/issues/8323): Fix a false positive for `Style/HashAsLastArrayItem` when hash is not a last array item. ([@fatkodima][])
* [#8299](https://github.com/rubocop/rubocop/issues/8299): Fix an incorrect auto-correct for `Style/RedundantCondition` when using `raise`, `rescue`, or `and` without argument parentheses in `else`. ([@koic][])
* [#8335](https://github.com/rubocop/rubocop/issues/8335): Fix incorrect character class detection for nested or POSIX bracket character classes in `Style/RedundantRegexpEscape`. ([@owst][])
* [#8347](https://github.com/rubocop/rubocop/issues/8347): Fix an incorrect auto-correct for `EnforcedStyle: hash_rockets` of `Style/HashSyntax` with `Layout/HashAlignment`. ([@koic][])
* [#8375](https://github.com/rubocop/rubocop/pull/8375): Fix an infinite loop error for `Style/EmptyMethod`. ([@koic][])
* [#8385](https://github.com/rubocop/rubocop/pull/8385): Remove auto-correction for `Lint/EnsureReturn`. ([@marcandre][])
* [#8391](https://github.com/rubocop/rubocop/issues/8391): Mark `Style/ArrayCoercion` as not safe. ([@marcandre][])
* [#8406](https://github.com/rubocop/rubocop/issues/8406): Improve `Style/AccessorGrouping`'s auto-correction to remove redundant blank lines. ([@koic][])
* [#8330](https://github.com/rubocop/rubocop/issues/8330): Fix a false positive for `Style/MissingRespondToMissing` when defined method with inline access modifier. ([@koic][])
* [#8422](https://github.com/rubocop/rubocop/issues/8422): Fix an error for `Lint/SelfAssignment` when using or-assignment for constant. ([@koic][])
* [#8423](https://github.com/rubocop/rubocop/issues/8423): Fix an error for `Style/SingleArgumentDig` when without a receiver. ([@koic][])
* [#8424](https://github.com/rubocop/rubocop/issues/8424): Fix an error for `Lint/IneffectiveAccessModifier` when there is `begin...end` before a method definition. ([@koic][])
* [#8006](https://github.com/rubocop/rubocop/issues/8006): Fix line length calculation for `Style/IfUnlessModifier` to correctly take into account code before the if condition when considering conversation to a single-line form. ([@dsavochkin][])
* [#8283](https://github.com/rubocop/rubocop/issues/8283): Fix line length calculation for `Style/IfUnlessModifier` to correctly take into account a comment on the first line when considering conversation to a single-line form. ([@dsavochkin][])
* [#7957](https://github.com/rubocop/rubocop/issues/7957): Fix line length calculation for `Style/IfUnlessModifier` to correctly take into account code on the last line after the end keyword when considering conversion to a single-line form. ([@dsavochkin][])
* [#8226](https://github.com/rubocop/rubocop/issues/8226): Fix `Style/IfUnlessModifier` to add parentheses when converting if-end condition inside an array or a hash to a single-line form. ([@dsavochkin][])
* [#8443](https://github.com/rubocop/rubocop/pull/8443): Fix an incorrect auto-correct for `Style/StructInheritance` when there is a comment before class declaration. ([@koic][])
* [#8444](https://github.com/rubocop/rubocop/issues/8444): Fix an error for `Layout/FirstMethodArgumentLineBreak` when using kwargs in `super`. ([@koic][])
* [#8448](https://github.com/rubocop/rubocop/pull/8448): Fix `Style/NestedParenthesizedCalls` to include line continuations in whitespace for auto-correct. ([@biinari][])

### Changes

* [#8376](https://github.com/rubocop/rubocop/pull/8376): `Style/MethodMissingSuper` cop is removed in favor of new `Lint/MissingSuper` cop. ([@fatkodima][])
* [#8433](https://github.com/rubocop/rubocop/pull/8433): `Lint/UselessComparison` cop is removed in favor of new `Lint/BinaryOperatorWithIdenticalOperands` cop. ([@fatkodima][])
* [#8350](https://github.com/rubocop/rubocop/pull/8350): Set default max line length to 120 for `Style/MultilineMethodSignature`. ([@koic][])
* [#8338](https://github.com/rubocop/rubocop/pull/8338): **potentially breaking**. Config#for_department now returns only the config specified for that department; the 'Enabled' attribute is no longer calculated. ([@marcandre][])
* [#8037](https://github.com/rubocop/rubocop/pull/8037): **(Breaking)** Cop `Metrics/AbcSize` now counts ||=, &&=, multiple assignments, for, yield, iterating blocks. `&.` now count as conditions too (unless repeated on the same variable). Default bumped from 15 to 17. Consider using `rubocop -a --disable-uncorrectable` to ease transition. ([@marcandre][])
* [#8276](https://github.com/rubocop/rubocop/issues/8276): Cop `Metrics/CyclomaticComplexity` not longer counts `&.` when repeated on the same variable. ([@marcandre][])
* [#8204](https://github.com/rubocop/rubocop/pull/8204): **(Breaking)** Cop `Metrics/PerceivedComplexity` now counts `else` in `case` statements, `&.`, `||=`, `&&=` and blocks known to iterate. Default bumped from 7 to 8. Consider using `rubocop -a --disable-uncorrectable` to ease transition. ([@marcandre][])
* [#8416](https://github.com/rubocop/rubocop/issues/8416): Cop `Lint/InterpolationCheck` marked as unsafe. ([@marcandre][])
* [#8442](https://github.com/rubocop/rubocop/pull/8442): Remove `RuboCop::Cop::ParserDiagnostic` mixin module. ([@koic][])

## 0.88.0 (2020-07-13)

### New features

* [#8279](https://github.com/rubocop/rubocop/pull/8279): Recognise require method passed as argument in `Lint/NonDeterministicRequireOrder` cop. ([@biinari][])
* [#7333](https://github.com/rubocop/rubocop/issues/7333): Add new `Style/RedundantFileExtensionInRequire` cop. ([@fatkodima][])
* [#8316](https://github.com/rubocop/rubocop/pull/8316): Support autocorrect for `Lint/DisjunctiveAssignmentInConstructor` cop. ([@fatkodima][])
* [#8242](https://github.com/rubocop/rubocop/pull/8242): Internal profiling available with `bin/rubocop-profile` and rake tasks. ([@marcandre][])
* [#8295](https://github.com/rubocop/rubocop/pull/8295): Add new `Style/ArrayCoercion` cop. ([@fatkodima][])
* [#8293](https://github.com/rubocop/rubocop/pull/8293): Add new `Lint/DuplicateElsifCondition` cop. ([@fatkodima][])
* [#7736](https://github.com/rubocop/rubocop/issues/7736): Add new `Style/CaseLikeIf` cop. ([@fatkodima][])
* [#4286](https://github.com/rubocop/rubocop/issues/4286): Add new `Style/HashAsLastArrayItem` cop. ([@fatkodima][])
* [#8247](https://github.com/rubocop/rubocop/issues/8247): Add new `Style/HashLikeCase` cop. ([@fatkodima][])
* [#8286](https://github.com/rubocop/rubocop/issues/8286): Internal method `expect_offense` allows abbreviated offense messages. ([@marcandre][])

### Bug fixes

* [#8232](https://github.com/rubocop/rubocop/issues/8232): Fix a false positive for `Layout/EmptyLinesAroundAccessModifier` when `end` immediately after access modifier. ([@koic][])
* [#7777](https://github.com/rubocop/rubocop/issues/7777): Fix crash for `Layout/MultilineArrayBraceLayout` when comment is present after last element. ([@shekhar-patil][])
* [#7776](https://github.com/rubocop/rubocop/issues/7776): Fix crash for `Layout/MultilineMethodCallBraceLayout` when comment is present before closing braces. ([@shekhar-patil][])
* [#8282](https://github.com/rubocop/rubocop/issues/8282): Fix `Style/IfUnlessModifier` bad precedence detection. ([@tejasbubane][])
* [#8289](https://github.com/rubocop/rubocop/issues/8289): Fix `Style/AccessorGrouping` to not register offense for accessor with comment. ([@tejasbubane][])
* [#8310](https://github.com/rubocop/rubocop/pull/8310): Handle major version requirements in `Gemspec/RequiredRubyVersion`. ([@eugeneius][])
* [#8315](https://github.com/rubocop/rubocop/pull/8315): Fix crash for `Style/PercentLiteralDelimiters` when the source contains invalid characters. ([@eugeneius][])
* [#8239](https://github.com/rubocop/rubocop/pull/8239): Don't load `.rubocop.yml` files at all outside of the current project, unless they are personal configuration files and the project has no configuration. ([@deivid-rodriguez][])

### Changes

* [#8021](https://github.com/rubocop/rubocop/issues/8021): Rewrite `Layout/SpaceAroundMethodCallOperator` cop to make it faster. ([@fatkodima][])
* [#8294](https://github.com/rubocop/rubocop/pull/8294): Add `of` to `AllowedNames` of `MethodParameterName` cop. ([@AlexWayfer][])

## 0.87.1 (2020-07-07)

### Bug fixes

* [#8189](https://github.com/rubocop/rubocop/issues/8189): Fix an error for `Layout/MultilineBlockLayout` where spaces for a new line where not considered. ([@knejad][])
* [#8252](https://github.com/rubocop/rubocop/issues/8252): Fix a command line option name from `--safe-autocorrect` to `--safe-auto-correct`, which is compatible with RuboCop 0.86 and lower. ([@koic][])
* [#8259](https://github.com/rubocop/rubocop/issues/8259): Fix false positives for `Style/BisectedAttrAccessor` when accessors have different access modifiers. ([@fatkodima][])
* [#8253](https://github.com/rubocop/rubocop/issues/8253): Fix false positives for `Style/AccessorGrouping` when accessors have different access modifiers. ([@fatkodima][])
* [#8257](https://github.com/rubocop/rubocop/issues/8257): Fix an error for `Style/BisectedAttrAccessor` when using `attr_reader` and `attr_writer` with splat arguments. ([@fatkodima][])
* [#8239](https://github.com/rubocop/rubocop/pull/8239): Don't load `.rubocop.yml` from personal folders to check for exclusions if given a custom configuration file. ([@deivid-rodriguez][])
* [#8256](https://github.com/rubocop/rubocop/issues/8256): Fix an error for `--auto-gen-config` when running a cop who do not support auto-correction. ([@koic][])
* [#8262](https://github.com/rubocop/rubocop/pull/8262): Fix `Lint/DeprecatedOpenSSLConstant` auto-correction of `OpenSSL::Cipher` to use lower case, as some Linux-based systems do not accept upper cased cipher names. ([@bdewater][])

## 0.87.0 (2020-07-06)

### New features

* [#7868](https://github.com/rubocop/rubocop/pull/7868): `Cop::Base` is the new recommended base class for cops. ([@marcandre][])
* [#3983](https://github.com/rubocop/rubocop/issues/3983): Add new `Style/AccessorGrouping` cop. ([@fatkodima][])
* [#8244](https://github.com/rubocop/rubocop/pull/8244): Add new `Style/BisectedAttrAccessor` cop. ([@fatkodima][])
* [#7458](https://github.com/rubocop/rubocop/issues/7458): Add new `AsciiConstants` option for `Naming/AsciiIdentifiers`. ([@fatkodima][])
* [#7373](https://github.com/rubocop/rubocop/issues/7373): Add new `Style/RedundantAssignment` cop. ([@fatkodima][])
* [#8213](https://github.com/rubocop/rubocop/pull/8213): Permit to specify TargetRubyVersion 2.8 (experimental). ([@koic][])
* [#8159](https://github.com/rubocop/rubocop/pull/8159): Add new `CountAsOne` option for code length related `Metric` cops. ([@fatkodima][])
* [#8164](https://github.com/rubocop/rubocop/pull/8164): Support auto-correction for `Lint/InterpolationCheck`. ([@koic][])
* [#8223](https://github.com/rubocop/rubocop/pull/8223): Support auto-correction for `Style/IfUnlessModifierOfIfUnless`. ([@koic][])
* [#8172](https://github.com/rubocop/rubocop/pull/8172): Support auto-correction for `Lint/SafeNavigationWithEmpty`. ([@koic][])

### Bug fixes

* [#8039](https://github.com/rubocop/rubocop/pull/8039): Fix false positives for `Lint/ParenthesesAsGroupedExpression` in when using operators or chain functions. ([@CamilleDrapier][])
* [#8196](https://github.com/rubocop/rubocop/issues/8196): Fix a false positive for `Style/RedundantFetchBlock` when using with `Rails.cache`. ([@fatkodima][])
* [#8195](https://github.com/rubocop/rubocop/issues/8195): Fix an error for `Style/RedundantFetchBlock` when using `#fetch` with empty block. ([@koic][])
* [#8193](https://github.com/rubocop/rubocop/issues/8193): Fix a false positive for `Style/RedundantRegexpCharacterClass` when using `[\b]`. ([@owst][])
* [#8205](https://github.com/rubocop/rubocop/issues/8205): Fix a false positive for `Style/RedundantRegexpCharacterClass` when using a leading escaped `]`. ([@owst][])
* [#8208](https://github.com/rubocop/rubocop/issues/8208): Fix `Style/RedundantParentheses` with hash literal as first argument to `yield`. ([@karlwithak][])
* [#8176](https://github.com/rubocop/rubocop/pull/8176): Don't load `.rubocop.yml` from personal folders to check for exclusions if there's a project configuration. ([@deivid-rodriguez][])

### Changes

* [#7868](https://github.com/rubocop/rubocop/pull/7868): **(Breaking)** Extensive refactoring of internal classes `Team`, `Commissioner`, `Corrector`. `Cop::Cop#corrections` not completely compatible. See Upgrade Notes. ([@marcandre][])
* [#8156](https://github.com/rubocop/rubocop/issues/8156): **(Breaking)** `rubocop -a / --auto-correct` no longer run unsafe corrections; `rubocop -A / --auto-correct-all` run both safe and unsafe corrections. Options `--safe-autocorrect` is deprecated. ([@marcandre][])
* [#8207](https://github.com/rubocop/rubocop/pull/8207): **(Breaking)** Order for gems names now disregards underscores and dashes unless `ConsiderPunctuation` setting is set to `true`. ([@marcandre][])
* [#8211](https://github.com/rubocop/rubocop/pull/8211): `Style/ClassVars` cop now detects `class_variable_set`. ([@biinari][])
* [#8245](https://github.com/rubocop/rubocop/pull/8245): Detect top-level constants like `::Const` in various cops. ([@biinari][])

## 0.86.0 (2020-06-22)

### New features

* [#8147](https://github.com/rubocop/rubocop/pull/8147): Add new `Style/RedundantFetchBlock` cop. ([@fatkodima][])
* [#8111](https://github.com/rubocop/rubocop/pull/8111): Add auto-correct for `Style/StructInheritance`. ([@tejasbubane][])
* [#8113](https://github.com/rubocop/rubocop/pull/8113): Let `expect_offense` templates add variable-length whitespace with `_{foo}`. ([@eugeneius][])
* [#8148](https://github.com/rubocop/rubocop/pull/8148): Support auto-correction for `Style/MultilineTernaryOperator`. ([@koic][])
* [#8151](https://github.com/rubocop/rubocop/pull/8151): Support auto-correction for `Style/NestedTernaryOperator`. ([@koic][])
* [#8142](https://github.com/rubocop/rubocop/pull/8142): Add `Lint/ConstantResolution` cop. ([@robotdana][])
* [#8170](https://github.com/rubocop/rubocop/pull/8170): Support auto-correction for `Lint/RegexpAsCondition`. ([@koic][])
* [#8169](https://github.com/rubocop/rubocop/pull/8169): Support auto-correction for `Lint/RaiseException`. ([@koic][])

### Bug fixes

* [#8132](https://github.com/rubocop/rubocop/issues/8132): Fix the problem with `Naming/MethodName: EnforcedStyle: camelCase` and `_` or `i` variables. ([@avrusanov][])
* [#8115](https://github.com/rubocop/rubocop/issues/8115): Fix false negative for `Lint::FormatParameterMismatch` when argument contains formatting. ([@andrykonchin][])
* [#8131](https://github.com/rubocop/rubocop/pull/8131): Fix false positive for `Style/RedundantRegexpEscape` with escaped delimiters. ([@owst][])
* [#8124](https://github.com/rubocop/rubocop/issues/8124): Fix a false positive for `Lint/FormatParameterMismatch` when using named parameters with escaped `%`. ([@koic][])
* [#7979](https://github.com/rubocop/rubocop/issues/7979): Fix "uninitialized constant DidYouMean::SpellChecker" exception. ([@bquorning][])
* [#8098](https://github.com/rubocop/rubocop/issues/8098): Fix a false positive for `Style/RedundantRegexpCharacterClass` when using interpolations. ([@owst][])
* [#8150](https://github.com/rubocop/rubocop/pull/8150): Fix a false positive for `Layout/EmptyLinesAroundAttributeAccessor` when using attribute accessors in `if` ... `else` branches. ([@koic][])
* [#8179](https://github.com/rubocop/rubocop/issues/8179): Fix an infinite correction loop error for `Layout/MultilineBlockLayout` when missing newline before opening parenthesis `(` for block body. ([@koic][])
* [#8185](https://github.com/rubocop/rubocop/issues/8185): Fix a false positive for `Style/YodaCondition` when interpolation is used on the left hand side. ([@koic][])

### Changes

* [#8149](https://github.com/rubocop/rubocop/pull/8149): **(Breaking)** Cop `Metrics/CyclomaticComplexity` now counts `&.`, `||=`, `&&=` and blocks known to iterate. Default bumped from 6 to 7. Consider using `rubocop -a --disable-uncorrectable` to ease transition. ([@marcandre][])
* [#8146](https://github.com/rubocop/rubocop/pull/8146): Use UTC in RuboCop todo file generation. ([@mauro-oto][])
* [#8178](https://github.com/rubocop/rubocop/pull/8178): Mark unsafe for `Lint/RaiseException`. ([@koic][])

## 0.85.1 (2020-06-07)

### Bug fixes

* [#8083](https://github.com/rubocop/rubocop/issues/8083): Fix an error for `Lint/MixedRegexpCaptureTypes` cop when using a regular expression that cannot be processed by regexp_parser gem. ([@koic][])
* [#8081](https://github.com/rubocop/rubocop/issues/8081): Fix a false positive for `Lint/SuppressedException` when empty rescue block in `do` block. ([@koic][])
* [#8096](https://github.com/rubocop/rubocop/issues/8096): Fix a false positive for `Lint/SuppressedException` when empty rescue block in defs. ([@koic][])
* [#8108](https://github.com/rubocop/rubocop/issues/8108): Fix infinite loop in `Layout/HeredocIndentation` auto-correct. ([@jonas054][])
* [#8042](https://github.com/rubocop/rubocop/pull/8042): Fix raising error in `Lint::FormatParameterMismatch` when it handles invalid format strings and add new offense. ([@andrykonchin][])

## 0.85.0 (2020-06-01)

### New features

* [#6289](https://github.com/rubocop/rubocop/issues/6289): Add new `CheckDefinitionPathHierarchy` option for `Naming/FileName`. ([@jschneid][])
* [#8055](https://github.com/rubocop/rubocop/pull/8055): Add new `Style/RedundantRegexpCharacterClass` cop. ([@owst][])
* [#8069](https://github.com/rubocop/rubocop/issues/8069): New option for `expect_offense` to help format offense templates. ([@marcandre][])
* [#7908](https://github.com/rubocop/rubocop/pull/7908): Add new `Style/RedundantRegexpEscape` cop. ([@owst][])
* [#7978](https://github.com/rubocop/rubocop/pull/7978): Add new option `OnlyFor` to the `Bundler/GemComment` cop. ([@ric2b][])
* [#8063](https://github.com/rubocop/rubocop/issues/8063): Add new `AllowedNames` option for `Naming/ClassAndModuleCamelCase`. ([@tejasbubane][])
* [#8050](https://github.com/rubocop/rubocop/pull/8050): New option `--display-only-failed` that can be used with `--format junit`. Speeds up test report processing for large codebases and helps address the sorts of concerns raised at [mikian/rubocop-junit-formatter #18](https://github.com/mikian/rubocop-junit-formatter/issues/18). ([@burnettk][])
* [#7746](https://github.com/rubocop/rubocop/issues/7746): Add new `Lint/MixedRegexpCaptureTypes` cop. ([@pocke][])

### Bug fixes

* [#8008](https://github.com/rubocop/rubocop/issues/8008): Fix an error for `Lint/SuppressedException` when empty rescue block in `def`. ([@koic][])
* [#8012](https://github.com/rubocop/rubocop/issues/8012): Fix an incorrect auto-correct for `Lint/DeprecatedOpenSSLConstant` when deprecated OpenSSL constant is used in a block. ([@koic][])
* [#8017](https://github.com/rubocop/rubocop/pull/8017): Fix a false positive for `Lint/SuppressedException` when empty rescue with comment in `def`. ([@koic][])
* [#7990](https://github.com/rubocop/rubocop/issues/7990): Fix resolving `inherit_gem` in remote configs. ([@CvX][])
* [#8035](https://github.com/rubocop/rubocop/issues/8035): Fix a false positive for `Lint/DeprecatedOpenSSLConstant` when using double quoted string argument. ([@koic][])
* [#7971](https://github.com/rubocop/rubocop/issues/7971): Fix an issue where `--disable-uncorrectable` would not update uncorrected code with `rubocop:todo`. ([@rrosenblum][])
* [#8035](https://github.com/rubocop/rubocop/issues/8035): Fix a false positive for `Lint/DeprecatedOpenSSLConstant` when argument is a variable, method, or constant. ([@koic][])

### Changes

* [#8056](https://github.com/rubocop/rubocop/pull/8056): **(Breaking)** Remove support for unindent/active_support/powerpack from `Layout/HeredocIndentation`, so it only recommends using squiggly heredoc. ([@bquorning][])

## 0.84.0 (2020-05-21)

### New features

* [#7735](https://github.com/rubocop/rubocop/issues/7735): `NodePattern` and `AST` classes have been moved to the [`rubocop-ast` gem](https://github.com/rubocop/rubocop-ast). ([@marcandre][])
* [#7950](https://github.com/rubocop/rubocop/pull/7950): Add new `Lint/DeprecatedOpenSSLConstant` cop. ([@bdewater][])
* [#7976](https://github.com/rubocop/rubocop/issues/7976): Add `AllowAliasSyntax` and `AllowedMethods` options for `Layout/EmptyLinesAroundAttributeAccessor`. ([@koic][])
* [#7984](https://github.com/rubocop/rubocop/pull/7984): New `rake` task "check_commit" will run `rspec` and `rubocop` on files touched by the last commit. Currently available when developing from the main repository only. ([@marcandre][])

### Bug fixes

* [#7953](https://github.com/rubocop/rubocop/issues/7953): Fix an error for `Lint/AmbiguousOperator` when a method with no arguments is used in advance. ([@koic][])
* [#7962](https://github.com/rubocop/rubocop/issues/7962): Fix a false positive for `Lint/ParenthesesAsGroupedExpression` when heredoc has a space between the same string as the method name and `(`. ([@koic][])
* [#7967](https://github.com/rubocop/rubocop/pull/7967): `Style/SlicingWithRange` cop now supports any expression as its first index. ([@zverok][])
* [#7972](https://github.com/rubocop/rubocop/issues/7972): Fix an incorrect autocorrect for `Style/HashSyntax` when using a return value uses `return`. ([@koic][])
* [#7886](https://github.com/rubocop/rubocop/issues/7886): Fix a bug in `AllowComments` logic in `Lint/SuppressedException`. ([@jonas054][])
* [#7991](https://github.com/rubocop/rubocop/issues/7991): Fix an error for `Layout/EmptyLinesAroundAttributeAccessor` when attribute method is method chained. ([@koic][])
* [#7993](https://github.com/rubocop/rubocop/issues/7993): Fix a false positive for `Migration/DepartmentName` when a disable comment contains an unexpected character for department name. ([@koic][])
* [#7983](https://github.com/rubocop/rubocop/pull/7983): Make the config loader Bundler-aware. ([@CvX][])

### Changes

* [#7952](https://github.com/rubocop/rubocop/pull/7952): **(Breaking)** Change the max line length of `Layout/LineLength` to 120 by default. ([@koic][])
* [#7959](https://github.com/rubocop/rubocop/pull/7959): Change enforced style to conditionals for `Style/AndOr`. ([@koic][])
* [#7985](https://github.com/rubocop/rubocop/pull/7985): Add `EnforcedStyle` for `Style/DoubleNegation` cop and allow double negation in contexts that use boolean as a return value. ([@koic][])

## 0.83.0 (2020-05-11)

### New features

* [#7951](https://github.com/rubocop/rubocop/pull/7951): Include `rakefile` file by default. ([@jethrodaniel][])
* [#7921](https://github.com/rubocop/rubocop/pull/7921): Add new `Style/SlicingWithRange` cop. ([@zverok][])
* [#7895](https://github.com/rubocop/rubocop/pull/7895): Include `.simplecov` file by default. ([@robotdana][])
* [#7916](https://github.com/rubocop/rubocop/pull/7916): Support auto-correction for `Lint/AmbiguousRegexpLiteral`. ([@koic][])
* [#7917](https://github.com/rubocop/rubocop/pull/7917): Support auto-correction for `Lint/UselessAccessModifier`. ([@koic][])
* [#595](https://github.com/rubocop/rubocop/issues/595): Add ERB pre-processing for configuration files. ([@jonas054][])
* [#7918](https://github.com/rubocop/rubocop/pull/7918): Support auto-correction for `Lint/AmbiguousOperator`. ([@koic][])
* [#7937](https://github.com/rubocop/rubocop/pull/7937): Support auto-correction for `Style/IfWithSemicolon`. ([@koic][])
* [#3696](https://github.com/rubocop/rubocop/issues/3696): Add `AllowComments` option to `Lint/EmptyWhen` cop. ([@koic][])
* [#7910](https://github.com/rubocop/rubocop/pull/7910): Support auto-correction for `Lint/ParenthesesAsGroupedExpression`. ([@koic][])
* [#7925](https://github.com/rubocop/rubocop/pull/7925): Support auto-correction for `Layout/ConditionPosition`. ([@koic][])
* [#7934](https://github.com/rubocop/rubocop/pull/7934): Support auto-correction for `Lint/EnsureReturn`. ([@koic][])
* [#7922](https://github.com/rubocop/rubocop/pull/7922): Add new `Layout/EmptyLineAroundAttributeAccessor` cop. ([@koic][])

### Bug fixes

* [#7929](https://github.com/rubocop/rubocop/issues/7929): Fix `Style/FrozenStringLiteralComment` to accept frozen_string_literal anywhere in leading comment lines. ([@jeffcarbs][])
* [#7882](https://github.com/rubocop/rubocop/pull/7882): Fix `Style/CaseEquality` when `AllowOnConstant` is `true` and the method receiver is implicit. ([@rafaelfranca][])
* [#7790](https://github.com/rubocop/rubocop/issues/7790): Fix `--parallel` and `--ignore-parent-exclusion` combination. ([@jonas054][])
* [#7881](https://github.com/rubocop/rubocop/issues/7881): Fix `--parallel` and `--force-default-config` combination. ([@jonas054][])
* [#7635](https://github.com/rubocop/rubocop/issues/7635): Fix a false positive for `Style/MultilineWhenThen` when `then` required for a body of `when` is used. ([@koic][])
* [#7905](https://github.com/rubocop/rubocop/pull/7905): Fix an error when running `rubocop --only` or `rubocop --except` options without cop name argument. ([@koic][])
* [#7903](https://github.com/rubocop/rubocop/pull/7903): Fix an incorrect auto-correct for `Style/HashTransformKeys` and `Style/HashTransformValues` cops when line break before `to_h` method. ([@diogoosorio][], [@koic][])
* [#7899](https://github.com/rubocop/rubocop/issues/7899): Fix an infinite loop error for `Layout/SpaceAroundOperators` with `Layout/ExtraSpacing` when using `ForceEqualSignAlignment: true`. ([@koic][])
* [#7885](https://github.com/rubocop/rubocop/issues/7885): Fix `Style/IfUnlessModifier` logic when tabs are used for indentation. ([@jonas054][])
* [#7909](https://github.com/rubocop/rubocop/pull/7909): Fix a false positive for `Lint/ParenthesesAsGroupedExpression` when using an intended grouped parentheses. ([@koic][])
* [#7913](https://github.com/rubocop/rubocop/pull/7913): Fix a false positive for `Lint/LiteralAsCondition` when using `true` literal in `while` and similar cases. ([@koic][])
* [#7928](https://github.com/rubocop/rubocop/issues/7928): Fix a false message for `Style/GuardClause` when using `and` or `or` operators for guard clause in `then` or `else` branches. ([@koic][])
* [#7928](https://github.com/rubocop/rubocop/issues/7928): Fix a false positive for `Style/GuardClause` when assigning the result of a guard condition with `else`. ([@koic][])

### Changes

* [#7860](https://github.com/rubocop/rubocop/issues/7860): Change `AllowInHeredoc` option of `Layout/TrailingWhitespace` to `true` by default. ([@koic][])
* [#7094](https://github.com/rubocop/rubocop/issues/7094): Clarify alignment in `Layout/MultilineOperationIndentation`. ([@jonas054][])
* [#4245](https://github.com/rubocop/rubocop/issues/4245): **(Breaking)** Inspect all files given on command line unless `--only-recognized-file-types` is given. ([@jonas054][])
* [#7390](https://github.com/rubocop/rubocop/issues/7390): **(Breaking)** Enabling a cop overrides disabling its department. ([@jonas054][])
* [#7936](https://github.com/rubocop/rubocop/issues/7936): Mark `Lint/BooleanSymbol` as unsafe. ([@laurmurclar][])
* [#7948](https://github.com/rubocop/rubocop/pull/7948): Mark unsafe for `Style/OptionalArguments`. ([@koic][])
* [#7931](https://github.com/rubocop/rubocop/pull/7931): Remove dependency on the `jaro_winkler` gem, instead depending on `did_you_mean`. This may be a breaking change for RuboCop libraries calling `NameSimilarity#find_similar_name`. ([@bquorning][])

## 0.82.0 (2020-04-16)

### New features

* [#7867](https://github.com/rubocop/rubocop/pull/7867): Add support for tabs in indentation. ([@DracoAter][])
* [#7863](https://github.com/rubocop/rubocop/issues/7863): Corrector now accepts nodes in addition to ranges. ([@marcandre][])
* [#7862](https://github.com/rubocop/rubocop/issues/7862): Corrector now has a `wrap` method. ([@marcandre][])
* [#7850](https://github.com/rubocop/rubocop/issues/7850): Make it possible to enable/disable pending cops. ([@koic][])
* [#7861](https://github.com/rubocop/rubocop/issues/7861): Make it to allow `Style/CaseEquality` when the receiver is a constant. ([@rafaelfranca][])
* [#7851](https://github.com/rubocop/rubocop/pull/7851): Add a new `Style/ExponentialNotation` cop. ([@tdeo][])
* [#7384](https://github.com/rubocop/rubocop/pull/7384): Add new `Style/DisableCopsWithinSourceCodeDirective` cop. ([@egze][])
* [#7826](https://github.com/rubocop/rubocop/issues/7826): Add new `Layout/SpaceAroundMethodCallOperator` cop. ([@saurabhmaurya15][])

### Bug fixes

* [#7871](https://github.com/rubocop/rubocop/pull/7871): Fix an auto-correction bug in `Lint/BooleanSymbol`. ([@knu][])
* [#7842](https://github.com/rubocop/rubocop/issues/7842): Fix a false positive for `Lint/RaiseException` when raising Exception with explicit namespace. ([@koic][])
* [#7834](https://github.com/rubocop/rubocop/issues/7834): Fix `Lint/UriRegexp` to register offense with array arguments. ([@tejasbubane][])
* [#7841](https://github.com/rubocop/rubocop/issues/7841): Fix an error for `Style/TrailingCommaInBlockArgs` when lambda literal (`->`) has multiple arguments. ([@koic][])
* [#7842](https://github.com/rubocop/rubocop/issues/7842): Fix a false positive for `Lint/RaiseException` when Exception without cbase specified under the namespace `Gem` by adding  `AllowedImplicitNamespaces` option. ([@koic][])
* `Style/IfUnlessModifier` does not infinite-loop when auto-correcting long lines which use if/unless modifiers and have multiple statements separated by semicolons. ([@alexdowad][])
* [rubocop/rubocop-rails#127](https://github.com/rubocop/rubocop-rails/issues/127): Use `ConfigLoader.default_configuration` for the default config. ([@hanachin][])

### Changes

* [#7867](https://github.com/rubocop/rubocop/pull/7867): **(Breaking)** Renamed `Layout/Tab` cop to `Layout/IndentationStyle`. ([@DracoAter][])
* [#7869](https://github.com/rubocop/rubocop/pull/7869): **(Compatibility)** Drop support for Ruby 2.3. ([@koic][])

## 0.81.0 (2020-04-01)

### New features

* [#7299](https://github.com/rubocop/rubocop/issues/7299): Add new `Lint/RaiseException` cop. ([@denys281][])
* [#7793](https://github.com/rubocop/rubocop/pull/7793): Prefer `include?` over `member?` in `Style/CollectionMethods`. ([@dmolesUC][])
* [#7654](https://github.com/rubocop/rubocop/issues/7654): Support `with_fixed_indentation` option for `Layout/ArrayAlignment` cop. ([@nikitasakov][])
* [#7783](https://github.com/rubocop/rubocop/pull/7783): Support Ruby 2.7's numbered parameter for `Style/RedundantSort`. ([@koic][])
* [#7795](https://github.com/rubocop/rubocop/issues/7795): Make `Layout/EmptyLineAfterGuardClause` aware of case where `and` or `or` is used before keyword that break control (e.g. `and return`). ([@koic][])
* [#7786](https://github.com/rubocop/rubocop/pull/7786): Support Ruby 2.7's pattern match for `Layout/ElseAlignment` cop. ([@koic][])
* [#7784](https://github.com/rubocop/rubocop/pull/7784): Support Ruby 2.7's numbered parameter for `Lint/SafeNavigationChain`. ([@koic][])
* [#7331](https://github.com/rubocop/rubocop/issues/7331): Add `forbidden` option to `Style/ModuleFunction` cop. ([@weh][])
* [#7699](https://github.com/rubocop/rubocop/pull/7699): Add new `Lint/StructNewOverride` cop. ([@ybiquitous][])
* [#7637](https://github.com/rubocop/rubocop/pull/7637): Add new `Style/TrailingCommaInBlockArgs` cop. ([@pawptart][])
* [#7809](https://github.com/rubocop/rubocop/pull/7809): Add auto-correction for `Style/EndBlock` cop. ([@tejasbubane][])
* [#7739](https://github.com/rubocop/rubocop/pull/7739): Add `IgnoreNotImplementedMethods` configuration to `Lint/UnusedMethodArgument`. ([@tejasbubane][])
* [#7740](https://github.com/rubocop/rubocop/issues/7740): Add `AllowModifiersOnSymbols` configuration to `Style/AccessModifierDeclarations`. ([@tejasbubane][])
* [#7812](https://github.com/rubocop/rubocop/pull/7812): Add auto-correction for `Lint/BooleanSymbol` cop. ([@tejasbubane][])
* [#7823](https://github.com/rubocop/rubocop/pull/7823): Add `IgnoredMethods` configuration in `Metrics/AbcSize`, `Metrics/CyclomaticComplexity`, and `Metrics/PerceivedComplexity` cops. ([@drenmi][])
* [#7816](https://github.com/rubocop/rubocop/pull/7816): Support Ruby 2.7's numbered parameter for `Style/Lambda`. ([@koic][])
* [#7829](https://github.com/rubocop/rubocop/issues/7829): Fix an error for `Style/OneLineConditional` when one of the branches contains `next` keyword. ([@koic][])

### Bug fixes

* [#7236](https://github.com/rubocop/rubocop/pull/7236): Mark `Style/InverseMethods` auto-correct as incompatible with `Style/SymbolProc`. ([@drenmi][])
* [#7144](https://github.com/rubocop/rubocop/issues/7144): Fix `Style/Documentation` constant visibility declaration in namespace. ([@AdrienSldy][])
* [#7779](https://github.com/rubocop/rubocop/issues/7779): Fix a false positive for `Style/MultilineMethodCallIndentation` when using Ruby 2.7's numbered parameter. ([@koic][])
* [#7733](https://github.com/rubocop/rubocop/issues/7733): Fix rubocop-junit-formatter incompatibility XML for JUnit formatter. ([@koic][])
* [#7767](https://github.com/rubocop/rubocop/issues/7767): Skip array literals in `Style/HashTransformValues` and `Style/HashTransformKeys`. ([@tejasbubane][])
* [#7791](https://github.com/rubocop/rubocop/issues/7791): Fix an error on auto-correction for `Layout/BlockEndNewline` when `}` of multiline block without processing is not on its own line. ([@koic][])
* [#7778](https://github.com/rubocop/rubocop/issues/7778): Fix a false positive for `Layout/EndAlignment` when a non-whitespace is used before the `end` keyword. ([@koic][])
* [#7806](https://github.com/rubocop/rubocop/pull/7806): Fix an error for `Lint/ErbNewArguments` cop when inspecting `ActionView::Template::Handlers::ERB.new`. ([@koic][])
* [#7814](https://github.com/rubocop/rubocop/issues/7814): Fix a false positive for `Migrate/DepartmentName` cop when inspecting an unexpected disabled comment format. ([@koic][])
* [#7728](https://github.com/rubocop/rubocop/issues/7728): Fix an error for `Style/OneLineConditional` when one of the branches contains a self keyword. ([@koic][])
* [#7825](https://github.com/rubocop/rubocop/issues/7825): Fix crash for `Layout/MultilineMethodCallIndentation` with key access to hash. ([@tejasbubane][])
* [#7831](https://github.com/rubocop/rubocop/issues/7831): Fix a false positive for `Style/HashEachMethods` when receiver is implicit. ([@koic][])

### Changes

* [#7797](https://github.com/rubocop/rubocop/pull/7797): Allow unicode-display_width dependency version 1.7.0. ([@yuritomanek][])
* [#7805](https://github.com/rubocop/rubocop/pull/7805): Change `AllowComments` option of `Lint/SuppressedException` to true by default. ([@koic][])
* [#7320](https://github.com/rubocop/rubocop/issues/7320): `Naming/MethodName` now flags `attr_reader/attr_writer/attr_accessor/attr`. ([@denys281][])
* [#7813](https://github.com/rubocop/rubocop/issues/7813): **(Breaking)** Remove `Lint/EndInMethod` cop. ([@tejasbubane][])

## 0.80.1 (2020-02-29)

### Bug fixes

* [#7719](https://github.com/rubocop/rubocop/issues/7719): Fix `Style/NestedParenthesizedCalls` cop for newline. ([@tejasbubane][])
* [#7709](https://github.com/rubocop/rubocop/issues/7709): Fix correction of `Style/RedundantCondition` when the else branch contains a range. ([@rrosenblum][])
* [#7682](https://github.com/rubocop/rubocop/issues/7682): Fix `Style/InverseMethods` autofix leaving parenthesis. ([@tejasbubane][])
* [#7745](https://github.com/rubocop/rubocop/issues/7745): Suppress a pending cop warnings when pending cop's department is disabled. ([@koic][])
* [#7759](https://github.com/rubocop/rubocop/issues/7759): Fix an error for `Layout/LineLength` cop when using lambda syntax that argument is not enclosed in parentheses. ([@koic][])

### Changes

* [#7765](https://github.com/rubocop/rubocop/pull/7765): When warning about a pending cop, display the version with the cop added. ([@koic][])

## 0.80.0 (2020-02-18)

### New features

* [#7693](https://github.com/rubocop/rubocop/pull/7693): NodePattern: Add `` ` `` for descendant search. ([@marcandre][])
* [#7577](https://github.com/rubocop/rubocop/pull/7577): Add `AllowGemfileRubyComment` configuration on `Layout/LeadingCommentSpace`. ([@cetinajero][])
* [#7663](https://github.com/rubocop/rubocop/pull/7663): Add new `Style/HashTransformKeys` and `Style/HashTransformValues` cops. ([@djudd][], [@eugeneius][])
* [#7619](https://github.com/rubocop/rubocop/issues/7619): Support auto-correct of legacy cop names for `Migration/DepartmentName`. ([@koic][])
* [#7659](https://github.com/rubocop/rubocop/pull/7659): `Layout/LineLength` auto-correct now breaks up long lines with blocks. ([@maxh][])
* [#7677](https://github.com/rubocop/rubocop/pull/7677): Add new `Style/HashEachMethods` cop for `Hash#each_key` and `Hash#each_value`. ([@jemmaissroff][])
* Add `BracesRequiredMethods` parameter to `Style/BlockDelimiters` to require braces for specific methods such as Sorbet's `sig`. ([@maxh][])
* [#7686](https://github.com/rubocop/rubocop/pull/7686): Add new `JUnitFormatter` formatter based on `rubocop-junit-formatter` gem. ([@koic][])
* [#7715](https://github.com/rubocop/rubocop/pull/7715): Add `Steepfile` to default `Include` list. ([@ybiquitous][])

### Bug fixes

* [#7644](https://github.com/rubocop/rubocop/issues/7644): Fix patterns with named wildcards in unions. ([@marcandre][])
* [#7639](https://github.com/rubocop/rubocop/pull/7639): Fix logical operator edge case in `omit_parentheses` style of `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])
* [#7661](https://github.com/rubocop/rubocop/pull/7661): Fix to return correct info from multi-line regexp. ([@Tietew][])
* [#7655](https://github.com/rubocop/rubocop/issues/7655): Fix an error when processing a regexp with a line break at the start of capture parenthesis. ([@koic][])
* [#7647](https://github.com/rubocop/rubocop/issues/7647): Fix an `undefined method on_numblock` error when using Ruby 2.7's numbered parameters. ([@hanachin][])
* [#7675](https://github.com/rubocop/rubocop/issues/7675): Fix a false negative for `Layout/SpaceBeforeFirstArg` when a vertical argument positions are aligned. ([@koic][])
* [#7688](https://github.com/rubocop/rubocop/issues/7688): Fix a bug in `Style/MethodCallWithArgsParentheses` that made `--auto-gen-config` crash. ([@buehmann][])
* [#7203](https://github.com/rubocop/rubocop/issues/7203): Fix an infinite loop error for `Style/TernaryParentheses` with `Style/RedundantParentheses` when using `EnforcedStyle: require_parentheses_when_complex`. ([@koic][])
* [#7708](https://github.com/rubocop/rubocop/issues/7708): Make it possible to use EOL `rubocop:disable` comments on comment lines. ([@jonas054][])
* [#7712](https://github.com/rubocop/rubocop/issues/7712): Fix an incorrect auto-correct for `Style/OrAssignment` when using `elsif` branch. ([@koic][])

### Changes

* [#7636](https://github.com/rubocop/rubocop/issues/7636): Remove `console` from `Lint/Debugger` to prevent false positives. ([@gsamokovarov][])
* [#7641](https://github.com/rubocop/rubocop/issues/7641): **(Breaking)** Remove `Style/BracesAroundHashParameters` cop. ([@pocke][])
* Add the method name to highlight area of `Layout/EmptyLineBetweenDefs` to help provide more context. ([@rrosenblum][])
* [#7652](https://github.com/rubocop/rubocop/pull/7652): Allow `pp` to allowed names of `Naming/MethodParameterName` cop in default config. ([@masarakki][])
* [#7309](https://github.com/rubocop/rubocop/pull/7309): Mark `Lint/UselessSetterCall` an "not safe" and improve documentation. ([@jonas054][])
* [#7723](https://github.com/rubocop/rubocop/pull/7723): Enable `Migration/DepartmentName` cop by default. ([@koic][])

## 0.79.0 (2020-01-06)

### New features

* [#7296](https://github.com/rubocop/rubocop/issues/7296): Recognize `console` and `binding.console` ([rails/web-console](https://github.com/rails/web-console)) calls in `Lint/Debuggers`. ([@gsamokovarov][])
* [#7567](https://github.com/rubocop/rubocop/pull/7567): Introduce new `pending` status for new cops. ([@Darhazer][], [@pirj][])
* [#7426](https://github.com/rubocop/rubocop/issues/7426): Add `always_true` style to Style/FrozenStringLiteralComment. ([@parkerfinch][], [@gfyoung][])

### Bug fixes

* [#7193](https://github.com/rubocop/rubocop/issues/7193): Prevent `Style/PercentLiteralDelimiters` from changing `%i` literals that contain escaped delimiters. ([@buehmann][])
* [#7590](https://github.com/rubocop/rubocop/issues/7590): Fix an error for `Layout/SpaceBeforeBlockBraces` when using with `EnforcedStyle: line_count_based` of `Style/BlockDelimiters` cop. ([@koic][])
* [#7569](https://github.com/rubocop/rubocop/issues/7569): Make `Style/YodaCondition` accept `__FILE__ == $0`. ([@koic][])
* [#7576](https://github.com/rubocop/rubocop/issues/7576): Fix an error for `Gemspec/OrderedDependencies` when using a local variable in an argument of dependent gem. ([@koic][])
* [#7595](https://github.com/rubocop/rubocop/issues/7595): Make `Style/NumericPredicate` aware of ignored methods when specifying ignored methods. ([@koic][])
* [#7607](https://github.com/rubocop/rubocop/issues/7607): Fix `Style/FrozenStringLiteralComment` infinite loop when magic comments are newline-separated. ([@pirj][])
* [#7602](https://github.com/rubocop/rubocop/pull/7602): Ensure proper handling of Ruby 2.7 syntax. ([@drenmi][])
* [#7620](https://github.com/rubocop/rubocop/issues/7620): Fix a false positive for `Migration/DepartmentName` when a disable comment contains a plain comment. ([@koic][])
* [#7616](https://github.com/rubocop/rubocop/issues/7616): Fix an incorrect auto-correct for `Style/MultilineWhenThen` for when statement with then is an array or a hash. ([@koic][])
* [#7628](https://github.com/rubocop/rubocop/issues/7628): Fix an incorrect auto-correct for `Layout/MultilineBlockLayout` removing trailing comma with single argument. ([@pawptart][])
* [#7627](https://github.com/rubocop/rubocop/issues/7627): Fix a false negative for `Migration/DepartmentName` when there is space around `:` (e.g. `# rubocop : disable`). ([@koic][])

### Changes

* [#7287](https://github.com/rubocop/rubocop/issues/7287): `Style/FrozenStringLiteralComment` is now considered unsafe. ([@buehmann][])

## 0.78.0 (2019-12-18)

### New features

* [#7528](https://github.com/rubocop/rubocop/pull/7528): Add new `Lint/NonDeterministicRequireOrder` cop. ([@mangara][])
* [#7559](https://github.com/rubocop/rubocop/pull/7559): Add `EnforcedStyleForExponentOperator` parameter to `Layout/SpaceAroundOperators` cop. ([@khiav223577][])

### Bug fixes

* [#7530](https://github.com/rubocop/rubocop/issues/7530): Typo in `Style/TrivialAccessors`'s `AllowedMethods`. ([@movermeyer][])
* [#7532](https://github.com/rubocop/rubocop/issues/7532): Fix an error for `Style/TrailingCommaInArguments` when using an anonymous function with multiple line arguments with `EnforcedStyleForMultiline: consistent_comma`. ([@koic][])
* [#7534](https://github.com/rubocop/rubocop/issues/7534): Fix an incorrect auto-correct for `Style/BlockDelimiters` cop and `Layout/SpaceBeforeBlockBraces` cop with `EnforcedStyle: no_space` when using multiline braces. ([@koic][])
* [#7231](https://github.com/rubocop/rubocop/issues/7231): Fix the exit code to be `2` rather when `0` when the config file contains an unknown cop. ([@jethroo][])
* [#7513](https://github.com/rubocop/rubocop/issues/7513): Fix abrupt error on auto-correcting with `--disable-uncorrectable`. ([@tejasbubane][])
* [#7537](https://github.com/rubocop/rubocop/issues/7537): Fix a false positive for `Layout/SpaceAroundOperators` when using a Rational literal with `/` (e.g. `2/3r`). ([@koic][])
* [#7029](https://github.com/rubocop/rubocop/issues/7029): Make `Style/Attr` not flag offense for custom `attr` method. ([@tejasbubane][])
* [#7574](https://github.com/rubocop/rubocop/issues/7574): Fix a corner case that made `Style/GuardClause` crash. ([@buehmann][])

### Changes

* [#7514](https://github.com/rubocop/rubocop/pull/7514): Expose correctable status on offense and in formatters. ([@tyler-ball][])
* [#7542](https://github.com/rubocop/rubocop/pull/7542): **(Breaking)** Move `LineLength` cop from `Metrics` department to `Layout` department. ([@koic][])

## 0.77.0 (2019-11-27)

### Bug fixes

* [#7493](https://github.com/rubocop/rubocop/issues/7493): Fix `Style/RedundantReturn` to inspect conditional constructs that are preceded by other statements. ([@buehmann][])
* [#7509](https://github.com/rubocop/rubocop/issues/7509): Fix `Layout/SpaceInsideArrayLiteralBrackets` to correct empty lines. ([@ayacai115][])
* [#7517](https://github.com/rubocop/rubocop/issues/7517): `Style/SpaceAroundKeyword` allows `::` after `super`. ([@ozydingo][])
* [#7515](https://github.com/rubocop/rubocop/issues/7515): Fix a false negative for `Style/RedundantParentheses` when calling a method with safe navigation operator. ([@koic][])
* [#7477](https://github.com/rubocop/rubocop/issues/7477): Fix line length auto-correct for semicolons in string literals. ([@maxh][])
* [#7522](https://github.com/rubocop/rubocop/pull/7522): Fix a false-positive edge case (`n % 2 == 2`) for `Style/EvenOdd`. ([@buehmann][])
* [#7506](https://github.com/rubocop/rubocop/issues/7506): Make `Style/IfUnlessModifier` respect all settings in `Metrics/LineLength`. ([@jonas054][])

### Changes

* [#7077](https://github.com/rubocop/rubocop/issues/7077): **(Breaking)** Further standardisation of cop names. ([@scottmatthewman][])
* [#7469](https://github.com/rubocop/rubocop/pull/7469): **(Breaking)** Replace usages of the terms `Whitelist` and `Blacklist` with better alternatives. ([@koic][])
* [#7502](https://github.com/rubocop/rubocop/pull/7502): Remove `SafeMode` module. ([@koic][])

## 0.76.0 (2019-10-28)

### Bug fixes

* [#7439](https://github.com/rubocop/rubocop/issues/7439): Make `Style/FormatStringToken` ignore percent escapes (`%%`). ([@buehmann][])
* [#7438](https://github.com/rubocop/rubocop/issues/7438): Fix assignment edge-cases in `Layout/MultilineAssignmentLayout`. ([@gsamokovarov][])
* [#7449](https://github.com/rubocop/rubocop/pull/7449): Make `Style/IfUnlessModifier` respect `rubocop:disable` comments for `Metrics/LineLength`. ([@jonas054][])
* [#7442](https://github.com/rubocop/rubocop/issues/7442): Fix an incorrect auto-correct for `Style/SafeNavigation` when an object check followed by a method call with a comment at EOL. ([@koic][])
* [#7434](https://github.com/rubocop/rubocop/issues/7434): Fix an incorrect auto-correct for `Style/MultilineWhenThen` when the body of `when` branch starts with `then`. ([@koic][])
* [#7464](https://github.com/rubocop/rubocop/pull/7464): Let `Performance/StartWith` and `Performance/EndWith` correct regexes that contain forward slashes. ([@eugeneius][])

### Changes

* [#7465](https://github.com/rubocop/rubocop/pull/7465): Add `os` to allowed names of `Naming/UncommunicativeMethodParamName` cop in default config. ([@nijikon][])
* [#7446](https://github.com/rubocop/rubocop/issues/7446): Add `merge` to list of non-mutating methods. ([@cstyles][])
* [#7077](https://github.com/rubocop/rubocop/issues/7077): **(Breaking)** Rename `Unneeded*` cops to `Redundant*` (e.g., `Style/UnneededPercentQ` becomes `Style/RedundantPercentQ`). ([@scottmatthewman][])
* [#7396](https://github.com/rubocop/rubocop/issues/7396): Display assignments, branches, and conditions values with the offense. ([@avmnu-sng][])

## 0.75.1 (2019-10-14)

### Bug fixes

* [#7391](https://github.com/rubocop/rubocop/issues/7391): Support pacman formatter on Windows. ([@laurenball][])
* [#7407](https://github.com/rubocop/rubocop/issues/7407): Make `Style/FormatStringToken` work inside hashes. ([@buehmann][])
* [#7389](https://github.com/rubocop/rubocop/issues/7389): Fix an issue where passing a formatter might result in an error depending on what character it started with. ([@jfhinchcliffe][])
* [#7397](https://github.com/rubocop/rubocop/issues/7397): Fix extra comments being added to the correction of `Style/SafeNavigation`. ([@rrosenblum][])
* [#7378](https://github.com/rubocop/rubocop/pull/7378): Fix heredoc edge cases in `Layout/EmptyLineAfterGuardClause`. ([@gsamokovarov][])
* [#7404](https://github.com/rubocop/rubocop/issues/7404): Fix a false negative for `Layout/IndentAssignment` when multiple assignment with line breaks on each line. ([@koic][])

### Changes

* [#7410](https://github.com/rubocop/rubocop/issues/7410): `Style/FormatStringToken` now finds unannotated format sequences in `printf` arguments. ([@buehmann][])
* [#6964](https://github.com/rubocop/rubocop/issues/6964): Set default `IgnoreCopDirectives` to `true` for `Metrics/LineLength`. ([@jdkaplan][])

## 0.75.0 (2019-09-30)

### New features

* [#7274](https://github.com/rubocop/rubocop/issues/7274): Add new `Lint/SendWithMixinArgument` cop. ([@koic][])
* [#7272](https://github.com/rubocop/rubocop/pull/7272): Show warning message if passed string to `Enabled`, `Safe`, `SafeAuto-Correct`, and `Auto-Correct` keys in .rubocop.yml. ([@unasuke][])
* [#7295](https://github.com/rubocop/rubocop/pull/7295): Make it possible to set `StyleGuideBaseURL` per department. ([@koic][])
* [#7301](https://github.com/rubocop/rubocop/pull/7301): Add check for calls to `remote_byebug` to `Lint/Debugger` cop. ([@riley-klingler][])
* [#7321](https://github.com/rubocop/rubocop/issues/7321): Allow YAML aliases in `.rubocop.yml`. ([@raymondfallon][])
* [#7317](https://github.com/rubocop/rubocop/pull/7317): Add new formatter `pacman`. ([@crojasaragonez][])
* [#6075](https://github.com/rubocop/rubocop/issues/6075): Support `IgnoredPatterns` option for `Naming/MethodName` cop. ([@koic][])
* [#7335](https://github.com/rubocop/rubocop/pull/7335): Add todo as an alias to disable. `--disable-uncorrectable` will now disable cops using `rubocop:todo` instead of `rubocop:disable`. ([@desheikh][])

### Bug fixes

* [#7391](https://github.com/rubocop/rubocop/issues/7391): Support pacman formatter on Windows. ([@laurenball][])
* [#7256](https://github.com/rubocop/rubocop/issues/7256): Fix an error of `Style/RedundantParentheses` on method calls where the first argument begins with a hash literal. ([@halfwhole][])
* [#7263](https://github.com/rubocop/rubocop/issues/7263): Make `Layout/SpaceInsideArrayLiteralBrackets` properly handle tab-indented arrays. ([@buehmann][])
* [#7252](https://github.com/rubocop/rubocop/issues/7252): Prevent infinite loops by making `Layout/SpaceInsideStringInterpolation` skip over interpolations that start or end with a line break. ([@buehmann][])
* [#7262](https://github.com/rubocop/rubocop/issues/7262): `Lint/FormatParameterMismatch` did not recognize named format sequences like `%.2<name>f` where the name appears after some modifiers. ([@buehmann][])
* [#7253](https://github.com/rubocop/rubocop/issues/7253): Fix an error for `Lint/NumberConversion` when `#to_i` called without a receiver. ([@koic][])
* [#7271](https://github.com/rubocop/rubocop/issues/7271), [#6498](https://github.com/rubocop/rubocop/issues/6498): Fix an interference between `Style/TrailingCommaIn*Literal` and `Layout/Multiline*BraceLayout` for arrays and hashes. ([@buehmann][])
* [#7241](https://github.com/rubocop/rubocop/issues/7241): Make `Style/FrozenStringLiteralComment` match only true & false. ([@tejasbubane][])
* [#7290](https://github.com/rubocop/rubocop/issues/7290): Handle inner conditional inside `else` in `Style/ConditionalAssignment`. ([@jonas054][])
* [#5788](https://github.com/rubocop/rubocop/issues/5788): Allow block arguments on separate lines if line would be too long in `Layout/MultilineBlockLayout`. ([@jonas054][])
* [#7305](https://github.com/rubocop/rubocop/issues/7305): Register `Style/BlockDelimiters` offense when block result is assigned to an attribute. ([@mvz][])
* [#4802](https://github.com/rubocop/rubocop/issues/4802): Don't leave any `Lint/UnneededCopEnableDirective` offenses undetected/uncorrected. ([@jonas054][])
* [#7326](https://github.com/rubocop/rubocop/issues/7326): Fix a false positive for `Style/AccessModifierDeclarations` when access modifier name is used for hash literal value. ([@koic][])
* [#3591](https://github.com/rubocop/rubocop/issues/3591): Handle modifier `if`/`unless` correctly in `Lint/UselessAssignment`. ([@jonas054][])
* [#7161](https://github.com/rubocop/rubocop/issues/7161): Fix `Style/SafeNavigation` cop for preserve comments inside if expression. ([@tejasbubane][])
* [#5212](https://github.com/rubocop/rubocop/issues/5212): Avoid false positive for braces that are needed to preserve semantics in `Style/BracesAroundHashParameters`. ([@jonas054][])
* [#7353](https://github.com/rubocop/rubocop/issues/7353): Fix a false positive for `Style/RedundantSelf` when receiver and multiple assigned lvalue have the same name. ([@koic][])
* [#7353](https://github.com/rubocop/rubocop/issues/7353): Fix a false positive for `Style/RedundantSelf` when a self receiver is used as a method argument. ([@koic][])
* [#7358](https://github.com/rubocop/rubocop/issues/7358): Fix an incorrect auto-correct for `Style/NestedModifier` when parentheses are required in method arguments. ([@koic][])
* [#7361](https://github.com/rubocop/rubocop/issues/7361): Fix a false positive for `Style/TernaryParentheses` when only the closing parenthesis is used in the last line of condition. ([@koic][])
* [#7369](https://github.com/rubocop/rubocop/issues/7369): Fix an infinite loop error for `Layout/IndentAssignment` with `Layout/IndentFirstArgument` when using multiple assignment. ([@koic][])
* [#7177](https://github.com/rubocop/rubocop/issues/7177), [#7370](https://github.com/rubocop/rubocop/issues/7370): When correcting alignment, do not insert spaces into string literals. ([@buehmann][])
* [#7367](https://github.com/rubocop/rubocop/issues/7367): Fix an error for `Style/OrAssignment` cop when `then` branch body is empty. ([@koic][])
* [#7363](https://github.com/rubocop/rubocop/issues/7363): Fix an incorrect auto-correct for `Layout/SpaceInsideBlockBraces` and `Style/BlockDelimiters` when using multiline empty braces. ([@koic][])
* [#7212](https://github.com/rubocop/rubocop/issues/7212): Fix a false positive for `Layout/EmptyLinesAroundAccessModifier` and `UselessAccessModifier` when using method with the same name as access modifier around a method definition. ([@koic][])

### Changes

* [#7312](https://github.com/rubocop/rubocop/pull/7312): Mark `Style/StringHashKeys` as unsafe. ([@prathamesh-sonpatki][])
* [#7275](https://github.com/rubocop/rubocop/issues/7275): Make `Style/VariableName` aware argument names when invoking a method. ([@koic][])
* [#3534](https://github.com/rubocop/rubocop/issues/3534): Make `Style/IfUnlessModifier` report and auto-correct modifier lines that are too long. ([@jonas054][])
* [#7261](https://github.com/rubocop/rubocop/issues/7261): `Style/FrozenStringLiteralComment` no longer inserts an empty line after the comment. This is left to `Layout/EmptyLineAfterMagicComment`. ([@buehmann][])
* [#7091](https://github.com/rubocop/rubocop/issues/7091): `Style/FormatStringToken` now detects format sequences with flags and modifiers. ([@buehmann][])
* [#7319](https://github.com/rubocop/rubocop/pull/7319): Rename `IgnoredMethodPatterns` option to `IgnoredPatterns` option for `Style/MethodCallWithArgsParentheses`. ([@koic][])
* [#7345](https://github.com/rubocop/rubocop/issues/7345): Mark unsafe for `Style/YodaCondition`. ([@koic][])

## 0.74.0 (2019-07-31)

### New features

* [#7219](https://github.com/rubocop/rubocop/issues/7219): Support auto-correct for `Lint/ErbNewArguments`. ([@koic][])

### Bug fixes

* [#7217](https://github.com/rubocop/rubocop/pull/7217): Make `Style/TrailingMethodEndStatement` work on more than the first `def`. ([@buehmann][])
* [#7190](https://github.com/rubocop/rubocop/issues/7190): Support lower case drive letters on Windows. ([@jonas054][])
* Fix the auto-correction of `Lint/UnneededSplatExpansion` when the splat expansion of `Array.new` with a block is assigned to a variable. ([@rrosenblum][])
* [#5628](https://github.com/rubocop/rubocop/issues/5628): Fix an error of `Layout/SpaceInsideStringInterpolation` on interpolations with multiple statements. ([@buehmann][])
* [#7128](https://github.com/rubocop/rubocop/issues/7128): Make `Metrics/LineLength` aware of shebang. ([@koic][])
* [#6861](https://github.com/rubocop/rubocop/issues/6861): Fix a false positive for `Layout/IndentationWidth` when using `EnforcedStyle: outdent` of `Layout/AccessModifierIndentation`. ([@koic][])
* [#7235](https://github.com/rubocop/rubocop/issues/7235): Fix an error where `Style/ConditionalAssignment` would swallow a nested `if` condition. ([@buehmann][])
* [#7242](https://github.com/rubocop/rubocop/issues/7242): Make `Style/ConstantVisibility` work on non-trivial class and module bodies. ([@buehmann][])

### Changes

* [#5265](https://github.com/rubocop/rubocop/issues/5265): Improved `Layout/ExtraSpacing` cop to handle nested consecutive assignments. ([@jfelchner][])
* [#7215](https://github.com/rubocop/rubocop/issues/7215): Make it clear what's wrong in the message from `Style/GuardClause`. ([@jonas054][])
* [#7245](https://github.com/rubocop/rubocop/pull/7245): Make cops detect string interpolations in more contexts: inside of backticks, regular expressions, and symbols. ([@buehmann][])
* Deprecate the `SafeMode` option. Users will need to upgrade `rubocop-performance` to 1.5.0+ before the `SafeMode` module is removed. ([@rrosenblum][])

## 0.73.0 (2019-07-16)

### New features

* Add `AllowDoxygenCommentStyle` configuration on `Layout/LeadingCommentSpace`. ([@anthony-robin][])
* [#7114](https://github.com/rubocop/rubocop/pull/7114): Add `MultilineWhenThen` cop. ([@okuramasafumi][])
* [#4127](https://github.com/rubocop/rubocop/pull/4127): Add `--disable-uncorrectable` flag to generate `rubocop:disable` comments. ([@vergenzt][], [@jonas054][])

### Bug fixes

* [#7170](https://github.com/rubocop/rubocop/issues/7170): Fix a false positive for `Layout/RescueEnsureAlignment` when def line is preceded with `private_class_method`. ([@tatsuyafw][])
* [#7186](https://github.com/rubocop/rubocop/issues/7186): Fix a false positive for `Style/MixinUsage` when using inside multiline block and `if` condition is after `include`. ([@koic][])
* [#7099](https://github.com/rubocop/rubocop/issues/7099): Fix an error of `Layout/RescueEnsureAlignment` on assigned blocks. ([@tatsuyafw][])
* [#5088](https://github.com/rubocop/rubocop/issues/5088): Fix an error of `Layout/MultilineMethodCallIndentation` on method chains inside an argument. ([@buehmann][])
* [#4719](https://github.com/rubocop/rubocop/issues/4719): Make `Layout/Tab` detect tabs between string literals. ([@buehmann][])
* [#7203](https://github.com/rubocop/rubocop/pull/7203): Fix an infinite loop error for `Layout/SpaceInsideBlockBraces` when `EnforcedStyle: no_space` with `SpaceBeforeBlockParameters: false` are set in multiline block. ([@koic][])
* [#6653](https://github.com/rubocop/rubocop/issues/6653): Fix a bug where `Layout/IndentHeredoc` would remove empty lines when auto-correcting heredocs. ([@buehmann][])

### Changes

* [#7181](https://github.com/rubocop/rubocop/pull/7181): Sort analyzed file alphabetically. ([@pocke][])
* [#7188](https://github.com/rubocop/rubocop/pull/7188): Include inspected file location in auto-correction error. ([@pocke][])

## 0.72.0 (2019-06-25)

### New features

* [#7137](https://github.com/rubocop/rubocop/issues/7137): Add new `Gemspec/RubyVersionGlobalsUsage` cop. ([@malyshkosergey][])
* [#7150](https://github.com/rubocop/rubocop/pull/7150): Add `AllowIfModifier` option to `Style/IfInsideElse` cop. ([@koic][])
* [#7153](https://github.com/rubocop/rubocop/pull/7153): Add new cop `Style/FloatDivision` that checks coercion. ([@tejasbubane][])

### Bug fixes

* [#7121](https://github.com/rubocop/rubocop/pull/7121): Fix `Style/TernaryParentheses` cop to allow safe navigation operator without parentheses. ([@timon][])
* [#7063](https://github.com/rubocop/rubocop/issues/7063): Fix auto-correct in `Style/TernaryParentheses` cop. ([@parkerfinch][])
* [#7106](https://github.com/rubocop/rubocop/issues/7106): Fix an error for `Lint/NumberConversion` when `#to_i` called on a variable on a hash. ([@koic][])
* [#7107](https://github.com/rubocop/rubocop/issues/7107): Fix parentheses offence for numeric arguments with an operator in `Style/MethodCallWithArgsParentheses`. ([@gsamokovarov][])
* [#7119](https://github.com/rubocop/rubocop/pull/7119): Fix cache with non UTF-8 offense message. ([@pocke][])
* [#7118](https://github.com/rubocop/rubocop/pull/7118): Fix `Style/WordArray` with `encoding: binary` magic comment and non-ASCII string. ([@pocke][])
* [#7159](https://github.com/rubocop/rubocop/issues/7159): Fix an error for `Lint/DuplicatedKey` when using endless range. ([@koic][])
* [#7151](https://github.com/rubocop/rubocop/issues/7151): Fix `Style/WordArray` to also consider words containing hyphens. ([@fwitzke][])
* [#6893](https://github.com/rubocop/rubocop/issues/6893): Handle implicit rescue correctly in `Naming/RescuedExceptionsVariableName`. ([@pocke][], [@anthony-robin][])
* [#7165](https://github.com/rubocop/rubocop/issues/7165): Fix an auto-correct error for `Style/ConditionalAssignment` when without `else` branch'. ([@koic][])
* [#7171](https://github.com/rubocop/rubocop/issues/7171): Fix an error for `Style/SafeNavigation` when using `unless nil?` as a safeguarded'. ([@koic][])
* [#7130](https://github.com/rubocop/rubocop/pull/7130): Skip auto-correct in `Style/FormatString` if second argument to `String#%` is a variable. ([@tejasbubane][])
* [#7171](https://github.com/rubocop/rubocop/issues/7171): Fix an error for `Style/SafeNavigation` when using `unless nil?` as a safeguarded'. ([@koic][])

### Changes

* [#5976](https://github.com/rubocop/rubocop/issues/5976): Remove Rails cops. ([@koic][])
* [#5976](https://github.com/rubocop/rubocop/issues/5976): Remove `rubocop -R/--rails` option. ([@koic][])
* [#7113](https://github.com/rubocop/rubocop/pull/7113): Rename `EnforcedStyle: rails` to `EnabledStyle: indented_internal_methods` for `Layout/IndentationConsistency`. ([@koic][])

## 0.71.0 (2019-05-30)

### New features

* [#7084](https://github.com/rubocop/rubocop/pull/7084): Permit to specify TargetRubyVersion 2.7. ([@koic][])
* [#7092](https://github.com/rubocop/rubocop/pull/7092): Node patterns can now use `*`, `+` and `?` for repetitions. ([@marcandre][])

### Bug fixes

* [#7066](https://github.com/rubocop/rubocop/issues/7066): Fix `Layout/AlignHash` when mixed Hash styles are used. ([@rmm5t][])
* [#7073](https://github.com/rubocop/rubocop/issues/7073): Fix false positive in `Naming/RescuedExceptionsVariableName` cop. ([@tejasbubane][])
* [#7090](https://github.com/rubocop/rubocop/pull/7090): Fix `Layout/EmptyLinesAroundBlockBody` for multi-line method calls. ([@eugeneius][])
* [#6936](https://github.com/rubocop/rubocop/issues/6936): Fix `Layout/MultilineMethodArgumentLineBreaks` when bracket hash assignment on multiple lines. ([@maxh][])
* Mark `Layout/HeredocArgumentClosingParenthesis` incompatible with `Style/TrailingCommaInArguments`. ([@maxh][])

### Changes

* [#5976](https://github.com/rubocop/rubocop/issues/5976): Warn for Rails Cops. ([@koic][])
* [#5976](https://github.com/rubocop/rubocop/issues/5976): Warn for `rubocop -R/--rails` option. ([@koic][])
* [#7078](https://github.com/rubocop/rubocop/issues/7078): Mark `Lint/PercentStringArray` as unsafe. ([@mikegee][])

## 0.70.0 (2019-05-21)

### New features

* [#6649](https://github.com/rubocop/rubocop/pull/6649): `Layout/AlignHash` supports list of options. ([@stoivo][])
* Add `IgnoreMethodPatterns` config option to `Style/MethodCallWithArgsParentheses`. ([@tejasbubane][])
* [#7059](https://github.com/rubocop/rubocop/pull/7059): Add `EnforcedStyle` to `Layout/EmptyLinesAroundAccessModifier`. ([@koic][])
* [#7052](https://github.com/rubocop/rubocop/issues/7052): Add `AllowComments` option to ` Lint/HandleExceptions`. ([@tejasbubane][])

### Bug fixes

* [#7013](https://github.com/rubocop/rubocop/pull/7013): Respect DisabledByDefault for custom cops. ([@XrXr][])
* [#7043](https://github.com/rubocop/rubocop/issues/7043): Prevent RDoc error when installing RuboCop 0.69.0 on Ubuntu. ([@koic][])
* [#7023](https://github.com/rubocop/rubocop/issues/7023): Auto-Correction for `Lint/NumberConversion`. ([@Bhacaz][])

### Changes

* [#6359](https://github.com/rubocop/rubocop/issues/6359): Mark `Style/PreferredHashMethods` as unsafe. ([@tejasbubane][])

## 0.69.0 (2019-05-13)

### New features

* Add support for subclassing using `Class.new` to `Lint/InheritException`. ([@houli][])
* [#6779](https://github.com/rubocop/rubocop/issues/6779): Add new cop `Style/NegatedUnless` that checks for unless with negative condition. ([@tejasbubane][])

### Bug fixes

* [#6900](https://github.com/rubocop/rubocop/issues/6900): Fix `Rails/TimeZone` auto-correct `Time.current` to `Time.zone.now`. ([@vfonic][])
* [#6900](https://github.com/rubocop/rubocop/issues/6900): Fix `Rails/TimeZone` to prefer `Time.zone.#{method}` over other acceptable corrections. ([@vfonic][])
* [#7007](https://github.com/rubocop/rubocop/pull/7007): Fix `Style/BlockDelimiters` with `braces_for_chaining` style false positive, when chaining using safe navigation. ([@Darhazer][])
* [#6880](https://github.com/rubocop/rubocop/issues/6880): Fix `.rubocop` file parsing. ([@hoshinotsuyoshi][])
* [#5782](https://github.com/rubocop/rubocop/issues/5782): Do not auto-correct `Lint/UnifiedInteger` if `TargetRubyVersion < 2.4`. ([@lavoiesl][])
* [#6387](https://github.com/rubocop/rubocop/issues/6387): Prevent `Lint/NumberConversion` from reporting error with `Time`/`DateTime`. ([@tejasbubane][])
* [#6980](https://github.com/rubocop/rubocop/issues/6980): Fix `Style/StringHashKeys` to allow string as keys for hash arguments to gsub methods. ([@tejasbubane][])
* [#6969](https://github.com/rubocop/rubocop/issues/6969): Fix a false positive with block methods in `Style/InverseMethods`. ([@dduugg][])
* [#6729](https://github.com/rubocop/rubocop/pull/6729): Handle array spread for `change_column_default` in `Rails/ReversibleMigration` cop. ([@tejasbubane][])
* [#7033](https://github.com/rubocop/rubocop/issues/7033): Fix an error for `Layout/EmptyLineAfterGuardClause` when guard clause is a ternary operator. ([@koic][])
* Replace `Time.zone.current` with `Time.zone.today` on `Rails::Date` cop message. ([@vfonic][])

### Changes

* [#6945](https://github.com/rubocop/rubocop/issues/6945): Drop support for Ruby 2.2. ([@koic][])
* [#6945](https://github.com/rubocop/rubocop/issues/6945): Set default `EnforcedStyle` to `squiggly` option for `Layout/IndentHeredoc` and `auto_detection` option is removed. ([@koic][])
* [#6945](https://github.com/rubocop/rubocop/issues/6945): Set default `EnforcedStyle` to `always` option for `Style/FrozenStringLiteralComment` and `when_needed` option is removed. ([@koic][])
* [#7027](https://github.com/rubocop/rubocop/pull/7027): Allow `unicode/display_width` dependency version 1.6.0. ([@tagliala][])

## 0.68.1 (2019-04-30)

### Bug fixes

* [#6993](https://github.com/rubocop/rubocop/pull/6993): Allowing for empty if blocks, preventing `Style/SafeNavigation` from crashing. ([@RicardoTrindade][])
* [#6995](https://github.com/rubocop/rubocop/pull/6995): Fix an incorrect auto-correct for `Style/RedundantParentheses` when enclosed in parentheses at `while-post` or `until-post`. ([@koic][])
* [#6996](https://github.com/rubocop/rubocop/pull/6996): Fix a false positive for `Style/RedundantFreeze` when freezing the result of `String#*`. ([@bquorning][])
* [#6998](https://github.com/rubocop/rubocop/pull/6998): Fix auto-correct of `Naming/RescuedExceptionsVariableName` to also rename all references to the variable. ([@Darhazer][])
* [#6992](https://github.com/rubocop/rubocop/pull/6992): Fix unknown default configuration for `Layout/IndentFirstParameter` cop. ([@drenmi][])
* [#6972](https://github.com/rubocop/rubocop/issues/6972): Fix a false positive for `Style/MixinUsage` when using inside block and `if` condition is after `include`. ([@koic][])
* [#6738](https://github.com/rubocop/rubocop/issues/6738): Prevent auto-correct conflict of `Style/Next` and `Style/SafeNavigation`. ([@hoshinotsuyoshi][])
* [#6847](https://github.com/rubocop/rubocop/pull/6847): Fix `Style/BlockDelimiters` to properly check if the node is chained when `braces_for_chaining` is set. ([@att14][])


## 0.68.0 (2019-04-29)

### New features

* [#6973](https://github.com/rubocop/rubocop/pull/6973): Add `always_braces` to `Style/BlockDelimiter`. ([@iGEL][])
* [#6841](https://github.com/rubocop/rubocop/issues/6841): Node patterns can now match children in any order using `<>`. ([@marcandre][])
* [#6928](https://github.com/rubocop/rubocop/pull/6928): Add `--init` option for generate `.rubocop.yml` file in the current directory. ([@koic][])
* Add new `Layout/HeredocArgumentClosingParenthesis` cop. ([@maxh][])
* [#6895](https://github.com/rubocop/rubocop/pull/6895): Add support for XDG config home for user-config. ([@Mange][], [@tejasbubane][])
* Add initial auto-correction support to `Metrics/LineLength`. ([@maxh][])
* Add `Layout/IndentFirstParameter`. ([@maxh][])
* [#6974](https://github.com/rubocop/rubocop/issues/6974): Make `Layout/FirstMethodArgumentLineBreak` aware of calling using `super`. ([@koic][])
* Add new `Lint/HeredocMethodCallPosition` cop. ([@maxh][])


### Bug fixes

* Do not annotate message with cop name in JSON output. ([@elebow][])
* [#6914](https://github.com/rubocop/rubocop/issues/6914): Fix an error for `Rails/RedundantAllowNil` when with interpolations. ([@Blue-Pix][])
* [#6888](https://github.com/rubocop/rubocop/issues/6888): Fix an error for `Rails/ActiveRecordOverride ` when no `parent_class` present. ([@diachini][])
* [#6941](https://github.com/rubocop/rubocop/issues/6941): Add missing absence validations to `Rails/Validation`. ([@jmanian][])
* [#6926](https://github.com/rubocop/rubocop/issues/6926): Allow nil values to unset config defaults. ([@dduugg][])
* [#6946](https://github.com/rubocop/rubocop/pull/6946): Allow `Rails/ReflectionClassName` to use string interpolation for `class_name`. ([@r7kamura][])
* [#6778](https://github.com/rubocop/rubocop/issues/6778): Fix a false positive in `Style/HashSyntax` cop when a hash key is an interpolated string and EnforcedStyle is ruby19_no_mixed_keys. ([@tatsuyafw][])
* [#6902](https://github.com/rubocop/rubocop/issues/6902): Fix a bug where `Naming/RescuedExceptionsVariableName` would handle an only first rescue for multiple rescue groups. ([@tatsuyafw][])
* [#6860](https://github.com/rubocop/rubocop/issues/6860): Prevent auto-correct conflict of `Style/InverseMethods` and `Style/Not`. ([@hoshinotsuyoshi][])
* [#6935](https://github.com/rubocop/rubocop/issues/6935): `Layout/AccessModifierIndentation` should ignore access modifiers that apply to specific methods. ([@deivid-rodriguez][])
* [#6956](https://github.com/rubocop/rubocop/issues/6956): Prevent auto-correct conflict of `Lint/Lambda` and `Lint/UnusedBlockArgument`. ([@koic][])
* [#6915](https://github.com/rubocop/rubocop/issues/6915): Fix false positive in `Style/SafeNavigation` when a modifier if is safe guarding a method call being passed to `break`, `fail`, `next`, `raise`, `return`, `throw`, and `yield`. ([@rrosenblum][])
* [#6822](https://github.com/rubocop/rubocop/issues/6822): Fix Lint/LiteralInInterpolation auto-correction for single quotes. ([@hoshinotsuyoshi][])
* [#6985](https://github.com/rubocop/rubocop/issues/6985): Fix an incorrect auto-correct for `Lint/LiteralInInterpolation` if contains array percent literal. ([@yakout][])
* [#7003](https://github.com/rubocop/rubocop/pull/7003): Fix an incorrect auto-correct for `Style/InverseMethods` when using `BasicObject#!`. ([@koic][])

### Changes

* [#6966](https://github.com/rubocop/rubocop/pull/6966): Mark Rails/TimeZone as unsafe. ([@vfonic][])
* [#5977](https://github.com/rubocop/rubocop/issues/5977): Remove Performance cops. ([@koic][])
* Add auto-correction to `Naming/RescuedExceptionsVariableName`. ([@anthony-robin][])
* [#6903](https://github.com/rubocop/rubocop/issues/6903): Handle variables prefixed with `_` in `Naming/RescuedExceptionsVariableName` cop. ([@anthony-robin][])
* [#6917](https://github.com/rubocop/rubocop/issues/6917): Bump Bundler dependency to >= 1.15.0. ([@koic][])
* Add `--auto-gen-only-exclude` to the command outputted in `rubocop_todo.yml` if the option is specified. ([@dvandersluis][])
* [#6887](https://github.com/rubocop/rubocop/pull/6887): Allow `Lint/UnderscorePrefixedVariableName` cop to be configured to allow use of block keyword args. ([@dduugg][])
* [#6885](https://github.com/rubocop/rubocop/pull/6885): Revert adding psych >= 3.1 as runtime dependency. ([@andreaseger][])
* Rename `Layout/FirstParameterIndentation` to `Layout/IndentFirstArgument`. ([@maxh][])
* Extract method call argument alignment behavior from `Layout/AlignParameters` into `Layout/AlignArguments`. ([@maxh][])
* Rename `IndentArray` and `IndentHash` to `IndentFirstArrayElement` and `IndentFirstHashElement`. ([@maxh][])

## 0.67.2 (2019-04-05)

### Bug fixes

* [#6882](https://github.com/rubocop/rubocop/issues/6882): Fix an error for `Rails/RedundantAllowNil` when not using both `allow_nil` and `allow_blank`. ([@koic][])

## 0.67.1 (2019-04-04)

### Changes

* [#6881](https://github.com/rubocop/rubocop/pull/6881): Set default `PreferredName` to `e` for `Naming/RescuedExceptionsVariableName`. ([@koic][])

## 0.67.0 (2019-04-04)

### New features

* [#5184](https://github.com/rubocop/rubocop/issues/5184): Add new multiline element line break cops. ([@maxh][])
* Add new cop `Rails/ActiveRecordOverride` that checks for overriding Active Record methods instead of using callbacks. ([@elebow][])
* Add new cop `Rails/RedundantAllowNil` that checks for cases when `allow_blank` makes `allow_nil` unnecessary in model validations. ([@elebow][])
* Add new `Naming/RescuedExceptionsVariableName` cop. ([@AdrienSldy][])

### Bug fixes

* [#6761](https://github.com/rubocop/rubocop/issues/6761): Make `Naming/UncommunicativeMethodParamName` account for param names prefixed with underscores. ([@thomthom][])
* [#6855](https://github.com/rubocop/rubocop/pull/6855): Fix an exception in `Rails/RedundantReceiverInWithOptions` when the body is empty. ([@ericsullivan][])
* [#6856](https://github.com/rubocop/rubocop/pull/6856): Fix auto-correction for `Style/BlockComments` when the file is missing a trailing blank line. ([@ericsullivan][])
* [#6858](https://github.com/rubocop/rubocop/issues/6858): Fix an incorrect auto-correct for `Lint/ToJSON` when there are no `to_json` arguments. ([@koic][])
* [#6865](https://github.com/rubocop/rubocop/pull/6865): Fix deactivated `StyleGuideBaseURL` for `Layout/ClassStructure`. ([@aeroastro][])
* [#6868](https://github.com/rubocop/rubocop/pull/6868): Fix `Rails/LinkToBlank` auto-correct bug when using symbol for target. ([@r7kamura][])
* [#6869](https://github.com/rubocop/rubocop/pull/6869): Fix false positive for `Rails/LinkToBlank` when rel is a symbol value. ([@r7kamura][])
* Add `IncludedMacros` param to default rubocop config for `Style/MethodCallWithArgsParentheses`. ([@maxh][])
* [#6785](https://github.com/rubocop/rubocop/issues/6785): Do not register an offense for `Rails/Present` or `Rails/Blank` in an `unless else` context when `Style/UnlessElse` is enabled. ([@rrosenblum][])

### Changes

* [#6854](https://github.com/rubocop/rubocop/pull/6854): Mark Rails/LexicallyScopedActionFilter as unsafe and document risks. ([@urbanautomaton][])
* [#5977](https://github.com/rubocop/rubocop/issues/5977): Warn for Performance Cops. ([@koic][])
* [#6637](https://github.com/rubocop/rubocop/issues/6637): Move `LstripRstrip` from `Performance` to `Style` department and rename it to `Strip`. ([@anuja-joshi][])
* [#6875](https://github.com/rubocop/rubocop/pull/6875): Mention block form of `Struct.new` in ` Style/StructInheritance`. ([@XrXr][])
* [#6871](https://github.com/rubocop/rubocop/issues/6871): Move `Performance/RedundantSortBy`, `Performance/UnneededSort` and `Performance/Sample` to the Style department. ([@bbatsov][])

## 0.66.0 (2019-03-18)

### New features

* [#6393](https://github.com/rubocop/rubocop/issues/6393): Add `AllowBracesOnProceduralOneLiners` option to fine-tune `Style/BlockDelimiter`'s semantic mode. ([@davearonson][])
* [#6383](https://github.com/rubocop/rubocop/issues/6383): Add `AllowBeforeTrailingComments` option on `Layout/ExtraSpacing` cop. ([@davearonson][])
* New cop `Lint/SafeNavigationWithEmpty` checks for `foo&.empty?` in conditionals. ([@rspeicher][])
* Add new `Style/ConstantVisibility` cop for enforcing visibility declarations of class and module constants. ([@drenmi][])
* [#6378](https://github.com/rubocop/rubocop/issues/6378): Add `Lint/ToJSON` cop to enforce an argument when overriding `#to_json`. ([@allcentury][])
* [#6346](https://github.com/rubocop/rubocop/issues/6346): Add auto-correction to `Rails/TimeZone`. ([@dcluna][])
* [#6840](https://github.com/rubocop/rubocop/issues/6840): Node patterns now allow unlimited elements after `...`. ([@marcandre][])

### Bug fixes

* [#4321](https://github.com/rubocop/rubocop/pull/4321): Fix false offense for `Style/RedundantSelf` when the method is also defined on `Kernel`. ([@mikegee][])
* [#6821](https://github.com/rubocop/rubocop/pull/6821): Fix false negative for `Rails/LinkToBlank` when `_blank` is a symbol. ([@Intrepidd][])
* [#6699](https://github.com/rubocop/rubocop/issues/6699): Fix infinite loop for `Layout/IndentationWidth` and `Layout/IndentationConsistency` when bad modifier indentation before good method definition. ([@koic][])
* [#6777](https://github.com/rubocop/rubocop/issues/6777): Fix a false positive for `Style/TrivialAccessors` when using trivial reader/writer methods at the top level. ([@koic][])
* [#6799](https://github.com/rubocop/rubocop/pull/6799): Fix errors for `Style/ConditionalAssignment`, `Style/IdenticalConditionalBranches`, `Lint/ElseLayout`, and `Layout/IndentationWidth` with empty braces. ([@pocke][])
* [#6802](https://github.com/rubocop/rubocop/pull/6802): Fix auto-correction for `Style/SymbolArray` with array contains interpolation when `EnforcedStyle` is `brackets`. ([@pocke][])
* [#6797](https://github.com/rubocop/rubocop/pull/6797): Fix false negative for Layout/SpaceAroundBlockParameters on block parameter with parens. ([@pocke][])
* [#6798](https://github.com/rubocop/rubocop/pull/6798): Fix infinite loop for `Layout/SpaceAroundBlockParameters` with `EnforcedStyleInsidePipes: :space`. ([@pocke][])
* [#6803](https://github.com/rubocop/rubocop/pull/6803): Fix error for `Style/NumericLiterals` on a literal that contains spaces. ([@pocke][])
* [#6801](https://github.com/rubocop/rubocop/pull/6801): Fix auto-correction for `Style/Lambda` with no-space argument. ([@pocke][])
* [#6804](https://github.com/rubocop/rubocop/pull/6804): Fix auto-correction of `Style/NumericLiterals` on numeric literal with exponent. ([@pocke][])
* [#6800](https://github.com/rubocop/rubocop/issues/6800): Fix an incorrect auto-correct for `Rails/Validation` when method arguments are enclosed in parentheses. ([@koic][])
* [#6808](https://github.com/rubocop/rubocop/issues/6808): Prevent false positive in `Naming/ConstantName` when assigning a frozen range. ([@drenmi][])
* Fix the calculation of `Metrics/AbcSize`. Comparison methods and `else` branches add to the comparison count. ([@rrosenblum][])
* [#6791](https://github.com/rubocop/rubocop/pull/6791): Allow `Rails/ReflectionClassName` to use symbol argument for `class_name`. ([@unasuke][])
* [#5465](https://github.com/rubocop/rubocop/issues/5465): Fix `Layout/ClassStructure` to allow grouping macros by their visibility. ([@gprado][])
* [#6461](https://github.com/rubocop/rubocop/pull/6461): Restrict `Ctrl-C` handling to RuboCop's loop and simplify it to a single phase. ([@deivid-rodriguez][])

### Changes

* Add `$stdout`/`$stderr` and `STDOUT`/`STDERR` method calls to `Rails/Output`. ([@elebow][])
* [#6688](https://github.com/rubocop/rubocop/pull/6688): Add `iterator?` to deprecated methods and prefer `block_given?` instead. ([@tejasbubane][])
* [#6806](https://github.com/rubocop/rubocop/pull/6806): Remove `powerpack` dependency. ([@dduugg][])
* [#6810](https://github.com/rubocop/rubocop/pull/6810): Exclude gemspec file by default for `Metrics/BlockLength` cop. ([@koic][])
* [#6813](https://github.com/rubocop/rubocop/pull/6813): Allow unicode/display_width dependency version 1.5.0. ([@tagliala][])
* Make `Style/RedundantFreeze` aware of methods that will produce frozen objects. ([@rrosenblum][])
* [#6675](https://github.com/rubocop/rubocop/issues/6675): Avoid printing deprecation warnings about constants. ([@elmasantos][])
* [#6746](https://github.com/rubocop/rubocop/issues/6746): Avoid offense on `$stderr.puts` with no arguments. ([@luciamo][])
* Replace md5 with sha1 for FIPS compliance. ([@dirtyharrycallahan][])

## 0.65.0 (2019-02-19)

### New features

* [#6126](https://github.com/rubocop/rubocop/pull/6126): Add an experimental strict mode to `Style/MutableConstant` that will freeze all constants, rather than just literals. ([@rrosenblum][])
* Add `IncludedMacros` to `Style/MethodCallWithArgsParentheses` to allow including specific macros when `IgnoreMacros` is true. ([@maxh][])

### Bug fixes

* [#6765](https://github.com/rubocop/rubocop/pull/6765): Fix false positives in keyword arguments for `Style/MethodCallWithArgsParentheses` `omit_parentheses`. ([@gsamokovarov][])
* [#6763](https://github.com/rubocop/rubocop/pull/6763): Fix false positives in range literals for `Style/MethodCallWithArgsParentheses` `omit_parentheses`. ([@gsamokovarov][])
* [#6748](https://github.com/rubocop/rubocop/issues/6748): Fix `Style/RaiseArgs` auto-correction breaking in contexts that require parentheses. ([@drenmi][])
* [#6751](https://github.com/rubocop/rubocop/issues/6751): Prevent `Style/OneLineConditional` from breaking on `retry` and `break` keywords. ([@drenmi][])
* [#6755](https://github.com/rubocop/rubocop/issues/6755): Prevent `Style/TrailingCommaInArgument` from breaking when a safe method call is chained on the offending method. ([@drenmi][], [@hoshinotsuyoshi][])

### Changes

* [#6766](https://github.com/rubocop/rubocop/pull/6766): Drop support for Ruby 2.2.0 and 2.2.1. ([@pocke][])
* [#6733](https://github.com/rubocop/rubocop/pull/6733): Warn duplicated keys in `.rubocop.yml`. ([@pocke][])
* [#6613](https://github.com/rubocop/rubocop/pull/6613): Mark `Style/ModuleFunction` as `SafeAuto-Correct: false` and disable auto-correct by default. ([@dduugg][])

## 0.64.0 (2019-02-10)

### New features

* [#6704](https://github.com/rubocop/rubocop/pull/6704): Add new `Rails/ReflectionClassName` cop. ([@Bhacaz][])
* [#6643](https://github.com/rubocop/rubocop/pull/6643): Support `AllowParenthesesInCamelCaseMethod` option on `Style/MethodCallWithArgsParentheses` `omit_parentheses`. ([@dazuma][])

### Bug fixes

* [#6254](https://github.com/rubocop/rubocop/issues/6254): Fix `Layout/RescueEnsureAlignment` for non-local assignments. ([@marcotc][])
* [#6648](https://github.com/rubocop/rubocop/issues/6648): Fix auto-correction of `Style/EmptyLiteral` when `Hash.new` is passed as the first argument to `super`. ([@rrosenblum][])
* [#6351](https://github.com/rubocop/rubocop/pull/6351): Fix a false positive for `Layout/ClosingParenthesisIndentation` when first argument is multiline. ([@antonzaytsev][])
* [#6689](https://github.com/rubocop/rubocop/pull/6689): Support more complex argument patterns on `Rails/Validation` auto-correction. ([@r7kamura][])
* [#6668](https://github.com/rubocop/rubocop/issues/6668): Fix auto-correction for `Style/UnneededCondition` when conditional has the `unless` form. ([@mvz][])
* [#6382](https://github.com/rubocop/rubocop/issues/6382): Fix `Layout/IndentationWidth` with `Layout/EndAlignment` set to start_of_line. ([@dischorde][], [@siegfault][], [@mhelmetag][])
* [#6710](https://github.com/rubocop/rubocop/issues/6710): Fix `Naming/MemoizedInstanceVariableName` on method starts with underscore. ([@pocke][])
* [#6722](https://github.com/rubocop/rubocop/issues/6722): Fix an error for `Style/OneLineConditional` when `then` branch has no body. ([@koic][])
* [#6702](https://github.com/rubocop/rubocop/pull/6702): Fix `TrailingComma` regression where heredoc with commas caused false positives. ([@abrom][])
* [#6737](https://github.com/rubocop/rubocop/issues/6737): Fix an incorrect auto-correct for `Rails/LinkToBlank` when `link_to` method arguments are enclosed in parentheses. ([@koic][])
* [#6720](https://github.com/rubocop/rubocop/issues/6720): Fix detection of `:native` line ending for `Layout/EndOfLine` on JRuby. ([@enkessler][])

### Changes

* [#6597](https://github.com/rubocop/rubocop/issues/6597): `Style/LineEndConcatenation` is now known to be unsafe for auto-correct. ([@jaredbeck][])
* [#6725](https://github.com/rubocop/rubocop/issues/6725): Mark `Style/SymbolProc` as unsafe for auto-correct. ([@drenmi][])
* [#6708](https://github.com/rubocop/rubocop/issues/6708): Make `Style/CommentedKeyword` allow the `:yields:` RDoc comment. ([@bquorning][])
* [#6749](https://github.com/rubocop/rubocop/pull/6749): Make some cops aware of safe navigation operator. ([@hoshinotsuyoshi][])

## 0.63.1 (2019-01-22)

### Bug fixes

* [#6678](https://github.com/rubocop/rubocop/issues/6678): Fix `Lint/DisjunctiveAssignmentInConstructor` when it finds an empty constructor. ([@rmm5t][])
* Do not attempt to auto-correct mass assignment or optional assignment in `Rails/RelativeDateConstant`. ([@rrosenblum][])
* Fix auto-correction of `Style/WordArray` and `Style/SymbolArray` when all elements are on separate lines and there is a trailing comment after the closing bracket. ([@rrosenblum][])
* Fix an exception that occurs when auto-correcting `Layout/ClosingParenthesesIndentation` when there are no arguments. ([@rrosenblum][])

## 0.63.0 (2019-01-16)

### New features

* [#6604](https://github.com/rubocop/rubocop/pull/6604): Add auto-correct support to `Rails/LinkToBlank`. ([@Intrepidd][])
* [#6660](https://github.com/rubocop/rubocop/pull/6660): Add new `Rails/IgnoredSkipActionFilterOption` cop. ([@wata727][])
* [#6363](https://github.com/rubocop/rubocop/issues/6363): Allow `Style/YodaCondition` cop to be configured to enforce yoda conditions. ([@tejasbubane][])
* [#6150](https://github.com/rubocop/rubocop/issues/6150): Add support to enforce disabled cops to be executed. ([@roooodcastro][])
* [#6596](https://github.com/rubocop/rubocop/pull/6596): Add new `Rails/BelongsTo` cop with auto-correct for Rails >= 5. ([@petehamilton][])

### Bug fixes

* [#6627](https://github.com/rubocop/rubocop/pull/6627): Fix handling of hashes in trailing comma. ([@abrom][])
* [#6638](https://github.com/rubocop/rubocop/pull/6638): Fix `Rails/LinkToBlank` detection to allow `rel: 'noreferrer`. ([@fwininger][])
* [#6623](https://github.com/rubocop/rubocop/pull/6623): Fix heredoc detection in trailing comma. ([@palkan][])
* [#6100](https://github.com/rubocop/rubocop/issues/6100): Fix a false positive in `Naming/ConstantName` cop when rhs is a conditional expression. ([@tatsuyafw][])
* [#6526](https://github.com/rubocop/rubocop/issues/6526): Fix a wrong line highlight in `Lint/ShadowedException` cop. ([@tatsuyafw][])
* [#6617](https://github.com/rubocop/rubocop/issues/6617): Prevent traversal error on infinite ranges. ([@drenmi][])
* [#6625](https://github.com/rubocop/rubocop/issues/6625): Revert the "auto-exclusion of files ignored by git" feature. ([@bbatsov][])
* [#4460](https://github.com/rubocop/rubocop/issues/4460): Fix the determination of unsafe auto-correct in `Style/TernaryParentheses`. ([@jonas054][])
* [#6651](https://github.com/rubocop/rubocop/issues/6651): Fix auto-correct issue in `Style/RegexpLiteral` cop when there is string interpolation. ([@roooodcastro][])
* [#6670](https://github.com/rubocop/rubocop/issues/6670): Fix a false positive for `Style/SafeNavigation` when a method call safeguarded with a negative check for the object. ([@koic][])
* [#6633](https://github.com/rubocop/rubocop/issues/6633): Fix `Lint/SafeNavigation` complaining about use of `to_d`. ([@tejasbubane][])
* [#6575](https://github.com/rubocop/rubocop/issues/6575): Fix `Naming/PredicateName` suggesting invalid rename. ([@tejasbubane][])
* [#6673](https://github.com/rubocop/rubocop/issues/6673): Fix `Style/DocumentationMethod` cop to recognize documentation comments for `def` inline with `module_function`. ([@tejasbubane][])
* [#6648](https://github.com/rubocop/rubocop/issues/6648): Fix auto-correction of `Style/EmptyLiteral` when `Hash.new` is passed as the first argument to `super`. ([@rrosenblum][])

### Changes

* [#6607](https://github.com/rubocop/rubocop/pull/6607): Improve CLI usage message for --stdin option. ([@jaredbeck][])
* [#6641](https://github.com/rubocop/rubocop/issues/6641): Specify `Performance/RangeInclude` as unsafe because `Range#include?` and `Range#cover?` are not equivalent. ([@koic][])
* [#6636](https://github.com/rubocop/rubocop/pull/6636): Move `FlipFlop` cop from `Style` to `Lint` department because flip-flop is deprecated since Ruby 2.6.0. ([@koic][])
* [#6661](https://github.com/rubocop/rubocop/pull/6661): Abandon making frozen string literals default for Ruby 3.0. ([@koic][])

## 0.62.0 (2019-01-01)

### New features

* [#6580](https://github.com/rubocop/rubocop/pull/6580): New cop `Rails/LinkToBlank` checks for `link_to` calls with `target: '_blank'` and no `rel: 'noopener'`. ([@Intrepidd][])
* [#6586](https://github.com/rubocop/rubocop/issues/6586): New cop `Lint/DisjunctiveAssignmentInConstructor` checks constructors for disjunctive assignments that should be plain assignments. ([@jaredbeck][])

### Bug fixes

* [#6560](https://github.com/rubocop/rubocop/issues/6560): Consider file count, not offense count, for `--exclude-limit` in combination with `--auto-gen-only-exclude`. ([@jonas054][])
* [#4229](https://github.com/rubocop/rubocop/issues/4229): Fix unexpected Style/HashSyntax consistency offence. ([@timon][])
* [#6500](https://github.com/rubocop/rubocop/issues/6500): Add offense to use `in_time_zone` instead of deprecated `to_time_in_current_zone`. ([@nadiyaka][])
* [#6577](https://github.com/rubocop/rubocop/pull/6577): Prevent Rails/Blank cop from adding offense when define the blank method. ([@jonatas][])
* [#6554](https://github.com/rubocop/rubocop/issues/6554): Prevent Layout/RescueEnsureAlignment cop from breaking on block assignment when assignment is on a separate line. ([@timmcanty][])
* [#6343](https://github.com/rubocop/rubocop/pull/6343): Optimise `--auto-gen-config` when `Metrics/LineLength` cop is disabled. ([@tom-lord][])
* [#6389](https://github.com/rubocop/rubocop/pull/6389): Fix false negative for `Style/TrailingCommaInHashLiteral`/`Style/TrailingCommaInArrayLiteral` when there is a comment in the last line. ([@bayandin][])
* [#6566](https://github.com/rubocop/rubocop/issues/6566): Fix false positive for `Layout/EmptyLinesAroundAccessModifier` when at the end of specifying a superclass is missing blank line. ([@koic][])
* [#6571](https://github.com/rubocop/rubocop/issues/6571): Fix a false positive for `Layout/TrailingCommaInArguments` when a line break before a method call and `EnforcedStyleForMultiline` is set to `consistent_comma`. ([@koic][])
* [#6573](https://github.com/rubocop/rubocop/pull/6573): Make `Layout/AccessModifierIndentation` work for dynamic module or class definitions. ([@deivid-rodriguez][])
* [#6562](https://github.com/rubocop/rubocop/pull/6562): Fix a false positive for `Style/MethodCallWithArgsParentheses` `omit_parentheses` enforced style after safe navigation call. ([@gsamokovarov][])
* [#6570](https://github.com/rubocop/rubocop/pull/6570): Fix a false positive for `Style/MethodCallWithArgsParentheses` `omit_parentheses` enforced style while splatting the result of a method invocation. ([@gsamokovarov][])
* [#6598](https://github.com/rubocop/rubocop/pull/6598): Fix a false positive for `Style/MethodCallWithArgsParentheses` `omit_parentheses` enforced style for calls with regexp slash literals argument. ([@gsamokovarov][])
* [#6598](https://github.com/rubocop/rubocop/pull/6598): Fix a false positive for `Style/MethodCallWithArgsParentheses` `omit_parentheses` enforced style for default argument value calls. ([@gsamokovarov][])
* [#6598](https://github.com/rubocop/rubocop/pull/6598): Fix a false positive for `Style/MethodCallWithArgsParentheses` `omit_parentheses` enforced style for argument calls with braced blocks. ([@gsamokovarov][])
* [#6594](https://github.com/rubocop/rubocop/pull/6594): Fix a false positive for `Rails/OutputSafety` when the receiver is a non-interpolated string literal. ([@amatsuda][])
* [#6574](https://github.com/rubocop/rubocop/pull/6574): Fix `Style/AccessModifierIndentation` not handling arbitrary blocks. ([@deivid-rodriguez][])
* [#6370](https://github.com/rubocop/rubocop/issues/6370): Fix the enforcing style from `extend self` into `module_function` when there are private methods. ([@Ruffeng][])

### Changes

* [#595](https://github.com/rubocop/rubocop/issues/595): Exclude files ignored by `git`. ([@AlexWayfer][])
* [#6429](https://github.com/rubocop/rubocop/issues/6429): Fix auto-correct in Rails/Validation to not wrap hash options with braces in an extra set of braces. ([@bquorning][])
* [#6533](https://github.com/rubocop/rubocop/issues/6533): Improved warning message for unrecognized cop parameters to include Supported parameters. ([@MagedMilad][])

## 0.61.1 (2018-12-06)

### Bug fixes

* [#6550](https://github.com/rubocop/rubocop/issues/6550): Prevent Layout/RescueEnsureAlignment cop from breaking on assigned begin-end. ([@drenmi][])

## 0.61.0 (2018-12-05)

### New features

* [#6457](https://github.com/rubocop/rubocop/pull/6457): Support inner slash correction on `Style/RegexpLiteral`. ([@r7kamura][])
* [#6475](https://github.com/rubocop/rubocop/pull/6475): Support brace correction on `Style/Lambda`. ([@r7kamura][])
* [#6469](https://github.com/rubocop/rubocop/pull/6469): Enforce no parentheses style in the `Style/MethodCallWithArgsParentheses` cop. ([@gsamokovarov][])
* New cop `Performance/OpenStruct` checks for `OpenStruct.new` calls. ([@xlts][])

### Bug fixes

* [#6433](https://github.com/rubocop/rubocop/issues/6433): Fix Ruby 2.5 `Layout/RescueEnsureAlignment` error on assigned blocks. ([@gmcgibbon][])
* [#6405](https://github.com/rubocop/rubocop/issues/6405): Fix a false positive for `Lint/UselessAssignment` when using a variable in a module name. ([@itsWill][])
* [#5934](https://github.com/rubocop/rubocop/issues/5934): Handle the combination of `--auto-gen-config` and `--config FILE` correctly. ([@jonas054][])
* [#5970](https://github.com/rubocop/rubocop/issues/5970): Make running `--auto-gen-config` in a subdirectory work. ([@jonas054][])
* [#6412](https://github.com/rubocop/rubocop/issues/6412): Fix an `unknown keywords` error when using `Psych.safe_load` with Ruby 2.6.0-preview2. ([@koic][])
* [#6436](https://github.com/rubocop/rubocop/pull/6436): Fix exit status code to be 130 when rubocop is interrupted. ([@deivid-rodriguez][])
* [#6443](https://github.com/rubocop/rubocop/pull/6443): Fix an incorrect auto-correct for `Style/BracesAroundHashParameters` when the opening brace is before the first hash element at same line. ([@koic][])
* [#6445](https://github.com/rubocop/rubocop/pull/6445): Treat `yield` and `super` like regular method calls in `Style/AlignHash`. ([@mvz][])
* [#3301](https://github.com/rubocop/rubocop/issues/3301): Don't suggest or make semantic changes to the code in `Style/InfiniteLoop`. ([@jonas054][])
* [#3586](https://github.com/rubocop/rubocop/issues/3586): Handle single argument spanning multiple lines in `Style/TrailingCommaInArguments`. ([@jonas054][])
* [#6478](https://github.com/rubocop/rubocop/pull/6478): Fix EmacsComment#encoding to match the `coding` variable. ([@akihiro17][])
* Don't show "unrecognized parameter" warning for `inherit_mode` parameter to individual cop configurations. ([@maxh][])
* [#6449](https://github.com/rubocop/rubocop/pull/6449): Fix a false negative for `Layout/IndentationWidth` when setting `EnforcedStyle: rails` of `Layout/IndentationConsistency` and method definition indented to access modifier in a singleton class. ([@koic][])
* [#6482](https://github.com/rubocop/rubocop/issues/6482): Fix a false positive for `Lint/FormatParameterMismatch` when using (digit)$ flag. ([@koic][])
* [#6489](https://github.com/rubocop/rubocop/issues/6489): Fix an error for `Style/UnneededCondition` when `if` condition and `then` branch are the same and it has no `else` branch. ([@koic][])
* Fix NoMethodError for `Style/FrozenStringLiteral` when a file contains only a shebang. ([@takaram][])
* [#6511](https://github.com/rubocop/rubocop/issues/6511): Fix an incorrect auto-correct for `Style/EmptyCaseCondition` when used as an argument of a method. ([@koic][])
* [#6509](https://github.com/rubocop/rubocop/issues/6509): Fix an incorrect auto-correct for `Style/RaiseArgs` when an exception object is assigned to a local variable. ([@koic][])
* [#6534](https://github.com/rubocop/rubocop/issues/6534): Fix a false positive for `Lint/UselessAccessModifier` when using `private_class_method`. ([@dduugg][])
* [#6545](https://github.com/rubocop/rubocop/issues/6545): Fix a regression where `Performance/RedundantMerge` raises an error on a sole double splat argument passed to `merge!`. ([@mmedal][])
* [#6360](https://github.com/rubocop/rubocop/issues/6360): Detect bad indentation in `if` nodes even if the first branch is empty. ([@bquorning][])

### Changes

* [#6492](https://github.com/rubocop/rubocop/issues/6492): Auto-correct chunks of comment lines in `Layout/CommentIndentation` to avoid unnecessary iterations for `rubocop -a`. ([@jonas054][])
* Fix `--auto-gen-config` when individual cops have regexp literal exclude paths. ([@maxh][])

## 0.60.0 (2018-10-26)

### New features

* [#5980](https://github.com/rubocop/rubocop/issues/5980): Add `--safe` and `--safe-auto-correct` options. ([@Darhazer][])
* [#4156](https://github.com/rubocop/rubocop/issues/4156): Add command line option `--auto-gen-only-exclude`. ([@Ana06][], [@jonas054][])
* [#6386](https://github.com/rubocop/rubocop/pull/6386): Add `VersionAdded` meta data to config/default.yml when running `rake new_cop`. ([@koic][])
* [#6395](https://github.com/rubocop/rubocop/pull/6395): Permit to specify TargetRubyVersion 2.6. ([@koic][])
* [#6392](https://github.com/rubocop/rubocop/pull/6392): Add `Whitelist` config to `Rails/SkipsModelValidations` rule. ([@DiscoStarslayer][])

### Bug fixes

* [#6330](https://github.com/rubocop/rubocop/issues/6330): Fix an error for `Rails/ReversibleMigration` when using variable assignment. ([@koic][], [@scottmatthewman][])
* [#6331](https://github.com/rubocop/rubocop/issues/6331): Fix a false positive for `Style/RedundantFreeze` and a false negative for `Style/MutableConstant` when assigning a regexp object to a constant. ([@koic][])
* [#6334](https://github.com/rubocop/rubocop/pull/6334): Fix a false negative for `Style/RedundantFreeze` when assigning a range object to a constant. ([@koic][])
* [#5538](https://github.com/rubocop/rubocop/issues/5538): Fix false negatives in modifier cops when line length cop is disabled. ([@drenmi][])
* [#6340](https://github.com/rubocop/rubocop/pull/6340): Fix an error for `Rails/ReversibleMigration` when block argument is empty. ([@koic][])
* [#6274](https://github.com/rubocop/rubocop/issues/6274): Fix "[Corrected]" message being displayed even when nothing has been corrected. ([@jekuta][])
* [#6380](https://github.com/rubocop/rubocop/pull/6380): Allow use of a hyphen-separated frozen string literal in Emacs style magic comment. ([@y-yagi][])
* Fix and improve `LineLength` cop for tab-indented code. ([@AlexWayfer][])

### Changes

* [#3727](https://github.com/rubocop/rubocop/issues/3727): Enforce single spaces for `key` option in `Layout/AlignHash` cop. ([@albaer][])
* [#6321](https://github.com/rubocop/rubocop/pull/6321): Fix run of RuboCop when cache directory is not writable. ([@Kevinrob][])

## 0.59.2 (2018-09-24)

### New features

* Update `Style/MethodCallWithoutArgsParentheses` to highlight the closing parentheses in addition to the opening parentheses. ([@rrosenblum][])

### Bug fixes

* [#6266](https://github.com/rubocop/rubocop/issues/6266): Fix a false positive for `Rails/HasManyOrHasOneDependent` when using associations of Active Resource. ([@tejasbubane][], [@koic][])
* [#6296](https://github.com/rubocop/rubocop/issues/6296): Fix an auto-correct error for `Style/For` when setting `EnforcedStyle: each` and `for` dose not have `do` or semicolon. ([@autopp][])
* [#6300](https://github.com/rubocop/rubocop/pull/6300): Fix a false positive for `Layout/EmptyLineAfterGuardClause` when guard clause including heredoc. ([@koic][])
* [#6287](https://github.com/rubocop/rubocop/pull/6287): Fix `AllowURI` option for `Metrics/LineLength` cop with disabled `Layout/Tab` cop. ([@AlexWayfer][])
* [#5338](https://github.com/rubocop/rubocop/pull/5338): Move checking of class- and module defining blocks from `Metrics/BlockLength` into the respective length cops. ([@drenmi][])
* [#2841](https://github.com/rubocop/rubocop/pull/2841): Fix `Style/ZeroLengthPredicate` false positives when inspecting `Tempfile`, `StringIO`, and `File::Stat` objects. ([@drenmi][])
* [#6305](https://github.com/rubocop/rubocop/pull/6305): Fix infinite loop for `Layout/EmptyLinesAroundAccessModifier` and `Layout/EmptyLinesAroundAccessModifier` when specifying a superclass that breaks the line. ([@koic][])
* [#6007](https://github.com/rubocop/rubocop/pull/6007): Fix false positive in `Style/IfUnlessModifier` when using named capture. ([@drenmi][])
* [#6311](https://github.com/rubocop/rubocop/pull/6311): Prevent `Style/Semicolon` from breaking on single line if-then-else in assignment. ([@drenmi][])
* [#6315](https://github.com/rubocop/rubocop/pull/6315): Fix an error for `Rails/HasManyOrHasOneDependent` when an Active Record model does not have any relations. ([@koic][])
* [#6316](https://github.com/rubocop/rubocop/issues/6316): Fix an auto-correct error for `Style/For` when setting `EnforcedStyle: each` with range provided to the `for` loop without a `do` keyword or semicolon and without enclosing parenthesis. ([@lukasz-wojcik][])
* [#6326](https://github.com/rubocop/rubocop/issues/6326): Fix an alignment source for `Layout/RescueEnsureAlignment` when using inline access modifier. ([@andrew-aladev][])

### Changes

* [#6286](https://github.com/rubocop/rubocop/pull/6286): Allow exclusion of certain methods for `Metrics/MethodLength`. ([@akanoi][])

## 0.59.1 (2018-09-15)

### Bug fixes

* [#6267](https://github.com/rubocop/rubocop/pull/6267): Fix undefined method 'method_name' for `Rails/FindEach`. ([@Knack][])
* [#6278](https://github.com/rubocop/rubocop/pull/6278): Fix false positive for `Naming/FileName` when investigating gemspecs. ([@kddeisz][])
* [#6256](https://github.com/rubocop/rubocop/pull/6256): Fix false positive for `Naming/FileName` when investigating dotfiles. ([@sinsoku][])
* [#6242](https://github.com/rubocop/rubocop/pull/6242): Fix `Style/EmptyCaseCondition` auto-correction removes comment between `case` and first `when`. ([@koic][])
* [#6261](https://github.com/rubocop/rubocop/pull/6261): Fix undefined method error for `Style/RedundantBegin` when calling `super` with a block. ([@eitoball][])
* [#6263](https://github.com/rubocop/rubocop/issues/6263): Fix an error `Layout/EmptyLineAfterGuardClause` when guard clause is after heredoc including string interpolation. ([@koic][])
* [#6281](https://github.com/rubocop/rubocop/pull/6281): Fix false negative in `Style/MultilineMethodSignature`. ([@drenmi][])
* [#6264](https://github.com/rubocop/rubocop/issues/6264): Fix an incorrect auto-correct for `Layout/EmptyLineAfterGuardClause` cop when `if` condition is after heredoc. ([@koic][])

### Changes

* [#6272](https://github.com/rubocop/rubocop/pull/6272): Make `Lint/UnreachableCode` detect `exit`, `exit!` and `abort`. ([@hoshinotsuyoshi][])
* [#6295](https://github.com/rubocop/rubocop/pull/6295): Exclude `#===` from `Naming/BinaryOperatorParameterName`. ([@zverok][])
* Add `+` to allowed file names of `Naming/FileName`. ([@yensaki][])
* [#5303](https://github.com/rubocop/rubocop/issues/5303): Extract `PercentLiteralCorrector` class from `PercentLiteral` mixin. ([@ryanhageman][])

## 0.59.0 (2018-09-09)

### New features

* [#6109](https://github.com/rubocop/rubocop/pull/6109): Add new `Bundler/GemComment` cop. ([@sunny][])
* [#6148](https://github.com/rubocop/rubocop/pull/6148): Add `IgnoredMethods` option to `Style/NumericPredicate` cop. ([@AlexWayfer][])
* [#6174](https://github.com/rubocop/rubocop/pull/6174): Add `--display-only-fail-level-offenses` to only output offenses at or above the fail level. ([@robotdana][])
* Add auto-correct to `Style/For`. ([@rrosenblum][])
* [#6173](https://github.com/rubocop/rubocop/pull/6173): Add `AllowImplicitReturn` option to `Rails/SaveBang` cop. ([@robotdana][])
* [#6218](https://github.com/rubocop/rubocop/pull/6218): Add `comparison` style to `Style/NilComparison`. ([@khiav223577][])
* Add new `Style/MultilineMethodSignature` cop. ([@drenmi][])
* [#6234](https://github.com/rubocop/rubocop/pull/6234): Add `Performance/ChainArrayAllocation` cop. ([@schneems][])
* [#6136](https://github.com/rubocop/rubocop/pull/6136): Add remote url in remote url download error message. ([@ShockwaveNN][])
* [#5659](https://github.com/rubocop/rubocop/issues/5659): Make `Layout/EmptyLinesAroundClassBody` aware of specifying a superclass that breaks the line. ([@koic][])

### Bug fixes

* [#6107](https://github.com/rubocop/rubocop/pull/6107): Fix indentation of multiline postfix conditionals. ([@jaredbeck][])
* [#6140](https://github.com/rubocop/rubocop/pull/6140): Fix `Style/DateTime` not detecting `#to_datetime`. It can be configured to allow this. ([@bdewater][])
* [#6132](https://github.com/rubocop/rubocop/issues/6132): Fix a false negative for `Naming/FileName` when `Include` of `AllCops` is the default setting. ([@koic][])
* [#4115](https://github.com/rubocop/rubocop/issues/4115): Fix false positive for unary operations in `Layout/MultilineOperationIndentation`. ([@jonas054][])
* [#6127](https://github.com/rubocop/rubocop/issues/6127): Fix an error for `Layout/ClosingParenthesisIndentation` when method arguments are empty with newlines. ([@tatsuyafw][])
* [#6152](https://github.com/rubocop/rubocop/pull/6152): Fix a false negative for `Layout/AccessModifierIndentation` when using access modifiers with arguments within nested classes. ([@gmalette][])
* [#6124](https://github.com/rubocop/rubocop/issues/6124): Fix `Style/IfUnlessModifier` cop for disabled `Layout/Tab` cop when there is no `IndentationWidth` config. ([@AlexWayfer][])
* [#6133](https://github.com/rubocop/rubocop/pull/6133): Fix `AllowURI` option of `Metrics/LineLength` cop for files with tabs indentation. ([@AlexWayfer][])
* [#6164](https://github.com/rubocop/rubocop/issues/6164): Fix incorrect auto-correct for `Style/UnneededCondition` when using operator method higher precedence than `||`. ([@koic][])
* [#6138](https://github.com/rubocop/rubocop/issues/6138): Fix a false positive for assigning a block local variable in `Lint/ShadowedArgument`. ([@jonas054][])
* [#6022](https://github.com/rubocop/rubocop/issues/6022): Fix `Layout/MultilineHashBraceLayout` and `Layout/MultilineArrayBraceLayout` auto-correct syntax error when there is a comment on the last element. ([@bacchir][])
* [#6175](https://github.com/rubocop/rubocop/issues/6175): Fix `Style/BracesAroundHashParameters` auto-correct syntax error when there is a trailing comma. ([@bacchir][])
* [#6192](https://github.com/rubocop/rubocop/issues/6192): Make `Style/RedundantBegin` aware of stabby lambdas. ([@drenmi][])
* [#6208](https://github.com/rubocop/rubocop/pull/6208): Ignore assignment methods in `Naming/PredicateName`. ([@sunny][])
* [#6196](https://github.com/rubocop/rubocop/issues/6196): Fix incorrect auto-correct for `Style/EmptyCaseCondition` when using `return` in `when` clause and assigning the return value of `case`. ([@koic][])
* [#6142](https://github.com/rubocop/rubocop/issues/6142): Ignore keyword arguments in `Rails/Delegate`. ([@sunny][])
* [#6240](https://github.com/rubocop/rubocop/issues/6240): Fix an auto-correct error for `Style/WordArray` when setting `EnforcedStyle: brackets` and using string interpolation in `%W` literal. ([@koic][])
* [#6202](https://github.com/rubocop/rubocop/issues/6202): Fix infinite loop when auto-correcting `Lint/RescueEnsureAlignment` when `end` is misaligned. The alignment and message are now based on the beginning position rather than the `end` position. ([@rrosenblum][])
* [#6199](https://github.com/rubocop/rubocop/issues/6199): Don't recommend `Date` usage in `Style/DateTime`. ([@deivid-rodriguez][])

### Changes

* [#6161](https://github.com/rubocop/rubocop/pull/6161): Add scope methods to `Rails/FindEach` cop. Makes the cop also check for the following scopes: `eager_load`, `includes`, `joins`, `left_joins`, `left_outer_joins`, `preload`, `references`, and `unscoped`. ([@repinel][])
* [#6137](https://github.com/rubocop/rubocop/pull/6137): Allow `db` to allowed names of `Naming/UncommunicativeMethodParamName` cop in default config. ([@mkenyon][])
* Update the highlighting of `Lint/DuplicateMethods` to include the method name. ([@rrosenblum][])
* [#6057](https://github.com/rubocop/rubocop/issues/6057): Return 0 when running `rubocop --auto-gen-conf` if the todo file is successfully created even if there are offenses. ([@MagedMilad][])
* [#4301](https://github.com/rubocop/rubocop/issues/4301): Turn off auto-correct for `Rails/RelativeDateConstant` by default. ([@koic][])
* [#4832](https://github.com/rubocop/rubocop/issues/4832): Change the path pattern (`*`) to match the hidden file. ([@koic][])
* `Style/For` now highlights the entire statement rather than just the keyword. ([@rrosenblum][])
* Disable `Performance/CaseWhenSplat` and its auto-correction by default. ([@rrosenblum][])
* [#6235](https://github.com/rubocop/rubocop/pull/6235): Enable `Layout/EmptyLineAfterGuardClause` cop by default. ([@koic][])
* [#6199](https://github.com/rubocop/rubocop/pull/6199): `Style/DateTime` has been moved to disabled by default. ([@deivid-rodriguez][])

## 0.58.2 (2018-07-23)

### New features

* [#6105](https://github.com/rubocop/rubocop/issues/6105): Support `{a,b}` file name globs in `Exclude` and `Include` config. ([@mikeyhew][])

### Bug fixes

* [#6103](https://github.com/rubocop/rubocop/pull/6103): Fix a false positive for `Layout/IndentationWidth` when multiple modifiers are used in a block and a method call is made at end of the block. ([@koic][])
* [#6084](https://github.com/rubocop/rubocop/issues/6084): Fix `Naming/MemoizedInstanceVariableName` cop to allow methods to have leading underscores. ([@kenman345][])
* [#6098](https://github.com/rubocop/rubocop/issues/6098): Fix an error for `Layout/ClassStructure` when there is a comment in the macro method to be auto-correct. ([@koic][])
* [#6115](https://github.com/rubocop/rubocop/issues/6115): Fix a false positive for `Lint/OrderedMagicComments` when using `{ encoding: Encoding::SJIS }` hash object after `frozen_string_literal` magic comment. ([@koic][])

### Changes

* [#6116](https://github.com/rubocop/rubocop/pull/6116): Add `ip` to allowed names of `Naming/UncommunicativeMethodParamName` cop in default config. ([@nijikon][])

## 0.58.1 (2018-07-10)

### Bug fixes

* [#6071](https://github.com/rubocop/rubocop/issues/6071): Fix auto-correct `Style/MethodCallWithArgsParentheses` when arguments are method calls. ([@maxh][])
* Fix `Style/RedundantParentheses` with hash literal as first argument to `super`. ([@maxh][])
* [#6086](https://github.com/rubocop/rubocop/issues/6086): Fix an error for `Gemspec/OrderedDependencies` when using method call to gem names in gemspec. ([@koic][])
* [#6089](https://github.com/rubocop/rubocop/issues/6089): Make `Rails/BulkChangeTable` aware of variable table name. ([@wata727][])
* [#6088](https://github.com/rubocop/rubocop/issues/6088): Fix an error for `Layout/MultilineAssignmentLayout` cop when using multi-line block defines on separate lines. ([@koic][])
* [#6092](https://github.com/rubocop/rubocop/issues/6092): Don't use the broken parser 2.5.1.1 version. ([@bbatsov][])

## 0.58.0 (2018-07-07)

### New features

* [#5973](https://github.com/rubocop/rubocop/issues/5973): Add new `Style/IpAddresses` cop. ([@dvandersluis][])
* [#5843](https://github.com/rubocop/rubocop/issues/5843): Add configuration options to `Naming/MemoizedInstanceVariableName` cop to allow leading underscores. ([@leklund][])
* [#5843](https://github.com/rubocop/rubocop/issues/5843): Add `EnforcedStyleForLeadingUnderscores` to `Naming/MemoizedInstanceVariableName` cop to allow leading underscores. ([@leklund][])
* `Performance/Sample` will now register an offense when using `shuffle` followed by `at` or `slice`. ([@rrosenblum][])

### Bug fixes

* [#5987](https://github.com/rubocop/rubocop/issues/5987): Suppress errors when using ERB template in Rails/BulkChangeTable. ([@wata727][])
* [#4878](https://github.com/rubocop/rubocop/issues/4878): Fix false positive in `Layout/IndentationWidth` when multiple modifiers and def are on the same line. ([@tatsuyafw][])
* [#5966](https://github.com/rubocop/rubocop/issues/5966): Fix a false positive for `Layout/ClosingHeredocIndentation` when heredoc content is outdented compared to the closing. ([@koic][])
* Fix auto-correct support check for custom cops on --auto-gen-config. ([@r7kamura][])
* Fix exception that occurs when auto-correcting a modifier if statement in `Style/UnneededCondition`. ([@rrosenblum][])
* [#6025](https://github.com/rubocop/rubocop/pull/6025): Fix an incorrect auto-correct for `Lint/UnneededCondition` when using if_branch in `else` branch. ([@koic][])
* [#6029](https://github.com/rubocop/rubocop/issues/6029): Fix a false positive for `Lint/ShadowedArgument` when reassigning to splat variable. ([@koic][])
* [#6035](https://github.com/rubocop/rubocop/issues/6035): Fix error on auto-correction when `Layout/LeadingBlankLines` is the first cop to act. ([@Vasfed][])
* [#6036](https://github.com/rubocop/rubocop/issues/6036): Make `Rails/BulkChangeTable` aware of string table name. ([@wata727][])
* [#5467](https://github.com/rubocop/rubocop/issues/5467): Fix a false negative for `Style/MultipleComparison` when multiple comparison is not part of a conditional. ([@koic][])
* [#6042](https://github.com/rubocop/rubocop/pull/6042): Fix `Lint/RedundantWithObject` error on missing parameter to `each_with_object`. ([@Vasfed][])
* [#6056](https://github.com/rubocop/rubocop/pull/6056): Support string timestamps in `Rails/CreateTableWithTimestamps` cop. ([@drn][])
* [#6052](https://github.com/rubocop/rubocop/issues/6052): Fix a false positive for `Style/SymbolProc` when using  block with adding a comma after the sole argument. ([@koic][])
* [#2743](https://github.com/rubocop/rubocop/issues/2743): Support `<<` as a kind of assignment operator in `Layout/EndAlignment`. ([@jonas054][])
* [#6067](https://github.com/rubocop/rubocop/issues/6067): Prevent auto-correct error for `Performance/InefficientHashSearch` when a method by itself and `include?` method are method chaining. ([@koic][])

### Changes

* [#6006](https://github.com/rubocop/rubocop/pull/6006): Remove `rake repl` task. ([@koic][])
* [#5990](https://github.com/rubocop/rubocop/pull/5990): Drop support for MRI 2.1. ([@drenmi][])
* [#3299](https://github.com/rubocop/rubocop/issues/3299): `Lint/UselessAccessModifier` now warns when `private_class_method` is used without arguments. ([@Darhazer][])
* [#6026](https://github.com/rubocop/rubocop/pull/6026): Exclude `refine` by default from `Metrics/BlockLength` cop. ([@kddeisz][])
* [#4882](https://github.com/rubocop/rubocop/issues/4882): Use `IndentationWidth` of `Layout/Tab` for other cops. ([@AlexWayfer][])

## 0.57.2 (2018-06-12)

### Bug fixes

* [#5968](https://github.com/rubocop/rubocop/issues/5968): Prevent `Layout/ClosingHeredocIndentation` from raising an error on `<<` heredocs. ([@dvandersluis][])
* [#5965](https://github.com/rubocop/rubocop/issues/5965): Prevent `Layout/ClosingHeredocIndentation` from raising an error on heredocs containing only a newline. ([@drenmi][])
* Prevent a crash in `Layout/IndentationConsistency` cop triggered by an empty expression string interpolation. ([@alexander-lazarov][])
* [#5951](https://github.com/rubocop/rubocop/issues/5951): Prevent `Style/MethodCallWithArgsParentheses` from raising an error in certain cases. ([@drenmi][])

## 0.57.1 (2018-06-07)

### Bug fixes

* [#5963](https://github.com/rubocop/rubocop/issues/5963): Allow Performance/ReverseEach to apply to any receiver. ([@dvandersluis][])
* [#5917](https://github.com/rubocop/rubocop/issues/5917): Fix erroneous warning for `inherit_mode` directive. ([@jonas054][])
* [#5380](https://github.com/rubocop/rubocop/issues/5380): Fix false negative in `Layout/IndentationWidth` when an access modifier section has an invalid indentation body. ([@tatsuyafw][])
* [#5909](https://github.com/rubocop/rubocop/pull/5909): Even when a module has no public methods, `Layout/IndentationConsistency` should still register an offense for private methods. ([@jaredbeck][])
* [#5958](https://github.com/rubocop/rubocop/issues/5958): Handle empty method body in `Rails/BulkChangeTable`. ([@wata727][])
* [#5954](https://github.com/rubocop/rubocop/issues/5954): Make `Style/UnneededCondition` cop accepts a case of condition and `if_branch` are same when using `elsif` branch. ([@koic][])

## 0.57.0 (2018-06-06)

### New features

* [#5881](https://github.com/rubocop/rubocop/pull/5881): Add new `Rails/BulkChangeTable` cop. ([@wata727][])
* [#5444](https://github.com/rubocop/rubocop/pull/5444): Add new `Style/AccessModifierDeclarations` cop. ([@brandonweiss][])
* [#5803](https://github.com/rubocop/rubocop/issues/5803): Add new `Style/UnneededCondition` cop. ([@balbesina][])
* [#5406](https://github.com/rubocop/rubocop/issues/5406): Add new `Layout/ClosingHeredocIndentation` cop. ([@siegfault][])
* [#5823](https://github.com/rubocop/rubocop/issues/5823): Add new `slashes` style to `Rails/FilePath` since Ruby accepts forward slashes even on Windows. ([@sunny][])
* New cop `Layout/LeadingBlankLines` checks for empty lines at the beginning of a file. ([@rrosenblum][])

### Bug fixes

* [#5897](https://github.com/rubocop/rubocop/issues/5897): Fix `Style/SymbolArray` and `Style/WordArray` not working on arrays of size 1. ([@TikiTDO][])
* [#5894](https://github.com/rubocop/rubocop/pull/5894): Fix `Rails/AssertNot` to allow it to have failure message. ([@koic][])
* [#5888](https://github.com/rubocop/rubocop/issues/5888): Do not register an offense for `headers` or `env` keyword arguments in `Rails/HttpPositionalArguments`. ([@rrosenblum][])
* Fix the indentation of auto-corrected closing squiggly heredocs. ([@garettarrowood][])
* [#5908](https://github.com/rubocop/rubocop/pull/5908): Fix `Style/BracesAroundHashParameters` auto-correct going past the end of the file when the closing curly brace is on the last line of a file. ([@EiNSTeiN-][])
* Fix a bug where `Style/FrozenStringLiteralComment` would be added to the second line if the first line is empty. ([@rrosenblum][])
* [#5914](https://github.com/rubocop/rubocop/issues/5914): Make `Layout/SpaceInsideReferenceBrackets` aware of `no_space` when using nested reference brackets. ([@koic][])
* [#5799](https://github.com/rubocop/rubocop/issues/5799): Fix false positive in `Style/MixinGrouping` when method named `include` accepts block. ([@Darhazer][])

### Changes

* [#5937](https://github.com/rubocop/rubocop/pull/5937): Add new `--fix-layout/-x` command line alias. ([@scottmatthewman][])
* [#5887](https://github.com/rubocop/rubocop/issues/5887): Remove `Lint/SplatKeywordArguments` cop. ([@koic][])
* [#5761](https://github.com/rubocop/rubocop/pull/5761): Add `httpdate` to accepted `Rails/TimeZone` methods. ([@cupakromer][])
* [#5899](https://github.com/rubocop/rubocop/pull/5899): Add `xmlschema` to accepted `Rails/TimeZone` methods. ([@koic][])
* [#5906](https://github.com/rubocop/rubocop/pull/5906): Move REPL command from `rake repl` task to `bin/console` command. ([@koic][])
* [#5917](https://github.com/rubocop/rubocop/issues/5917): Let `inherit_mode` work for default configuration too. ([@jonas054][])
* [#5929](https://github.com/rubocop/rubocop/pull/5929): Stop including string extensions from `unicode/display_width`. ([@nroman-stripe][])

## 0.56.0 (2018-05-14)

### New features

* [#5848](https://github.com/rubocop/rubocop/pull/5848): Add new `Performance/InefficientHashSearch` cop. ([@JacobEvelyn][])
* [#5801](https://github.com/rubocop/rubocop/pull/5801): Add new `Rails/RefuteMethods` cop. ([@koic][])
* [#5805](https://github.com/rubocop/rubocop/pull/5805): Add new `Rails/AssertNot` cop. ([@composerinteralia][])
* [#4136](https://github.com/rubocop/rubocop/issues/4136): Allow more robust `Layout/ClosingParenthesisIndentation` detection including method chaining. ([@jfelchner][])
* [#5699](https://github.com/rubocop/rubocop/pull/5699): Add `consistent_relative_to_receiver` style option to `Layout/FirstParameterIndentation`. ([@jfelchner][])
* [#5821](https://github.com/rubocop/rubocop/pull/5821): Support `AR::Migration#up_only` for `Rails/ReversibleMigration` cop. ([@koic][])
* [#5800](https://github.com/rubocop/rubocop/issues/5800): Don't show a stacktrace for invalid command-line params. ([@shanecav84][])
* [#5845](https://github.com/rubocop/rubocop/pull/5845): Add new `Lint/ErbNewArguments` cop. ([@koic][])
* [#5871](https://github.com/rubocop/rubocop/pull/5871): Add new `Lint/SplatKeywordArguments` cop. ([@koic][])
* [#4247](https://github.com/rubocop/rubocop/issues/4247): Remove hard-coded file patterns and use only `Include`, `Exclude` and the new `RubyInterpreters` parameters for file selection. ([@jonas054][])

### Bug fixes

* Fix bug in `Style/EmptyMethod` which concatenated the method name and first argument if no method def parentheses are used. ([@thomasbrus][])
* [#5819](https://github.com/rubocop/rubocop/issues/5819): Fix `Rails/SaveBang` when using negated if. ([@Edouard-chin][])
* [#5286](https://github.com/rubocop/rubocop/issues/5286): Fix `Lint/SafeNavigationChain` not detecting chained operators after block. ([@Darhazer][])
* Fix bug where `Lint/SafeNavigationConsistency` registers multiple offenses for the same method call. ([@rrosenblum][])
* [#5713](https://github.com/rubocop/rubocop/issues/5713): Fix `Style/CommentAnnotation` reporting only the first of multiple consecutive offending lines. ([@svendittmer][])
* [#5791](https://github.com/rubocop/rubocop/issues/5791): Fix exception in `Lint/SafeNavigationConsistency` when there is code around the condition. ([@rrosenblum][])
* [#5784](https://github.com/rubocop/rubocop/issues/5784): Fix a false positive for `Rails/HasManyOrHasOneDependent` when using nested `with_options`. ([@koic][])
* [#4666](https://github.com/rubocop/rubocop/issues/4666): `--stdin` always treats input as Ruby source irregardless of filename. ([@PointlessOne][])
* Fix auto-correction for `Style/MethodCallWithArgsParentheses` adding extra parentheses if the method argument was already parenthesized. ([@dvandersluis][])
* [#5668](https://github.com/rubocop/rubocop/issues/5668): Fix an issue where files with unknown extensions, listed in `AllCops/Include` were not inspected when passing the file name as an option. ([@drenmi][])
* [#5809](https://github.com/rubocop/rubocop/issues/5809): Fix exception `Lint/PercentStringArray` and `Lint/PercentSymbolArray` when the inspected file is binary encoded. ([@akhramov][])
* [#5840](https://github.com/rubocop/rubocop/issues/5840): Do not register an offense for methods that `nil` responds to in `Lint/SafeNavigationConsistency`. ([@rrosenblum][])
* [#5862](https://github.com/rubocop/rubocop/issues/5862): Fix an incorrect auto-correct for `Lint/LiteralInInterpolation` if contains numbers. ([@koic][])
* [#5868](https://github.com/rubocop/rubocop/pull/5868): Fix `Rails/CreateTableWithTimestamps` when using hash options. ([@wata727][])
* [#5708](https://github.com/rubocop/rubocop/issues/5708): Fix exception in `Lint/UnneededCopEnableDirective` for instruction '# rubocop:enable **all**'. ([@balbesina][])
* Fix auto-correction of `Rails/HttpPositionalArguments` to use `session` instead of `header`. ([@rrosenblum][])

### Changes

* Split `Style/MethodMissing` into two cops, `Style/MethodMissingSuper` and `Style/MissingRespondToMissing`. ([@rrosenblum][])
* [#5757](https://github.com/rubocop/rubocop/issues/5757): Add `AllowInMultilineConditions` option to `Style/ParenthesesAroundCondition` cop. ([@Darhazer][])
* [#5806](https://github.com/rubocop/rubocop/issues/5806): Fix `Layout/SpaceInsideReferenceBrackets` when assigning a reference bracket to a reference bracket. ([@joshuapinter][])
* [#5082](https://github.com/rubocop/rubocop/issues/5082): Allow caching together with `--auto-correct`. ([@jonas054][])
* Add `try!` to the list of whitelisted methods for `Lint/SafeNavigationChain` and `Style/SafeNavigation`. ([@rrosenblum][])
* [#5886](https://github.com/rubocop/rubocop/pull/5886): Move `Style/EmptyLineAfterGuardClause` cop to `Layout` department. ([@koic][])

## 0.55.0 (2018-04-16)

### New features

* [#5753](https://github.com/rubocop/rubocop/pull/5753): Add new `Performance/UnneededSort` cop. ([@parkerfinch][])
* Add new `Lint/SafeNavigationConsistency` cop. ([@rrosenblum][])

### Bug fixes

* [#5759](https://github.com/rubocop/rubocop/pull/5759): Fix `Performance/RegexpMatch` cop not correcting negated match operator. ([@bdewater][])
* [#5726](https://github.com/rubocop/rubocop/issues/5726): Fix false positive for `:class_name` option in Rails/InverseOf cop. ([@bdewater][])
* [#5686](https://github.com/rubocop/rubocop/issues/5686): Fix a regression for `Style/SymbolArray` and `Style/WordArray` for multiline Arrays. ([@istateside][])
* [#5730](https://github.com/rubocop/rubocop/pull/5730): Stop `Rails/InverseOf` cop allowing `inverse_of: nil` to opt-out. ([@bdewater][])
* [#5561](https://github.com/rubocop/rubocop/issues/5561): Fix `Lint/ShadowedArgument` false positive with shorthand assignments. ([@akhramov][])
* [#5403](https://github.com/rubocop/rubocop/issues/5403): Fix `Naming/HeredocDelimiterNaming` blacklist patterns. ([@mcfisch][])
* [#4298](https://github.com/rubocop/rubocop/issues/4298): Fix auto-correction of `Performance/RegexpMatch` to produce code that safe guards against the receiver being `nil`. ([@rrosenblum][])
* [#5738](https://github.com/rubocop/rubocop/issues/5738): Make `Rails/HttpStatus` ignoring hash order to fix false negative. ([@pocke][])
* [#5720](https://github.com/rubocop/rubocop/pull/5720): Fix false positive for `Style/EmptyLineAfterGuardClause` when guard clause is after heredoc. ([@koic][])
* [#5760](https://github.com/rubocop/rubocop/pull/5760): Fix incorrect offense location for `Style/EmptyLineAfterGuardClause` when guard clause is after heredoc argument. ([@koic][])
* [#5764](https://github.com/rubocop/rubocop/pull/5764): Fix `Style/UnpackFirst` false positive of `unpack('h*').take(1)`. ([@parkerfinch][])
* [#5766](https://github.com/rubocop/rubocop/issues/5766): Update `Style/FrozenStringLiteralComment` auto-correction to insert a new line between the comment and the code. ([@rrosenblum][])
* [#5551](https://github.com/rubocop/rubocop/issues/5551): Fix `Lint/Void` not detecting void context in blocks with single expression. ([@Darhazer][])

### Changes

* [#5752](https://github.com/rubocop/rubocop/pull/5752): Add `String#delete_{prefix,suffix}` to Lint/Void cop. ([@bdewater][])
* [#5734](https://github.com/rubocop/rubocop/pull/5734): Add `by`, `on`, `in` and `at` to allowed names of `Naming/UncommunicativeMethodParamName` cop in default config. ([@AlexWayfer][])
* [#5666](https://github.com/rubocop/rubocop/issues/5666): Add spaces as an `EnforcedStyle` option to `Layout/SpaceInsideParens`, allowing you to enforce spaces inside of parentheses. ([@joshuapinter][])
* [#4257](https://github.com/rubocop/rubocop/issues/4257): Allow specifying module name in `Metrics/BlockLength`'s `ExcludedMethods` configuration option. ([@akhramov][])
* [#4753](https://github.com/rubocop/rubocop/issues/4753): Add `IgnoredMethods` option to `Style/MethodCallWithoutArgsParentheses` cop. ([@Darhazer][])
* [#4517](https://github.com/rubocop/rubocop/issues/4517): Add option to allow trailing whitespaces inside heredoc strings. ([@Darhazer][])
* [#5652](https://github.com/rubocop/rubocop/issues/5652): Make `Style/OptionHash` aware of implicit parameter passing to super. ([@Wei-LiangChew][])
* [#5451](https://github.com/rubocop/rubocop/issues/5451): When using --auto-gen-config, do not output offenses unless the --output-offenses flag is also passed. ([@drewpterry][])

## 0.54.0 (2018-03-21)

### New features

* [#5597](https://github.com/rubocop/rubocop/pull/5597): Add new `Rails/HttpStatus` cop. ([@anthony-robin][])
* [#5643](https://github.com/rubocop/rubocop/pull/5643): Add new `Style/UnpackFirst` cop. ([@bdewater][])

### Bug fixes

* [#5744](https://github.com/rubocop/rubocop/pull/5744): Teach `Performance/StartWith` and `EndWith` cops to look for `Regexp#match?`. ([@bdewater][])
* [#5683](https://github.com/rubocop/rubocop/issues/5683): Fix message for `Naming/UncommunicativeXParamName` cops. ([@jlfaber][])
* [#5680](https://github.com/rubocop/rubocop/issues/5680): Fix `Layout/ElseAlignment` for `rescue/else/ensure` inside `do/end` blocks. ([@YukiJikumaru][])
* [#5642](https://github.com/rubocop/rubocop/pull/5642): Fix `Style/Documentation` `:nodoc:` for compact-style nested modules/classes. ([@ojab][])
* [#5648](https://github.com/rubocop/rubocop/issues/5648): Suggest valid memoized instance variable for predicate method. ([@satyap][])
* [#5670](https://github.com/rubocop/rubocop/issues/5670): Suggest valid memoized instance variable for bang method. ([@pocke][])
* [#5623](https://github.com/rubocop/rubocop/pull/5623): Fix `Bundler/OrderedGems` when a group includes duplicate gems. ([@colorbox][])
* [#5633](https://github.com/rubocop/rubocop/pull/5633): Fix broken `--fail-fast`. ([@mmyoji][])
* [#5630](https://github.com/rubocop/rubocop/issues/5630): Fix false positive for `Style/FormatStringToken` when using placeholder arguments in `format` method. ([@koic][])
* [#5651](https://github.com/rubocop/rubocop/pull/5651): Fix NoMethodError when specified config file that does not exist. ([@onk][])
* [#5647](https://github.com/rubocop/rubocop/pull/5647): Fix encoding method of RuboCop::MagicComment::SimpleComment. ([@htwroclau][])
* [#5619](https://github.com/rubocop/rubocop/issues/5619): Do not register an offense in `Style/InverseMethods` when comparing constants with `<`, `>`, `<=`, or `>=`. If the code is being used to determine class hierarchy, the correction might not be accurate. ([@rrosenblum][])
* [#5641](https://github.com/rubocop/rubocop/issues/5641): Disable `Style/TrivialAccessors` auto-correction for `def` with `private`. ([@pocke][])
* Fix bug where `Style/SafeNavigation` does not auto-correct all chained methods resulting in a `Lint/SafeNavigationChain` offense. ([@rrosenblum][])
* [#5436](https://github.com/rubocop/rubocop/issues/5436): Allow empty kwrest args in `UncommunicativeName` cops. ([@pocke][])
* [#5674](https://github.com/rubocop/rubocop/issues/5674): Fix auto-correction of `Layout/EmptyComment` when the empty comment appears on the same line as code. ([@rrosenblum][])
* [#5679](https://github.com/rubocop/rubocop/pull/5679): Fix a false positive for `Style/EmptyLineAfterGuardClause` when guard clause is before `rescue` or `ensure`. ([@koic][])
* [#5694](https://github.com/rubocop/rubocop/issues/5694): Match Rails versions with multiple digits when reading the TargetRailsVersion from the bundler lock files. ([@roberts1000][])
* [#5700](https://github.com/rubocop/rubocop/pull/5700): Fix a false positive for `Style/EmptyLineAfterGuardClause` when guard clause is before `else`. ([@koic][])
* Fix false positive in `Naming/ConstantName` when using conditional assignment. ([@drenmi][])

### Changes

* [#5626](https://github.com/rubocop/rubocop/pull/5626): Change `Naming/UncommunicativeMethodParamName` add `to` to allowed names in default config. ([@unused][])
* [#5640](https://github.com/rubocop/rubocop/issues/5640): Warn about user configuration overriding other user configuration only with `--debug`. ([@jonas054][])
* [#5637](https://github.com/rubocop/rubocop/issues/5637): Fix error for `Layout/SpaceInsideArrayLiteralBrackets` when contains an array literal as an argument after a heredoc is started. ([@koic][])
* [#5610](https://github.com/rubocop/rubocop/issues/5610): Use `gems.locked` or `Gemfile.lock` to determine the best `TargetRubyVersion` when it is not specified in the config. ([@roberts1000][])
* [#5390](https://github.com/rubocop/rubocop/issues/5390): Allow exceptions to `Style/InlineComment` for inline comments which enable or disable rubocop cops. ([@jfelchner][])
* Add progress bar to offenses formatter. ([@drewpterry][])
* [#5498](https://github.com/rubocop/rubocop/issues/5498): Correct `IndentHeredoc` message for Ruby 2.3 when using `<<~` operator with invalid indentation. ([@hamada14][])

## 0.53.0 (2018-03-05)

### New features

* [#3666](https://github.com/rubocop/rubocop/issues/3666): Add new `Naming/UncommunicativeBlockParamName` cop. ([@garettarrowood][])
* [#3666](https://github.com/rubocop/rubocop/issues/3666): Add new `Naming/UncommunicativeMethodParamName` cop. ([@garettarrowood][])
* [#5356](https://github.com/rubocop/rubocop/issues/5356): Add new `Lint/UnneededCopEnableDirective` cop. ([@garettarrowood][])
* [#5248](https://github.com/rubocop/rubocop/pull/5248): Add new `Lint/BigDecimalNew` cop. ([@koic][])
* Add new `Style/TrailingBodyOnClass` cop. ([@garettarrowood][])
* Add new `Style/TrailingBodyOnModule` cop. ([@garettarrowood][])
* [#3394](https://github.com/rubocop/rubocop/issues/3394): Add new `Style/TrailingCommaInArrayLiteral` cop. ([@garettarrowood][])
* [#3394](https://github.com/rubocop/rubocop/issues/3394): Add new `Style/TrailingCommaInHashLiteral` cop. ([@garettarrowood][])
* [#5319](https://github.com/rubocop/rubocop/pull/5319): Add new `Security/Open` cop. ([@mame][])
* Add `EnforcedStyleForEmptyBrackets` configuration to `Layout/SpaceInsideReferenceBrackets`. ([@garettarrowood][])
* [#5050](https://github.com/rubocop/rubocop/issues/5050): Add auto-correction to `Style/ModuleFunction`. ([@garettarrowood][])
* [#5358](https://github.com/rubocop/rubocop/pull/5358):  `--no-auto-gen-timestamp` CLI option suppresses the inclusion of the date and time it was generated in auto-generated config. ([@dominicsayers][])
* [#4274](https://github.com/rubocop/rubocop/issues/4274): Add new `Layout/EmptyComment` cop. ([@koic][])
* [#4477](https://github.com/rubocop/rubocop/issues/4477): Add new configuration directive: `inherit_mode` for merging arrays. ([@leklund][])
* [#5532](https://github.com/rubocop/rubocop/pull/5532): Include `.axlsx` file by default. ([@georf][])
* [#5490](https://github.com/rubocop/rubocop/issues/5490): Add new `Lint/OrderedMagicComments` cop. ([@koic][])
* [#4008](https://github.com/rubocop/rubocop/issues/4008): Add new `Style/ExpandPathArguments` cop. ([@koic][])
* [#4812](https://github.com/rubocop/rubocop/issues/4812): Add `beginning_only` and `ending_only` style options to `Layout/EmptyLinesAroundClassBody` cop. ([@jmks][])
* [#5591](https://github.com/rubocop/rubocop/pull/5591): Include `.arb` file by default. ([@deivid-rodriguez][])
* [#5473](https://github.com/rubocop/rubocop/issues/5473): Use `gems.locked` or `Gemfile.lock` to determine the best `TargetRailsVersion` when it is not specified in the config. ([@roberts1000][])
* Add new `Naming/MemoizedInstanceVariableName` cop. ([@satyap][])
* [#5376](https://github.com/rubocop/rubocop/issues/5376): Add new `Style/EmptyLineAfterGuardClause` cop. ([@unkmas][])
* Add new `Rails/ActiveRecordAliases` cop. ([@elebow][])

### Bug fixes

* [#4105](https://github.com/rubocop/rubocop/issues/4105): Fix `Lint/IndentationWidth` when `Lint/EndAlignment` is configured with `start_of_line`. ([@brandonweiss][])
* [#5453](https://github.com/rubocop/rubocop/issues/5453): Fix erroneous downcase in `Performance/Casecmp` auto-correction. ([@walinga][])
* [#5343](https://github.com/rubocop/rubocop/issues/5343): Fix offense detection in `Style/TrailingMethodEndStatement`. ([@garettarrowood][])
* [#5334](https://github.com/rubocop/rubocop/issues/5334): Fix semicolon removal for `Style/TrailingBodyOnMethodDefinition` auto-correction. ([@garettarrowood][])
* [#5350](https://github.com/rubocop/rubocop/issues/5350): Fix `Metric/LineLength` false offenses for URLs in double quotes. ([@garettarrowood][])
* [#5333](https://github.com/rubocop/rubocop/issues/5333): Fix `Layout/EmptyLinesAroundArguments` false positives for inline access modifiers. ([@garettarrowood][])
* [#5339](https://github.com/rubocop/rubocop/issues/5339): Fix `Layout/EmptyLinesAroundArguments` false positives for multiline heredoc arguments. ([@garettarrowood][])
* [#5383](https://github.com/rubocop/rubocop/issues/5383): Fix `Rails/Presence` false detection of receiver for locally defined `blank?` & `present?` methods. ([@garettarrowood][])
* [#5314](https://github.com/rubocop/rubocop/issues/5314): Fix false positives for `Lint/NestedPercentLiteral` when percent characters are nested. ([@asherkach][])
* [#5357](https://github.com/rubocop/rubocop/issues/5357): Fix `Lint/InterpolationCheck` false positives on escaped interpolations. ([@pocke][])
* [#5409](https://github.com/rubocop/rubocop/issues/5409): Fix multiline indent for `Style/SymbolArray` and `Style/WordArray` auto-correct. ([@flyerhzm][])
* [#5393](https://github.com/rubocop/rubocop/issues/5393): Fix `Rails/Delegate`'s false positive with a method call with arguments. ([@pocke][])
* [#5348](https://github.com/rubocop/rubocop/issues/5348): Fix false positive for `Style/SafeNavigation` when safe guarding more comparison methods. ([@rrosenblum][])
* [#4889](https://github.com/rubocop/rubocop/issues/4889): Auto-correcting `Style/SafeNavigation` will add safe navigation to all methods in a method chain. ([@rrosenblum][])
* [#5287](https://github.com/rubocop/rubocop/issues/5287): Do not register an offense in `Style/SafeNavigation` if there is an unsafe method used in a method chain. ([@rrosenblum][])
* [#5401](https://github.com/rubocop/rubocop/issues/5401): Fix `Style/RedundantReturn` to trigger when begin-end, rescue, and ensure blocks present. ([@asherkach][])
* [#5426](https://github.com/rubocop/rubocop/issues/5426): Make `Rails/InverseOf` accept `inverse_of: nil` to opt-out. ([@wata727][])
* [#5448](https://github.com/rubocop/rubocop/issues/5448): Improve `Rails/LexicallyScopedActionFilter`. ([@wata727][])
* [#3947](https://github.com/rubocop/rubocop/issues/3947): Fix false positive for `Rails/FilePath` when using `Rails.root.join` in string interpolation of argument. ([@koic][])
* [#5479](https://github.com/rubocop/rubocop/issues/5479): Fix false positives for `Rails/Presence` when using with `elsif`. ([@wata727][])
* [#5427](https://github.com/rubocop/rubocop/pull/5427): Fix exception when executing from a different drive on Windows. ([@orgads][])
* [#5429](https://github.com/rubocop/rubocop/issues/5429): Detect tabs other than indentation by `Layout/Tab`. ([@pocke][])
* [#5496](https://github.com/rubocop/rubocop/pull/5496): Fix a false positive of `Style/FormatStringToken` with unrelated `format` call. ([@pocke][])
* [#5503](https://github.com/rubocop/rubocop/issues/5503): Fix `Rails/CreateTableWithTimestamps` false positive when using `to_proc` syntax. ([@wata727][])
* [#5512](https://github.com/rubocop/rubocop/issues/5512): Improve `Lint/Void` to detect `Kernel#tap` as method that ignores the block's value. ([@untitaker][])
* [#5520](https://github.com/rubocop/rubocop/issues/5520): Fix `Style/RedundantException` auto-correction does not keep parenthesization. ([@dpostorivo][])
* [#5524](https://github.com/rubocop/rubocop/issues/5524): Return the instance based on the new type when calls `RuboCop::AST::Node#updated`. ([@wata727][])
* [#5527](https://github.com/rubocop/rubocop/issues/5527): Avoid behavior-changing corrections in `Style/SafeNavigation`. ([@jonas054][])
* [#5539](https://github.com/rubocop/rubocop/pull/5539): Fix compilation error and ruby code generation when passing args to funcall and predicates. ([@Edouard-chin][])
* [#4669](https://github.com/rubocop/rubocop/issues/4669): Use binary file contents for cache key so changing EOL characters invalidates the cache. ([@jonas054][])
* [#3947](https://github.com/rubocop/rubocop/issues/3947): Fix false positive for `Performance::RegexpMatch` when using `MatchData` before guard clause. ([@koic][])
* [#5515](https://github.com/rubocop/rubocop/issues/5515): Fix `Style/EmptyElse` auto-correct for nested if and case statements. ([@asherkach][])
* [#5582](https://github.com/rubocop/rubocop/issues/5582): Fix `end` alignment for variable assignment with line break after `=` in `Layout/EndAlignment`. ([@jonas054][])
* [#5602](https://github.com/rubocop/rubocop/pull/5602): Fix false positive for `Style/ColonMethodCall` when using Java package namespace. ([@koic][])
* [#5603](https://github.com/rubocop/rubocop/pull/5603): Fix falsey offense for `Style/RedundantSelf` with pseudo variables. ([@pocke][])
* [#5547](https://github.com/rubocop/rubocop/issues/5547): Fix auto-correction of `Layout/BlockEndNewline` when there is top level code outside of a class. ([@rrosenblum][])
* [#5599](https://github.com/rubocop/rubocop/issues/5599): Fix the suggestion being used by `Lint/NumberConversion` to use base 10 with Integer. ([@rrosenblum][])
* [#5534](https://github.com/rubocop/rubocop/issues/5534): Fix `Style/EachWithObject` auto-correction leaves an empty line. ([@flyerhzm][])
* Fix `Layout/EmptyLinesAroundAccessModifier` false-negative when next string after access modifier started with end. ([@unkmas][])

### Changes

* [#5589](https://github.com/rubocop/rubocop/issues/5589): Remove `Performance/HashEachMethods` cop as it no longer provides a performance benefit. ([@urbanautomaton][])
* [#3394](https://github.com/rubocop/rubocop/issues/3394): Remove `Style/TrailingCommaInLiteral` in favor of two new cops. ([@garettarrowood][])
* Rename `Lint/UnneededDisable` to `Lint/UnneededCopDisableDirective`. ([@garettarrowood][])
* [#5365](https://github.com/rubocop/rubocop/pull/5365): Add `*.gemfile` to Bundler cop target. ([@sue445][])
* [#4477](https://github.com/rubocop/rubocop/issues/4477): Warn when user configuration overrides other user configuration. ([@jonas054][])
* [#5240](https://github.com/rubocop/rubocop/pull/5240): Make `Style/StringHashKeys` to accepts environment variables. ([@pocke][])
* [#5395](https://github.com/rubocop/rubocop/pull/5395): Always exit 2 when specified configuration file does not exist. ([@pocke][])
* [#5402](https://github.com/rubocop/rubocop/pull/5402): Remove undefined `ActiveSupport::TimeZone#strftime` method from defined dangerous methods of `Rails/TimeZone` cop. ([@koic][])
* [#4704](https://github.com/rubocop/rubocop/issues/4704): Move `Lint/EndAlignment`, `Lint/DefEndAlignment`, `Lint/BlockAlignment`, and `Lint/ConditionPosition` to the `Layout` namespace. ([@bquorning][])
* [#5283](https://github.com/rubocop/rubocop/issues/5283): Change file path output by `Formatter::JSONFormatter` from relative path to smart path. ([@koic][])
* `Style/SafeNavigation` will now register an offense for methods that `nil` responds to. ([@rrosenblum][])
* [#5542](https://github.com/rubocop/rubocop/pull/5542): Exclude `.git/` by default. ([@pocke][])
* Tell Read the Docs to build downloadable docs. ([@eostrom][])
* Change `Style/SafeNavigation` to no longer register an offense for method chains exceeding 2 methods. ([@rrosenblum][])
* Remove auto-correction from `Lint/SafeNavigationChain`. ([@rrosenblum][])
* Change the highlighting of `Lint/SafeNavigationChain` to highlight the entire method chain beyond the safe navigation portion. ([@rrosenblum][])

## 0.52.1 (2017-12-27)

### Bug fixes

* [#5241](https://github.com/rubocop/rubocop/issues/5241): Fix an error for `Layout/AlignHash` when using a hash including only a keyword splat. ([@wata727][])
* [#5245](https://github.com/rubocop/rubocop/issues/5245): Make `Style/FormatStringToken` to allow regexp token. ([@pocke][])
* [#5224](https://github.com/rubocop/rubocop/pull/5224): Fix false positives for `Layout/EmptyLinesAroundArguments` operating on blocks. ([@garettarrowood][])
* [#5234](https://github.com/rubocop/rubocop/issues/5234): Fix a false positive for `Rails/HasManyOrHasOneDependent` when using `class_name` option. ([@koic][])
* [#5273](https://github.com/rubocop/rubocop/issues/5273): Fix `Style/EvalWithLocation` reporting bad line offset. ([@pocke][])
* [#5228](https://github.com/rubocop/rubocop/issues/5228): Handle overridden `Metrics/LineLength:Max` for `--auto-gen-config`. ([@jonas054][])
* [#5226](https://github.com/rubocop/rubocop/issues/5226): Suppress false positives for `Rails/RedundantReceiverInWithOptions` when including another receiver in `with_options`. ([@wata727][])
* [#5259](https://github.com/rubocop/rubocop/pull/5259): Fix false positives in `Style/CommentedKeyword`. ([@garettarrowood][])
* [#5238](https://github.com/rubocop/rubocop/pull/5238): Fix error when #present? or #blank? is used in if or unless modifier. ([@eitoball][])
* [#5261](https://github.com/rubocop/rubocop/issues/5261): Fix a false positive for `Style/MixinUsage` when using inside class or module. ([@koic][])
* [#5289](https://github.com/rubocop/rubocop/issues/5289): Fix `Layout/SpaceInsideReferenceBrackets` and `Layout/SpaceInsideArrayLiteralBrackets` configuration conflicts. ([@garettarrowood][])
* [#4444](https://github.com/rubocop/rubocop/issues/4444): Fix `Style/AutoResourceCleanup` shouldn't flag `File.open(...).close`. ([@dpostorivo][])
* [#5278](https://github.com/rubocop/rubocop/pull/5278): Fix deprecation check to use `loaded_path` in warning. ([@chrishulton][])
* [#5293](https://github.com/rubocop/rubocop/issues/5293): Fix a regression for `Rails/HasManyOrHasOneDependent` when using a option of `has_many` or `has_one` association. ([@koic][])
* [#5223](https://github.com/rubocop/rubocop/issues/5223): False offences in :unannotated Style/FormatStringToken. ([@nattfodd][])
* [#5258](https://github.com/rubocop/rubocop/issues/5258): Fix incorrect auto-correction for `Rails/Presence` when the else block is multiline. ([@wata727][])
* [#5297](https://github.com/rubocop/rubocop/pull/5297): Improve inspection for `Rails/InverseOf` when including `through` or `polymorphic` options. ([@wata727][])
* [#5281](https://github.com/rubocop/rubocop/issues/5281): Fix issue where `--auto-gen-config` might fail on invalid YAML. ([@bquorning][])
* [#5313](https://github.com/rubocop/rubocop/issues/5313): Fix `Style/HashSyntax` from stripping quotes off of symbols during auto-correction for ruby22+. ([@garettarrowood][])
* [#5315](https://github.com/rubocop/rubocop/issues/5315): Fix a false positive of `Layout/RescueEnsureAlignment` in Ruby 2.5. ([@pocke][])
* [#5236](https://github.com/rubocop/rubocop/issues/5236): Fix false positives for `Rails/InverseOf` when using `with_options`. ([@wata727][])
* [#5291](https://github.com/rubocop/rubocop/issues/5291): Fix multiline indent for `Style/BracesAroundHashParameters` auto-correct. ([@flyerhzm][])
* [#3318](https://github.com/rubocop/rubocop/issues/3318): Look for `.ruby-version` in parent directories. ([@ybiquitous][])

### Changes

* [#5300](https://github.com/rubocop/rubocop/pull/5300): Display correction candidate if an incorrect cop name is given. ([@yhirano55][])
* [#5233](https://github.com/rubocop/rubocop/pull/5233): Remove `Style/ExtendSelf` cop. ([@pocke][])
* [#5221](https://github.com/rubocop/rubocop/issues/5221): Change `Layout/SpaceBeforeBlockBraces`'s `EnforcedStyleForEmptyBraces` from `no_space` to `space`. ([@garettarrowood][])
* [#3558](https://github.com/rubocop/rubocop/pull/3558): Create `Corrector` classes and move all `autocorrect` methods out of mixin Modules. ([@garettarrowood][])
* [#3437](https://github.com/rubocop/rubocop/issues/3437): Add new `Lint/NumberConversion` cop. ([@albertpaulp][])

## 0.52.0 (2017-12-12)

### New features

* [#5101](https://github.com/rubocop/rubocop/pull/5101): Allow to specify `TargetRubyVersion` 2.5. ([@walf443][])
* [#1575](https://github.com/rubocop/rubocop/issues/1575): Add new `Layout/ClassStructure` cop that checks whether definitions in a class are in the configured order. This cop is disabled by default. ([@jonatas][])
* New cop `Rails/InverseOf` checks for association arguments that require setting the `inverse_of` option manually. ([@bdewater][])
* [#4811](https://github.com/rubocop/rubocop/issues/4811): Add new `Layout/SpaceInsideReferenceBrackets` cop. ([@garettarrowood][])
* [#4811](https://github.com/rubocop/rubocop/issues/4811): Add new `Layout/SpaceInsideArrayLiteralBrackets` cop. ([@garettarrowood][])
* [#4252](https://github.com/rubocop/rubocop/issues/4252): Add new `Style/TrailingBodyOnMethodDefinition` cop. ([@garettarrowood][])
* Add new `Style/TrailingMethodEndStatement` cop. ([@garettarrowood][])
* [#5074](https://github.com/rubocop/rubocop/issues/5074): Add Layout/EmptyLinesAroundArguments cop. ([@garettarrowood][])
* [#4650](https://github.com/rubocop/rubocop/issues/4650): Add new `Style/StringHashKeys` cop. ([@donjar][])
* [#1583](https://github.com/rubocop/rubocop/issues/1583): Add a quiet formatter. ([@drenmi][])
* Add new `Style/RandomWithOffset` cop. ([@donjar][])
* [#4892](https://github.com/rubocop/rubocop/issues/4892): Add new `Lint/ShadowedArgument` cop and remove argument shadowing detection from `Lint/UnusedBlockArgument` and `Lint/UnusedMethodArgument`. ([@akhramov][])
* [#4674](https://github.com/rubocop/rubocop/issues/4674): Add a new `Lint/MissingCopEnableDirective` cop. ([@tdeo][])
* Add new `Rails/EnvironmentComparison` cop. ([@tdeo][])
* Add `AllowedChars` option to `Style/AsciiComments` cop. ([@hedgesky][])
* [#5031](https://github.com/rubocop/rubocop/pull/5031): Add new `Style/EmptyBlockParameter` and `Style/EmptyLambdaParameter` cops. ([@pocke][])
* [#5057](https://github.com/rubocop/rubocop/pull/5057): Add new `Gemspec/RequiredRubyVersion` cop. ([@koic][])
* [#5087](https://github.com/rubocop/rubocop/pull/5087): Add new `Gemspec/RedundantAssignment` cop. ([@koic][])
* Add `unannotated` option to `Style/FormatStringToken` cop. ([@drenmi][])
* [#5077](https://github.com/rubocop/rubocop/pull/5077): Add new `Rails/CreateTableWithTimestamps` cop. ([@wata727][])
* Add new `Style/ColonMethodDefinition` cop. ([@rrosenblum][])
* Add new `Style/ExtendSelf` cop. ([@drenmi][])
* [#5185](https://github.com/rubocop/rubocop/pull/5185): Add new `Rails/RedundantReceiverInWithOptions` cop. ([@koic][])
* [#5177](https://github.com/rubocop/rubocop/pull/5177): Add new `Rails/LexicallyScopedActionFilter` cop. ([@wata727][])
* [#5173](https://github.com/rubocop/rubocop/pull/5173): Add new `Style/EvalWithLocation` cop. ([@pocke][])
* [#5208](https://github.com/rubocop/rubocop/pull/5208): Add new `Rails/Presence` cop. ([@wata727][])
* Allow auto-correction of ClassAndModuleChildren. ([@siegfault][], [@melch][])

### Bug fixes

* [#5096](https://github.com/rubocop/rubocop/issues/5096): Fix incorrect detection and auto-correction of multiple extend/include/prepend. ([@marcandre][])
* [#5219](https://github.com/rubocop/rubocop/issues/5219): Fix incorrect empty line detection for block arguments in `Layout/EmptyLinesAroundArguments`. ([@garettarrowood][])
* [#4662](https://github.com/rubocop/rubocop/issues/4662): Fix incorrect indent level detection when first line of heredoc is blank. ([@sambostock][])
* [#5016](https://github.com/rubocop/rubocop/issues/5016): Fix a false positive for `Style/ConstantName` with constant names using non-ASCII capital letters with accents. ([@timrogers][])
* [#4866](https://github.com/rubocop/rubocop/issues/4866): Prevent `Layout/BlockEndNewline` cop from introducing trailing whitespaces. ([@bgeuken][])
* [#3396](https://github.com/rubocop/rubocop/issues/3396): Concise error when config. file not found. ([@jaredbeck][])
* [#4881](https://github.com/rubocop/rubocop/issues/4881): Fix a false positive for `Performance/HashEachMethods` when unused argument(s) exists in other blocks. ([@pocke][])
* [#4883](https://github.com/rubocop/rubocop/pull/4883): Fix auto-correction for `Performance/HashEachMethods`. ([@pocke][])
* [#4896](https://github.com/rubocop/rubocop/pull/4896): Fix Style/DateTime wrongly triggered on classes `...::DateTime`. ([@dpostorivo][])
* [#4938](https://github.com/rubocop/rubocop/pull/4938): Fix behavior of `Lint/UnneededDisable`, which was returning offenses even after being disabled in a comment. ([@tdeo][])
* [#4887](https://github.com/rubocop/rubocop/pull/4887): Add undeclared configuration option `EnforcedStyleForEmptyBraces` for `Layout/SpaceBeforeBlockBraces` cop. ([@drenmi][])
* [#4987](https://github.com/rubocop/rubocop/pull/4987): Skip permission check when using stdin option. ([@mtsmfm][])
* [#4909](https://github.com/rubocop/rubocop/issues/4909): Make `Rails/HasManyOrHasOneDependent` aware of multiple associations in `with_options`. ([@koic][])
* [#4794](https://github.com/rubocop/rubocop/issues/4794): Fix an error in `Layout/MultilineOperationIndentation` when an operation spans multiple lines and contains a ternary expression. ([@rrosenblum][])
* [#4885](https://github.com/rubocop/rubocop/issues/4885): Fix false offense detected by `Style/MixinUsage` cop. ([@koic][])
* [#3363](https://github.com/rubocop/rubocop/pull/3363): Fix `Style/EmptyElse` auto-correction removes comments from branches. ([@dpostorivo][])
* [#5025](https://github.com/rubocop/rubocop/issues/5025): Fix error with Layout/MultilineMethodCallIndentation cop and lambda.(...). ([@dpostorivo][])
* [#4781](https://github.com/rubocop/rubocop/issues/4781): Prevent `Style/UnneededPercentQ` from breaking on strings that are concatenated with backslash. ([@pocke][])
* [#4363](https://github.com/rubocop/rubocop/issues/4363): Fix `Style/PercentLiteralDelimiters` incorrectly automatically modifies escaped percent literal delimiter. ([@koic][])
* [#5053](https://github.com/rubocop/rubocop/issues/5053): Fix `Naming/ConstantName` false offense on assigning to a nonoffensive assignment. ([@garettarrowood][])
* [#5019](https://github.com/rubocop/rubocop/pull/5019): Fix auto-correct for `Style/HashSyntax` cop when hash is used as unspaced argument. ([@drenmi][])
* [#5052](https://github.com/rubocop/rubocop/pull/5052): Improve accuracy of `Style/BracesAroundHashParameters` auto-correction. ([@garettarrowood][])
* [#5059](https://github.com/rubocop/rubocop/issues/5059): Fix a false positive for `Style/MixinUsage` when `include` call is a method argument. ([@koic][])
* [#5071](https://github.com/rubocop/rubocop/pull/5071): Fix a false positive in `Lint/UnneededSplatExpansion`, when `Array.new` resides in an array literal. ([@akhramov][])
* [#4071](https://github.com/rubocop/rubocop/issues/4071): Prevent generating wrong code by Style/ColonMethodCall and Style/RedundantSelf. ([@pocke][])
* [#5089](https://github.com/rubocop/rubocop/issues/5089): Fix false positive for `Style/SafeNavigation` when safe guarding arithmetic operation or assignment. ([@tiagotex][])
* [#5099](https://github.com/rubocop/rubocop/pull/5099): Prevent `Style/MinMax` from breaking on implicit receivers. ([@drenmi][])
* [#5079](https://github.com/rubocop/rubocop/issues/5079): Fix false positive for `Style/SafeNavigation` when safe guarding comparisons. ([@tiagotex][])
* [#5075](https://github.com/rubocop/rubocop/issues/5075): Fix auto-correct for `Style/RedundantParentheses` cop when unspaced ternary is present. ([@tiagotex][])
* [#5155](https://github.com/rubocop/rubocop/issues/5155): Fix a false negative for `Naming/ConstantName` cop when using frozen object assignment. ([@koic][])
* Fix a false positive in `Style/SafeNavigation` when the right hand side is negated. ([@rrosenblum][])
* [#5128](https://github.com/rubocop/rubocop/issues/5128): Fix `Bundler/OrderedGems` when gems are references from variables (ignores them in the sorting). ([@tdeo][])

### Changes

* [#4848](https://github.com/rubocop/rubocop/pull/4848): Exclude lambdas and procs from `Metrics/ParameterLists`. ([@reitermarkus][])
* [#5120](https://github.com/rubocop/rubocop/pull/5120):  Improve speed of RuboCop::PathUtil#smart_path. ([@walf443][])
* [#4888](https://github.com/rubocop/rubocop/pull/4888): Improve offense message of `Style/StderrPuts`. ([@jaredbeck][])
* [#4886](https://github.com/rubocop/rubocop/issues/4886): Fix false offense for Style/CommentedKeyword. ([@michniewicz][])
* [#4977](https://github.com/rubocop/rubocop/pull/4977): Make `Lint/RedundantWithIndex` cop aware of offset argument. ([@koic][])
* [#2679](https://github.com/rubocop/rubocop/issues/2679): Handle dependencies to `Metrics/LineLength: Max` when generating `.rubocop_todo.yml`. ([@jonas054][])
* [#4943](https://github.com/rubocop/rubocop/pull/4943): Make cop generator compliant with the repo's rubocop config. ([@tdeo][])
* [#5011](https://github.com/rubocop/rubocop/pull/5011): Remove `SupportedStyles` from "Configuration parameters" in `.rubocop_todo.yml`. ([@pocke][])
* `Lint/RescueWithoutErrorClass` has been replaced by `Style/RescueStandardError`. ([@rrosenblum][])
* [#4811](https://github.com/rubocop/rubocop/issues/4811): Remove `Layout/SpaceInsideBrackets` in favor of two new configurable cops. ([@garettarrowood][])
* [#5042](https://github.com/rubocop/rubocop/pull/5042): Make offense locations of metrics cops to contain whole a method. ([@pocke][])
* [#5044](https://github.com/rubocop/rubocop/pull/5044): Add last_line and last_column into outputs of the JSON formatter. ([@pocke][])
* [#4633](https://github.com/rubocop/rubocop/issues/4633): Make metrics cops aware of `define_method`. ([@pocke][])
* [#5037](https://github.com/rubocop/rubocop/pull/5037): Make display cop names to enable by default. ([@pocke][])
* [#4449](https://github.com/rubocop/rubocop/issues/4449): Make `Layout/IndentHeredoc` aware of line length. ([@pocke][])
* [#5146](https://github.com/rubocop/rubocop/pull/5146): Make `--show-cops` option aware of `--force-default-config`. ([@pocke][])
* [#3001](https://github.com/rubocop/rubocop/issues/3001): Add configuration to `Lint/MissingCopEnableDirective` cop. ([@tdeo][])
* [#4932](https://github.com/rubocop/rubocop/issues/4932): Do not fail if configuration contains `Lint/Syntax` cop with the same settings as the default. ([@tdeo][])
* [#5175](https://github.com/rubocop/rubocop/pull/5175): Make Style/RedundantBegin aware of do-end block in Ruby 2.5. ([@pocke][])

## 0.51.0 (2017-10-18)

### New features

* [#4791](https://github.com/rubocop/rubocop/pull/4791): Add new `Rails/UnknownEnv` cop. ([@pocke][])
* [#4690](https://github.com/rubocop/rubocop/issues/4690): Add new `Lint/UnneededRequireStatement` cop. ([@koic][])
* [#4813](https://github.com/rubocop/rubocop/pull/4813): Add new `Style/StderrPuts` cop. ([@koic][])
* [#4796](https://github.com/rubocop/rubocop/pull/4796): Add new `Lint/RedundantWithObject` cop. ([@koic][])
* [#4663](https://github.com/rubocop/rubocop/issues/4663): Add new `Style/CommentedKeyword` cop. ([@donjar][])
* Add `IndentationWidth` configuration for `Layout/Tab` cop. ([@rrosenblum][])
* [#4854](https://github.com/rubocop/rubocop/pull/4854): Add new `Lint/RegexpAsCondition` cop. ([@pocke][])
* [#4862](https://github.com/rubocop/rubocop/pull/4862): Add `MethodDefinitionMacros` option to `Naming/PredicateName` cop. ([@koic][])
* [#4874](https://github.com/rubocop/rubocop/pull/4874): Add new `Gemspec/OrderedDependencies` cop. ([@sue445][])
* [#4840](https://github.com/rubocop/rubocop/pull/4840): Add new `Style/MixinUsage` cop. ([@koic][])
* [#1952](https://github.com/rubocop/rubocop/issues/1952): Add new `Style/DateTime` cop. ([@dpostorivo][])
* [#4727](https://github.com/rubocop/rubocop/issues/4727): Make `Lint/Void` check for nonmutating methods as well. ([@donjar][])

### Bug fixes

* [#3312](https://github.com/rubocop/rubocop/issues/3312): Make `Rails/Date` Correct false positive on `#to_time` for strings ending in UTC-"Z". ([@erikdstock][])
* [#4741](https://github.com/rubocop/rubocop/issues/4741): Make `Style/SafeNavigation` correctly exclude methods called without dot. ([@drenmi][])
* [#4740](https://github.com/rubocop/rubocop/issues/4740): Make `Lint/RescueWithoutErrorClass` aware of modifier form `rescue`. ([@drenmi][])
* [#4745](https://github.com/rubocop/rubocop/issues/4745): Make `Style/SafeNavigation` ignore negated continuations. ([@drenmi][])
* [#4732](https://github.com/rubocop/rubocop/issues/4732): Prevent `Performance/HashEachMethods` from registering an offense when `#each` follows `#to_a`. ([@drenmi][])
* [#4730](https://github.com/rubocop/rubocop/issues/4730): False positive on Lint/InterpolationCheck. ([@koic][])
* [#4751](https://github.com/rubocop/rubocop/issues/4751): Prevent `Rails/HasManyOrHasOneDependent` cop from registering offense if `:through` option was specified. ([@smakagon][])
* [#4737](https://github.com/rubocop/rubocop/issues/4737): Fix ReturnInVoidContext cop when `return` is in top scope. ([@frodsan][])
* [#4776](https://github.com/rubocop/rubocop/issues/4776): Non utf-8 magic encoding comments are now respected. ([@deivid-rodriguez][])
* [#4241](https://github.com/rubocop/rubocop/issues/4241): Prevent `Rails/Blank` and `Rails/Present` from breaking when there is no explicit receiver. ([@rrosenblum][])
* [#4814](https://github.com/rubocop/rubocop/issues/4814): Prevent `Rails/Blank` from breaking on send with an argument. ([@pocke][])
* [#4759](https://github.com/rubocop/rubocop/issues/4759): Make `Naming/HeredocDelimiterNaming` and `Naming/HeredocDelimiterCase` aware of more delimiter patterns. ([@drenmi][])
* [#4823](https://github.com/rubocop/rubocop/issues/4823): Make `Lint/UnusedMethodArgument` and `Lint/UnusedBlockArgument` aware of overriding assignments. ([@akhramov][])
* [#4830](https://github.com/rubocop/rubocop/issues/4830): Prevent `Lint/BooleanSymbol` from truncating symbol's value in the message when offense is located in the new syntax hash. ([@akhramov][])
* [#4747](https://github.com/rubocop/rubocop/issues/4747): Fix `Rails/HasManyOrHasOneDependent` cop incorrectly flags `with_options` blocks. ([@koic][])
* [#4836](https://github.com/rubocop/rubocop/issues/4836): Make `Rails/OutputSafety` aware of safe navigation operator. ([@drenmi][])
* [#4843](https://github.com/rubocop/rubocop/issues/4843): Make `Lint/ShadowedException` cop aware of same system error code. ([@koic][])
* [#4757](https://github.com/rubocop/rubocop/issues/4757): Make `Style/TrailingUnderscoreVariable` work for nested assignments. ([@donjar][])
* [#4597](https://github.com/rubocop/rubocop/pull/4597): Fix `Style/StringLiterals` cop not registering an offense on single quoted strings containing an escaped single quote when configured to use double quotes. ([@promisedlandt][])
* [#4850](https://github.com/rubocop/rubocop/issues/4850): `Lint/UnusedMethodArgument` respects `IgnoreEmptyMethods` setting by ignoring unused method arguments for singleton methods. ([@jmks][])
* [#2040](https://github.com/rubocop/rubocop/issues/2040): Document how to write a custom cop. ([@jonatas][])

### Changes

* [#4746](https://github.com/rubocop/rubocop/pull/4746): The `Lint/InvalidCharacterLiteral` cop has been removed since it was never being actually triggered. ([@deivid-rodriguez][])
* [#4789](https://github.com/rubocop/rubocop/pull/4789): Analyzing code that needs to support MRI 1.9 is no longer supported. ([@deivid-rodriguez][])
* [#4582](https://github.com/rubocop/rubocop/issues/4582): `Severity` and other common parameters can be configured on department level. ([@jonas054][])
* [#4787](https://github.com/rubocop/rubocop/pull/4787): Analyzing code that needs to support MRI 2.0 is no longer supported. ([@deivid-rodriguez][])
* [#4787](https://github.com/rubocop/rubocop/pull/4787): RuboCop no longer installs on MRI 2.0. ([@deivid-rodriguez][])
* [#4266](https://github.com/rubocop/rubocop/issues/4266): Download the inherited config files of a remote file from the same remote. ([@tdeo][])
* [#4853](https://github.com/rubocop/rubocop/pull/4853): Make `Lint/LiteralInCondition` cop aware of `!` and `not`. ([@pocke][])
* [#4864](https://github.com/rubocop/rubocop/pull/4864): Rename `Lint/LiteralInCondition` to `Lint/LiteralAsCondition`. ([@pocke][])

## 0.50.0 (2017-09-14)

### New features

* [#4464](https://github.com/rubocop/rubocop/pull/4464): Add `EnforcedStyleForEmptyBraces` parameter to `Layout/SpaceBeforeBlockBraces` cop. ([@palkan][])
* [#4453](https://github.com/rubocop/rubocop/pull/4453): New cop `Style/RedundantConditional` checks for conditionals that return true/false. ([@petehamilton][])
* [#4448](https://github.com/rubocop/rubocop/pull/4448): Add new `TapFormatter`. ([@cyberdelia][])
* [#4467](https://github.com/rubocop/rubocop/pull/4467): Add new `Style/HeredocDelimiters` cop(Note: This cop was renamed to `Naming/HeredocDelimiterNaming`). ([@drenmi][])
* [#4153](https://github.com/rubocop/rubocop/issues/4153): New cop `Lint/ReturnInVoidContext` checks for the use of a return with a value in a context where it will be ignored. ([@harold-s][])
* [#4506](https://github.com/rubocop/rubocop/pull/4506): Add auto-correct support to `Lint/ScriptPermission`. ([@rrosenblum][])
* [#4514](https://github.com/rubocop/rubocop/pull/4514): Add configuration options to `Style/YodaCondition` to support checking all comparison operators or equality operators only. ([@smakagon][])
* [#4515](https://github.com/rubocop/rubocop/pull/4515): Add new `Lint/BooleanSymbol` cop. ([@droptheplot][])
* [#4535](https://github.com/rubocop/rubocop/pull/4535): Make `Rails/PluralizationGrammar` use singular methods for `-1` / `-1.0`. ([@promisedlandt][])
* [#4541](https://github.com/rubocop/rubocop/pull/4541): Add new `Rails/HasManyOrHasOneDependent` cop. ([@oboxodo][])
* [#4552](https://github.com/rubocop/rubocop/pull/4552): Add new `Style/Dir` cop. ([@drenmi][])
* [#4548](https://github.com/rubocop/rubocop/pull/4548): Add new `Style/HeredocDelimiterCase` cop(Note: This cop is renamed to `Naming/HeredocDelimiterCase`). ([@drenmi][])
* [#2943](https://github.com/rubocop/rubocop/pull/2943): Add new `Lint/RescueWithoutErrorClass` cop. ([@drenmi][])
* [#4568](https://github.com/rubocop/rubocop/pull/4568): Fix auto-correction for `Style/TrailingUnderscoreVariable`. ([@smakagon][])
* [#4586](https://github.com/rubocop/rubocop/pull/4586): Add new `Performance/UnfreezeString` cop. ([@pocke][])
* [#2976](https://github.com/rubocop/rubocop/issues/2976): Add `Whitelist` configuration option to `Style/NestedParenthesizedCalls` cop. ([@drenmi][])
* [#3965](https://github.com/rubocop/rubocop/issues/3965): Add new `Style/OrAssignment` cop. ([@donjar][])
* [#4655](https://github.com/rubocop/rubocop/pull/4655): Make `rake new_cop` create parent directories if they do not already exist. ([@highb][])
* [#4368](https://github.com/rubocop/rubocop/issues/4368): Make `Performance/HashEachMethod` inspect send nodes with any receiver. ([@gohdaniel15][])
* [#4508](https://github.com/rubocop/rubocop/issues/4508): Add new `Style/ReturnNil` cop. ([@donjar][])
* [#4629](https://github.com/rubocop/rubocop/issues/4629): Add Metrics/MethodLength cop for `define_method`. ([@jekuta][])
* [#4702](https://github.com/rubocop/rubocop/pull/4702): Add new `Lint/UriEscapeUnescape` cop. ([@koic][])
* [#4696](https://github.com/rubocop/rubocop/pull/4696): Add new `Performance/UriDefaultParser` cop. ([@koic][])
* [#4694](https://github.com/rubocop/rubocop/pull/4694): Add new `Lint/UriRegexp` cop. ([@koic][])
* [#4711](https://github.com/rubocop/rubocop/pull/4711): Add new `Style/MinMax` cop. ([@drenmi][])
* [#4720](https://github.com/rubocop/rubocop/pull/4720): Add new `Bundler/InsecureProtocolSource` cop. ([@koic][])
* [#4708](https://github.com/rubocop/rubocop/pull/4708): Add new `Lint/RedundantWithIndex` cop. ([@koic][])
* [#4480](https://github.com/rubocop/rubocop/pull/4480): Add new `Lint/InterpolationCheck` cop. ([@GauthamGoli][])
* [#4628](https://github.com/rubocop/rubocop/issues/4628): Add new `Lint/NestedPercentLiteral` cop. ([@asherkach][])

### Bug fixes

* [#4709](https://github.com/rubocop/rubocop/pull/4709): Use cached remote config on network failure. ([@kristjan][])
* [#4688](https://github.com/rubocop/rubocop/pull/4688): Accept yoda condition which isn't commutative. ([@fujimura][])
* [#4676](https://github.com/rubocop/rubocop/issues/4676): Make `Style/RedundantConditional` cop work with elsif. ([@akhramov][])
* [#4656](https://github.com/rubocop/rubocop/issues/4656): Modify `Style/ConditionalAssignment` auto-correction to work with unbracketed arrays. ([@akhramov][])
* [#4615](https://github.com/rubocop/rubocop/pull/4615): Don't consider `<=>` a comparison method. ([@iGEL][])
* [#4664](https://github.com/rubocop/rubocop/pull/4664): Fix typos in Rails/HttpPositionalArguments. ([@JoeCohen][])
* [#4618](https://github.com/rubocop/rubocop/pull/4618): Fix `Lint/FormatParameterMismatch` false positive if format string includes `%%5B` (CGI encoded left bracket). ([@barthez][])
* [#4604](https://github.com/rubocop/rubocop/pull/4604): Fix `Style/LambdaCall` to auto-correct `obj.call` to `obj.`. ([@iGEL][])
* [#4443](https://github.com/rubocop/rubocop/pull/4443): Prevent `Style/YodaCondition` from breaking `not LITERAL`. ([@pocke][])
* [#4434](https://github.com/rubocop/rubocop/issues/4434): Prevent bad auto-correct in `Style/Alias` for non-literal arguments. ([@drenmi][])
* [#4451](https://github.com/rubocop/rubocop/issues/4451): Make `Style/AndOr` cop aware of comparison methods. ([@drenmi][])
* [#4457](https://github.com/rubocop/rubocop/pull/4457): Fix false negative in `Lint/Void` with initialize and setter methods. ([@pocke][])
* [#4418](https://github.com/rubocop/rubocop/issues/4418): Register an offense in `Style/ConditionalAssignment` when the assignment line is the longest line, and it does not exceed the max line length. ([@rrosenblum][])
* [#4491](https://github.com/rubocop/rubocop/issues/4491): Prevent bad auto-correct in `Style/EmptyElse` for nested `if`. ([@pocke][])
* [#4485](https://github.com/rubocop/rubocop/pull/4485): Handle 304 status for remote config files. ([@daniloisr][])
* [#4529](https://github.com/rubocop/rubocop/pull/4529): Make `Lint/UnreachableCode` aware of `if` and `case`. ([@pocke][])
* [#4469](https://github.com/rubocop/rubocop/issues/4469): Include permissions in file cache. ([@pocke][])
* [#4270](https://github.com/rubocop/rubocop/issues/4270): Fix false positive in `Performance/RegexpMatch` for named captures. ([@pocke][])
* [#4525](https://github.com/rubocop/rubocop/pull/4525): Fix regexp for checking comment config of `rubocop:disable all` in `Lint/UnneededDisable`. ([@meganemura][])
* [#4555](https://github.com/rubocop/rubocop/issues/4555): Make `Style/VariableName` aware of optarg, kwarg and other arguments. ([@pocke][])
* [#4481](https://github.com/rubocop/rubocop/issues/4481): Prevent `Style/WordArray` and `Style/SymbolArray` from registering offenses where percent arrays don't work. ([@drenmi][])
* [#4447](https://github.com/rubocop/rubocop/issues/4447): Prevent `Layout/EmptyLineBetweenDefs` from removing too many lines. ([@drenmi][])
* [#3892](https://github.com/rubocop/rubocop/issues/3892): Make `Style/NumericPredicate` ignore numeric comparison of global variables. ([@drenmi][])
* [#4101](https://github.com/rubocop/rubocop/issues/4101): Skip auto-correct for literals with trailing comment and chained method call in `Layout/Multiline*BraceLayout`. ([@jonas054][])
* [#4518](https://github.com/rubocop/rubocop/issues/4518): Fix bug where `Style/SafeNavigation` does not register an offense when there are chained method calls. ([@rrosenblum][])
* [#3040](https://github.com/rubocop/rubocop/issues/3040): Ignore safe navigation in `Rails/Delegate`. ([@cgriego][])
* [#4587](https://github.com/rubocop/rubocop/pull/4587): Fix false negative for void unary operators in `Lint/Void` cop. ([@pocke][])
* [#4589](https://github.com/rubocop/rubocop/issues/4589): Fix false positive in `Performance/RegexpMatch` cop for `=~` is in a class method. ([@pocke][])
* [#4578](https://github.com/rubocop/rubocop/issues/4578): Fix false positive in `Lint/FormatParameterMismatch` for format with "asterisk" (`*`) width and precision. ([@smakagon][])
* [#4285](https://github.com/rubocop/rubocop/issues/4285): Make `Lint/DefEndAlignment` aware of multiple modifiers. ([@drenmi][])
* [#4634](https://github.com/rubocop/rubocop/issues/4634): Handle heredoc that contains empty lines only in `Layout/IndentHeredoc` cop. ([@pocke][])
* [#4646](https://github.com/rubocop/rubocop/issues/4646): Make `Lint/Debugger` aware of `Kernel` and cbase. ([@pocke][])
* [#4643](https://github.com/rubocop/rubocop/issues/4643): Modify `Style/InverseMethods` to not register a separate offense for an inverse method nested inside of the block of an inverse method offense. ([@rrosenblum][])
* [#4593](https://github.com/rubocop/rubocop/issues/4593): Fix false positive in `Rails/SaveBang` when `save/update_attribute` is used with a `case` statement. ([@theRealNG][])
* [#4322](https://github.com/rubocop/rubocop/issues/4322): Fix Style/MultilineMemoization from auto-correcting to invalid ruby. ([@dpostorivo][])
* [#4722](https://github.com/rubocop/rubocop/pull/4722): Fix `rake new_cop` problem that doesn't add `require` line. ([@koic][])
* [#4723](https://github.com/rubocop/rubocop/issues/4723): Fix `RaiseArgs` auto-correction issue for `raise` with 3 arguments. ([@smakagon][])

### Changes

* [#4470](https://github.com/rubocop/rubocop/issues/4470): Improve the error message for `Lint/AssignmentInCondition`. ([@brandonweiss][])
* [#4553](https://github.com/rubocop/rubocop/issues/4553): Add `node_modules` to default excludes. ([@iainbeeston][])
* [#4445](https://github.com/rubocop/rubocop/pull/4445): Make `Style/Encoding` cop enabled by default. ([@deivid-rodriguez][])
* [#4452](https://github.com/rubocop/rubocop/pull/4452): Add option to `Rails/Delegate` for enforcing the prefixed method name case. ([@klesse413][])
* [#4493](https://github.com/rubocop/rubocop/pull/4493): Make `Lint/Void` cop aware of `Enumerable#each` and `for`. ([@pocke][])
* [#4492](https://github.com/rubocop/rubocop/pull/4492): Make `Lint/DuplicateMethods` aware of `alias` and `alias_method`. ([@pocke][])
* [#4478](https://github.com/rubocop/rubocop/issues/4478): Fix confusing message of `Performance/Caller` cop. ([@pocke][])
* [#4543](https://github.com/rubocop/rubocop/pull/4543): Make `Lint/DuplicateMethods` aware of `attr_*` methods. ([@pocke][])
* [#4550](https://github.com/rubocop/rubocop/pull/4550): Mark `RuboCop::CLI#run` as a public API. ([@yujinakayama][])
* [#4551](https://github.com/rubocop/rubocop/pull/4551): Make `Performance/Caller` aware of `caller_locations`. ([@pocke][])
* [#4547](https://github.com/rubocop/rubocop/pull/4547): Rename `Style/HeredocDelimiters` to `Style/HeredocDelimiterNaming`. ([@drenmi][])
* [#4157](https://github.com/rubocop/rubocop/issues/4157): Enhance offense message for `Style/RedundantReturn` cop. ([@gohdaniel15][])
* [#4521](https://github.com/rubocop/rubocop/issues/4521): Move naming related cops into their own `Naming` department. ([@drenmi][])
* [#4600](https://github.com/rubocop/rubocop/pull/4600): Make `Style/RedundantSelf` aware of arguments of a block. ([@Envek][])
* [#4658](https://github.com/rubocop/rubocop/issues/4658): Disable auto-correction for `Performance/TimesMap` by default. ([@Envek][])

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
