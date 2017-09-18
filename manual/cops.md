## Cops

In RuboCop lingo the various checks performed on the code are called cops.
Each cop is responsible for detecting one particular offense. There are several
cop departments, grouping the cops by class of offense. A short description of
the different departments is provided below.

Many of the Style and Layout cops have configuration options, allowing them to
enforce different coding conventions.

You can also load [custom cops](extensions.md#custom-cops).

### Style

Style cops check for stylistic consistency of your code. Many of the them are
based on the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

### Layout

Layout cops inspect your code for consistent use of indentation, alignment,
and white space.

### Lint

Lint cops check for ambiguities and possible errors in your code.

RuboCop implements, in a portable way, all built-in MRI lint checks
(`ruby -wc`) and adds a lot of extra lint checks of its own.

You can run only the Lint cops like this:

```sh
$ rubocop -l
```

The `-l`/`--lint` option can be used together with `--only` to run all the
enabled Lint cops plus a selection of other cops.

Disabling Lint cops is generally a bad idea.

### Metrics

Metrics cops deal with properties of the source code that can be measured,
such as class length, method length, etc. Generally speaking, they have a
configuration parameter called `Max` and when running
`rubocop --auto-gen-config`, this parameter will be set to the highest value
found for the inspected code.

### Naming

Naming cops check for naming issue of your code, such as method name, constant
name, file name, etc.

### Performance

Performance cops catch Ruby idioms which are known to be slower than another,
semantically equivalent idiom.

### Security

Security cops checks for method calls and constructs which are known to be
associated with potential security issues.

### Rails

Rails cops are specific to the Ruby on Rails framework. Unlike all other cop
types they are not used by default, and you have to request them explicitly:

```sh
$ rubocop -R
```

or add the following directive to your `.rubocop.yml`:

```yaml
Rails:
  Enabled: true
```

### Bundler

Bundler cops check for style or bad practices in Bundler files, e.g. `Gemfile`.

### Available cops

In the following section you find all available cops:

<!-- START_COP_LIST -->
#### Department [Bundler](cops_bundler.md)

* [Bundler/DuplicatedGem](cops_bundler.md#bundlerduplicatedgem)
* [Bundler/InsecureProtocolSource](cops_bundler.md#bundlerinsecureprotocolsource)
* [Bundler/OrderedGems](cops_bundler.md#bundlerorderedgems)

#### Department [Layout](cops_layout.md)

* [Layout/AccessModifierIndentation](cops_layout.md#layoutaccessmodifierindentation)
* [Layout/AlignArray](cops_layout.md#layoutalignarray)
* [Layout/AlignHash](cops_layout.md#layoutalignhash)
* [Layout/AlignParameters](cops_layout.md#layoutalignparameters)
* [Layout/BlockEndNewline](cops_layout.md#layoutblockendnewline)
* [Layout/CaseIndentation](cops_layout.md#layoutcaseindentation)
* [Layout/ClosingParenthesisIndentation](cops_layout.md#layoutclosingparenthesisindentation)
* [Layout/CommentIndentation](cops_layout.md#layoutcommentindentation)
* [Layout/DotPosition](cops_layout.md#layoutdotposition)
* [Layout/ElseAlignment](cops_layout.md#layoutelsealignment)
* [Layout/EmptyLineAfterMagicComment](cops_layout.md#layoutemptylineaftermagiccomment)
* [Layout/EmptyLineBetweenDefs](cops_layout.md#layoutemptylinebetweendefs)
* [Layout/EmptyLines](cops_layout.md#layoutemptylines)
* [Layout/EmptyLinesAroundAccessModifier](cops_layout.md#layoutemptylinesaroundaccessmodifier)
* [Layout/EmptyLinesAroundBeginBody](cops_layout.md#layoutemptylinesaroundbeginbody)
* [Layout/EmptyLinesAroundBlockBody](cops_layout.md#layoutemptylinesaroundblockbody)
* [Layout/EmptyLinesAroundClassBody](cops_layout.md#layoutemptylinesaroundclassbody)
* [Layout/EmptyLinesAroundExceptionHandlingKeywords](cops_layout.md#layoutemptylinesaroundexceptionhandlingkeywords)
* [Layout/EmptyLinesAroundMethodBody](cops_layout.md#layoutemptylinesaroundmethodbody)
* [Layout/EmptyLinesAroundModuleBody](cops_layout.md#layoutemptylinesaroundmodulebody)
* [Layout/EndOfLine](cops_layout.md#layoutendofline)
* [Layout/ExtraSpacing](cops_layout.md#layoutextraspacing)
* [Layout/FirstArrayElementLineBreak](cops_layout.md#layoutfirstarrayelementlinebreak)
* [Layout/FirstHashElementLineBreak](cops_layout.md#layoutfirsthashelementlinebreak)
* [Layout/FirstMethodArgumentLineBreak](cops_layout.md#layoutfirstmethodargumentlinebreak)
* [Layout/FirstMethodParameterLineBreak](cops_layout.md#layoutfirstmethodparameterlinebreak)
* [Layout/FirstParameterIndentation](cops_layout.md#layoutfirstparameterindentation)
* [Layout/IndentArray](cops_layout.md#layoutindentarray)
* [Layout/IndentAssignment](cops_layout.md#layoutindentassignment)
* [Layout/IndentHash](cops_layout.md#layoutindenthash)
* [Layout/IndentHeredoc](cops_layout.md#layoutindentheredoc)
* [Layout/IndentationConsistency](cops_layout.md#layoutindentationconsistency)
* [Layout/IndentationWidth](cops_layout.md#layoutindentationwidth)
* [Layout/InitialIndentation](cops_layout.md#layoutinitialindentation)
* [Layout/LeadingCommentSpace](cops_layout.md#layoutleadingcommentspace)
* [Layout/MultilineArrayBraceLayout](cops_layout.md#layoutmultilinearraybracelayout)
* [Layout/MultilineAssignmentLayout](cops_layout.md#layoutmultilineassignmentlayout)
* [Layout/MultilineBlockLayout](cops_layout.md#layoutmultilineblocklayout)
* [Layout/MultilineHashBraceLayout](cops_layout.md#layoutmultilinehashbracelayout)
* [Layout/MultilineMethodCallBraceLayout](cops_layout.md#layoutmultilinemethodcallbracelayout)
* [Layout/MultilineMethodCallIndentation](cops_layout.md#layoutmultilinemethodcallindentation)
* [Layout/MultilineMethodDefinitionBraceLayout](cops_layout.md#layoutmultilinemethoddefinitionbracelayout)
* [Layout/MultilineOperationIndentation](cops_layout.md#layoutmultilineoperationindentation)
* [Layout/RescueEnsureAlignment](cops_layout.md#layoutrescueensurealignment)
* [Layout/SpaceAfterColon](cops_layout.md#layoutspaceaftercolon)
* [Layout/SpaceAfterComma](cops_layout.md#layoutspaceaftercomma)
* [Layout/SpaceAfterMethodName](cops_layout.md#layoutspaceaftermethodname)
* [Layout/SpaceAfterNot](cops_layout.md#layoutspaceafternot)
* [Layout/SpaceAfterSemicolon](cops_layout.md#layoutspaceaftersemicolon)
* [Layout/SpaceAroundBlockParameters](cops_layout.md#layoutspacearoundblockparameters)
* [Layout/SpaceAroundEqualsInParameterDefault](cops_layout.md#layoutspacearoundequalsinparameterdefault)
* [Layout/SpaceAroundKeyword](cops_layout.md#layoutspacearoundkeyword)
* [Layout/SpaceAroundOperators](cops_layout.md#layoutspacearoundoperators)
* [Layout/SpaceBeforeBlockBraces](cops_layout.md#layoutspacebeforeblockbraces)
* [Layout/SpaceBeforeComma](cops_layout.md#layoutspacebeforecomma)
* [Layout/SpaceBeforeComment](cops_layout.md#layoutspacebeforecomment)
* [Layout/SpaceBeforeFirstArg](cops_layout.md#layoutspacebeforefirstarg)
* [Layout/SpaceBeforeSemicolon](cops_layout.md#layoutspacebeforesemicolon)
* [Layout/SpaceInLambdaLiteral](cops_layout.md#layoutspaceinlambdaliteral)
* [Layout/SpaceInsideArrayPercentLiteral](cops_layout.md#layoutspaceinsidearraypercentliteral)
* [Layout/SpaceInsideBlockBraces](cops_layout.md#layoutspaceinsideblockbraces)
* [Layout/SpaceInsideBrackets](cops_layout.md#layoutspaceinsidebrackets)
* [Layout/SpaceInsideHashLiteralBraces](cops_layout.md#layoutspaceinsidehashliteralbraces)
* [Layout/SpaceInsideParens](cops_layout.md#layoutspaceinsideparens)
* [Layout/SpaceInsidePercentLiteralDelimiters](cops_layout.md#layoutspaceinsidepercentliteraldelimiters)
* [Layout/SpaceInsideRangeLiteral](cops_layout.md#layoutspaceinsiderangeliteral)
* [Layout/SpaceInsideStringInterpolation](cops_layout.md#layoutspaceinsidestringinterpolation)
* [Layout/Tab](cops_layout.md#layouttab)
* [Layout/TrailingBlankLines](cops_layout.md#layouttrailingblanklines)
* [Layout/TrailingWhitespace](cops_layout.md#layouttrailingwhitespace)

#### Department [Lint](cops_lint.md)

* [Lint/AmbiguousBlockAssociation](cops_lint.md#lintambiguousblockassociation)
* [Lint/AmbiguousOperator](cops_lint.md#lintambiguousoperator)
* [Lint/AmbiguousRegexpLiteral](cops_lint.md#lintambiguousregexpliteral)
* [Lint/AssignmentInCondition](cops_lint.md#lintassignmentincondition)
* [Lint/BlockAlignment](cops_lint.md#lintblockalignment)
* [Lint/BooleanSymbol](cops_lint.md#lintbooleansymbol)
* [Lint/CircularArgumentReference](cops_lint.md#lintcircularargumentreference)
* [Lint/ConditionPosition](cops_lint.md#lintconditionposition)
* [Lint/Debugger](cops_lint.md#lintdebugger)
* [Lint/DefEndAlignment](cops_lint.md#lintdefendalignment)
* [Lint/DeprecatedClassMethods](cops_lint.md#lintdeprecatedclassmethods)
* [Lint/DuplicateCaseCondition](cops_lint.md#lintduplicatecasecondition)
* [Lint/DuplicateMethods](cops_lint.md#lintduplicatemethods)
* [Lint/DuplicatedKey](cops_lint.md#lintduplicatedkey)
* [Lint/EachWithObjectArgument](cops_lint.md#linteachwithobjectargument)
* [Lint/ElseLayout](cops_lint.md#lintelselayout)
* [Lint/EmptyEnsure](cops_lint.md#lintemptyensure)
* [Lint/EmptyExpression](cops_lint.md#lintemptyexpression)
* [Lint/EmptyInterpolation](cops_lint.md#lintemptyinterpolation)
* [Lint/EmptyWhen](cops_lint.md#lintemptywhen)
* [Lint/EndAlignment](cops_lint.md#lintendalignment)
* [Lint/EndInMethod](cops_lint.md#lintendinmethod)
* [Lint/EnsureReturn](cops_lint.md#lintensurereturn)
* [Lint/FloatOutOfRange](cops_lint.md#lintfloatoutofrange)
* [Lint/FormatParameterMismatch](cops_lint.md#lintformatparametermismatch)
* [Lint/HandleExceptions](cops_lint.md#linthandleexceptions)
* [Lint/ImplicitStringConcatenation](cops_lint.md#lintimplicitstringconcatenation)
* [Lint/IneffectiveAccessModifier](cops_lint.md#lintineffectiveaccessmodifier)
* [Lint/InheritException](cops_lint.md#lintinheritexception)
* [Lint/InterpolationCheck](cops_lint.md#lintinterpolationcheck)
* [Lint/LiteralInCondition](cops_lint.md#lintliteralincondition)
* [Lint/LiteralInInterpolation](cops_lint.md#lintliteralininterpolation)
* [Lint/Loop](cops_lint.md#lintloop)
* [Lint/MultipleCompare](cops_lint.md#lintmultiplecompare)
* [Lint/NestedMethodDefinition](cops_lint.md#lintnestedmethoddefinition)
* [Lint/NextWithoutAccumulator](cops_lint.md#lintnextwithoutaccumulator)
* [Lint/NonLocalExitFromIterator](cops_lint.md#lintnonlocalexitfromiterator)
* [Lint/ParenthesesAsGroupedExpression](cops_lint.md#lintparenthesesasgroupedexpression)
* [Lint/PercentStringArray](cops_lint.md#lintpercentstringarray)
* [Lint/PercentSymbolArray](cops_lint.md#lintpercentsymbolarray)
* [Lint/RandOne](cops_lint.md#lintrandone)
* [Lint/RedundantWithIndex](cops_lint.md#lintredundantwithindex)
* [Lint/RequireParentheses](cops_lint.md#lintrequireparentheses)
* [Lint/RescueException](cops_lint.md#lintrescueexception)
* [Lint/RescueType](cops_lint.md#lintrescuetype)
* [Lint/RescueWithoutErrorClass](cops_lint.md#lintrescuewithouterrorclass)
* [Lint/ReturnInVoidContext](cops_lint.md#lintreturninvoidcontext)
* [Lint/SafeNavigationChain](cops_lint.md#lintsafenavigationchain)
* [Lint/ScriptPermission](cops_lint.md#lintscriptpermission)
* [Lint/ShadowedException](cops_lint.md#lintshadowedexception)
* [Lint/ShadowingOuterLocalVariable](cops_lint.md#lintshadowingouterlocalvariable)
* [Lint/StringConversionInInterpolation](cops_lint.md#lintstringconversionininterpolation)
* [Lint/Syntax](cops_lint.md#lintsyntax)
* [Lint/UnderscorePrefixedVariableName](cops_lint.md#lintunderscoreprefixedvariablename)
* [Lint/UnifiedInteger](cops_lint.md#lintunifiedinteger)
* [Lint/UnneededDisable](cops_lint.md#lintunneededdisable)
* [Lint/UnneededRequireStatement](cops_lint.md#lintunneededrequirestatement)
* [Lint/UnneededSplatExpansion](cops_lint.md#lintunneededsplatexpansion)
* [Lint/UnreachableCode](cops_lint.md#lintunreachablecode)
* [Lint/UnusedBlockArgument](cops_lint.md#lintunusedblockargument)
* [Lint/UnusedMethodArgument](cops_lint.md#lintunusedmethodargument)
* [Lint/UriEscapeUnescape](cops_lint.md#linturiescapeunescape)
* [Lint/UriRegexp](cops_lint.md#linturiregexp)
* [Lint/UselessAccessModifier](cops_lint.md#lintuselessaccessmodifier)
* [Lint/UselessAssignment](cops_lint.md#lintuselessassignment)
* [Lint/UselessComparison](cops_lint.md#lintuselesscomparison)
* [Lint/UselessElseWithoutRescue](cops_lint.md#lintuselesselsewithoutrescue)
* [Lint/UselessSetterCall](cops_lint.md#lintuselesssettercall)
* [Lint/Void](cops_lint.md#lintvoid)

#### Department [Metrics](cops_metrics.md)

* [Metrics/AbcSize](cops_metrics.md#metricsabcsize)
* [Metrics/BlockLength](cops_metrics.md#metricsblocklength)
* [Metrics/BlockNesting](cops_metrics.md#metricsblocknesting)
* [Metrics/ClassLength](cops_metrics.md#metricsclasslength)
* [Metrics/CyclomaticComplexity](cops_metrics.md#metricscyclomaticcomplexity)
* [Metrics/LineLength](cops_metrics.md#metricslinelength)
* [Metrics/MethodLength](cops_metrics.md#metricsmethodlength)
* [Metrics/ModuleLength](cops_metrics.md#metricsmodulelength)
* [Metrics/ParameterLists](cops_metrics.md#metricsparameterlists)
* [Metrics/PerceivedComplexity](cops_metrics.md#metricsperceivedcomplexity)

#### Department [Naming](cops_naming.md)

* [Naming/AccessorMethodName](cops_naming.md#namingaccessormethodname)
* [Naming/AsciiIdentifiers](cops_naming.md#namingasciiidentifiers)
* [Naming/BinaryOperatorParameterName](cops_naming.md#namingbinaryoperatorparametername)
* [Naming/ClassAndModuleCamelCase](cops_naming.md#namingclassandmodulecamelcase)
* [Naming/ConstantName](cops_naming.md#namingconstantname)
* [Naming/FileName](cops_naming.md#namingfilename)
* [Naming/HeredocDelimiterCase](cops_naming.md#namingheredocdelimitercase)
* [Naming/HeredocDelimiterNaming](cops_naming.md#namingheredocdelimiternaming)
* [Naming/MethodName](cops_naming.md#namingmethodname)
* [Naming/PredicateName](cops_naming.md#namingpredicatename)
* [Naming/VariableName](cops_naming.md#namingvariablename)
* [Naming/VariableNumber](cops_naming.md#namingvariablenumber)

#### Department [Performance](cops_performance.md)

* [Performance/Caller](cops_performance.md#performancecaller)
* [Performance/CaseWhenSplat](cops_performance.md#performancecasewhensplat)
* [Performance/Casecmp](cops_performance.md#performancecasecmp)
* [Performance/CompareWithBlock](cops_performance.md#performancecomparewithblock)
* [Performance/Count](cops_performance.md#performancecount)
* [Performance/Detect](cops_performance.md#performancedetect)
* [Performance/DoubleStartEndWith](cops_performance.md#performancedoublestartendwith)
* [Performance/EndWith](cops_performance.md#performanceendwith)
* [Performance/FixedSize](cops_performance.md#performancefixedsize)
* [Performance/FlatMap](cops_performance.md#performanceflatmap)
* [Performance/HashEachMethods](cops_performance.md#performancehasheachmethods)
* [Performance/LstripRstrip](cops_performance.md#performancelstriprstrip)
* [Performance/RangeInclude](cops_performance.md#performancerangeinclude)
* [Performance/RedundantBlockCall](cops_performance.md#performanceredundantblockcall)
* [Performance/RedundantMatch](cops_performance.md#performanceredundantmatch)
* [Performance/RedundantMerge](cops_performance.md#performanceredundantmerge)
* [Performance/RedundantSortBy](cops_performance.md#performanceredundantsortby)
* [Performance/RegexpMatch](cops_performance.md#performanceregexpmatch)
* [Performance/ReverseEach](cops_performance.md#performancereverseeach)
* [Performance/Sample](cops_performance.md#performancesample)
* [Performance/Size](cops_performance.md#performancesize)
* [Performance/StartWith](cops_performance.md#performancestartwith)
* [Performance/StringReplacement](cops_performance.md#performancestringreplacement)
* [Performance/TimesMap](cops_performance.md#performancetimesmap)
* [Performance/UnfreezeString](cops_performance.md#performanceunfreezestring)
* [Performance/UriDefaultParser](cops_performance.md#performanceuridefaultparser)

#### Department [Rails](cops_rails.md)

* [Rails/ActionFilter](cops_rails.md#railsactionfilter)
* [Rails/ActiveSupportAliases](cops_rails.md#railsactivesupportaliases)
* [Rails/ApplicationJob](cops_rails.md#railsapplicationjob)
* [Rails/ApplicationRecord](cops_rails.md#railsapplicationrecord)
* [Rails/Blank](cops_rails.md#railsblank)
* [Rails/Date](cops_rails.md#railsdate)
* [Rails/Delegate](cops_rails.md#railsdelegate)
* [Rails/DelegateAllowBlank](cops_rails.md#railsdelegateallowblank)
* [Rails/DynamicFindBy](cops_rails.md#railsdynamicfindby)
* [Rails/EnumUniqueness](cops_rails.md#railsenumuniqueness)
* [Rails/Exit](cops_rails.md#railsexit)
* [Rails/FilePath](cops_rails.md#railsfilepath)
* [Rails/FindBy](cops_rails.md#railsfindby)
* [Rails/FindEach](cops_rails.md#railsfindeach)
* [Rails/HasAndBelongsToMany](cops_rails.md#railshasandbelongstomany)
* [Rails/HasManyOrHasOneDependent](cops_rails.md#railshasmanyorhasonedependent)
* [Rails/HttpPositionalArguments](cops_rails.md#railshttppositionalarguments)
* [Rails/NotNullColumn](cops_rails.md#railsnotnullcolumn)
* [Rails/Output](cops_rails.md#railsoutput)
* [Rails/OutputSafety](cops_rails.md#railsoutputsafety)
* [Rails/PluralizationGrammar](cops_rails.md#railspluralizationgrammar)
* [Rails/Present](cops_rails.md#railspresent)
* [Rails/ReadWriteAttribute](cops_rails.md#railsreadwriteattribute)
* [Rails/RelativeDateConstant](cops_rails.md#railsrelativedateconstant)
* [Rails/RequestReferer](cops_rails.md#railsrequestreferer)
* [Rails/ReversibleMigration](cops_rails.md#railsreversiblemigration)
* [Rails/SafeNavigation](cops_rails.md#railssafenavigation)
* [Rails/SaveBang](cops_rails.md#railssavebang)
* [Rails/ScopeArgs](cops_rails.md#railsscopeargs)
* [Rails/SkipsModelValidations](cops_rails.md#railsskipsmodelvalidations)
* [Rails/TimeZone](cops_rails.md#railstimezone)
* [Rails/UniqBeforePluck](cops_rails.md#railsuniqbeforepluck)
* [Rails/UnknownEnv](cops_rails.md#railsunknownenv)
* [Rails/Validation](cops_rails.md#railsvalidation)

#### Department [Security](cops_security.md)

* [Security/Eval](cops_security.md#securityeval)
* [Security/JSONLoad](cops_security.md#securityjsonload)
* [Security/MarshalLoad](cops_security.md#securitymarshalload)
* [Security/YAMLLoad](cops_security.md#securityyamlload)

#### Department [Style](cops_style.md)

* [Style/Alias](cops_style.md#stylealias)
* [Style/AndOr](cops_style.md#styleandor)
* [Style/ArrayJoin](cops_style.md#stylearrayjoin)
* [Style/AsciiComments](cops_style.md#styleasciicomments)
* [Style/Attr](cops_style.md#styleattr)
* [Style/AutoResourceCleanup](cops_style.md#styleautoresourcecleanup)
* [Style/BarePercentLiterals](cops_style.md#stylebarepercentliterals)
* [Style/BeginBlock](cops_style.md#stylebeginblock)
* [Style/BlockComments](cops_style.md#styleblockcomments)
* [Style/BlockDelimiters](cops_style.md#styleblockdelimiters)
* [Style/BracesAroundHashParameters](cops_style.md#stylebracesaroundhashparameters)
* [Style/CaseEquality](cops_style.md#stylecaseequality)
* [Style/CharacterLiteral](cops_style.md#stylecharacterliteral)
* [Style/ClassAndModuleChildren](cops_style.md#styleclassandmodulechildren)
* [Style/ClassCheck](cops_style.md#styleclasscheck)
* [Style/ClassMethods](cops_style.md#styleclassmethods)
* [Style/ClassVars](cops_style.md#styleclassvars)
* [Style/CollectionMethods](cops_style.md#stylecollectionmethods)
* [Style/ColonMethodCall](cops_style.md#stylecolonmethodcall)
* [Style/CommandLiteral](cops_style.md#stylecommandliteral)
* [Style/CommentAnnotation](cops_style.md#stylecommentannotation)
* [Style/ConditionalAssignment](cops_style.md#styleconditionalassignment)
* [Style/Copyright](cops_style.md#stylecopyright)
* [Style/DefWithParentheses](cops_style.md#styledefwithparentheses)
* [Style/Dir](cops_style.md#styledir)
* [Style/Documentation](cops_style.md#styledocumentation)
* [Style/DocumentationMethod](cops_style.md#styledocumentationmethod)
* [Style/DoubleNegation](cops_style.md#styledoublenegation)
* [Style/EachForSimpleLoop](cops_style.md#styleeachforsimpleloop)
* [Style/EachWithObject](cops_style.md#styleeachwithobject)
* [Style/EmptyCaseCondition](cops_style.md#styleemptycasecondition)
* [Style/EmptyElse](cops_style.md#styleemptyelse)
* [Style/EmptyLiteral](cops_style.md#styleemptyliteral)
* [Style/EmptyMethod](cops_style.md#styleemptymethod)
* [Style/Encoding](cops_style.md#styleencoding)
* [Style/EndBlock](cops_style.md#styleendblock)
* [Style/EvenOdd](cops_style.md#styleevenodd)
* [Style/FlipFlop](cops_style.md#styleflipflop)
* [Style/For](cops_style.md#stylefor)
* [Style/FormatString](cops_style.md#styleformatstring)
* [Style/FormatStringToken](cops_style.md#styleformatstringtoken)
* [Style/FrozenStringLiteralComment](cops_style.md#stylefrozenstringliteralcomment)
* [Style/GlobalVars](cops_style.md#styleglobalvars)
* [Style/GuardClause](cops_style.md#styleguardclause)
* [Style/HashSyntax](cops_style.md#stylehashsyntax)
* [Style/IdenticalConditionalBranches](cops_style.md#styleidenticalconditionalbranches)
* [Style/IfInsideElse](cops_style.md#styleifinsideelse)
* [Style/IfUnlessModifier](cops_style.md#styleifunlessmodifier)
* [Style/IfUnlessModifierOfIfUnless](cops_style.md#styleifunlessmodifierofifunless)
* [Style/IfWithSemicolon](cops_style.md#styleifwithsemicolon)
* [Style/ImplicitRuntimeError](cops_style.md#styleimplicitruntimeerror)
* [Style/InfiniteLoop](cops_style.md#styleinfiniteloop)
* [Style/InlineComment](cops_style.md#styleinlinecomment)
* [Style/InverseMethods](cops_style.md#styleinversemethods)
* [Style/Lambda](cops_style.md#stylelambda)
* [Style/LambdaCall](cops_style.md#stylelambdacall)
* [Style/LineEndConcatenation](cops_style.md#stylelineendconcatenation)
* [Style/MethodCallWithArgsParentheses](cops_style.md#stylemethodcallwithargsparentheses)
* [Style/MethodCallWithoutArgsParentheses](cops_style.md#stylemethodcallwithoutargsparentheses)
* [Style/MethodCalledOnDoEndBlock](cops_style.md#stylemethodcalledondoendblock)
* [Style/MethodDefParentheses](cops_style.md#stylemethoddefparentheses)
* [Style/MethodMissing](cops_style.md#stylemethodmissing)
* [Style/MinMax](cops_style.md#styleminmax)
* [Style/MissingElse](cops_style.md#stylemissingelse)
* [Style/MixinGrouping](cops_style.md#stylemixingrouping)
* [Style/ModuleFunction](cops_style.md#stylemodulefunction)
* [Style/MultilineBlockChain](cops_style.md#stylemultilineblockchain)
* [Style/MultilineIfModifier](cops_style.md#stylemultilineifmodifier)
* [Style/MultilineIfThen](cops_style.md#stylemultilineifthen)
* [Style/MultilineMemoization](cops_style.md#stylemultilinememoization)
* [Style/MultilineTernaryOperator](cops_style.md#stylemultilineternaryoperator)
* [Style/MultipleComparison](cops_style.md#stylemultiplecomparison)
* [Style/MutableConstant](cops_style.md#stylemutableconstant)
* [Style/NegatedIf](cops_style.md#stylenegatedif)
* [Style/NegatedWhile](cops_style.md#stylenegatedwhile)
* [Style/NestedModifier](cops_style.md#stylenestedmodifier)
* [Style/NestedParenthesizedCalls](cops_style.md#stylenestedparenthesizedcalls)
* [Style/NestedTernaryOperator](cops_style.md#stylenestedternaryoperator)
* [Style/Next](cops_style.md#stylenext)
* [Style/NilComparison](cops_style.md#stylenilcomparison)
* [Style/NonNilCheck](cops_style.md#stylenonnilcheck)
* [Style/Not](cops_style.md#stylenot)
* [Style/NumericLiteralPrefix](cops_style.md#stylenumericliteralprefix)
* [Style/NumericLiterals](cops_style.md#stylenumericliterals)
* [Style/NumericPredicate](cops_style.md#stylenumericpredicate)
* [Style/OneLineConditional](cops_style.md#styleonelineconditional)
* [Style/OptionHash](cops_style.md#styleoptionhash)
* [Style/OptionalArguments](cops_style.md#styleoptionalarguments)
* [Style/OrAssignment](cops_style.md#styleorassignment)
* [Style/ParallelAssignment](cops_style.md#styleparallelassignment)
* [Style/ParenthesesAroundCondition](cops_style.md#styleparenthesesaroundcondition)
* [Style/PercentLiteralDelimiters](cops_style.md#stylepercentliteraldelimiters)
* [Style/PercentQLiterals](cops_style.md#stylepercentqliterals)
* [Style/PerlBackrefs](cops_style.md#styleperlbackrefs)
* [Style/PreferredHashMethods](cops_style.md#stylepreferredhashmethods)
* [Style/Proc](cops_style.md#styleproc)
* [Style/RaiseArgs](cops_style.md#styleraiseargs)
* [Style/RedundantBegin](cops_style.md#styleredundantbegin)
* [Style/RedundantConditional](cops_style.md#styleredundantconditional)
* [Style/RedundantException](cops_style.md#styleredundantexception)
* [Style/RedundantFreeze](cops_style.md#styleredundantfreeze)
* [Style/RedundantParentheses](cops_style.md#styleredundantparentheses)
* [Style/RedundantReturn](cops_style.md#styleredundantreturn)
* [Style/RedundantSelf](cops_style.md#styleredundantself)
* [Style/RegexpLiteral](cops_style.md#styleregexpliteral)
* [Style/RescueModifier](cops_style.md#stylerescuemodifier)
* [Style/ReturnNil](cops_style.md#stylereturnnil)
* [Style/SafeNavigation](cops_style.md#stylesafenavigation)
* [Style/SelfAssignment](cops_style.md#styleselfassignment)
* [Style/Semicolon](cops_style.md#stylesemicolon)
* [Style/Send](cops_style.md#stylesend)
* [Style/SignalException](cops_style.md#stylesignalexception)
* [Style/SingleLineBlockParams](cops_style.md#stylesinglelineblockparams)
* [Style/SingleLineMethods](cops_style.md#stylesinglelinemethods)
* [Style/SpecialGlobalVars](cops_style.md#stylespecialglobalvars)
* [Style/StabbyLambdaParentheses](cops_style.md#stylestabbylambdaparentheses)
* [Style/StringLiterals](cops_style.md#stylestringliterals)
* [Style/StringLiteralsInInterpolation](cops_style.md#stylestringliteralsininterpolation)
* [Style/StringMethods](cops_style.md#stylestringmethods)
* [Style/StructInheritance](cops_style.md#stylestructinheritance)
* [Style/SymbolArray](cops_style.md#stylesymbolarray)
* [Style/SymbolLiteral](cops_style.md#stylesymbolliteral)
* [Style/SymbolProc](cops_style.md#stylesymbolproc)
* [Style/TernaryParentheses](cops_style.md#styleternaryparentheses)
* [Style/TrailingCommaInArguments](cops_style.md#styletrailingcommainarguments)
* [Style/TrailingCommaInLiteral](cops_style.md#styletrailingcommainliteral)
* [Style/TrailingUnderscoreVariable](cops_style.md#styletrailingunderscorevariable)
* [Style/TrivialAccessors](cops_style.md#styletrivialaccessors)
* [Style/UnlessElse](cops_style.md#styleunlesselse)
* [Style/UnneededCapitalW](cops_style.md#styleunneededcapitalw)
* [Style/UnneededInterpolation](cops_style.md#styleunneededinterpolation)
* [Style/UnneededPercentQ](cops_style.md#styleunneededpercentq)
* [Style/VariableInterpolation](cops_style.md#stylevariableinterpolation)
* [Style/WhenThen](cops_style.md#stylewhenthen)
* [Style/WhileUntilDo](cops_style.md#stylewhileuntildo)
* [Style/WhileUntilModifier](cops_style.md#stylewhileuntilmodifier)
* [Style/WordArray](cops_style.md#stylewordarray)
* [Style/YodaCondition](cops_style.md#styleyodacondition)
* [Style/ZeroLengthPredicate](cops_style.md#stylezerolengthpredicate)

<!-- END_COP_LIST -->
