# Change log

<!---
  Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.

  Please add an entry file to the https://github.com/rubocop/rubocop/blob/master/changelog/
  named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.

  See https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
-->

## master (unreleased)

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

* [#13839](https://github.com/rubocop/rubocop/pull/13839): Extension plugin is loaded automatically with `require 'rubocop/rspec/support'. ([@koic][])

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

## Older Versions
* [CHANGELOG_v1.0.0-v1.49.0](https://github.com/rubocop/rubocop/blob/master/relnotes/CHANGELOG_v1.0.0-v1.49.0.md)
* [CHANGELOG_v0.50.0-v0.93.1](https://github.com/rubocop/rubocop/blob/master/relnotes/CHANGELOG_v0.50.0-v0.93.1.md)
* [CHANGELOG_v0.19.0-v0.49.1](https://github.com/rubocop/rubocop/blob/master/relnotes/CHANGELOG_v0.19.0-v0.49.1.md)

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
