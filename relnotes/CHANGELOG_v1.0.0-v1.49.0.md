# Change log

<!---
  Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.

  Please add an entry file to the https://github.com/rubocop/rubocop/blob/master/changelog/
  named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.

  See https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
-->

See current entries: https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md

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
