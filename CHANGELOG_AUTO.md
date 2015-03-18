# Change Log

## [Unreleased](https://github.com/bbatsov/rubocop/tree/HEAD)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.29.1...HEAD)

**Implemented enhancements:**

- Add autocorrect for Style/IfUnlessModifier cop [\#1281](https://github.com/bbatsov/rubocop/issues/1281)

- Add autocorrect for Style/WhileUntilModifier cop [\#1275](https://github.com/bbatsov/rubocop/issues/1275)

**Fixed bugs:**

- hash symbol key incorrectly converted to string [\#1684](https://github.com/bbatsov/rubocop/issues/1684)

**Closed issues:**

- Suspect false alert [\#1698](https://github.com/bbatsov/rubocop/issues/1698)

- Style/TrivialAccessors incorrectly suggests using attr\_writer for a method that stores a block [\#1694](https://github.com/bbatsov/rubocop/issues/1694)

- ExtraSpacingCop has no way of opting-out of variable assignment [\#1688](https://github.com/bbatsov/rubocop/issues/1688)

- Question mark reader method [\#1686](https://github.com/bbatsov/rubocop/issues/1686)

- Allow content piped to binary? [\#1682](https://github.com/bbatsov/rubocop/issues/1682)

- Can't disable cop Metrics/AbcSize inline [\#1679](https://github.com/bbatsov/rubocop/issues/1679)

- Ruby 2.2.0 crash with Style/SpaceAroundBlockParameters and stabby lambdas [\#1675](https://github.com/bbatsov/rubocop/issues/1675)

- Inconsistent indentation for a begin ... end block [\#1674](https://github.com/bbatsov/rubocop/issues/1674)

- Style/FirstParameterIndentation is making me sad :-\( [\#1667](https://github.com/bbatsov/rubocop/issues/1667)

- Finding matching cops is hard. [\#1662](https://github.com/bbatsov/rubocop/issues/1662)

- TrailingWhitespace cop calling out blank lines with whitespace in them [\#1658](https://github.com/bbatsov/rubocop/issues/1658)

- ~/rubocop.yml seems to not be working [\#1652](https://github.com/bbatsov/rubocop/issues/1652)

- Validate whitespace around << [\#1651](https://github.com/bbatsov/rubocop/issues/1651)

- Rubocop localization [\#1650](https://github.com/bbatsov/rubocop/issues/1650)

- Allow autocorrect to be configured by cop [\#1626](https://github.com/bbatsov/rubocop/issues/1626)

- Japanese Windows user may see encoding trouble with --format html [\#1617](https://github.com/bbatsov/rubocop/issues/1617)

- Style/EmptyElse probably doesn't distinguish between actual nil and empty block [\#1611](https://github.com/bbatsov/rubocop/issues/1611)

- Style/TrivialAccessors includes class method accessors [\#1604](https://github.com/bbatsov/rubocop/issues/1604)

- Style/Documentation: \# :nodoc: not respected [\#1602](https://github.com/bbatsov/rubocop/issues/1602)

- Style/MethodDefParentheses doesn't support middle-ground [\#1599](https://github.com/bbatsov/rubocop/issues/1599)

- False auto-correction in Lint/BlockAlignment [\#1573](https://github.com/bbatsov/rubocop/issues/1573)

- Style/HashSyntax to support hash rockets when pointing to symbols [\#1437](https://github.com/bbatsov/rubocop/issues/1437)

- use `attr\_reader` to define trivial reader methods on class-level instance variables [\#1412](https://github.com/bbatsov/rubocop/issues/1412)

- Railcop for avoiding Time.now [\#1405](https://github.com/bbatsov/rubocop/issues/1405)

- Opal likes multiline %x{} [\#1397](https://github.com/bbatsov/rubocop/issues/1397)

**Merged pull requests:**

- Fix CommandLiteral\#node\_body [\#1720](https://github.com/bbatsov/rubocop/pull/1720) ([bquorning](https://github.com/bquorning))

- \[Fix \#1281\] Add auto-correct for Style/IfUnlessModifier cop [\#1717](https://github.com/bbatsov/rubocop/pull/1717) ([lumeet](https://github.com/lumeet))

- Refactor config perfomance/detect code [\#1716](https://github.com/bbatsov/rubocop/pull/1716) ([palkan](https://github.com/palkan))

- Improve perfomance/detect code [\#1715](https://github.com/bbatsov/rubocop/pull/1715) ([palkan](https://github.com/palkan))

- fix multi-line lambda autocorrect whitespace issue [\#1714](https://github.com/bbatsov/rubocop/pull/1714) ([zvkemp](https://github.com/zvkemp))

- Add Perfomance/Detect cop [\#1704](https://github.com/bbatsov/rubocop/pull/1704) ([palkan](https://github.com/palkan))

- Hash key ending in = needs a hashrocket [\#1702](https://github.com/bbatsov/rubocop/pull/1702) ([bquorning](https://github.com/bquorning))

- Add new cop Performance/ReverseEach [\#1701](https://github.com/bbatsov/rubocop/pull/1701) ([rrosenblum](https://github.com/rrosenblum))

- \[Fix \#1275\] Add auto-correct for Style/WhileUntilModifier cop [\#1700](https://github.com/bbatsov/rubocop/pull/1700) ([lumeet](https://github.com/lumeet))

- Fix bug with --auto-gen-config and SpaceInsideBlockBraces [\#1695](https://github.com/bbatsov/rubocop/pull/1695) ([meganemura](https://github.com/meganemura))

- Use English spelling offense instead of offence [\#1693](https://github.com/bbatsov/rubocop/pull/1693) ([bquorning](https://github.com/bquorning))

- Fix spacing in yaml files [\#1692](https://github.com/bbatsov/rubocop/pull/1692) ([bquorning](https://github.com/bquorning))

- \[Fix \#1602\] Add :nodoc:-support to Documentation [\#1687](https://github.com/bbatsov/rubocop/pull/1687) ([lumeet](https://github.com/lumeet))

- Use YAML.safe\_load [\#1680](https://github.com/bbatsov/rubocop/pull/1680) ([croaky](https://github.com/croaky))

- \[\#1611\] Add MissingElse cop [\#1672](https://github.com/bbatsov/rubocop/pull/1672) ([rrosenblum](https://github.com/rrosenblum))

- Add command-line switch -S/--display-style-guide [\#1669](https://github.com/bbatsov/rubocop/pull/1669) ([marxarelli](https://github.com/marxarelli))

- Add rails/time\_zone cop [\#1668](https://github.com/bbatsov/rubocop/pull/1668) ([palkan](https://github.com/palkan))

- Fix more tests that do the wrong thing for SpaceAroundOperators [\#1666](https://github.com/bbatsov/rubocop/pull/1666) ([bquorning](https://github.com/bquorning))

- Cleanup [\#1665](https://github.com/bbatsov/rubocop/pull/1665) ([rrosenblum](https://github.com/rrosenblum))

- Add auto-correct to Encoding cop [\#1664](https://github.com/bbatsov/rubocop/pull/1664) ([rrosenblum](https://github.com/rrosenblum))

- \[Fix \#1611\] Add SupportedStyles to EmptyElse cop [\#1660](https://github.com/bbatsov/rubocop/pull/1660) ([rrosenblum](https://github.com/rrosenblum))

- Fix stack overflow when loading default config - JRuby on Windows 8 [\#1659](https://github.com/bbatsov/rubocop/pull/1659) ([pimterry](https://github.com/pimterry))

- allow autocorrect to be turned off for specific cops by configuration [\#1657](https://github.com/bbatsov/rubocop/pull/1657) ([jdoconnor](https://github.com/jdoconnor))

- `UnneededPercentX` accepts \n in `%x`-expressions [\#1655](https://github.com/bbatsov/rubocop/pull/1655) ([bquorning](https://github.com/bquorning))

- Check for multiple spaces around operators [\#1654](https://github.com/bbatsov/rubocop/pull/1654) ([bquorning](https://github.com/bquorning))

- New hash syntax cop that reports mixed syntax in the same hash [\#1641](https://github.com/bbatsov/rubocop/pull/1641) ([iainbeeston](https://github.com/iainbeeston))

- Fix 1555 remove gem spec files [\#1623](https://github.com/bbatsov/rubocop/pull/1623) ([e2](https://github.com/e2))

- `TrailingComma` got `strict\_comma` [\#1621](https://github.com/bbatsov/rubocop/pull/1621) ([tamird](https://github.com/tamird))

- Allow hash rockets in hashes with symbol values [\#1589](https://github.com/bbatsov/rubocop/pull/1589) ([rrosenblum](https://github.com/rrosenblum))

- Fixed correction for && for return without value [\#1678](https://github.com/bbatsov/rubocop/pull/1678) ([ankane](https://github.com/ankane))

- Fixed multiple formatter support for RakeTask [\#1671](https://github.com/bbatsov/rubocop/pull/1671) ([madkiwi](https://github.com/madkiwi))

## [v0.29.1](https://github.com/bbatsov/rubocop/tree/v0.29.1) (2015-02-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.29.0...v0.29.1)

**Fixed bugs:**

- FirstParameterIndentation in interpolated string works strangely [\#1638](https://github.com/bbatsov/rubocop/issues/1638)

**Closed issues:**

- Style/TrivialAccessors false positive [\#1653](https://github.com/bbatsov/rubocop/issues/1653)

- Error in UselessSetterCall cop [\#1649](https://github.com/bbatsov/rubocop/issues/1649)

- Style/StyleAroundBlockParameters failing [\#1647](https://github.com/bbatsov/rubocop/issues/1647)

- Not finish to search files when there is a directory named "," [\#1644](https://github.com/bbatsov/rubocop/issues/1644)

- undefined method `empty?' for nil:NilClass in progress\_formatter.rb [\#1642](https://github.com/bbatsov/rubocop/issues/1642)

- Powerpack dependency [\#1632](https://github.com/bbatsov/rubocop/issues/1632)

- Ruby version incorrectly reported with -V [\#1564](https://github.com/bbatsov/rubocop/issues/1564)

**Merged pull requests:**

- \[Fix \#1647\] Skip Style/SpaceAroundBlockParameters when lambda has no argument [\#1648](https://github.com/bbatsov/rubocop/pull/1648) ([eitoball](https://github.com/eitoball))

- \[Fix \#1644\] Avoid globbing entire file system [\#1645](https://github.com/bbatsov/rubocop/pull/1645) ([bquorning](https://github.com/bquorning))

- \[Fix \#1642\] Raise right exception on bad config [\#1643](https://github.com/bbatsov/rubocop/pull/1643) ([bquorning](https://github.com/bquorning))

- \[Fix \#1638\] Better comment matching in FirstParameterIndentation [\#1640](https://github.com/bbatsov/rubocop/pull/1640) ([jonas054](https://github.com/jonas054))

## [v0.29.0](https://github.com/bbatsov/rubocop/tree/v0.29.0) (2015-02-05)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.28.0...v0.29.0)

**Implemented enhancements:**

- Add autocorrect for Style/SelfAssignment cop [\#1276](https://github.com/bbatsov/rubocop/issues/1276)

- Add autocorrect for Lint/BlockAlignment cop [\#1273](https://github.com/bbatsov/rubocop/issues/1273)

- Add autocorrect for Style/Lambda cop [\#1271](https://github.com/bbatsov/rubocop/issues/1271)

**Fixed bugs:**

- FirstParameterIndentation unindents parenthesized arguments  [\#1622](https://github.com/bbatsov/rubocop/issues/1622)

- Style/FileName: false positive when inspecting file in non-current directory [\#1598](https://github.com/bbatsov/rubocop/issues/1598)

- Issue with "Align the operands of an expression in an assignment spanning multiple lines" [\#1591](https://github.com/bbatsov/rubocop/issues/1591)

- Style/StructInheritance crashes during rubocop's self inspection [\#1586](https://github.com/bbatsov/rubocop/issues/1586)

- Several auto-correction/offense disparities in Style/TrivialAccessors [\#1580](https://github.com/bbatsov/rubocop/issues/1580)

- Hash.new autocorrect leaves invalid ruby [\#1574](https://github.com/bbatsov/rubocop/issues/1574)

- %W cop too strong, misses \t case [\#1112](https://github.com/bbatsov/rubocop/issues/1112)

- Regression on LineEndConcatenation [\#1054](https://github.com/bbatsov/rubocop/issues/1054)

**Closed issues:**

- Style multiline with + is indented [\#1628](https://github.com/bbatsov/rubocop/issues/1628)

- No cop checking for space after \(or within\) block arguments? [\#1627](https://github.com/bbatsov/rubocop/issues/1627)

- documentation for inline disabling is deceptive [\#1625](https://github.com/bbatsov/rubocop/issues/1625)

- \[Question\] Override default severity [\#1624](https://github.com/bbatsov/rubocop/issues/1624)

- Prefer Double Quoted Strings by Default [\#1615](https://github.com/bbatsov/rubocop/issues/1615)

- Please expand\_path on inherit\_from [\#1612](https://github.com/bbatsov/rubocop/issues/1612)

- Style/ClassMethods gets singleton methods wrong [\#1610](https://github.com/bbatsov/rubocop/issues/1610)

- Style/TrivialAccessors doesn't differentiate the method name and variable accessed [\#1605](https://github.com/bbatsov/rubocop/issues/1605)

- Warnings in yard doc generation [\#1594](https://github.com/bbatsov/rubocop/issues/1594)

- How do I get from an error \(e,g, "Missing Top Level Class Documentation Comment"\) to the yml setting to control it? [\#1582](https://github.com/bbatsov/rubocop/issues/1582)

- No longer possible to use exit code after autocorrect to determine if something was wrong [\#1565](https://github.com/bbatsov/rubocop/issues/1565)

- Fails with F: Invalid byte sequence In windows if EOL is not UNIX [\#1560](https://github.com/bbatsov/rubocop/issues/1560)

- Some of Style/SelfAssignment cop tests are wrong [\#1557](https://github.com/bbatsov/rubocop/issues/1557)

- minor: remove spec files from gem [\#1555](https://github.com/bbatsov/rubocop/issues/1555)

- Taboo word list [\#1552](https://github.com/bbatsov/rubocop/issues/1552)

- Updating Wiki for autocorrected cops [\#1548](https://github.com/bbatsov/rubocop/issues/1548)

- One-liner semicolon terminating expression claimed as corrected when it's not [\#1547](https://github.com/bbatsov/rubocop/issues/1547)

- Style/AlignParameters and `system` [\#1546](https://github.com/bbatsov/rubocop/issues/1546)

- Lint/ShadowingOuterLocalVariable doesn't recognize when local variable is in another context in `case` [\#1544](https://github.com/bbatsov/rubocop/issues/1544)

- Style/LineEndConcatenation and interspersed comments [\#1542](https://github.com/bbatsov/rubocop/issues/1542)

- sendgrid\_category is not a useless assignment. [\#1540](https://github.com/bbatsov/rubocop/issues/1540)

- Autocorrect BracesAroundHashParameters leaves extra space [\#1527](https://github.com/bbatsov/rubocop/issues/1527)

- Rubocop reports an error on multiline lambdas in scopes [\#1520](https://github.com/bbatsov/rubocop/issues/1520)

- False negative on Style/FormatString? [\#1512](https://github.com/bbatsov/rubocop/issues/1512)

- Delegate cop should ignore class delegation [\#1509](https://github.com/bbatsov/rubocop/issues/1509)

- Cop warning about capybara debug methods [\#1507](https://github.com/bbatsov/rubocop/issues/1507)

- require': cannot load such file -- onfgaton fo bocop \(LoadError\) [\#1504](https://github.com/bbatsov/rubocop/issues/1504)

- Metrics/LineLength AllowURI does not work with interpolated strings [\#1503](https://github.com/bbatsov/rubocop/issues/1503)

- Infinite loop in autocorrect when running Style/SpaceAfterSemicolon & Style/SpaceInsideBlockBraces [\#1501](https://github.com/bbatsov/rubocop/issues/1501)

- Infinite loop in autocorrect of Style/IndentationWidth for if block [\#1500](https://github.com/bbatsov/rubocop/issues/1500)

- \#!/usr/bin/ruby shebang generates false positive for style linter. [\#1496](https://github.com/bbatsov/rubocop/issues/1496)

- No formatter for "html" [\#1490](https://github.com/bbatsov/rubocop/issues/1490)

- Use && instead of and even when purposefully using and [\#1487](https://github.com/bbatsov/rubocop/issues/1487)

- EmptyLinesAroundAccessModifier: autocorrect hangs on a function that looks like a modifier [\#1484](https://github.com/bbatsov/rubocop/issues/1484)

- Opting-out of cops at the command line [\#1430](https://github.com/bbatsov/rubocop/issues/1430)

- Severe: Rubocop silently accepts complete garbage as configuration [\#1428](https://github.com/bbatsov/rubocop/issues/1428)

- --display-cop-names from .rubocop.yml? [\#1324](https://github.com/bbatsov/rubocop/issues/1324)

- No offense detected on a block that looks wrong [\#1309](https://github.com/bbatsov/rubocop/issues/1309)

- Suggestion: Ban AndOr almost everywhere [\#1288](https://github.com/bbatsov/rubocop/issues/1288)

- Add support for groups to --only flag [\#1284](https://github.com/bbatsov/rubocop/issues/1284)

- RequireParentheses enhancement [\#1045](https://github.com/bbatsov/rubocop/issues/1045)

- Rubocop broken by regexp [\#796](https://github.com/bbatsov/rubocop/issues/796)

**Merged pull requests:**

- \[Fix \#1627\] New cop SpaceAroundBlockParameters [\#1636](https://github.com/bbatsov/rubocop/pull/1636) ([jonas054](https://github.com/jonas054))

- Lock RSpec version since some specs are failing on 3.2.0 [\#1635](https://github.com/bbatsov/rubocop/pull/1635) ([cshaffer](https://github.com/cshaffer))

- Fix PerlBackrefs Cop Autocorrections to Not Raise [\#1634](https://github.com/bbatsov/rubocop/pull/1634) ([cshaffer](https://github.com/cshaffer))

- Added missing default for AllCops/StyleGuideCopsOnly [\#1631](https://github.com/bbatsov/rubocop/pull/1631) ([marxarelli](https://github.com/marxarelli))

- \[Fix \#1624\] Inform about default severity in README [\#1630](https://github.com/bbatsov/rubocop/pull/1630) ([jonas054](https://github.com/jonas054))

- \[Fix \#1622\] Handle line breaks better in FirstParameterIndentation [\#1629](https://github.com/bbatsov/rubocop/pull/1629) ([jonas054](https://github.com/jonas054))

- New cop Style/FirstParameterIndentation [\#1620](https://github.com/bbatsov/rubocop/pull/1620) ([jonas054](https://github.com/jonas054))

- \[Fix \#1580\] Use fail instead of return in TrivialAccessors\#autocorrect [\#1619](https://github.com/bbatsov/rubocop/pull/1619) ([lumeet](https://github.com/lumeet))

- \[Fix \#1598\] Match absolute path too in Config\#file\_to\_include? [\#1618](https://github.com/bbatsov/rubocop/pull/1618) ([jonas054](https://github.com/jonas054))

- \[Fix \#1612\] Allowed expand\_path on inherit\_from in .rubocop.yml [\#1616](https://github.com/bbatsov/rubocop/pull/1616) ([mattjmcnaughton](https://github.com/mattjmcnaughton))

- \[Fix \#1594\] Fix Warnings in yard doc generation regarding @example [\#1595](https://github.com/bbatsov/rubocop/pull/1595) ([mattjmcnaughton](https://github.com/mattjmcnaughton))

- \[Fix \#1591\] Don't check \#\[\] parameters in MultilineOperationIndentation [\#1592](https://github.com/bbatsov/rubocop/pull/1592) ([jonas054](https://github.com/jonas054))

- \[Fix \#1574\] Don't auto-correct Hash.new into block braces [\#1590](https://github.com/bbatsov/rubocop/pull/1590) ([jonas054](https://github.com/jonas054))

- \[Fix \#1586\] StructInheritance cop failing with `< DelegateClass\(Something\)` [\#1588](https://github.com/bbatsov/rubocop/pull/1588) ([mmozuras](https://github.com/mmozuras))

- Exit with exit code 1 if there were errors [\#1587](https://github.com/bbatsov/rubocop/pull/1587) ([jonas054](https://github.com/jonas054))

- \[Fix \#1309\] Add argument handling to MultilineBlockLayout [\#1585](https://github.com/bbatsov/rubocop/pull/1585) ([lumeet](https://github.com/lumeet))

- Add autocorrect to RedundantException [\#1581](https://github.com/bbatsov/rubocop/pull/1581) ([mattjmcnaughton](https://github.com/mattjmcnaughton))

- \[Fix \#1565\] Add fail level A/autocorrect [\#1578](https://github.com/bbatsov/rubocop/pull/1578) ([jonas054](https://github.com/jonas054))

- Duplicate method lint [\#1577](https://github.com/bbatsov/rubocop/pull/1577) ([d4rk5eed](https://github.com/d4rk5eed))

- Fix auto-correct for BlockAlignment [\#1576](https://github.com/bbatsov/rubocop/pull/1576) ([lumeet](https://github.com/lumeet))

- Add StructInheritance cop [\#1571](https://github.com/bbatsov/rubocop/pull/1571) ([mmozuras](https://github.com/mmozuras))

- Add testing for Util\#range\_with\_surrounding\_space [\#1570](https://github.com/bbatsov/rubocop/pull/1570) ([jonas054](https://github.com/jonas054))

- Markdown refresh [\#1567](https://github.com/bbatsov/rubocop/pull/1567) ([veelenga](https://github.com/veelenga))

- Add autocorrect for Style/SelfAssignment cop [\#1562](https://github.com/bbatsov/rubocop/pull/1562) ([lumeet](https://github.com/lumeet))

- \[Fix \#1503\] Add comment in LineLength config for URI handling [\#1561](https://github.com/bbatsov/rubocop/pull/1561) ([jonas054](https://github.com/jonas054))

- \[Fix \#1284\] Support namespace args to --only/--except [\#1559](https://github.com/bbatsov/rubocop/pull/1559) ([jonas054](https://github.com/jonas054))

- Fix existing tests Style/SelfAssignment cop [\#1558](https://github.com/bbatsov/rubocop/pull/1558) ([lumeet](https://github.com/lumeet))

- \[Fix \#1547\] Use fail in in Semicolon\#autocorrect instead of if [\#1556](https://github.com/bbatsov/rubocop/pull/1556) ([jonas054](https://github.com/jonas054))

- \[Fix \#1324\] Add AllCops/DisplayCopNames config option [\#1554](https://github.com/bbatsov/rubocop/pull/1554) ([jonas054](https://github.com/jonas054))

- Fixes an issue with empty lines around modifier keyword and beginning of a block [\#1553](https://github.com/bbatsov/rubocop/pull/1553) ([volkert](https://github.com/volkert))

- fix link to style guide [\#1551](https://github.com/bbatsov/rubocop/pull/1551) ([mockdeep](https://github.com/mockdeep))

- Add autocorrect for Style/Lambda cop [\#1550](https://github.com/bbatsov/rubocop/pull/1550) ([lumeet](https://github.com/lumeet))

- Implement autocorrection for Rails/ReadWriteAttribute cop. [\#1539](https://github.com/bbatsov/rubocop/pull/1539) ([huerlisi](https://github.com/huerlisi))

- Remove deprecated flags [\#1538](https://github.com/bbatsov/rubocop/pull/1538) ([bquorning](https://github.com/bquorning))

- Don't wrap .run arguments in two arrays [\#1537](https://github.com/bbatsov/rubocop/pull/1537) ([bquorning](https://github.com/bquorning))

- \[Fix \#1527\] Fix autocorrect bracesaroundhashparameters leaves extra space [\#1536](https://github.com/bbatsov/rubocop/pull/1536) ([mattjmcnaughton](https://github.com/mattjmcnaughton))

- Remove unused code [\#1535](https://github.com/bbatsov/rubocop/pull/1535) ([bquorning](https://github.com/bquorning))

- Spec invalid configuration [\#1534](https://github.com/bbatsov/rubocop/pull/1534) ([bquorning](https://github.com/bquorning))

- Increase test coverage [\#1530](https://github.com/bbatsov/rubocop/pull/1530) ([bquorning](https://github.com/bquorning))

- Rework line end concatenation [\#1529](https://github.com/bbatsov/rubocop/pull/1529) ([jonas054](https://github.com/jonas054))

- Configure Debugger cop to check for Capybara debug methods [\#1528](https://github.com/bbatsov/rubocop/pull/1528) ([rrosenblum](https://github.com/rrosenblum))

- Remove duplicate code [\#1526](https://github.com/bbatsov/rubocop/pull/1526) ([rrosenblum](https://github.com/rrosenblum))

- \[TASK\] Configure Travis for better build performance [\#1524](https://github.com/bbatsov/rubocop/pull/1524) ([oliverklee](https://github.com/oliverklee))

- Require support/coverage before the rubocop code [\#1523](https://github.com/bbatsov/rubocop/pull/1523) ([bquorning](https://github.com/bquorning))

- Increase test coverage [\#1521](https://github.com/bbatsov/rubocop/pull/1521) ([bquorning](https://github.com/bquorning))

- Remove disallowed array syntax in specs [\#1519](https://github.com/bbatsov/rubocop/pull/1519) ([bquorning](https://github.com/bquorning))

- \[Fix \#1512\] Fix false negative for typical string formatting examples [\#1517](https://github.com/bbatsov/rubocop/pull/1517) ([jonas054](https://github.com/jonas054))

- Clean up specs part deux [\#1516](https://github.com/bbatsov/rubocop/pull/1516) ([jonas054](https://github.com/jonas054))

- Add auto-correct for the `EvenOdd` cop to the chnagelog. [\#1515](https://github.com/bbatsov/rubocop/pull/1515) ([blainesch](https://github.com/blainesch))

- Remove arrays wrapping a single string in inspect\_source calls [\#1514](https://github.com/bbatsov/rubocop/pull/1514) ([jonas054](https://github.com/jonas054))

- \[Fix \#1501\] Make sure offenses are printed after infinite loop [\#1513](https://github.com/bbatsov/rubocop/pull/1513) ([jonas054](https://github.com/jonas054))

- Raise TypeError if the config file is malformed [\#1511](https://github.com/bbatsov/rubocop/pull/1511) ([bquorning](https://github.com/bquorning))

- Fix bug where auto\_correct Rake tasks does not take in the options specified in its parent task [\#1508](https://github.com/bbatsov/rubocop/pull/1508) ([rrosenblum](https://github.com/rrosenblum))

- Add autocorrection for even? and odd? style cop. [\#1506](https://github.com/bbatsov/rubocop/pull/1506) ([blainesch](https://github.com/blainesch))

- \[Fix \#1500\] Remove double handling of elsif in IndentationWidth [\#1505](https://github.com/bbatsov/rubocop/pull/1505) ([jonas054](https://github.com/jonas054))

- Require digest/md5 for ProcessedSource\#checksum [\#1502](https://github.com/bbatsov/rubocop/pull/1502) ([jonas054](https://github.com/jonas054))

- Added periods where periods are due. [\#1499](https://github.com/bbatsov/rubocop/pull/1499) ([dblock](https://github.com/dblock))

- Fix bug in how Exclude works [\#1498](https://github.com/bbatsov/rubocop/pull/1498) ([jonas054](https://github.com/jonas054))

- \[Fix \#1430\] Add option --except for disabling cops on command line [\#1497](https://github.com/bbatsov/rubocop/pull/1497) ([jonas054](https://github.com/jonas054))

- Abort when auto-correct causes an infinite loop. [\#1492](https://github.com/bbatsov/rubocop/pull/1492) ([dblock](https://github.com/dblock))

- Fix `EmptyLinesAroundAccessModifier` incorrectly finding a violation inside method calls with names identical to an access modifier. [\#1491](https://github.com/bbatsov/rubocop/pull/1491) ([dblock](https://github.com/dblock))

- Make sure element assignment is handled correctly [\#1489](https://github.com/bbatsov/rubocop/pull/1489) ([jonas054](https://github.com/jonas054))

- add 'quiet' formatter as child of simple\_text formatter. [\#1596](https://github.com/bbatsov/rubocop/pull/1596) ([dhempy](https://github.com/dhempy))

- Formatter: Quiet [\#1593](https://github.com/bbatsov/rubocop/pull/1593) ([dhempy](https://github.com/dhempy))

- Add autocorrect to RedundantException [\#1549](https://github.com/bbatsov/rubocop/pull/1549) ([mattjmcnaughton](https://github.com/mattjmcnaughton))

- Update config\_store.rb [\#1533](https://github.com/bbatsov/rubocop/pull/1533) ([Zrp200](https://github.com/Zrp200))

- Simplified code slightly [\#1532](https://github.com/bbatsov/rubocop/pull/1532) ([Zrp200](https://github.com/Zrp200))

- Remove duplicate code [\#1525](https://github.com/bbatsov/rubocop/pull/1525) ([rrosenblum](https://github.com/rrosenblum))

- Make coverage measurements work again [\#1522](https://github.com/bbatsov/rubocop/pull/1522) ([jonas054](https://github.com/jonas054))

- Speeding up Travis-CI, fix Rubinius. [\#1494](https://github.com/bbatsov/rubocop/pull/1494) ([dblock](https://github.com/dblock))

- Added multi-line comments [\#1488](https://github.com/bbatsov/rubocop/pull/1488) ([Zrp200](https://github.com/Zrp200))

## [v0.28.0](https://github.com/bbatsov/rubocop/tree/v0.28.0) (2014-12-10)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.27.1...v0.28.0)

**Implemented enhancements:**

- Disabling BracesAroundHashParameters when second to last param is also a hash [\#801](https://github.com/bbatsov/rubocop/issues/801)

**Fixed bugs:**

- auto-gen-config enables "Style/MultilineOperationIndentation" [\#1449](https://github.com/bbatsov/rubocop/issues/1449)

- Misautocorrection by Style/Block [\#1441](https://github.com/bbatsov/rubocop/issues/1441)

**Closed issues:**

- Pass :x instead of block in proc leads to an error [\#1485](https://github.com/bbatsov/rubocop/issues/1485)

- Configuration to enable cop name by default? [\#1483](https://github.com/bbatsov/rubocop/issues/1483)

- Rubocop  reports an error on multiline lambdas in scopes [\#1482](https://github.com/bbatsov/rubocop/issues/1482)

- It is not always possible to exchange inject with each\_with\_object [\#1477](https://github.com/bbatsov/rubocop/issues/1477)

- Multiline string with `<<` not caught by `Style/LineEndConcatenation` [\#1474](https://github.com/bbatsov/rubocop/issues/1474)

- Style/MultilineOperationIndentation doesn't catch lines ending in `\` [\#1473](https://github.com/bbatsov/rubocop/issues/1473)

- Conflicting Lint/UnusedBlockArgument & Style/SingleLineBlockParams [\#1466](https://github.com/bbatsov/rubocop/issues/1466)

- Rubocop autocorrecting "\#$1" produces incorrect code  [\#1465](https://github.com/bbatsov/rubocop/issues/1465)

- Bad auto-correct "while\(!foo\)" -\> "until foo" [\#1459](https://github.com/bbatsov/rubocop/issues/1459)

- --auto-gen-config todo not capturing all offences [\#1453](https://github.com/bbatsov/rubocop/issues/1453)

- Support for keyword arguments + Style/HashSyntax: hash\_rockets [\#1451](https://github.com/bbatsov/rubocop/issues/1451)

- Unnecessary spaces cop [\#1450](https://github.com/bbatsov/rubocop/issues/1450)

- Opal, Rails asset preprocessor and Style/LeadingCommentSpace [\#1445](https://github.com/bbatsov/rubocop/issues/1445)

- Documentation ideas \(from walkthrough with Hound-CI and guard-rubocop\) [\#1442](https://github.com/bbatsov/rubocop/issues/1442)

- UnnecessarySpaceCharacter [\#1434](https://github.com/bbatsov/rubocop/issues/1434)

- Offense missed by Style/StringLiterals [\#1432](https://github.com/bbatsov/rubocop/issues/1432)

- TargetFinder performance [\#1427](https://github.com/bbatsov/rubocop/issues/1427)

- Deadlock on this enforced StringLiterals+InInterpolation style [\#1421](https://github.com/bbatsov/rubocop/issues/1421)

- -a/--auto-correct should exit cleanly [\#1325](https://github.com/bbatsov/rubocop/issues/1325)

- Refactor specs? [\#1240](https://github.com/bbatsov/rubocop/issues/1240)

- Quote choice is ignored if inside an interpolated string [\#1181](https://github.com/bbatsov/rubocop/issues/1181)

**Merged pull requests:**

- \[Fix \#1473\] Recognize operator \[\]= in MultilineOperationIndentation [\#1486](https://github.com/bbatsov/rubocop/pull/1486) ([jonas054](https://github.com/jonas054))

- Expand test coverage for ExtraSpacing cop [\#1481](https://github.com/bbatsov/rubocop/pull/1481) ([hackling](https://github.com/hackling))

- \[Fix \#1474\] LineEndConcatenation cop catches multiline string with '<<' and '\' [\#1480](https://github.com/bbatsov/rubocop/pull/1480) ([katieschilling](https://github.com/katieschilling))

- \[Fix \#1325\] Don't consider corrected offenses as failure [\#1479](https://github.com/bbatsov/rubocop/pull/1479) ([jonas054](https://github.com/jonas054))

- Correct some spelling errors [\#1476](https://github.com/bbatsov/rubocop/pull/1476) ([jonas054](https://github.com/jonas054))

- Add ExtraSpacing cop that detects unnecessary whitespace. [\#1475](https://github.com/bbatsov/rubocop/pull/1475) ([blainesch](https://github.com/blainesch))

- Handle elsif+else in ElseAlignment [\#1472](https://github.com/bbatsov/rubocop/pull/1472) ([jonas054](https://github.com/jonas054))

- Update README.md [\#1471](https://github.com/bbatsov/rubocop/pull/1471) ([jeffreyjackson](https://github.com/jeffreyjackson))

- \[Fix \#1466\] Allow underscored parameters in SingleLineBlockParams [\#1469](https://github.com/bbatsov/rubocop/pull/1469) ([jonas054](https://github.com/jonas054))

- \[Fix \#1459\] Handle parentheses around condition in NegatedWhile [\#1464](https://github.com/bbatsov/rubocop/pull/1464) ([jonas054](https://github.com/jonas054))

- Add EmptyLinesAroundBlockBody cop [\#1463](https://github.com/bbatsov/rubocop/pull/1463) ([jcarbo](https://github.com/jcarbo))

- fix `%W\[\]` auto corrected to `%w\(\]` [\#1462](https://github.com/bbatsov/rubocop/pull/1462) ([toy](https://github.com/toy))

- Fix Style/ElseAlignment Cop error on def/rescue/else/ensure/end. [\#1457](https://github.com/bbatsov/rubocop/pull/1457) ([oneamtu](https://github.com/oneamtu))

- Fix SymbolProc autocorrect with multiple offenses [\#1456](https://github.com/bbatsov/rubocop/pull/1456) ([jcarbo](https://github.com/jcarbo))

- Support style-guide only usage [\#1454](https://github.com/bbatsov/rubocop/pull/1454) ([marxarelli](https://github.com/marxarelli))

- \[Fix \#1449\] Detect unrecognized style in MultilineOperationIndentation [\#1452](https://github.com/bbatsov/rubocop/pull/1452) ([jonas054](https://github.com/jonas054))

- \[Fix \#1427\] Exclude top level directories early [\#1448](https://github.com/bbatsov/rubocop/pull/1448) ([jonas054](https://github.com/jonas054))

- \[Fix \#1181\] Don't report strings in interpolations in StringLiterals [\#1447](https://github.com/bbatsov/rubocop/pull/1447) ([jonas054](https://github.com/jonas054))

- Update README adding HTML formatter [\#1446](https://github.com/bbatsov/rubocop/pull/1446) ([joventuraz](https://github.com/joventuraz))

- New cop Style/ElseNil [\#1444](https://github.com/bbatsov/rubocop/pull/1444) ([Koronen](https://github.com/Koronen))

- \[Fix \#1441\] Compare AST for whole buffer in AutocorrectUnlessChangingAST [\#1443](https://github.com/bbatsov/rubocop/pull/1443) ([jonas054](https://github.com/jonas054))

- \[Fix \#801\] Add a `context\_dependent` style to BracesAroundHashParameters [\#1439](https://github.com/bbatsov/rubocop/pull/1439) ([jonas054](https://github.com/jonas054))

- Else alignment bug [\#1470](https://github.com/bbatsov/rubocop/pull/1470) ([tamird](https://github.com/tamird))

- Deprecate --format disabled and add cop DisableCopComment [\#1413](https://github.com/bbatsov/rubocop/pull/1413) ([jonas054](https://github.com/jonas054))

- add autocorrect for UselessAccessModifier cop [\#1320](https://github.com/bbatsov/rubocop/pull/1320) ([sch1zo](https://github.com/sch1zo))

## [v0.27.1](https://github.com/bbatsov/rubocop/tree/v0.27.1) (2014-11-08)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.27.0...v0.27.1)

**Fixed bugs:**

- Deprecation warning on `dir/\*\*/\*` style pattern [\#1418](https://github.com/bbatsov/rubocop/issues/1418)

- Bug in StringLiteralsInInterpolation [\#1415](https://github.com/bbatsov/rubocop/issues/1415)

**Closed issues:**

- ElseAlignment cop doesn't respect begin/rescue blocks [\#1436](https://github.com/bbatsov/rubocop/issues/1436)

- Error occurred while Style/ElseAlignment cop was inspecting [\#1435](https://github.com/bbatsov/rubocop/issues/1435)

- rubocop ignored try with eval [\#1429](https://github.com/bbatsov/rubocop/issues/1429)

- Lint/RescueException auto-correct is broken / too aggressive [\#1426](https://github.com/bbatsov/rubocop/issues/1426)

- .rubocop.yml read from excluded folders [\#1425](https://github.com/bbatsov/rubocop/issues/1425)

- False positive about interpolation quoting when joining lines with slash [\#1422](https://github.com/bbatsov/rubocop/issues/1422)

- Style/ElseAlignment trips up on this code [\#1420](https://github.com/bbatsov/rubocop/issues/1420)

- Allow dashes in the `Style/FileName` cop [\#1419](https://github.com/bbatsov/rubocop/issues/1419)

- Error with Style/ElseAlignment cop [\#1416](https://github.com/bbatsov/rubocop/issues/1416)

- Style/MultilineOperationIndentation blows up on `lambda.\(...\)` in 0.27.0 [\#1411](https://github.com/bbatsov/rubocop/issues/1411)

- Style/SpaceInsideRangeLiteral should allow newlines [\#1406](https://github.com/bbatsov/rubocop/issues/1406)

- How to make RuboCop inspect a file in a folder that starts with dot [\#1401](https://github.com/bbatsov/rubocop/issues/1401)

- Auto correcting substitues a rescued Exception with a blind rescue [\#1343](https://github.com/bbatsov/rubocop/issues/1343)

**Merged pull requests:**

- Support empty elsif in MultilineIfThen [\#1438](https://github.com/bbatsov/rubocop/pull/1438) ([jonas054](https://github.com/jonas054))

- \[Fix \#1425\] Find included files in a simpler way [\#1431](https://github.com/bbatsov/rubocop/pull/1431) ([jonas054](https://github.com/jonas054))

- \[Fix \#1418\] Avoid deprecation warning for hidden directories [\#1424](https://github.com/bbatsov/rubocop/pull/1424) ([jonas054](https://github.com/jonas054))

- \[Fix \#1416\] Handle begin/rescue/else/end in ElseAlignment [\#1423](https://github.com/bbatsov/rubocop/pull/1423) ([jonas054](https://github.com/jonas054))

- \[Fix \#1415\] Handle backslash-concatenation [\#1417](https://github.com/bbatsov/rubocop/pull/1417) ([jonas054](https://github.com/jonas054))

- \[Fix \#1401\] Enable including hidden directories in config [\#1414](https://github.com/bbatsov/rubocop/pull/1414) ([jonas054](https://github.com/jonas054))

- Add \(failing\) test for empty elsif branch [\#1433](https://github.com/bbatsov/rubocop/pull/1433) ([janraasch](https://github.com/janraasch))

## [v0.27.0](https://github.com/bbatsov/rubocop/tree/v0.27.0) (2014-10-30)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.26.1...v0.27.0)

**Implemented enhancements:**

- Configurable IndentationWidth [\#872](https://github.com/bbatsov/rubocop/issues/872)

- Spell checking of Rubocop [\#846](https://github.com/bbatsov/rubocop/issues/846)

- EmptyLinesAroundBody required? [\#805](https://github.com/bbatsov/rubocop/issues/805)

**Closed issues:**

- Java::float is a class not a method call [\#1410](https://github.com/bbatsov/rubocop/issues/1410)

- Rubocop disable comments are included in line length [\#1408](https://github.com/bbatsov/rubocop/issues/1408)

- Auto Correct corrupted Gemfile.lock [\#1404](https://github.com/bbatsov/rubocop/issues/1404)

- Add `\*.opal` to default inclusions  [\#1396](https://github.com/bbatsov/rubocop/issues/1396)

- Ruby 2.1.3 support [\#1390](https://github.com/bbatsov/rubocop/issues/1390)

- rubocop --out does not create parent directories [\#1389](https://github.com/bbatsov/rubocop/issues/1389)

- FormatString is confused by other "format"s with EnforcedStyle: percent [\#1388](https://github.com/bbatsov/rubocop/issues/1388)

- DoubleNegation cop has a bad example [\#1387](https://github.com/bbatsov/rubocop/issues/1387)

- File count goes down by 4 when including file on .rubocop.yml [\#1384](https://github.com/bbatsov/rubocop/issues/1384)

- Allow configuration of MethodLength to permit multi-line hashes [\#1382](https://github.com/bbatsov/rubocop/issues/1382)

- Cop to check for blank lines at the beginning/end of a method [\#1378](https://github.com/bbatsov/rubocop/issues/1378)

- SymbolProc might break code in conjunction with SpaceBeforeBlockBraces [\#1374](https://github.com/bbatsov/rubocop/issues/1374)

- GuardClause false positive [\#1372](https://github.com/bbatsov/rubocop/issues/1372)

- Another MultilineOperationIndentation bug \(sorry\) [\#1368](https://github.com/bbatsov/rubocop/issues/1368)

- 1 trailing blank lines detected. [\#1363](https://github.com/bbatsov/rubocop/issues/1363)

- MultilineOperationIndentation bugs [\#1362](https://github.com/bbatsov/rubocop/issues/1362)

- MethodLength/ClassLength cops take wrapped lines into account [\#1361](https://github.com/bbatsov/rubocop/issues/1361)

- return with a different exit code for different severity levels [\#1359](https://github.com/bbatsov/rubocop/issues/1359)

- `bundle exec rake` fails on Rubinius [\#1355](https://github.com/bbatsov/rubocop/issues/1355)

- Style/Next exception when not appropriate [\#1353](https://github.com/bbatsov/rubocop/issues/1353)

- Auto correct for Style/WordArray improvement [\#1352](https://github.com/bbatsov/rubocop/issues/1352)

- Case where auto correction of multiline { }  to do end block introduces a syntax error [\#1350](https://github.com/bbatsov/rubocop/issues/1350)

- Trailing comma autocorrected in the wrong place [\#1349](https://github.com/bbatsov/rubocop/issues/1349)

- autocorrect doesn't fully fix if / elsif block indentation [\#1348](https://github.com/bbatsov/rubocop/issues/1348)

- Autocorrect hash parameters introduces invalid ruby [\#1347](https://github.com/bbatsov/rubocop/issues/1347)

- Prefer find over detect within a Rails project [\#1334](https://github.com/bbatsov/rubocop/issues/1334)

- GuardClause / LineLength issue [\#1332](https://github.com/bbatsov/rubocop/issues/1332)

- PreferredMethods: `select` is not an equivalent substitute for `find\_all` [\#1084](https://github.com/bbatsov/rubocop/issues/1084)

- Allow documentation at the top of files which only contain one class [\#1030](https://github.com/bbatsov/rubocop/issues/1030)

**Merged pull requests:**

- Refine HTML formatter \(take 2\) [\#1403](https://github.com/bbatsov/rubocop/pull/1403) ([jonas054](https://github.com/jonas054))

- Shorter methods [\#1402](https://github.com/bbatsov/rubocop/pull/1402) ([jonas054](https://github.com/jonas054))

- Configurable empty lines [\#1399](https://github.com/bbatsov/rubocop/pull/1399) ([jonas054](https://github.com/jonas054))

- \[Fix \#872\] Make IndentationWidth configurable [\#1395](https://github.com/bbatsov/rubocop/pull/1395) ([jonas054](https://github.com/jonas054))

- NonNilCheck improvements [\#1394](https://github.com/bbatsov/rubocop/pull/1394) ([jonas054](https://github.com/jonas054))

- Check quotes in interpolation [\#1393](https://github.com/bbatsov/rubocop/pull/1393) ([jonas054](https://github.com/jonas054))

- Show decimals for Metrics/AbcSize:Max if given in config [\#1392](https://github.com/bbatsov/rubocop/pull/1392) ([jonas054](https://github.com/jonas054))

- Make `--out` to create parent directories [\#1391](https://github.com/bbatsov/rubocop/pull/1391) ([yous](https://github.com/yous))

- Small fixes for MultilineOperationIndentation [\#1386](https://github.com/bbatsov/rubocop/pull/1386) ([jonas054](https://github.com/jonas054))

- Do not use the syck YAML engine [\#1385](https://github.com/bbatsov/rubocop/pull/1385) ([jonas054](https://github.com/jonas054))

- \[Fix \#1368\] MultilineOperationIndentation's handling of RSpec code [\#1381](https://github.com/bbatsov/rubocop/pull/1381) ([jonas054](https://github.com/jonas054))

- \[Fix \#1374\] Always auto-correct one cop at a time [\#1379](https://github.com/bbatsov/rubocop/pull/1379) ([jonas054](https://github.com/jonas054))

- \[Fix \#1350\] Check that Blocks cop doesn't create syntax errors [\#1377](https://github.com/bbatsov/rubocop/pull/1377) ([jonas054](https://github.com/jonas054))

- String methods faster than regex [\#1376](https://github.com/bbatsov/rubocop/pull/1376) ([bquorning](https://github.com/bquorning))

- Spec was using Tempfile without requiring it [\#1375](https://github.com/bbatsov/rubocop/pull/1375) ([bquorning](https://github.com/bquorning))

- WordArray allows all characters except spaces [\#1371](https://github.com/bbatsov/rubocop/pull/1371) ([bquorning](https://github.com/bquorning))

- New cop Metrics/AbcSize [\#1370](https://github.com/bbatsov/rubocop/pull/1370) ([jonas054](https://github.com/jonas054))

- Recognize some Ruby files related with Chef: Berksfile, Cheffile, ... [\#1366](https://github.com/bbatsov/rubocop/pull/1366) ([zuazo](https://github.com/zuazo))

- Fix condition for special cases in MultilineOperationIndentation [\#1365](https://github.com/bbatsov/rubocop/pull/1365) ([jonas054](https://github.com/jonas054))

- \[Fix \#1349\] Don't change whitespace in BracesAroundHashParameters [\#1364](https://github.com/bbatsov/rubocop/pull/1364) ([jonas054](https://github.com/jonas054))

- New cop MultilineOperationIndentation [\#1360](https://github.com/bbatsov/rubocop/pull/1360) ([jonas054](https://github.com/jonas054))

- Force single-job bundle install [\#1358](https://github.com/bbatsov/rubocop/pull/1358) ([mvz](https://github.com/mvz))

- \[Fix \#1348\] Add ElseAlignment cop [\#1356](https://github.com/bbatsov/rubocop/pull/1356) ([jonas054](https://github.com/jonas054))

- Align hashes with some line breaks [\#1354](https://github.com/bbatsov/rubocop/pull/1354) ([mvz](https://github.com/mvz))

- Update description and use logo [\#1344](https://github.com/bbatsov/rubocop/pull/1344) ([yous](https://github.com/yous))

- Fix problem with encoding in WordArray [\#1383](https://github.com/bbatsov/rubocop/pull/1383) ([jonas054](https://github.com/jonas054))

- Add gems needed for Rubinius to the Gemfile [\#1357](https://github.com/bbatsov/rubocop/pull/1357) ([mvz](https://github.com/mvz))

- Allow DSL methods to be checked by some Metrics cops [\#1345](https://github.com/bbatsov/rubocop/pull/1345) ([smangelsdorf](https://github.com/smangelsdorf))

- Refine HTML formatter [\#1330](https://github.com/bbatsov/rubocop/pull/1330) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#835\] Add static choice for Style/StringLiterals:EnforcedStyle [\#1327](https://github.com/bbatsov/rubocop/pull/1327) ([jonas054](https://github.com/jonas054))

- `TrailingComma` now treats all multilines equally [\#1257](https://github.com/bbatsov/rubocop/pull/1257) ([tamird](https://github.com/tamird))

- Add and enable rubocop-spec in project [\#1249](https://github.com/bbatsov/rubocop/pull/1249) ([geniou](https://github.com/geniou))

- Allow disabling of all cops from default Rubocop config [\#1204](https://github.com/bbatsov/rubocop/pull/1204) ([rickmzp](https://github.com/rickmzp))

## [v0.26.1](https://github.com/bbatsov/rubocop/tree/v0.26.1) (2014-09-18)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.26.0...v0.26.1)

**Closed issues:**

- Style/SymbolProc cop crashes when method call has no receiver [\#1340](https://github.com/bbatsov/rubocop/issues/1340)

- OpMethod should also check \#eql? and \#equal? [\#1339](https://github.com/bbatsov/rubocop/issues/1339)

- Lint/UnusedMethodArgument issue with heredoc [\#1337](https://github.com/bbatsov/rubocop/issues/1337)

- Metrics/LineLength AllowURI is too permissive [\#1335](https://github.com/bbatsov/rubocop/issues/1335)

- FileInspector deleted from 0.23 to 0.24+ [\#1328](https://github.com/bbatsov/rubocop/issues/1328)

- SpaceInsideParens style checker does not recognize space after parens in some conditions [\#1326](https://github.com/bbatsov/rubocop/issues/1326)

- Check indentation of conditionals spanning multiple lines [\#1321](https://github.com/bbatsov/rubocop/issues/1321)

- RuboCop logo [\#578](https://github.com/bbatsov/rubocop/issues/578)

**Merged pull requests:**

- \[Fix \#1340\] Handle call with no receiver correctly in Style/SymbolProc cop [\#1341](https://github.com/bbatsov/rubocop/pull/1341) ([smangelsdorf](https://github.com/smangelsdorf))

- Restrict valid schemes for LineLength/AllowURI [\#1338](https://github.com/bbatsov/rubocop/pull/1338) ([smangelsdorf](https://github.com/smangelsdorf))

- Add more style guide references to cops [\#1336](https://github.com/bbatsov/rubocop/pull/1336) ([yous](https://github.com/yous))

- Fix spec pattern for RSpec 3.1.0 [\#1333](https://github.com/bbatsov/rubocop/pull/1333) ([yous](https://github.com/yous))

- Give a positive alternative to reduntant begin/rescue/end blocks [\#1331](https://github.com/bbatsov/rubocop/pull/1331) ([nilbus](https://github.com/nilbus))

- \[Fix \#1326\] Add other kind of parenthesis in SpaceInsideParens [\#1329](https://github.com/bbatsov/rubocop/pull/1329) ([jonas054](https://github.com/jonas054))

## [v0.26.0](https://github.com/bbatsov/rubocop/tree/v0.26.0) (2014-09-03)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.25.0...v0.26.0)

**Implemented enhancements:**

- Add autocorrect for Style/DotPosition cop [\#1279](https://github.com/bbatsov/rubocop/issues/1279)

- Add autocorrect for Lint/SpaceBeforeFirstArg cop [\#1277](https://github.com/bbatsov/rubocop/issues/1277)

- Add autocorrect for Style/MultilineIfThen cop [\#1274](https://github.com/bbatsov/rubocop/issues/1274)

- Add autocorrect for Style/Tab cop [\#1272](https://github.com/bbatsov/rubocop/issues/1272)

- Add autocorrect for style cops [\#743](https://github.com/bbatsov/rubocop/issues/743)

**Fixed bugs:**

- AndOr rule in a conditional block context [\#1313](https://github.com/bbatsov/rubocop/issues/1313)

- Autocorrect for Style/PercentLiteralDelimiters adds extra whitespace [\#1283](https://github.com/bbatsov/rubocop/issues/1283)

- False positive in UnneededCapitalW [\#1263](https://github.com/bbatsov/rubocop/issues/1263)

- Lint/UselessAssignment ignores unused variable in multiple rescue case [\#1211](https://github.com/bbatsov/rubocop/issues/1211)

**Closed issues:**

- Indentation in if and case expressions [\#1323](https://github.com/bbatsov/rubocop/issues/1323)

- Style/FormatString: Favor String\#% over format. [\#1319](https://github.com/bbatsov/rubocop/issues/1319)

- Pass &:x? as an argument to lambda instead of a block. [\#1316](https://github.com/bbatsov/rubocop/issues/1316)

- New SymbolProc cop breaks RuboCop when inspecting previously-approved code. [\#1314](https://github.com/bbatsov/rubocop/issues/1314)

- Rake task `options` treats arguments differently than CLI [\#1312](https://github.com/bbatsov/rubocop/issues/1312)

- Increase `module\_function` parity with `public`, `private`, and `protected` [\#1310](https://github.com/bbatsov/rubocop/issues/1310)

- RedundantBegin cop autocorrect modifies whitespace formatting [\#1307](https://github.com/bbatsov/rubocop/issues/1307)

- Enable Style/Encoding for Ruby \>= 2.0 [\#1304](https://github.com/bbatsov/rubocop/issues/1304)

- ternary condition trigger snake\_case warning [\#1299](https://github.com/bbatsov/rubocop/issues/1299)

- False positive: 'Unused block argument' when used in interpolated strings [\#1294](https://github.com/bbatsov/rubocop/issues/1294)

- Consider using AST extension gem [\#1291](https://github.com/bbatsov/rubocop/issues/1291)

- Style/Encoding: false doesn't always work for ruby 2.0 [\#1289](https://github.com/bbatsov/rubocop/issues/1289)

- EmptyLinesAroundBody & EmptyLinesAroundAccessModifier fight each other [\#1287](https://github.com/bbatsov/rubocop/issues/1287)

- False positive for Style/VariableName cop [\#1286](https://github.com/bbatsov/rubocop/issues/1286)

- Getting a strange warning after following documentation [\#1285](https://github.com/bbatsov/rubocop/issues/1285)

- Add autocorrect for Style/RedundantReturn cop [\#1280](https://github.com/bbatsov/rubocop/issues/1280)

- Thinks block is unused [\#1270](https://github.com/bbatsov/rubocop/issues/1270)

- Include cop name in offence messages [\#1268](https://github.com/bbatsov/rubocop/issues/1268)

- snake\_case rule: Make exceptions for popular configuration filenames [\#1265](https://github.com/bbatsov/rubocop/issues/1265)

- Lint/UselessAssignment - seems incorrect [\#1253](https://github.com/bbatsov/rubocop/issues/1253)

**Merged pull requests:**

- \[Fix \#1289\] Use utf-8 as default encoding for inspected files [\#1322](https://github.com/bbatsov/rubocop/pull/1322) ([jonas054](https://github.com/jonas054))

- Ignore missing blank line after access modifier at end of block [\#1318](https://github.com/bbatsov/rubocop/pull/1318) ([sch1zo](https://github.com/sch1zo))

- Handle post-conditional `while` and `until` in AndOr [\#1317](https://github.com/bbatsov/rubocop/pull/1317) ([yujinakayama](https://github.com/yujinakayama))

- Correct whitespace braces around hash parameters [\#1315](https://github.com/bbatsov/rubocop/pull/1315) ([jspanjers](https://github.com/jspanjers))

- \[Fix \#1283\] Fix bug concerning indentation in PercentLiteralDelimiters [\#1311](https://github.com/bbatsov/rubocop/pull/1311) ([jonas054](https://github.com/jonas054))

- Fix auto-correction `RedundantBegin` cop [\#1308](https://github.com/bbatsov/rubocop/pull/1308) ([yous](https://github.com/yous))

- Add more style guide references to cops [\#1306](https://github.com/bbatsov/rubocop/pull/1306) ([yous](https://github.com/yous))

- Remove duplicated character range [\#1305](https://github.com/bbatsov/rubocop/pull/1305) ([yous](https://github.com/yous))

- Keep line length to 80 [\#1303](https://github.com/bbatsov/rubocop/pull/1303) ([yous](https://github.com/yous))

- Force to use array join for `\n` in string [\#1302](https://github.com/bbatsov/rubocop/pull/1302) ([yous](https://github.com/yous))

- Add auto-correct to SpaceBeforeFirstArg cop [\#1301](https://github.com/bbatsov/rubocop/pull/1301) ([yous](https://github.com/yous))

- Add auto-correct to DotPosition cop [\#1300](https://github.com/bbatsov/rubocop/pull/1300) ([yous](https://github.com/yous))

- HTMLFormatter [\#1298](https://github.com/bbatsov/rubocop/pull/1298) ([SkuliOskarsson](https://github.com/SkuliOskarsson))

- Keep line length to 80 [\#1297](https://github.com/bbatsov/rubocop/pull/1297) ([yous](https://github.com/yous))

- Tab cop does auto-correction [\#1296](https://github.com/bbatsov/rubocop/pull/1296) ([yous](https://github.com/yous))

- Fix typo [\#1295](https://github.com/bbatsov/rubocop/pull/1295) ([yous](https://github.com/yous))

- Suggest similar name for useless assignment [\#1293](https://github.com/bbatsov/rubocop/pull/1293) ([yujinakayama](https://github.com/yujinakayama))

- Introduce astrolabe gem [\#1292](https://github.com/bbatsov/rubocop/pull/1292) ([yujinakayama](https://github.com/yujinakayama))

- Fix false negative in UselessAssignment with exclusive branches [\#1290](https://github.com/bbatsov/rubocop/pull/1290) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#1263\] Do not report %W literals with special characters [\#1269](https://github.com/bbatsov/rubocop/pull/1269) ([jonas054](https://github.com/jonas054))

- 'Sexy' isn't a particularly good description of validation syntax [\#1202](https://github.com/bbatsov/rubocop/pull/1202) ([GeekOnCoffee](https://github.com/GeekOnCoffee))

## [v0.25.0](https://github.com/bbatsov/rubocop/tree/v0.25.0) (2014-08-15)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.24.1...v0.25.0)

**Fixed bugs:**

- Style/AndOr gets confused about autocorrect [\#1255](https://github.com/bbatsov/rubocop/issues/1255)

- Lint/BlockAlignment suggest wrong `end` alignment [\#1219](https://github.com/bbatsov/rubocop/issues/1219)

- AlignHash deletes parts of code [\#1214](https://github.com/bbatsov/rubocop/issues/1214)

- Unneeded %Q Cop doesn't deal with escape codes [\#1210](https://github.com/bbatsov/rubocop/issues/1210)

- False positive for SpaceBeforeBlockParameters: false with new lambda syntax [\#1197](https://github.com/bbatsov/rubocop/issues/1197)

**Closed issues:**

- autocorrect hangs in situations involving single to multi line blocks [\#1264](https://github.com/bbatsov/rubocop/issues/1264)

- Issue with auto-correct feature and RegEx expressions.  [\#1262](https://github.com/bbatsov/rubocop/issues/1262)

- Style/AndOr enhanced autocorrect for `method a or method a,b` to `method\(a\)||method\(a,b\)` [\#1259](https://github.com/bbatsov/rubocop/issues/1259)

- Request for a new cop [\#1258](https://github.com/bbatsov/rubocop/issues/1258)

- Style/Not.rb errors out on not\(x\) syntax [\#1254](https://github.com/bbatsov/rubocop/issues/1254)

- Make AlignParameters cop understand `def\_delegators` [\#1247](https://github.com/bbatsov/rubocop/issues/1247)

- Bug in Style/PredicateName when method legitimately starts with 'is' [\#1245](https://github.com/bbatsov/rubocop/issues/1245)

- Style/MultilineBlockLayout producing errors while analyzing files [\#1243](https://github.com/bbatsov/rubocop/issues/1243)

- Cop Disabling via Source Comment Not Working \(0.24.1\) [\#1242](https://github.com/bbatsov/rubocop/issues/1242)

- Style/TrailingComma should do autocorrection [\#1241](https://github.com/bbatsov/rubocop/issues/1241)

- Ban and/or on conditionals only [\#1232](https://github.com/bbatsov/rubocop/issues/1232)

- \n inside string literal [\#1229](https://github.com/bbatsov/rubocop/issues/1229)

- Possible to depend on Multi\_Json Gem instead of Json Gem? [\#1228](https://github.com/bbatsov/rubocop/issues/1228)

- Changing yamler to syck [\#1227](https://github.com/bbatsov/rubocop/issues/1227)

- `Next` cop throwing false negative with complex conditionals [\#1225](https://github.com/bbatsov/rubocop/issues/1225)

- Style/MultilineBlockLayout wrongly reports subclass declaration [\#1224](https://github.com/bbatsov/rubocop/issues/1224)

- Style/MultilineBlockLayout fails on lambda with multiline block [\#1223](https://github.com/bbatsov/rubocop/issues/1223)

- Adding rubocop to existing project [\#1222](https://github.com/bbatsov/rubocop/issues/1222)

- Additional Option for Cyclomatic Complexity [\#1220](https://github.com/bbatsov/rubocop/issues/1220)

- Error should not be raised for do...end block in private method [\#1215](https://github.com/bbatsov/rubocop/issues/1215)

- Add ability to turn on Rails mode in .rubocop.yml [\#1213](https://github.com/bbatsov/rubocop/issues/1213)

- Global settings [\#1207](https://github.com/bbatsov/rubocop/issues/1207)

- Can not parse def func\(\*\*\) [\#1201](https://github.com/bbatsov/rubocop/issues/1201)

- Style/LineLength with `AllowURI: true` warns about URIs that ends with \{\*\} [\#1199](https://github.com/bbatsov/rubocop/issues/1199)

- Rubocop crashes with `invalid byte sequence in UTF-8` [\#1189](https://github.com/bbatsov/rubocop/issues/1189)

- EachWithObject: reduce vs each\_with\_objects [\#1185](https://github.com/bbatsov/rubocop/issues/1185)

- Interesting interaction with RSpec `let` inside a block [\#1184](https://github.com/bbatsov/rubocop/issues/1184)

**Merged pull requests:**

- Fix \#1259 : Enable parenthesizing for andor autocorrect [\#1261](https://github.com/bbatsov/rubocop/pull/1261) ([vrthra](https://github.com/vrthra))

- \[Fix \#1255\] Compare without context in AutocorrectUnlessChangingAST [\#1260](https://github.com/bbatsov/rubocop/pull/1260) ([jonas054](https://github.com/jonas054))

- Ignore block-pass in `TrailingComma` [\#1256](https://github.com/bbatsov/rubocop/pull/1256) ([tamird](https://github.com/tamird))

- TrailingComma cop does auto-correction [\#1252](https://github.com/bbatsov/rubocop/pull/1252) ([yous](https://github.com/yous))

- Fix PercentLiteralDelimiters auto-correct [\#1251](https://github.com/bbatsov/rubocop/pull/1251) ([hannestyden](https://github.com/hannestyden))

- Make tests run and pass in random orders [\#1250](https://github.com/bbatsov/rubocop/pull/1250) ([gylaz](https://github.com/gylaz))

- Fix problem with Psych::ENGINE for ruby-head [\#1248](https://github.com/bbatsov/rubocop/pull/1248) ([jonas054](https://github.com/jonas054))

- \[Fix \#1243\] Fix multiline-block cop which errors out on empty blocks [\#1244](https://github.com/bbatsov/rubocop/pull/1244) ([vrthra](https://github.com/vrthra))

- \[Fix \#1227\] Don't permanently change yamler [\#1239](https://github.com/bbatsov/rubocop/pull/1239) ([jonas054](https://github.com/jonas054))

- Make Debugger cop also check for `binding.pry\_remote` [\#1237](https://github.com/bbatsov/rubocop/pull/1237) ([yous](https://github.com/yous))

- \[Fix \#1232\] make the behavior of AndOr cop configurable [\#1236](https://github.com/bbatsov/rubocop/pull/1236) ([vrthra](https://github.com/vrthra))

- Update README with info on Metrics cops [\#1234](https://github.com/bbatsov/rubocop/pull/1234) ([jonas054](https://github.com/jonas054))

- New cop Metrics/PerceivedComplexity [\#1231](https://github.com/bbatsov/rubocop/pull/1231) ([jonas054](https://github.com/jonas054))

- Mention RunRailsCops configuration directive in README [\#1226](https://github.com/bbatsov/rubocop/pull/1226) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#1219\] Avoid reporting }/end sharing line with something [\#1221](https://github.com/bbatsov/rubocop/pull/1221) ([jonas054](https://github.com/jonas054))

- \[Fix \#1214\] Require one key per line for inspection in AlignHash [\#1218](https://github.com/bbatsov/rubocop/pull/1218) ([jonas054](https://github.com/jonas054))

- `Style::EmptyLinesAroundAccessModifier` cop does auto-correction. [\#1217](https://github.com/bbatsov/rubocop/pull/1217) ([tamird](https://github.com/tamird))

- Fix UnneededPercentQ [\#1216](https://github.com/bbatsov/rubocop/pull/1216) ([jonas054](https://github.com/jonas054))

- Fix `SpaceInsideBrackets` for `Hash\#\[\]` calls [\#1212](https://github.com/bbatsov/rubocop/pull/1212) ([mcls](https://github.com/mcls))

- \[\#835\] New cop BarePercentLiterals [\#1209](https://github.com/bbatsov/rubocop/pull/1209) ([jonas054](https://github.com/jonas054))

- Fix false positive in UnneededPercentQ for /%Q\(something\)/ [\#1208](https://github.com/bbatsov/rubocop/pull/1208) ([jonas054](https://github.com/jonas054))

- Fix error at anonymous keyword splat arguments [\#1206](https://github.com/bbatsov/rubocop/pull/1206) ([yujinakayama](https://github.com/yujinakayama))

- Add cop PercentQLiterals [\#1205](https://github.com/bbatsov/rubocop/pull/1205) ([jonas054](https://github.com/jonas054))

- Add support for string source in EndOfLine cop [\#1203](https://github.com/bbatsov/rubocop/pull/1203) ([gylaz](https://github.com/gylaz))

- Blacklist Vagrantfile like Rakefile in FileName cop [\#1200](https://github.com/bbatsov/rubocop/pull/1200) ([tobynet](https://github.com/tobynet))

- \[Fix \#1197\] Deal with new lambda syntax in SpaceInsideBlockBraces [\#1198](https://github.com/bbatsov/rubocop/pull/1198) ([jonas054](https://github.com/jonas054))

- Keep line length to 80, fix typo and remove trailing whitespace [\#1196](https://github.com/bbatsov/rubocop/pull/1196) ([yous](https://github.com/yous))

- Refactor cop mixins [\#1195](https://github.com/bbatsov/rubocop/pull/1195) ([yujinakayama](https://github.com/yujinakayama))

- Drop support for Ruby 1.9.2 [\#1194](https://github.com/bbatsov/rubocop/pull/1194) ([yujinakayama](https://github.com/yujinakayama))

- New cop: MultilineBlockLayout [\#1079](https://github.com/bbatsov/rubocop/pull/1079) ([barunio](https://github.com/barunio))

- Add auto-correct to BlockAlignment cop [\#1078](https://github.com/bbatsov/rubocop/pull/1078) ([barunio](https://github.com/barunio))

- chinese project [\#1267](https://github.com/bbatsov/rubocop/pull/1267) ([haydonduan](https://github.com/haydonduan))

- Create chinese [\#1266](https://github.com/bbatsov/rubocop/pull/1266) ([haydonduan](https://github.com/haydonduan))

- Fix old Metrics/LineLength in README [\#1235](https://github.com/bbatsov/rubocop/pull/1235) ([MatthewCallis](https://github.com/MatthewCallis))

- Fix rakefile sample code [\#1233](https://github.com/bbatsov/rubocop/pull/1233) ([hirocaster](https://github.com/hirocaster))

- New cop RepeatedKey [\#1230](https://github.com/bbatsov/rubocop/pull/1230) ([agrimm](https://github.com/agrimm))

- Enable rubocop-rspec [\#1149](https://github.com/bbatsov/rubocop/pull/1149) ([geniou](https://github.com/geniou))

## [v0.24.1](https://github.com/bbatsov/rubocop/tree/v0.24.1) (2014-07-03)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.24.0...v0.24.1)

**Fixed bugs:**

- Style/IndentationWidth crashes on cucumber.rake [\#1176](https://github.com/bbatsov/rubocop/issues/1176)

- An error occured while Style/AlignParameters cop was inspecting ... [\#1174](https://github.com/bbatsov/rubocop/issues/1174)

**Closed issues:**

- Style/Next cop crashes [\#1191](https://github.com/bbatsov/rubocop/issues/1191)

- Style/LineLength crashes [\#1190](https://github.com/bbatsov/rubocop/issues/1190)

- Style/LineLength crashes [\#1188](https://github.com/bbatsov/rubocop/issues/1188)

- parse error with new ruby 2.1 method definition style for private/protected [\#1183](https://github.com/bbatsov/rubocop/issues/1183)

- rubocop --auto-correct inverts if-statement [\#1179](https://github.com/bbatsov/rubocop/issues/1179)

- Lint/UnusedMethodArgument autocorrect renames unused keywords [\#1177](https://github.com/bbatsov/rubocop/issues/1177)

- EnforcedStyle and SuppotedStyles do not work [\#1175](https://github.com/bbatsov/rubocop/issues/1175)

- --only cli option seems to ignore require of config file [\#1157](https://github.com/bbatsov/rubocop/issues/1157)

**Merged pull requests:**

- Fix crash in Next cop [\#1193](https://github.com/bbatsov/rubocop/pull/1193) ([yujinakayama](https://github.com/yujinakayama))

- Fix crash in LineLength cop when AllowURI option is enabled [\#1192](https://github.com/bbatsov/rubocop/pull/1192) ([yujinakayama](https://github.com/yujinakayama))

- Bump Parser dependency to 2.2.0.pre.3 [\#1187](https://github.com/bbatsov/rubocop/pull/1187) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#1157\] Validate --only arguments later [\#1182](https://github.com/bbatsov/rubocop/pull/1182) ([jonas054](https://github.com/jonas054))

- Fix invalid auto-correction for unused keyword arguments [\#1180](https://github.com/bbatsov/rubocop/pull/1180) ([yujinakayama](https://github.com/yujinakayama))

- Fix bug in AutocorrectAlignment\#heredoc\_ranges [\#1178](https://github.com/bbatsov/rubocop/pull/1178) ([jonas054](https://github.com/jonas054))

- Work around a splat assignment bug in Rubinius [\#1173](https://github.com/bbatsov/rubocop/pull/1173) ([yujinakayama](https://github.com/yujinakayama))

## [v0.24.0](https://github.com/bbatsov/rubocop/tree/v0.24.0) (2014-06-25)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.23.0...v0.24.0)

**Implemented enhancements:**

- Add HTML formatter [\#692](https://github.com/bbatsov/rubocop/issues/692)

- Exclude files in .gitignore [\#595](https://github.com/bbatsov/rubocop/issues/595)

- Detect unnecessary parentheses [\#472](https://github.com/bbatsov/rubocop/issues/472)

- Generate Style Guide from .rubocop.yml [\#379](https://github.com/bbatsov/rubocop/issues/379)

**Fixed bugs:**

- TrailingComma still registers an offense when it shouldn't [\#1167](https://github.com/bbatsov/rubocop/issues/1167)

- \[Windows\] Different prefix 'X:/' and 'Y:/Ruby-x.x.x/..../rubocop/config [\#727](https://github.com/bbatsov/rubocop/issues/727)

**Closed issues:**

- Style/ParenthesesAroundCondition crashes on `true if \(true ? true : false\)` [\#1169](https://github.com/bbatsov/rubocop/issues/1169)

- False Negative in Style/IndentationWidth-Cop [\#1165](https://github.com/bbatsov/rubocop/issues/1165)

- rubocop --auto-correct gets stuck on bad code [\#1159](https://github.com/bbatsov/rubocop/issues/1159)

- auto-correct corrected floats into ints [\#1158](https://github.com/bbatsov/rubocop/issues/1158)

- Can't make rubocop read ~/.rubocop.yml [\#1153](https://github.com/bbatsov/rubocop/issues/1153)

- Allow semicolon in one-line `reduce`? [\#1148](https://github.com/bbatsov/rubocop/issues/1148)

- WordArray appears to skip arrays with special characters [\#1147](https://github.com/bbatsov/rubocop/issues/1147)

- :kind\_of? vs :is\_a? automation? [\#1145](https://github.com/bbatsov/rubocop/issues/1145)

- TrailingComma breaks on version 0.23.0 [\#1141](https://github.com/bbatsov/rubocop/issues/1141)

- \[Feature Request\] Cop for optional hash braces [\#1137](https://github.com/bbatsov/rubocop/issues/1137)

- Update specs for RSpec 3.0 [\#1134](https://github.com/bbatsov/rubocop/issues/1134)

- EachWithObject fail on 023.0 [\#1133](https://github.com/bbatsov/rubocop/issues/1133)

- MethodLength should not consider Heredocs [\#1077](https://github.com/bbatsov/rubocop/issues/1077)

- not including parent level dir [\#990](https://github.com/bbatsov/rubocop/issues/990)

- Rubocop preview [\#981](https://github.com/bbatsov/rubocop/issues/981)

- Question about IndentationWidth behavior [\#961](https://github.com/bbatsov/rubocop/issues/961)

- Check for useless square bracket assignment [\#639](https://github.com/bbatsov/rubocop/issues/639)

**Merged pull requests:**

- Add support for checking rescue indentation [\#1172](https://github.com/bbatsov/rubocop/pull/1172) ([jonas054](https://github.com/jonas054))

- Add AllowURI option to LineLength cop [\#1171](https://github.com/bbatsov/rubocop/pull/1171) ([yujinakayama](https://github.com/yujinakayama))

- Fix a false positive for `return` in Next cop [\#1170](https://github.com/bbatsov/rubocop/pull/1170) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#1167\] Fix handling of multi-line parameters in TrailingComma [\#1168](https://github.com/bbatsov/rubocop/pull/1168) ([jonas054](https://github.com/jonas054))

- Refactor core [\#1166](https://github.com/bbatsov/rubocop/pull/1166) ([yujinakayama](https://github.com/yujinakayama))

- Improve testing [\#1164](https://github.com/bbatsov/rubocop/pull/1164) ([jonas054](https://github.com/jonas054))

- New cop UnneededPercentQ [\#1163](https://github.com/bbatsov/rubocop/pull/1163) ([jonas054](https://github.com/jonas054))

- Fix most cases of offense being spelled as offence [\#1162](https://github.com/bbatsov/rubocop/pull/1162) ([agrimm](https://github.com/agrimm))

- New cops SpaceBeforeComma and SpaceBeforeSemicolon [\#1161](https://github.com/bbatsov/rubocop/pull/1161) ([agrimm](https://github.com/agrimm))

- Fix IndentationWidth and Attr [\#1160](https://github.com/bbatsov/rubocop/pull/1160) ([jonas054](https://github.com/jonas054))

- Support square bracket setters in UselessSetterCall [\#1156](https://github.com/bbatsov/rubocop/pull/1156) ([yujinakayama](https://github.com/yujinakayama))

- Correcting the pattern style in example on README [\#1154](https://github.com/bbatsov/rubocop/pull/1154) ([gaganawhad](https://github.com/gaganawhad))

- Handle `while/until` with no body in `Next` [\#1152](https://github.com/bbatsov/rubocop/pull/1152) ([tamird](https://github.com/tamird))

- \[Fix \#1141\] Clarify why trailing comma is not allowed [\#1150](https://github.com/bbatsov/rubocop/pull/1150) ([jonas054](https://github.com/jonas054))

- Add cop DefEndAlignment [\#1146](https://github.com/bbatsov/rubocop/pull/1146) ([jonas054](https://github.com/jonas054))

- Fix typo [\#1143](https://github.com/bbatsov/rubocop/pull/1143) ([takuyan](https://github.com/takuyan))

- Handle unused block local variables in UnusedBlockArgument rather than UselessAssignment [\#1142](https://github.com/bbatsov/rubocop/pull/1142) ([yujinakayama](https://github.com/yujinakayama))

- Upgrade to RSpec 3 [\#1140](https://github.com/bbatsov/rubocop/pull/1140) ([yujinakayama](https://github.com/yujinakayama))

- Update docs badge [\#1135](https://github.com/bbatsov/rubocop/pull/1135) ([rrrene](https://github.com/rrrene))

- WordArray checks arrays with special characters [\#1155](https://github.com/bbatsov/rubocop/pull/1155) ([camilleldn](https://github.com/camilleldn))

- UnneededCapitalW cop now does auto-correction [\#1139](https://github.com/bbatsov/rubocop/pull/1139) ([sfeldon](https://github.com/sfeldon))

## [v0.23.0](https://github.com/bbatsov/rubocop/tree/v0.23.0) (2014-06-02)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.22.0...v0.23.0)

**Fixed bugs:**

- Indentation auto-correct problems with heredocs [\#1120](https://github.com/bbatsov/rubocop/issues/1120)

- IndentationConsistency & IndentationWidth auto-correct combined breaks code [\#1118](https://github.com/bbatsov/rubocop/issues/1118)

- IndentationWidth auto-correct breaks block comments [\#1117](https://github.com/bbatsov/rubocop/issues/1117)

- Crash on € ISO-8859-15 character read as UTF-8 [\#1111](https://github.com/bbatsov/rubocop/issues/1111)

- Error remove brackets [\#1109](https://github.com/bbatsov/rubocop/issues/1109)

- Documentation followed by annotation comments [\#1090](https://github.com/bbatsov/rubocop/issues/1090)

**Closed issues:**

- Use --rails by default [\#1132](https://github.com/bbatsov/rubocop/issues/1132)

- rubocop:disable LineLength doesn't work in comments [\#1131](https://github.com/bbatsov/rubocop/issues/1131)

- "Use next to skip iteration" being thrown incorrectly [\#1122](https://github.com/bbatsov/rubocop/issues/1122)

- 'Next' cop errors on a method invoking super with 2+ args and a non-empty block. [\#1115](https://github.com/bbatsov/rubocop/issues/1115)

- Support parsing erb files [\#1113](https://github.com/bbatsov/rubocop/issues/1113)

- EachWithObject Cop Incorrectly Flags Block [\#1106](https://github.com/bbatsov/rubocop/issues/1106)

- cop each\_with\_object.rb fail in 0.22.0 [\#1104](https://github.com/bbatsov/rubocop/issues/1104)

- Trailing Comma needs to learn a 'only when at line end' style [\#1075](https://github.com/bbatsov/rubocop/issues/1075)

- number of offenses option? [\#1004](https://github.com/bbatsov/rubocop/issues/1004)

**Merged pull requests:**

- Add linter-rubocop Atom plugin to README \[ci skip\] [\#1130](https://github.com/bbatsov/rubocop/pull/1130) ([d-unseductable](https://github.com/d-unseductable))

- \[Fix \#1120\] Don't indent heredoc strings in auto-correct [\#1129](https://github.com/bbatsov/rubocop/pull/1129) ([jonas054](https://github.com/jonas054))

- Don't destroy code and do check right brackets [\#1128](https://github.com/bbatsov/rubocop/pull/1128) ([jonas054](https://github.com/jonas054))

- \[Fix \#1090\] Correct handling of documentation vs annotation comment [\#1127](https://github.com/bbatsov/rubocop/pull/1127) ([jonas054](https://github.com/jonas054))

- Fix bug with --auto-gen-config and RegexpLiteral [\#1126](https://github.com/bbatsov/rubocop/pull/1126) ([ggilder](https://github.com/ggilder))

- Support setter calls in safe assignment [\#1125](https://github.com/bbatsov/rubocop/pull/1125) ([jonas054](https://github.com/jonas054))

- Auto-correct class-level trivial accessors [\#1124](https://github.com/bbatsov/rubocop/pull/1124) ([ggilder](https://github.com/ggilder))

- Parentheses around setter in condition [\#1123](https://github.com/bbatsov/rubocop/pull/1123) ([tamird](https://github.com/tamird))

- \[Fix \#1075\] More strict limits on when to require trailing comma [\#1121](https://github.com/bbatsov/rubocop/pull/1121) ([jonas054](https://github.com/jonas054))

- Fix block comments [\#1119](https://github.com/bbatsov/rubocop/pull/1119) ([jonas054](https://github.com/jonas054))

- \[Fix \#1115\] Fix Next when methods invoking super [\#1116](https://github.com/bbatsov/rubocop/pull/1116) ([geniou](https://github.com/geniou))

- \[Fix \#1111\] Fix reading of non-UTF-8 files in EndOfLine [\#1114](https://github.com/bbatsov/rubocop/pull/1114) ([jonas054](https://github.com/jonas054))

- Make exception for JRuby in setting yamler to syck [\#1110](https://github.com/bbatsov/rubocop/pull/1110) ([jonas054](https://github.com/jonas054))

- \[Fix \#1106\] EachWithObject with method call body [\#1108](https://github.com/bbatsov/rubocop/pull/1108) ([geniou](https://github.com/geniou))

- Remove unnecessary hash merge in TargetFinder [\#1107](https://github.com/bbatsov/rubocop/pull/1107) ([jonas054](https://github.com/jonas054))

- Fix EachWithObject with modifier if [\#1105](https://github.com/bbatsov/rubocop/pull/1105) ([geniou](https://github.com/geniou))

- Namespaces for cop names [\#1103](https://github.com/bbatsov/rubocop/pull/1103) ([jonas054](https://github.com/jonas054))

- Add optional require directive to .rubocop.yml [\#1102](https://github.com/bbatsov/rubocop/pull/1102) ([geniou](https://github.com/geniou))

- Add section about custom cops \[ci skip\] [\#1099](https://github.com/bbatsov/rubocop/pull/1099) ([geniou](https://github.com/geniou))

- Add style cop that checks for inline comments [\#1062](https://github.com/bbatsov/rubocop/pull/1062) ([salbertson](https://github.com/salbertson))

## [v0.22.0](https://github.com/bbatsov/rubocop/tree/v0.22.0) (2014-05-20)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.21.0...v0.22.0)

**Implemented enhancements:**

- HashSyntax\#EnforcedStyle doesn't work properly [\#818](https://github.com/bbatsov/rubocop/issues/818)

- Make sure all the 'good' examples from the ruby-style-guide pass rubocop without generating offenses  [\#158](https://github.com/bbatsov/rubocop/issues/158)

**Fixed bugs:**

- Delegate cop error [\#1051](https://github.com/bbatsov/rubocop/issues/1051)

- auto-correct leads to wrong offense count, if lines are removed [\#1032](https://github.com/bbatsov/rubocop/issues/1032)

- Exclude not working as expected [\#1022](https://github.com/bbatsov/rubocop/issues/1022)

**Closed issues:**

- Error on rails controller [\#1101](https://github.com/bbatsov/rubocop/issues/1101)

- Namespaces for cop names [\#1097](https://github.com/bbatsov/rubocop/issues/1097)

- ClassAndModuleChildren incorrectly flags classes with a single method [\#1094](https://github.com/bbatsov/rubocop/issues/1094)

- Display cop names by default in offense messages [\#1086](https://github.com/bbatsov/rubocop/issues/1086)

- An error occurred while Delegate cop was inspecting [\#1085](https://github.com/bbatsov/rubocop/issues/1085)

- AndOr sees `render and return` as a violation [\#1083](https://github.com/bbatsov/rubocop/issues/1083)

- Check for spaces before comments [\#1074](https://github.com/bbatsov/rubocop/issues/1074)

- An error occurred while Delegate cop was inspecting [\#1071](https://github.com/bbatsov/rubocop/issues/1071)

- Crash in Rails Model parsing [\#1067](https://github.com/bbatsov/rubocop/issues/1067)

- Invalid auto-correct on negated if with parentheses [\#1066](https://github.com/bbatsov/rubocop/issues/1066)

- DisallowedMethods cop? [\#1065](https://github.com/bbatsov/rubocop/issues/1065)

- Running on ruby-head [\#1063](https://github.com/bbatsov/rubocop/issues/1063)

- Override a specific error message [\#1058](https://github.com/bbatsov/rubocop/issues/1058)

- Error parsing 180 .rb files [\#1057](https://github.com/bbatsov/rubocop/issues/1057)

- make TODO file name configurable [\#1050](https://github.com/bbatsov/rubocop/issues/1050)

- Next cop broken by ternary operator [\#1046](https://github.com/bbatsov/rubocop/issues/1046)

- Spurious useless assignment warning on reduce [\#1044](https://github.com/bbatsov/rubocop/issues/1044)

- LineEndConcatenation cop does not check after first line [\#1043](https://github.com/bbatsov/rubocop/issues/1043)

- UnusedMethodArgument for prototypes [\#1042](https://github.com/bbatsov/rubocop/issues/1042)

- FileName cop for lib/<project\_name\>.rb [\#1041](https://github.com/bbatsov/rubocop/issues/1041)

- An error occurred while LineEndConcatenation... [\#1036](https://github.com/bbatsov/rubocop/issues/1036)

- API Question: how to pass options within knife-spork plug-in [\#1027](https://github.com/bbatsov/rubocop/issues/1027)

- An error occurred while UselessSetterCall cop was inspecting [\#1026](https://github.com/bbatsov/rubocop/issues/1026)

- False-positive parameters align violation [\#1017](https://github.com/bbatsov/rubocop/issues/1017)

- GuardClause cop for loops [\#1010](https://github.com/bbatsov/rubocop/issues/1010)

- Github Ruby style guide [\#823](https://github.com/bbatsov/rubocop/issues/823)

**Merged pull requests:**

- Fix incorrect error message about rubocop-todo.yml [\#1098](https://github.com/bbatsov/rubocop/pull/1098) ([agrimm](https://github.com/agrimm))

- \[Fixes \#1094\] Fix bug in ClassAndModuleChildren [\#1096](https://github.com/bbatsov/rubocop/pull/1096) ([geniou](https://github.com/geniou))

- Cleanup specs [\#1095](https://github.com/bbatsov/rubocop/pull/1095) ([geniou](https://github.com/geniou))

- Use new pattern style [\#1091](https://github.com/bbatsov/rubocop/pull/1091) ([Dorian](https://github.com/Dorian))

- Add -F/--fail-fast option [\#1089](https://github.com/bbatsov/rubocop/pull/1089) ([jonas054](https://github.com/jonas054))

- \[Fix \#1074\] New cop SpaceBeforeComment [\#1088](https://github.com/bbatsov/rubocop/pull/1088) ([jonas054](https://github.com/jonas054))

- Minor refactoring of SelfAssignment cop [\#1082](https://github.com/bbatsov/rubocop/pull/1082) ([geniou](https://github.com/geniou))

- \[Fix \#1022\] Make auto-correct honor Exclude for individual cops [\#1081](https://github.com/bbatsov/rubocop/pull/1081) ([jonas054](https://github.com/jonas054))

- Fix a problem with empty yaml files [\#1080](https://github.com/bbatsov/rubocop/pull/1080) ([jonas054](https://github.com/jonas054))

- Fix Exclude configuration not working on Windows [\#1076](https://github.com/bbatsov/rubocop/pull/1076) ([wndhydrnt](https://github.com/wndhydrnt))

- Fix AlignParameters for multi-line method calls [\#1073](https://github.com/bbatsov/rubocop/pull/1073) ([molawson](https://github.com/molawson))

- Add auto-correct to unused argument cops [\#1072](https://github.com/bbatsov/rubocop/pull/1072) ([hannestyden](https://github.com/hannestyden))

- Switch to available SVG badges [\#1070](https://github.com/bbatsov/rubocop/pull/1070) ([nschonni](https://github.com/nschonni))

- \[Fix \#1066\] Fix auto-correct of parenthesized condition in NegatedIf [\#1068](https://github.com/bbatsov/rubocop/pull/1068) ([jonas054](https://github.com/jonas054))

- New cop UnneededPercentX [\#1056](https://github.com/bbatsov/rubocop/pull/1056) ([jonas054](https://github.com/jonas054))

- Rename rubocop-todo.yml file to .rubocop\_todo.yml [\#1055](https://github.com/bbatsov/rubocop/pull/1055) ([geniou](https://github.com/geniou))

- Fix up typos in default.yml [\#1053](https://github.com/bbatsov/rubocop/pull/1053) ([kevinjalbert](https://github.com/kevinjalbert))

- Add all each\_\* methods to Next cop check [\#1049](https://github.com/bbatsov/rubocop/pull/1049) ([geniou](https://github.com/geniou))

- Add check for unless to GuardClause and make one-line body configurable [\#1048](https://github.com/bbatsov/rubocop/pull/1048) ([geniou](https://github.com/geniou))

- Stabilize semantics of NonNilCheck autocorrect [\#1047](https://github.com/bbatsov/rubocop/pull/1047) ([hannestyden](https://github.com/hannestyden))

- add Next cop [\#1040](https://github.com/bbatsov/rubocop/pull/1040) ([geniou](https://github.com/geniou))

- \[Fix \#974\] New cop CommentIndentation [\#1039](https://github.com/bbatsov/rubocop/pull/1039) ([jonas054](https://github.com/jonas054))

- \[Fix \#1032\] Avoid duplicate reporting during --auto-correct [\#1038](https://github.com/bbatsov/rubocop/pull/1038) ([jonas054](https://github.com/jonas054))

- Fix short call syntax [\#1037](https://github.com/bbatsov/rubocop/pull/1037) ([biinari](https://github.com/biinari))

- Enable inspection of old code with config AllCops/Excludes [\#1035](https://github.com/bbatsov/rubocop/pull/1035) ([jonas054](https://github.com/jonas054))

- Fix typo in config/default.yml \(Ingore -\> Ignore\) [\#1034](https://github.com/bbatsov/rubocop/pull/1034) ([kevinjalbert](https://github.com/kevinjalbert))

- Add EachWithObject cop [\#1033](https://github.com/bbatsov/rubocop/pull/1033) ([geniou](https://github.com/geniou))

- Fix Delegate cop [\#1029](https://github.com/bbatsov/rubocop/pull/1029) ([geniou](https://github.com/geniou))

- Allow AssignedParameters cop to handle assigned methods [\#1009](https://github.com/bbatsov/rubocop/pull/1009) ([tommeier](https://github.com/tommeier))

- Remove ruby 1.9.2, Use private\_constant [\#1100](https://github.com/bbatsov/rubocop/pull/1100) ([geniou](https://github.com/geniou))

- Update name of auto generated rubocop todo file [\#1093](https://github.com/bbatsov/rubocop/pull/1093) ([ivanoats](https://github.com/ivanoats))

- Rspec cop [\#1087](https://github.com/bbatsov/rubocop/pull/1087) ([geniou](https://github.com/geniou))

- Fix LineEndConcatenation to handle chained concats [\#1006](https://github.com/bbatsov/rubocop/pull/1006) ([barunio](https://github.com/barunio))

- alinghash does not move comments correctly [\#974](https://github.com/bbatsov/rubocop/pull/974) ([tamird](https://github.com/tamird))

## [v0.21.0](https://github.com/bbatsov/rubocop/tree/v0.21.0) (2014-04-24)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.20.1...v0.21.0)

**Fixed bugs:**

- TrailingBlankLines should not trigger on empty file with single blank line [\#993](https://github.com/bbatsov/rubocop/issues/993)

**Closed issues:**

- AndOr and Not wrongly reporting corrected offenses [\#1028](https://github.com/bbatsov/rubocop/issues/1028)

- Conditions shouldn't need to be on the same line as a statement-modifier [\#1016](https://github.com/bbatsov/rubocop/issues/1016)

- Nested StringLiterals isn't detected properly. [\#1014](https://github.com/bbatsov/rubocop/issues/1014)

- Include/Exclude Globbing with '\*\*' Should Match Files In Base Directory [\#1011](https://github.com/bbatsov/rubocop/issues/1011)

- RegexpLiteral cop not being disabled in the rubocop-todo.yml file [\#1001](https://github.com/bbatsov/rubocop/issues/1001)

- Bad indentation check [\#1000](https://github.com/bbatsov/rubocop/issues/1000)

- Running `rubocop .` causes .rubocop.yml to be ignored [\#997](https://github.com/bbatsov/rubocop/issues/997)

- Spelling Mistake [\#992](https://github.com/bbatsov/rubocop/issues/992)

- Semicolon cop auto-correct not working [\#987](https://github.com/bbatsov/rubocop/issues/987)

- Opting in to cops on a cop-by-cop basis? [\#986](https://github.com/bbatsov/rubocop/issues/986)

- FinalNewline not working [\#980](https://github.com/bbatsov/rubocop/issues/980)

- LineLength: add an IgnoreComments parameter [\#977](https://github.com/bbatsov/rubocop/issues/977)

- Autocorrect for NonNilCheck changes code semantics [\#972](https://github.com/bbatsov/rubocop/issues/972)

- Implement a cop which tracks `\_`-prefixed variables/params that are actually used [\#934](https://github.com/bbatsov/rubocop/issues/934)

- Auto-correct not correcting AndOr offences [\#800](https://github.com/bbatsov/rubocop/issues/800)

- Cop for finding deprecated method calls File.exists? [\#791](https://github.com/bbatsov/rubocop/issues/791)

**Merged pull requests:**

- Check for non ASCII characters in Encoding cop [\#1025](https://github.com/bbatsov/rubocop/pull/1025) ([geniou](https://github.com/geniou))

- Fix `Delegate` handling of delegators with arguments [\#1024](https://github.com/bbatsov/rubocop/pull/1024) ([tamird](https://github.com/tamird))

- Fix tests in the presences of `ast` 2.0.0 [\#1023](https://github.com/bbatsov/rubocop/pull/1023) ([tamird](https://github.com/tamird))

- Use new style globbing in default config [\#1021](https://github.com/bbatsov/rubocop/pull/1021) ([tamird](https://github.com/tamird))

- Fix README formatting [\#1019](https://github.com/bbatsov/rubocop/pull/1019) ([jonas054](https://github.com/jonas054))

- \[Fix \#1011\] Add pattern matching with Dir\#\[\] for config. [\#1018](https://github.com/bbatsov/rubocop/pull/1018) ([jonas054](https://github.com/jonas054))

- \[Fix \#993\] Don't report offenses for an empty file [\#1015](https://github.com/bbatsov/rubocop/pull/1015) ([jonas054](https://github.com/jonas054))

- \[Fix \#1001\] Fix --auto-gen-config logic for RegexpLiteral [\#1013](https://github.com/bbatsov/rubocop/pull/1013) ([jonas054](https://github.com/jonas054))

- New Rails cop `Delegate` - checks for delegations [\#1012](https://github.com/bbatsov/rubocop/pull/1012) ([geniou](https://github.com/geniou))

- Fix indent after private def [\#1007](https://github.com/bbatsov/rubocop/pull/1007) ([jonas054](https://github.com/jonas054))

- Improve messages of lint cops [\#1003](https://github.com/bbatsov/rubocop/pull/1003) ([yujinakayama](https://github.com/yujinakayama))

- Refactor for smaller classes [\#999](https://github.com/bbatsov/rubocop/pull/999) ([jonas054](https://github.com/jonas054))

- \[Fix \#997\] Make sure paths are on normal form for exclude [\#998](https://github.com/bbatsov/rubocop/pull/998) ([jonas054](https://github.com/jonas054))

- New cop UnusedMethodArgument and UnusedBlockArgument [\#996](https://github.com/bbatsov/rubocop/pull/996) ([yujinakayama](https://github.com/yujinakayama))

- Update README.md regarding --only and --lint [\#995](https://github.com/bbatsov/rubocop/pull/995) ([jonas054](https://github.com/jonas054))

- Update --only and --lint functionality [\#994](https://github.com/bbatsov/rubocop/pull/994) ([jonas054](https://github.com/jonas054))

- Configurable trailing blank lines [\#991](https://github.com/bbatsov/rubocop/pull/991) ([jonas054](https://github.com/jonas054))

- Add auto\_correct task to Rake integration [\#989](https://github.com/bbatsov/rubocop/pull/989) ([fabiopelosin](https://github.com/fabiopelosin))

- Fix false positive with zero-arity super in UnderscorePrefixedVariableName [\#985](https://github.com/bbatsov/rubocop/pull/985) ([yujinakayama](https://github.com/yujinakayama))

- update LineEndConcatenation description [\#984](https://github.com/bbatsov/rubocop/pull/984) ([mockdeep](https://github.com/mockdeep))

- Fix infinite correction in IndentationWidth [\#983](https://github.com/bbatsov/rubocop/pull/983) ([jonas054](https://github.com/jonas054))

- New cop UnderscorePrefixedVariableName [\#979](https://github.com/bbatsov/rubocop/pull/979) ([yujinakayama](https://github.com/yujinakayama))

- Fix regression in IndentationWidth with method calls [\#978](https://github.com/bbatsov/rubocop/pull/978) ([tamird](https://github.com/tamird))

- Fix `IndentationWidth` not handling element assignment correctly. [\#976](https://github.com/bbatsov/rubocop/pull/976) ([tamird](https://github.com/tamird))

- Document CollectionMethods configuration [\#973](https://github.com/bbatsov/rubocop/pull/973) ([tamird](https://github.com/tamird))

- AllCops deprecation message shows the config path [\#971](https://github.com/bbatsov/rubocop/pull/971) ([bcobb](https://github.com/bcobb))

- Let the Debugger cop also check for byebug calls [\#969](https://github.com/bbatsov/rubocop/pull/969) ([bquorning](https://github.com/bquorning))

- Expand base dir to avoid exception from Pathname [\#968](https://github.com/bbatsov/rubocop/pull/968) ([bquorning](https://github.com/bquorning))

- Trivial accessors autocorrect [\#967](https://github.com/bbatsov/rubocop/pull/967) ([tamird](https://github.com/tamird))

- Rescue exception autocorrect [\#966](https://github.com/bbatsov/rubocop/pull/966) ([tamird](https://github.com/tamird))

- Add auto-correction to RedundantBegin cop [\#964](https://github.com/bbatsov/rubocop/pull/964) ([tamird](https://github.com/tamird))

- `TrivialAccessors` accepts DSL-style writers. [\#963](https://github.com/bbatsov/rubocop/pull/963) ([tamird](https://github.com/tamird))

- \[Fix \#800\] Do not report \[Corrected\] if correction wasn't done [\#962](https://github.com/bbatsov/rubocop/pull/962) ([jonas054](https://github.com/jonas054))

- Add `UnneededCapitalW` cop [\#1008](https://github.com/bbatsov/rubocop/pull/1008) ([sfeldon](https://github.com/sfeldon))

- Add auto-correct to BlockAlignment cop [\#1002](https://github.com/bbatsov/rubocop/pull/1002) ([barunio](https://github.com/barunio))

- UnderscorePrefixedVariableName does not work with `super` [\#982](https://github.com/bbatsov/rubocop/pull/982) ([tamird](https://github.com/tamird))

- Test case for infinite correction [\#975](https://github.com/bbatsov/rubocop/pull/975) ([tamird](https://github.com/tamird))

- Fixes typo in README.md [\#970](https://github.com/bbatsov/rubocop/pull/970) ([kryachkov](https://github.com/kryachkov))

- Useless access modifier autocorrect [\#965](https://github.com/bbatsov/rubocop/pull/965) ([tamird](https://github.com/tamird))

- Typos in Comments [\#955](https://github.com/bbatsov/rubocop/pull/955) ([phlco](https://github.com/phlco))

- Allow configuration of trailing blank lines [\#490](https://github.com/bbatsov/rubocop/pull/490) ([daviddavis](https://github.com/daviddavis))

## [v0.20.1](https://github.com/bbatsov/rubocop/tree/v0.20.1) (2014-04-05)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.20.0...v0.20.1)

**Fixed bugs:**

- automatic fix unexpectedly modifying the file [\#948](https://github.com/bbatsov/rubocop/issues/948)

- Confusing warning message from SpaceBeforeFirstArg cop with \[\] method [\#944](https://github.com/bbatsov/rubocop/issues/944)

- Autocorrect inserting a space mid-string [\#943](https://github.com/bbatsov/rubocop/issues/943)

**Closed issues:**

- disabled SingleSpaceBeforeFirstArg not always honoured [\#958](https://github.com/bbatsov/rubocop/issues/958)

- SpaceInsideHashLiteralBraces should allow comment after opening brace [\#957](https://github.com/bbatsov/rubocop/issues/957)

- Double corrections end in bad code [\#949](https://github.com/bbatsov/rubocop/issues/949)

- Non Nil in boolean methods [\#946](https://github.com/bbatsov/rubocop/issues/946)

- "Exclude" seems to be ignored in .rubocop.yml [\#935](https://github.com/bbatsov/rubocop/issues/935)

- unrecognized cop Syntax found [\#925](https://github.com/bbatsov/rubocop/issues/925)

**Merged pull requests:**

- \[Fix \#957\] Allow space + comment inside \( { and \[ [\#960](https://github.com/bbatsov/rubocop/pull/960) ([jonas054](https://github.com/jonas054))

- Fix do end auto-correct [\#959](https://github.com/bbatsov/rubocop/pull/959) ([jonas054](https://github.com/jonas054))

- \[Fix \#943\] Fix auto-correct interference with SpaceAfterComma [\#951](https://github.com/bbatsov/rubocop/pull/951) ([jonas054](https://github.com/jonas054))

- Fix SpaceBeforeFirstArg cop for multiline arguments [\#945](https://github.com/bbatsov/rubocop/pull/945) ([cschramm](https://github.com/cschramm))

- fix useless\_access\_modifier bug [\#942](https://github.com/bbatsov/rubocop/pull/942) ([fshowalter](https://github.com/fshowalter))

- \[Fix \#925\] Don't disable Syntax cop in rubocop-todo.yml [\#941](https://github.com/bbatsov/rubocop/pull/941) ([jonas054](https://github.com/jonas054))

- fix test, now it fails [\#956](https://github.com/bbatsov/rubocop/pull/956) ([tamird](https://github.com/tamird))

- failing test case for NilComparison autocorrect [\#954](https://github.com/bbatsov/rubocop/pull/954) ([tamird](https://github.com/tamird))

- failing test case for NonNilCheck [\#953](https://github.com/bbatsov/rubocop/pull/953) ([tamird](https://github.com/tamird))

- failing test case for StringConversionInInterpolation [\#952](https://github.com/bbatsov/rubocop/pull/952) ([tamird](https://github.com/tamird))

- failing test case for UselessAccessModifier [\#940](https://github.com/bbatsov/rubocop/pull/940) ([tamird](https://github.com/tamird))

- VariableName supports an enforced style of white space [\#938](https://github.com/bbatsov/rubocop/pull/938) ([agrimm](https://github.com/agrimm))

## [v0.20.0](https://github.com/bbatsov/rubocop/tree/v0.20.0) (2014-04-02)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.19.1...v0.20.0)

**Implemented enhancements:**

- When running rubocop on a file that .rubocop.yml excludes, have option to skip it [\#893](https://github.com/bbatsov/rubocop/issues/893)

- Space between selector and arguments [\#856](https://github.com/bbatsov/rubocop/issues/856)

- Detect use of uninitialized local variable [\#678](https://github.com/bbatsov/rubocop/issues/678)

**Fixed bugs:**

- SignalException cop incorrectly flags "Use `fail` instead of `raise` to signal exceptions [\#909](https://github.com/bbatsov/rubocop/issues/909)

- Rubocop fights with it self regarding TrailingComma vs SpaceInsideBrackets \[Lock-up\] [\#908](https://github.com/bbatsov/rubocop/issues/908)

- Paths in configuration should be relative to the configuration file [\#892](https://github.com/bbatsov/rubocop/issues/892)

**Closed issues:**

- OpMethod doesn't accept `\_other` [\#936](https://github.com/bbatsov/rubocop/issues/936)

- Re-word rubocop with --config hint [\#928](https://github.com/bbatsov/rubocop/issues/928)

- auto-gen complains about rubocop-todo.yml from parent directory [\#927](https://github.com/bbatsov/rubocop/issues/927)

- BlockNesting not auto-generating correctly [\#926](https://github.com/bbatsov/rubocop/issues/926)

- Autocorrect of HashSytnax does not work in some case [\#919](https://github.com/bbatsov/rubocop/issues/919)

- StringConversionInInterpolation Cop Error  [\#916](https://github.com/bbatsov/rubocop/issues/916)

- Rubocop documentation error when parsing [\#914](https://github.com/bbatsov/rubocop/issues/914)

- String concatenation not working correctly [\#912](https://github.com/bbatsov/rubocop/issues/912)

- Rubocop fights with it self regarding TrailingComma vs SpaceInsideBrackets [\#907](https://github.com/bbatsov/rubocop/issues/907)

- Issue with literal in interpolation [\#906](https://github.com/bbatsov/rubocop/issues/906)

- Error parsing in LiteralInInterpolation and StringConversionInInterpolation [\#904](https://github.com/bbatsov/rubocop/issues/904)

- FileName rule false positive [\#901](https://github.com/bbatsov/rubocop/issues/901)

- LineEndConcatenation rubocop with << [\#899](https://github.com/bbatsov/rubocop/issues/899)

- ActionFilter cop is only valid for Rails \>= 4.0 [\#898](https://github.com/bbatsov/rubocop/issues/898)

- Name conflict with ActiveRecord::Calculations\#average [\#888](https://github.com/bbatsov/rubocop/issues/888)

- Error in PercentLiteralDelimiters cop [\#876](https://github.com/bbatsov/rubocop/issues/876)

**Merged pull requests:**

- Typo in README: 'in generally' → 'is generally' [\#939](https://github.com/bbatsov/rubocop/pull/939) ([Dorian](https://github.com/Dorian))

- \[Fix \#926\] BlockNesting was not auto-generating correctly. [\#933](https://github.com/bbatsov/rubocop/pull/933) ([tmorris-fiksu](https://github.com/tmorris-fiksu))

- \[Fix \#927\] Overwrite rubocop-todo.yml without asking [\#932](https://github.com/bbatsov/rubocop/pull/932) ([jonas054](https://github.com/jonas054))

- add useless access modifier lint cop [\#931](https://github.com/bbatsov/rubocop/pull/931) ([fshowalter](https://github.com/fshowalter))

- \[Fix \#928\] re-word hint on using --config rubocop-todo.yml [\#930](https://github.com/bbatsov/rubocop/pull/930) ([tmorris-fiksu](https://github.com/tmorris-fiksu))

- Fall back to Ruby 2.1 parser if the current Ruby runtime is not supported in Parser [\#924](https://github.com/bbatsov/rubocop/pull/924) ([yujinakayama](https://github.com/yujinakayama))

- add link for tips on installing rbx on OSX [\#923](https://github.com/bbatsov/rubocop/pull/923) ([fshowalter](https://github.com/fshowalter))

- Add option --force-exclusion to always exclude files specified in config `Exclude` [\#922](https://github.com/bbatsov/rubocop/pull/922) ([yujinakayama](https://github.com/yujinakayama))

- Space before first arg [\#921](https://github.com/bbatsov/rubocop/pull/921) ([jonas054](https://github.com/jonas054))

- \[Fix \#919\] Remove auto-correct avoidance in HashSyntax [\#920](https://github.com/bbatsov/rubocop/pull/920) ([jonas054](https://github.com/jonas054))

- fix hanging while auto correct [\#918](https://github.com/bbatsov/rubocop/pull/918) ([hiroponz](https://github.com/hiroponz))

- Fix default exclusion of vendor directories [\#917](https://github.com/bbatsov/rubocop/pull/917) ([jonas054](https://github.com/jonas054))

- Make --only enable the given cop [\#915](https://github.com/bbatsov/rubocop/pull/915) ([jonas054](https://github.com/jonas054))

- `FileName` should accept multiple extensions [\#913](https://github.com/bbatsov/rubocop/pull/913) ([tamird](https://github.com/tamird))

- \[Fix \#876\] Deep merge hashes in configuration when overriding [\#910](https://github.com/bbatsov/rubocop/pull/910) ([jonas054](https://github.com/jonas054))

- Relative paths [\#905](https://github.com/bbatsov/rubocop/pull/905) ([jonas054](https://github.com/jonas054))

- adding << to end of line string concatenation cop [\#903](https://github.com/bbatsov/rubocop/pull/903) ([mockdeep](https://github.com/mockdeep))

- add '--failed-level' option [\#896](https://github.com/bbatsov/rubocop/pull/896) ([hiroponz](https://github.com/hiroponz))

- SERV-3980-rubocop-tab-autocorrection [\#937](https://github.com/bbatsov/rubocop/pull/937) ([yingnanliu](https://github.com/yingnanliu))

- \[Fix \#926\] BlockNesting was not auto-generating correctly. [\#929](https://github.com/bbatsov/rubocop/pull/929) ([tmorris-fiksu](https://github.com/tmorris-fiksu))

- fix for chained file names in FileName cop [\#902](https://github.com/bbatsov/rubocop/pull/902) ([mockdeep](https://github.com/mockdeep))

- Change the way MinDigits variable is used in NumericLiterals. [\#897](https://github.com/bbatsov/rubocop/pull/897) ([asok](https://github.com/asok))

## [v0.19.1](https://github.com/bbatsov/rubocop/tree/v0.19.1) (2014-03-17)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.19.0...v0.19.1)

**Closed issues:**

- Whiteliste Gemfile and Rakefile in the file name cop [\#895](https://github.com/bbatsov/rubocop/issues/895)

- PreferredCollectionMethods finds false positive when 'inject' is set to 'inject' [\#894](https://github.com/bbatsov/rubocop/issues/894)

- False positive in FileName cop [\#890](https://github.com/bbatsov/rubocop/issues/890)

- Literals should be allowed in case statements [\#889](https://github.com/bbatsov/rubocop/issues/889)

- NumericLiterals auto-gen-config Off By One [\#884](https://github.com/bbatsov/rubocop/issues/884)

- Favor modifier if usage weirdness [\#883](https://github.com/bbatsov/rubocop/issues/883)

- MaxSlashes of -1 produced [\#879](https://github.com/bbatsov/rubocop/issues/879)

- IndentHash with separator style AlignHash [\#875](https://github.com/bbatsov/rubocop/issues/875)

- nested modules/classes syntax cop [\#868](https://github.com/bbatsov/rubocop/issues/868)

**Merged pull requests:**

- Fix failing specs that break in PathUtil.relative\_path [\#891](https://github.com/bbatsov/rubocop/pull/891) ([jonas054](https://github.com/jonas054))

- \[\#884\] Fix --auto-gen-config for `NumericLiterals` so MinDigits is correct. [\#887](https://github.com/bbatsov/rubocop/pull/887) ([tmorris-fiksu](https://github.com/tmorris-fiksu))

- remove fancy quote [\#886](https://github.com/bbatsov/rubocop/pull/886) ([tmorris-fiksu](https://github.com/tmorris-fiksu))

- \[Fix \#875\] Handle separator style hashes in IndentHash [\#885](https://github.com/bbatsov/rubocop/pull/885) ([jonas054](https://github.com/jonas054))

- \[Fix \#879\] Do not generate RegexpLiteral: MaxSlashes: -1 [\#882](https://github.com/bbatsov/rubocop/pull/882) ([jonas054](https://github.com/jonas054))

- Fix PercentLiteralDelimiters auto-correct for regular expression with interpolation [\#880](https://github.com/bbatsov/rubocop/pull/880) ([hannestyden](https://github.com/hannestyden))

- \[WiP\] Fail on missing configuration options [\#881](https://github.com/bbatsov/rubocop/pull/881) ([hannestyden](https://github.com/hannestyden))

- Whitelist the Rakefile and Gemfile from name check [\#878](https://github.com/bbatsov/rubocop/pull/878) ([theckman](https://github.com/theckman))

- percent\_literal\_delimiters failing test case [\#877](https://github.com/bbatsov/rubocop/pull/877) ([tamird](https://github.com/tamird))

- Deal with all cli options that result in exit together [\#870](https://github.com/bbatsov/rubocop/pull/870) ([jkogara](https://github.com/jkogara))

- Fix for issue \#578: Rubocop logo [\#636](https://github.com/bbatsov/rubocop/pull/636) ([suranyami](https://github.com/suranyami))

## [v0.19.0](https://github.com/bbatsov/rubocop/tree/v0.19.0) (2014-03-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.18.1...v0.19.0)

**Implemented enhancements:**

- Fuubar style formatter [\#809](https://github.com/bbatsov/rubocop/issues/809)

- SpaceAroundBraces is misleading. [\#802](https://github.com/bbatsov/rubocop/issues/802)

- Explain why each Cop exists [\#666](https://github.com/bbatsov/rubocop/issues/666)

**Fixed bugs:**

- Single line disable broken? [\#862](https://github.com/bbatsov/rubocop/issues/862)

- `rubocop --show-cops` isn't updated to match `.rubocop.yml` [\#848](https://github.com/bbatsov/rubocop/issues/848)

- auto-gen-config doesn't patch %r{/} warning correctly [\#847](https://github.com/bbatsov/rubocop/issues/847)

- auto-correct issue with removing brackets from options hash [\#832](https://github.com/bbatsov/rubocop/issues/832)

- "spans more than one line" error when using --auto-correct [\#790](https://github.com/bbatsov/rubocop/issues/790)

**Closed issues:**

- Hang while auto correct [\#871](https://github.com/bbatsov/rubocop/issues/871)

- Error with Unicorn.rb [\#858](https://github.com/bbatsov/rubocop/issues/858)

- $CHILD\_STATUS doesn't check for require "English" [\#854](https://github.com/bbatsov/rubocop/issues/854)

- rubocop terminates with 'no implicit conversion of Proc into String' [\#852](https://github.com/bbatsov/rubocop/issues/852)

- Add configuration parameter to SpaceAroundEqualsInParameterDefault [\#839](https://github.com/bbatsov/rubocop/issues/839)

- No setting to disable "Surrounding space missing in default value assignment"? [\#838](https://github.com/bbatsov/rubocop/issues/838)

- RegexpLiteral cop inconsistent with `x` modifier prescription from style guide [\#836](https://github.com/bbatsov/rubocop/issues/836)

- Implement a cop that checks the delimiters of %-style literals [\#831](https://github.com/bbatsov/rubocop/issues/831)

- Auto Correct issue [\#827](https://github.com/bbatsov/rubocop/issues/827)

- Auto correct doesn't correct file? [\#826](https://github.com/bbatsov/rubocop/issues/826)

- DotPosition buggy with trailing dots [\#822](https://github.com/bbatsov/rubocop/issues/822)

- EmptyLines removes empty lines from heredoc strings [\#815](https://github.com/bbatsov/rubocop/issues/815)

- IndentationWidth should ignore Heredocs [\#814](https://github.com/bbatsov/rubocop/issues/814)

- rubocop doesn't work with rainbow 2.0.0 [\#812](https://github.com/bbatsov/rubocop/issues/812)

- Useless assignment to variable issue. [\#804](https://github.com/bbatsov/rubocop/issues/804)

- Indentation consistency in arrays and hashes [\#797](https://github.com/bbatsov/rubocop/issues/797)

- Autocorrect: Rules SpaceAfterControlKeyword and ParenthesesAroundCondition clash [\#794](https://github.com/bbatsov/rubocop/issues/794)

- Fix spelling of offence \(s/b offense\) [\#700](https://github.com/bbatsov/rubocop/issues/700)

- AlignParameters and AlignHash + Class DSLs [\#687](https://github.com/bbatsov/rubocop/issues/687)

**Merged pull requests:**

- Relax Filename cop [\#874](https://github.com/bbatsov/rubocop/pull/874) ([yujinakayama](https://github.com/yujinakayama))

- Bug hang auto correct [\#873](https://github.com/bbatsov/rubocop/pull/873) ([hiroponz](https://github.com/hiroponz))

- Add ClassAndModuleChildren cop [\#869](https://github.com/bbatsov/rubocop/pull/869) ([geniou](https://github.com/geniou))

- Redesign parsing logic of cop disabling comment [\#867](https://github.com/bbatsov/rubocop/pull/867) ([yujinakayama](https://github.com/yujinakayama))

- Add configuration option to AlignHash cop making it ignore last argument hashes [\#864](https://github.com/bbatsov/rubocop/pull/864) ([hannestyden](https://github.com/hannestyden))

- Add static alignment style to AlignParameters cop [\#863](https://github.com/bbatsov/rubocop/pull/863) ([hannestyden](https://github.com/hannestyden))

- Mention atom-lint in README [\#861](https://github.com/bbatsov/rubocop/pull/861) ([yujinakayama](https://github.com/yujinakayama))

- Add EnforcedStyle parameter for SpaceAroundEqualsInParameterDefault [\#859](https://github.com/bbatsov/rubocop/pull/859) ([jonas054](https://github.com/jonas054))

- \[Fix \#802\] Split SpaceAroundBlockBraces into two new cops [\#857](https://github.com/bbatsov/rubocop/pull/857) ([jonas054](https://github.com/jonas054))

- Add docs badge to README [\#853](https://github.com/bbatsov/rubocop/pull/853) ([rrrene](https://github.com/rrrene))

- \[Fix \#848\] Make --show-cops print current configuration [\#851](https://github.com/bbatsov/rubocop/pull/851) ([jonas054](https://github.com/jonas054))

- Fix bug in RegexpLiteral concerning --auto-gen-config [\#850](https://github.com/bbatsov/rubocop/pull/850) ([jonas054](https://github.com/jonas054))

- Fix two bugs in autocorrect [\#845](https://github.com/bbatsov/rubocop/pull/845) ([jonas054](https://github.com/jonas054))

- Rerun auto gen config to change offence to offense [\#844](https://github.com/bbatsov/rubocop/pull/844) ([agrimm](https://github.com/agrimm))

- Handle case statements with nothing after the case keyword [\#843](https://github.com/bbatsov/rubocop/pull/843) ([agrimm](https://github.com/agrimm))

- Fix percent literal delimiter multiline autocorrect [\#842](https://github.com/bbatsov/rubocop/pull/842) ([hannestyden](https://github.com/hannestyden))

- Fix `%r`-literal autocorrect [\#841](https://github.com/bbatsov/rubocop/pull/841) ([hannestyden](https://github.com/hannestyden))

- Add length value to locations of offense in JSON formatter [\#840](https://github.com/bbatsov/rubocop/pull/840) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#832\] Fix SpaceInsideHashLiteralBraces auto-correction bug [\#837](https://github.com/bbatsov/rubocop/pull/837) ([jonas054](https://github.com/jonas054))

- Add PercentLiteralDelimiters cop [\#834](https://github.com/bbatsov/rubocop/pull/834) ([hannestyden](https://github.com/hannestyden))

- Auto-correct indentation [\#833](https://github.com/bbatsov/rubocop/pull/833) ([jonas054](https://github.com/jonas054))

- Fix message from EndAlignment when AlignWith is keyword [\#829](https://github.com/bbatsov/rubocop/pull/829) ([jonas054](https://github.com/jonas054))

- More strict IndentationWidth [\#828](https://github.com/bbatsov/rubocop/pull/828) ([jonas054](https://github.com/jonas054))

- Fixed misspelling: follwed =\> followed [\#821](https://github.com/bbatsov/rubocop/pull/821) ([chessbyte](https://github.com/chessbyte))

- Fix problem with \[Corrected\] tag sometimes missing [\#820](https://github.com/bbatsov/rubocop/pull/820) ([jonas054](https://github.com/jonas054))

- Fix autocorrect problem [\#819](https://github.com/bbatsov/rubocop/pull/819) ([jonas054](https://github.com/jonas054))

- New cop IndentArray [\#817](https://github.com/bbatsov/rubocop/pull/817) ([jonas054](https://github.com/jonas054))

- Correct emacs/sublime text anchor links [\#816](https://github.com/bbatsov/rubocop/pull/816) ([Silex](https://github.com/Silex))

- New cop IndentHash [\#813](https://github.com/bbatsov/rubocop/pull/813) ([jonas054](https://github.com/jonas054))

- Introduce Fuubar style formatter [\#811](https://github.com/bbatsov/rubocop/pull/811) ([yujinakayama](https://github.com/yujinakayama))

- Fix error on a setter invocation with operator assignment in a loop body [\#810](https://github.com/bbatsov/rubocop/pull/810) ([yujinakayama](https://github.com/yujinakayama))

- Indicate machine-parsable formats in README [\#808](https://github.com/bbatsov/rubocop/pull/808) ([yujinakayama](https://github.com/yujinakayama))

- Fix a false positive with op-assignments in a loop in UselessAssignment [\#807](https://github.com/bbatsov/rubocop/pull/807) ([yujinakayama](https://github.com/yujinakayama))

- excluding `vendor` by default [\#806](https://github.com/bbatsov/rubocop/pull/806) ([jeremyolliver](https://github.com/jeremyolliver))

- Autocorrect single line methods [\#803](https://github.com/bbatsov/rubocop/pull/803) ([jonas054](https://github.com/jonas054))

- Improve formatter description in README [\#798](https://github.com/bbatsov/rubocop/pull/798) ([yujinakayama](https://github.com/yujinakayama))

- Add MaxLength parameter to IfUnlessModifier and WhileUntilModifier [\#795](https://github.com/bbatsov/rubocop/pull/795) ([agrimm](https://github.com/agrimm))

- Add printing total count when `rubocop --format offences` [\#793](https://github.com/bbatsov/rubocop/pull/793) ([ma2gedev](https://github.com/ma2gedev))

- \[Fix \#790\] Make smaller replace in MethodDefParentheses autocorrect [\#792](https://github.com/bbatsov/rubocop/pull/792) ([jonas054](https://github.com/jonas054))

- Fix typo in CHANGELOG.md [\#789](https://github.com/bbatsov/rubocop/pull/789) ([agrimm](https://github.com/agrimm))

- Move AlignHash cop logic to top of file [\#866](https://github.com/bbatsov/rubocop/pull/866) ([hannestyden](https://github.com/hannestyden))

- Add TextMate2 as an editor to the readme [\#860](https://github.com/bbatsov/rubocop/pull/860) ([mrdougal](https://github.com/mrdougal))

- Typos in README [\#855](https://github.com/bbatsov/rubocop/pull/855) ([attadanta](https://github.com/attadanta))

- Add 'Delimiters' parameter to WordArray cop autocorrect [\#830](https://github.com/bbatsov/rubocop/pull/830) ([hannestyden](https://github.com/hannestyden))

- Add space after '\# rubocop:' [\#825](https://github.com/bbatsov/rubocop/pull/825) ([AlexVPopov](https://github.com/AlexVPopov))

## [v0.18.1](https://github.com/bbatsov/rubocop/tree/v0.18.1) (2014-02-02)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.18.0...v0.18.1)

**Implemented enhancements:**

- "Method has too many lines" check not smart enough [\#494](https://github.com/bbatsov/rubocop/issues/494)

**Fixed bugs:**

- autocorrect of if statements with parenthesis places space in incorrect location [\#783](https://github.com/bbatsov/rubocop/issues/783)

- Issue with AlignHash [\#782](https://github.com/bbatsov/rubocop/issues/782)

- AccessModifierIndentation autocorrect can't make up its mind [\#781](https://github.com/bbatsov/rubocop/issues/781)

- False positives on Style:Documentation [\#751](https://github.com/bbatsov/rubocop/issues/751)

- Annotation keyword comments count as class comments [\#718](https://github.com/bbatsov/rubocop/issues/718)

**Closed issues:**

- False positives for TrailingComma cop, %w\(\) arrays [\#785](https://github.com/bbatsov/rubocop/issues/785)

- Invalid warning and correction by LineEndConcatenation [\#779](https://github.com/bbatsov/rubocop/issues/779)

- Keep order of offenses between runs [\#777](https://github.com/bbatsov/rubocop/issues/777)

- do/end for multi-line block misses some [\#776](https://github.com/bbatsov/rubocop/issues/776)

**Merged pull requests:**

- \[Fix \#718\] Don't regard annotations as class/module documentation [\#788](https://github.com/bbatsov/rubocop/pull/788) ([jonas054](https://github.com/jonas054))

- \[Fix \#782\] Fix false positive in AlignHash for single line hashes [\#787](https://github.com/bbatsov/rubocop/pull/787) ([jonas054](https://github.com/jonas054))

- \[Fix \#785\] Fix false positive on %w arrays in TrailingComma [\#786](https://github.com/bbatsov/rubocop/pull/786) ([jonas054](https://github.com/jonas054))

- \[Fix \#781\] Fix double reporting in AccessModifierIndentation [\#784](https://github.com/bbatsov/rubocop/pull/784) ([jonas054](https://github.com/jonas054))

- \[Fix \#751\] Let Documentation cop require class comment to be adjacent [\#780](https://github.com/bbatsov/rubocop/pull/780) ([jonas054](https://github.com/jonas054))

- Fix double reporting in EmptyLinesAroundBody for empty class [\#778](https://github.com/bbatsov/rubocop/pull/778) ([jonas054](https://github.com/jonas054))

## [v0.18.0](https://github.com/bbatsov/rubocop/tree/v0.18.0) (2014-01-30)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.17.0...v0.18.0)

**Fixed bugs:**

- Regression on Exclude [\#757](https://github.com/bbatsov/rubocop/issues/757)

**Closed issues:**

- Ignore rubocop inline directives when calculating LineLength [\#774](https://github.com/bbatsov/rubocop/issues/774)

- TrailingComma in HEREDOC [\#772](https://github.com/bbatsov/rubocop/issues/772)

- TrailingComma false positive in heredoc [\#764](https://github.com/bbatsov/rubocop/issues/764)

- Rubocop v0.16.0 incompatible with rainbow gem v2.0.0 [\#762](https://github.com/bbatsov/rubocop/issues/762)

- Reduce JSON requirement to ~\> 1.7 [\#761](https://github.com/bbatsov/rubocop/issues/761)

- \[new cop\] Concatenation of string literals [\#759](https://github.com/bbatsov/rubocop/issues/759)

- When cops are disabled in source code, are they disabled everywhere? [\#753](https://github.com/bbatsov/rubocop/issues/753)

- \[new cop\] Require parentheses [\#714](https://github.com/bbatsov/rubocop/issues/714)

- Rubocop finds .rubocop.yml in parent directories [\#536](https://github.com/bbatsov/rubocop/issues/536)

**Merged pull requests:**

- Correctly point to rubocop's issues page in contributor guidelines [\#775](https://github.com/bbatsov/rubocop/pull/775) ([scottmatthewman](https://github.com/scottmatthewman))

- Implement auto-correct for AccessModifierIndentation cop [\#773](https://github.com/bbatsov/rubocop/pull/773) ([jonas054](https://github.com/jonas054))

- Bugfix for \#768 [\#770](https://github.com/bbatsov/rubocop/pull/770) ([nevir](https://github.com/nevir))

- Excludes/includes support globs relative to the project \(PWD for now\). [\#769](https://github.com/bbatsov/rubocop/pull/769) ([nevir](https://github.com/nevir))

- Rake task now supports `requires` and `options` [\#768](https://github.com/bbatsov/rubocop/pull/768) ([nevir](https://github.com/nevir))

- Support mocked file paths in the spec helper's parse\_source [\#767](https://github.com/bbatsov/rubocop/pull/767) ([nevir](https://github.com/nevir))

- Support auto-correction in WordArray [\#766](https://github.com/bbatsov/rubocop/pull/766) ([jonas054](https://github.com/jonas054))

- \[Fix \#764\] Handle heredocs in TrailingComma [\#765](https://github.com/bbatsov/rubocop/pull/765) ([jonas054](https://github.com/jonas054))

- Support Rainbow gem both 1.99.x and 2.x [\#763](https://github.com/bbatsov/rubocop/pull/763) ([yujinakayama](https://github.com/yujinakayama))

- Add changelog format guide to CONTRIBUTING.md [\#758](https://github.com/bbatsov/rubocop/pull/758) ([yujinakayama](https://github.com/yujinakayama))

- \[Fix \#714\] New cop RequireParentheses. [\#756](https://github.com/bbatsov/rubocop/pull/756) ([jonas054](https://github.com/jonas054))

- Ensure changelog format [\#754](https://github.com/bbatsov/rubocop/pull/754) ([yujinakayama](https://github.com/yujinakayama))

- Fix typo with capital v for verbose output [\#760](https://github.com/bbatsov/rubocop/pull/760) ([kalabiyau](https://github.com/kalabiyau))

- Remove JSON dependency [\#755](https://github.com/bbatsov/rubocop/pull/755) ([sethvargo](https://github.com/sethvargo))

## [v0.17.0](https://github.com/bbatsov/rubocop/tree/v0.17.0) (2014-01-23)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.16.0...v0.17.0)

**Implemented enhancements:**

- Allow for configurable SpaceAfterComma exceptions [\#562](https://github.com/bbatsov/rubocop/issues/562)

**Fixed bugs:**

- Double quotes inside %{ } block not automatically fixed correctly  [\#738](https://github.com/bbatsov/rubocop/issues/738)

- Handle required keyword arguments by default [\#724](https://github.com/bbatsov/rubocop/issues/724)

- undefined method `loc' for :path\_to:Symbol [\#716](https://github.com/bbatsov/rubocop/issues/716)

- Disable terminal ANSI escape sequences when the output is a file [\#498](https://github.com/bbatsov/rubocop/issues/498)

**Closed issues:**

- Rubocop should ignore the schema in Rails projects [\#752](https://github.com/bbatsov/rubocop/issues/752)

- Auto-correct should not introduce new offenses [\#744](https://github.com/bbatsov/rubocop/issues/744)

- Blank file cop? [\#740](https://github.com/bbatsov/rubocop/issues/740)

- Blank line before the end of the file shouldn't be really considered a bad practice [\#734](https://github.com/bbatsov/rubocop/issues/734)

- support for new private syntax [\#730](https://github.com/bbatsov/rubocop/issues/730)

- \[new cop\] law of demeter [\#720](https://github.com/bbatsov/rubocop/issues/720)

- Trailing commas [\#713](https://github.com/bbatsov/rubocop/issues/713)

- EndAlignment: AlignWith: variable does not work with multiple assignment [\#709](https://github.com/bbatsov/rubocop/issues/709)

- UselessAssignment cop chokes on `||=` in argument list [\#707](https://github.com/bbatsov/rubocop/issues/707)

- improve rubocop-todo [\#702](https://github.com/bbatsov/rubocop/issues/702)

- Add required\_ruby\_version to gemspec [\#694](https://github.com/bbatsov/rubocop/issues/694)

- Squeel Syntax Confuses RuboCop [\#623](https://github.com/bbatsov/rubocop/issues/623)

**Merged pull requests:**

- removed duplicated require [\#750](https://github.com/bbatsov/rubocop/pull/750) ([pmenglund](https://github.com/pmenglund))

- Fix crash on ternary if in ParenthesesAroundCondition. [\#749](https://github.com/bbatsov/rubocop/pull/749) ([jonas054](https://github.com/jonas054))

- Fix EmptyLinesAroundBody so it doesn't report blank lines. [\#748](https://github.com/bbatsov/rubocop/pull/748) ([jonas054](https://github.com/jonas054))

- Updating README to indicate general ST support [\#747](https://github.com/bbatsov/rubocop/pull/747) ([pderichs](https://github.com/pderichs))

- Read, inspect, and write file repeatedly in --auto-correct. [\#746](https://github.com/bbatsov/rubocop/pull/746) ([jonas054](https://github.com/jonas054))

- \[Fix \#730\] Enforce end aligned with "private def", etc, in Ruby 2.1. [\#742](https://github.com/bbatsov/rubocop/pull/742) ([jonas054](https://github.com/jonas054))

- Fix 'Not a block' error for default\_scope [\#741](https://github.com/bbatsov/rubocop/pull/741) ([bhicks](https://github.com/bhicks))

- Shorter classes [\#739](https://github.com/bbatsov/rubocop/pull/739) ([jonas054](https://github.com/jonas054))

- Fix config loader [\#737](https://github.com/bbatsov/rubocop/pull/737) ([jonas054](https://github.com/jonas054))

- TrailingComma cop [\#735](https://github.com/bbatsov/rubocop/pull/735) ([jonas054](https://github.com/jonas054))

- NumericLiterals cop does auto-correction. [\#733](https://github.com/bbatsov/rubocop/pull/733) ([dblock](https://github.com/dblock))

- Consistent file naming for specs \(and \*TernaryOperator cops\) [\#732](https://github.com/bbatsov/rubocop/pull/732) ([nevir](https://github.com/nevir))

- Make sure config descriptions don't have trailing newlines. [\#729](https://github.com/bbatsov/rubocop/pull/729) ([jonas054](https://github.com/jonas054))

- Fix parsing of the --no-color option. [\#728](https://github.com/bbatsov/rubocop/pull/728) ([jonas054](https://github.com/jonas054))

- \[Fix \#724\] Allow colon for required keyword argument without space. [\#726](https://github.com/bbatsov/rubocop/pull/726) ([jonas054](https://github.com/jonas054))

- Spelling fix [\#725](https://github.com/bbatsov/rubocop/pull/725) ([bakongo](https://github.com/bakongo))

- Update CHANGELOG.md regarding --show-cops. [\#723](https://github.com/bbatsov/rubocop/pull/723) ([jonas054](https://github.com/jonas054))

- Improve --show-cops output [\#722](https://github.com/bbatsov/rubocop/pull/722) ([jonas054](https://github.com/jonas054))

- Fix a bug where some offences were discarded with cop specific target paths [\#721](https://github.com/bbatsov/rubocop/pull/721) ([yujinakayama](https://github.com/yujinakayama))

- Split Syntax cop [\#719](https://github.com/bbatsov/rubocop/pull/719) ([yujinakayama](https://github.com/yujinakayama))

- Organize cop files [\#717](https://github.com/bbatsov/rubocop/pull/717) ([yujinakayama](https://github.com/yujinakayama))

- Fix error on operator assignments in top level scope in UselessAssignment [\#712](https://github.com/bbatsov/rubocop/pull/712) ([yujinakayama](https://github.com/yujinakayama))

- Adding en example on how to specify regular expressions [\#711](https://github.com/bbatsov/rubocop/pull/711) ([AvnerCohen](https://github.com/AvnerCohen))

- Refactor duplication [\#710](https://github.com/bbatsov/rubocop/pull/710) ([jonas054](https://github.com/jonas054))

- \[Fix \#702\] Add comments for cops in rubocop-todo.yml. [\#708](https://github.com/bbatsov/rubocop/pull/708) ([jonas054](https://github.com/jonas054))

- Fix braces around hash parameters [\#706](https://github.com/bbatsov/rubocop/pull/706) ([jonas054](https://github.com/jonas054))

- Convert specs to the latest RSpec syntax [\#704](https://github.com/bbatsov/rubocop/pull/704) ([yujinakayama](https://github.com/yujinakayama))

- Disable terminal escape sequences when a formatter's output is not a TTY [\#701](https://github.com/bbatsov/rubocop/pull/701) ([yujinakayama](https://github.com/yujinakayama))

- More parameter generation for rubocop-todo.yml [\#699](https://github.com/bbatsov/rubocop/pull/699) ([jonas054](https://github.com/jonas054))

- Support Ruby 1.9.2 [\#697](https://github.com/bbatsov/rubocop/pull/697) ([yujinakayama](https://github.com/yujinakayama))

- facilitate integration into ci build [\#745](https://github.com/bbatsov/rubocop/pull/745) ([vaneyckt](https://github.com/vaneyckt))

- Shorter classes [\#736](https://github.com/bbatsov/rubocop/pull/736) ([jonas054](https://github.com/jonas054))

- UnitSpecNaming cop [\#731](https://github.com/bbatsov/rubocop/pull/731) ([nevir](https://github.com/nevir))

- Extract method Util\#new\_range, remove 1st arg to Util\#source\_range. [\#715](https://github.com/bbatsov/rubocop/pull/715) ([jonas054](https://github.com/jonas054))

- BracesAroundHashParameters auto-correction broken with trailing comma [\#703](https://github.com/bbatsov/rubocop/pull/703) ([tamird](https://github.com/tamird))

- Support Windows paths [\#698](https://github.com/bbatsov/rubocop/pull/698) ([rifraf](https://github.com/rifraf))

## [v0.16.0](https://github.com/bbatsov/rubocop/tree/v0.16.0) (2013-12-25)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.15.0...v0.16.0)

**Implemented enhancements:**

- New configuration option allowing method definitions without parenthesis around arguments [\#577](https://github.com/bbatsov/rubocop/issues/577)

- Parameters reporting [\#532](https://github.com/bbatsov/rubocop/issues/532)

- Disabling some cops for some files [\#360](https://github.com/bbatsov/rubocop/issues/360)

- Feature: Custom Cops [\#111](https://github.com/bbatsov/rubocop/issues/111)

**Fixed bugs:**

- EndOfLine cop broken for UTF-8 files [\#668](https://github.com/bbatsov/rubocop/issues/668)

- RSpec isolated environment not isolated enough? [\#418](https://github.com/bbatsov/rubocop/issues/418)

**Closed issues:**

- rubocop --version takes an excessive ammount of time [\#695](https://github.com/bbatsov/rubocop/issues/695)

- Missing top-level class documentation comment. [\#691](https://github.com/bbatsov/rubocop/issues/691)

- Useless assignment offends on assignment in modifier conditional [\#685](https://github.com/bbatsov/rubocop/issues/685)

- Colliding autocorrect rules: Autocorrect changes curly brackets to "d o" instead of "do" block. [\#684](https://github.com/bbatsov/rubocop/issues/684)

- "All cops support the Exclude param." [\#674](https://github.com/bbatsov/rubocop/issues/674)

- Combination of line length and not using single-line conditionals [\#671](https://github.com/bbatsov/rubocop/issues/671)

- IndentationWidth doesn't like chaining methods after conditions in assignment [\#670](https://github.com/bbatsov/rubocop/issues/670)

- IndentationWidth offending on assignment in conditional aligned with variable [\#669](https://github.com/bbatsov/rubocop/issues/669)

- Inconsistent indentation detected when I specify AccessModifierIndentation:EnforcedStyle:outdent [\#667](https://github.com/bbatsov/rubocop/issues/667)

- WhileUntil complains when alternative is not legal Ruby [\#664](https://github.com/bbatsov/rubocop/issues/664)

- Indentation of `if` when using the return value [\#661](https://github.com/bbatsov/rubocop/issues/661)

- Allow option for preferring `for` loop over `each` block [\#654](https://github.com/bbatsov/rubocop/issues/654)

- Problem with "Indent when as deep as case" [\#653](https://github.com/bbatsov/rubocop/issues/653)

- Redundant `self` cop incorrect when arguments mask methods [\#651](https://github.com/bbatsov/rubocop/issues/651)

- Ruby 2.1.0 support [\#647](https://github.com/bbatsov/rubocop/issues/647)

- Space inside brackets cop raises a false positive [\#645](https://github.com/bbatsov/rubocop/issues/645)

- Travis failures for Rubinius [\#643](https://github.com/bbatsov/rubocop/issues/643)

- Conflict between SpaceAroundBlockBraces and Blocks when autocorrecting [\#638](https://github.com/bbatsov/rubocop/issues/638)

- Error message when config has a comment [\#634](https://github.com/bbatsov/rubocop/issues/634)

- Introduce levels of severity [\#633](https://github.com/bbatsov/rubocop/issues/633)

- Inconsistent indentation not detected [\#631](https://github.com/bbatsov/rubocop/issues/631)

- Having trouble excluding code in test/ [\#629](https://github.com/bbatsov/rubocop/issues/629)

- \['AllCops'\]\['Excludes'\] ignored from configuration file passed via -c [\#620](https://github.com/bbatsov/rubocop/issues/620)

- Where is CyclomaticComplexity report shown? [\#619](https://github.com/bbatsov/rubocop/issues/619)

- What does the chars like CCWWW means? [\#617](https://github.com/bbatsov/rubocop/issues/617)

- apply ReduceArguments cop to each\_with\_object calls [\#616](https://github.com/bbatsov/rubocop/issues/616)

- EmptyLinesAroundBody find two lines when only one with Windows CRLF ending [\#609](https://github.com/bbatsov/rubocop/issues/609)

**Merged pull requests:**

- Use Parser 2.1 [\#696](https://github.com/bbatsov/rubocop/pull/696) ([yujinakayama](https://github.com/yujinakayama))

- Improve rubocop todo [\#693](https://github.com/bbatsov/rubocop/pull/693) ([jonas054](https://github.com/jonas054))

- Fix indentation when chaining block on end [\#690](https://github.com/bbatsov/rubocop/pull/690) ([jonas054](https://github.com/jonas054))

- Fix favor modifier check for assignment in condition [\#689](https://github.com/bbatsov/rubocop/pull/689) ([emou](https://github.com/emou))

- Fix the isolated environment spec on OS X [\#683](https://github.com/bbatsov/rubocop/pull/683) ([mitio](https://github.com/mitio))

- Fix autocorrect for MethodDefParentheses [\#682](https://github.com/bbatsov/rubocop/pull/682) ([skanev](https://github.com/skanev))

- \[Fix \#577\] A cop for requiring no parentheses in method definitions [\#681](https://github.com/bbatsov/rubocop/pull/681) ([skanev](https://github.com/skanev))

- \[Fix \#664\] Accept oneline while when condition has local variable assignment [\#680](https://github.com/bbatsov/rubocop/pull/680) ([emou](https://github.com/emou))

- New cop FlipFlop [\#679](https://github.com/bbatsov/rubocop/pull/679) ([agrimm](https://github.com/agrimm))

- \[Fix \#668\] Use encoding from Parser in call to IO.read in EndOfLine. [\#677](https://github.com/bbatsov/rubocop/pull/677) ([jonas054](https://github.com/jonas054))

- \[Fix \#674\] Do not issue warning for Exclude and Include config params. [\#676](https://github.com/bbatsov/rubocop/pull/676) ([jonas054](https://github.com/jonas054))

- \[Fix \#667\] Handle public/protected/private in IndentationWidth. [\#675](https://github.com/bbatsov/rubocop/pull/675) ([jonas054](https://github.com/jonas054))

- Fix indentation when chaining on end [\#673](https://github.com/bbatsov/rubocop/pull/673) ([jonas054](https://github.com/jonas054))

- Add config to EndAlignment [\#665](https://github.com/bbatsov/rubocop/pull/665) ([jonas054](https://github.com/jonas054))

- \[Fix \#654\] Add config option EnforcedStyle to For cop. [\#662](https://github.com/bbatsov/rubocop/pull/662) ([jonas054](https://github.com/jonas054))

- Add configuration parameters for CaseIndentation. [\#660](https://github.com/bbatsov/rubocop/pull/660) ([jonas054](https://github.com/jonas054))

- how to disable specific cop in .config.yaml [\#659](https://github.com/bbatsov/rubocop/pull/659) ([paulczar](https://github.com/paulczar))

- Remove printout from isolated environment spec. [\#658](https://github.com/bbatsov/rubocop/pull/658) ([jonas054](https://github.com/jonas054))

- Alias cop does auto-correction. [\#657](https://github.com/bbatsov/rubocop/pull/657) ([dblock](https://github.com/dblock))

- Options config with excludes paths [\#656](https://github.com/bbatsov/rubocop/pull/656) ([codez](https://github.com/codez))

- More implicit conditionals [\#655](https://github.com/bbatsov/rubocop/pull/655) ([agrimm](https://github.com/agrimm))

- Don't search for .rubocop.yml above the temporary work directory. [\#652](https://github.com/bbatsov/rubocop/pull/652) ([jonas054](https://github.com/jonas054))

- EmptyLinesAroundBody cop does auto-correction. [\#649](https://github.com/bbatsov/rubocop/pull/649) ([dblock](https://github.com/dblock))

- Number Literal message mistake. [\#648](https://github.com/bbatsov/rubocop/pull/648) ([kylewelsby](https://github.com/kylewelsby))

- Fix bug in SpaceAroundBlockBraces that desetroys code in -a mode. [\#646](https://github.com/bbatsov/rubocop/pull/646) ([jonas054](https://github.com/jonas054))

- Refactor to reduce lengths and complexity [\#644](https://github.com/bbatsov/rubocop/pull/644) ([jonas054](https://github.com/jonas054))

- Get rid of some duplication in SpaceAroundBlockBraces. [\#642](https://github.com/bbatsov/rubocop/pull/642) ([jonas054](https://github.com/jonas054))

- Fix block autocorrect clash [\#641](https://github.com/bbatsov/rubocop/pull/641) ([jonas054](https://github.com/jonas054))

- \[Fix \#631\] Check that consecutive lines have the same indentation. [\#637](https://github.com/bbatsov/rubocop/pull/637) ([jonas054](https://github.com/jonas054))

- Fix counting of slashes in RegexpLiteral. [\#635](https://github.com/bbatsov/rubocop/pull/635) ([jonas054](https://github.com/jonas054))

- Refactor SpaceAroundOperators [\#632](https://github.com/bbatsov/rubocop/pull/632) ([jonas054](https://github.com/jonas054))

- accept dot position on same line for trailing style [\#630](https://github.com/bbatsov/rubocop/pull/630) ([vonTronje](https://github.com/vonTronje))

- Allow self.Foo [\#628](https://github.com/bbatsov/rubocop/pull/628) ([chulkilee](https://github.com/chulkilee))

- Reduce duplication [\#626](https://github.com/bbatsov/rubocop/pull/626) ([jonas054](https://github.com/jonas054))

- Improve English in comments [\#625](https://github.com/bbatsov/rubocop/pull/625) ([agrimm](https://github.com/agrimm))

- `EmptyLines` cop does auto-correction. [\#624](https://github.com/bbatsov/rubocop/pull/624) ([dblock](https://github.com/dblock))

- Properly handle file inclusion/exclusion rules when using -c [\#621](https://github.com/bbatsov/rubocop/pull/621) ([fancyremarker](https://github.com/fancyremarker))

- Don't report missing space around operator for def self.method \*args. [\#615](https://github.com/bbatsov/rubocop/pull/615) ([jonas054](https://github.com/jonas054))

- Autocorrect ParenthesesAroundCondition. [\#614](https://github.com/bbatsov/rubocop/pull/614) ([dblock](https://github.com/dblock))

- Autocorrect BracesAroundHashParameters cop. [\#612](https://github.com/bbatsov/rubocop/pull/612) ([dblock](https://github.com/dblock))

- Add failing specs for chaining onto an 'end' with a block [\#686](https://github.com/bbatsov/rubocop/pull/686) ([patbenatar](https://github.com/patbenatar))

- \[WIP\] Adds failing specs for indentation/alignment cops when chaining onto `end` [\#672](https://github.com/bbatsov/rubocop/pull/672) ([patbenatar](https://github.com/patbenatar))

- Allow to overwrite the severity of a cop with the 'Severity' param [\#663](https://github.com/bbatsov/rubocop/pull/663) ([codez](https://github.com/codez))

- add support to set formatters in rake task [\#650](https://github.com/bbatsov/rubocop/pull/650) ([pmenglund](https://github.com/pmenglund))

- Allow symbol names such as :'bundle:install' [\#640](https://github.com/bbatsov/rubocop/pull/640) ([navinpeiris](https://github.com/navinpeiris))

- RegexpLiteral slash counter corner case test [\#627](https://github.com/bbatsov/rubocop/pull/627) ([develop7](https://github.com/develop7))

- Make sure Excludes from -c option are considered. [\#622](https://github.com/bbatsov/rubocop/pull/622) ([jonas054](https://github.com/jonas054))

- Remove duplicate changelog in 0.9.0 [\#618](https://github.com/bbatsov/rubocop/pull/618) ([ShockwaveNN](https://github.com/ShockwaveNN))

- SpaceAroundOperators complains about class method with \*args [\#613](https://github.com/bbatsov/rubocop/pull/613) ([mikegee](https://github.com/mikegee))

- fix crash when loading an empty config file [\#611](https://github.com/bbatsov/rubocop/pull/611) ([sinisterchipmunk](https://github.com/sinisterchipmunk))

- Specifying version printing option\(s\) no longer scans for files. [\#610](https://github.com/bbatsov/rubocop/pull/610) ([azanar](https://github.com/azanar))

## [v0.15.0](https://github.com/bbatsov/rubocop/tree/v0.15.0) (2013-11-06)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.14.1...v0.15.0)

**Implemented enhancements:**

- Doesn't allow single indentation of arrays [\#560](https://github.com/bbatsov/rubocop/issues/560)

- Auto-correction of space-related offences [\#553](https://github.com/bbatsov/rubocop/issues/553)

**Fixed bugs:**

- Empty curly braces should not contain a space [\#594](https://github.com/bbatsov/rubocop/issues/594)

- WordArray should allow multi-line arrays of words [\#554](https://github.com/bbatsov/rubocop/issues/554)

- allow alias in specific cases [\#173](https://github.com/bbatsov/rubocop/issues/173)

**Closed issues:**

- SpaceInsideHashLiteralBraces:EnforcedStyle causes error [\#605](https://github.com/bbatsov/rubocop/issues/605)

- Catch-22 with class containing nothing but protected or private methods [\#600](https://github.com/bbatsov/rubocop/issues/600)

- Apply rubocop to style guide code [\#596](https://github.com/bbatsov/rubocop/issues/596)

- If unless triggered by \_\_FILE\_\_ check [\#593](https://github.com/bbatsov/rubocop/issues/593)

- Variable name length cop [\#592](https://github.com/bbatsov/rubocop/issues/592)

- MethodCallParentheses lacks exception for empty blocks [\#589](https://github.com/bbatsov/rubocop/issues/589)

- MethodCallParentheses lacks exception for starting with uppercase letter [\#585](https://github.com/bbatsov/rubocop/issues/585)

- Rubocop runs very slowly [\#584](https://github.com/bbatsov/rubocop/issues/584)

- Cyclomatic complexity cop [\#579](https://github.com/bbatsov/rubocop/issues/579)

- Remove warnings when using JSON formatter [\#576](https://github.com/bbatsov/rubocop/issues/576)

- UselessSetterCall bug? [\#574](https://github.com/bbatsov/rubocop/issues/574)

- Pickaxe warns against using `Kernel\#proc` in new code. [\#573](https://github.com/bbatsov/rubocop/issues/573)

- NumericLiterals with negative number [\#561](https://github.com/bbatsov/rubocop/issues/561)

- A cop for CHANGELOG.md [\#558](https://github.com/bbatsov/rubocop/issues/558)

- Rubocop requires its own .rubocop.yml to exist to function correctly [\#557](https://github.com/bbatsov/rubocop/issues/557)

- Multiline offences breaks output [\#555](https://github.com/bbatsov/rubocop/issues/555)

**Merged pull requests:**

- Handle rescue var::SomeError. [\#608](https://github.com/bbatsov/rubocop/pull/608) ([jonas054](https://github.com/jonas054))

- Fix error on implicit match conditionals in FavorModifier [\#607](https://github.com/bbatsov/rubocop/pull/607) ([yujinakayama](https://github.com/yujinakayama))

- Add pending test about regexp in conditionals [\#604](https://github.com/bbatsov/rubocop/pull/604) ([agrimm](https://github.com/agrimm))

- Allow WordArray to support a minimum array size [\#603](https://github.com/bbatsov/rubocop/pull/603) ([claco](https://github.com/claco))

- Enable coverage builds again. [\#602](https://github.com/bbatsov/rubocop/pull/602) ([jonas054](https://github.com/jonas054))

- Refactor options [\#601](https://github.com/bbatsov/rubocop/pull/601) ([jonas054](https://github.com/jonas054))

- Make EndOfLine cop work again. [\#599](https://github.com/bbatsov/rubocop/pull/599) ([jonas054](https://github.com/jonas054))

- Fix empty braces bug [\#598](https://github.com/bbatsov/rubocop/pull/598) ([jonas054](https://github.com/jonas054))

- Output config validation warning to STDERR [\#597](https://github.com/bbatsov/rubocop/pull/597) ([yujinakayama](https://github.com/yujinakayama))

- Add brackets-rubocop to the editor integration section. [\#591](https://github.com/bbatsov/rubocop/pull/591) ([smockle](https://github.com/smockle))

- Add CyclomaticComplexity cop. [\#590](https://github.com/bbatsov/rubocop/pull/590) ([jonas054](https://github.com/jonas054))

- Fix English [\#588](https://github.com/bbatsov/rubocop/pull/588) ([agrimm](https://github.com/agrimm))

- Refactor long methods [\#587](https://github.com/bbatsov/rubocop/pull/587) ([jonas054](https://github.com/jonas054))

- Fix error on multiple-assignment with non-array rhs in UselessSetterCall [\#586](https://github.com/bbatsov/rubocop/pull/586) ([yujinakayama](https://github.com/yujinakayama))

- Make AccessControl indent depth configurable [\#582](https://github.com/bbatsov/rubocop/pull/582) ([sds](https://github.com/sds))

- Auto-correct in space-related cops [\#580](https://github.com/bbatsov/rubocop/pull/580) ([jonas054](https://github.com/jonas054))

- Show encoding errors as offences. [\#575](https://github.com/bbatsov/rubocop/pull/575) ([jonas054](https://github.com/jonas054))

- Grammar & naming [\#572](https://github.com/bbatsov/rubocop/pull/572) ([nevir](https://github.com/nevir))

- Run RuboCop over its self for the default rake task [\#571](https://github.com/bbatsov/rubocop/pull/571) ([nevir](https://github.com/nevir))

- Fix for the style breakage on master [\#570](https://github.com/bbatsov/rubocop/pull/570) ([nevir](https://github.com/nevir))

- Fix autocorrect clobbering [\#569](https://github.com/bbatsov/rubocop/pull/569) ([jonas054](https://github.com/jonas054))

- Credited contributors and fixed lack of periods at the end of changelog lines. [\#568](https://github.com/bbatsov/rubocop/pull/568) ([dblock](https://github.com/dblock))

- Fix: register an offence when the last hash parameter has braces. [\#567](https://github.com/bbatsov/rubocop/pull/567) ([dblock](https://github.com/dblock))

- Don't treat splats as trivial writers [\#566](https://github.com/bbatsov/rubocop/pull/566) ([nevir](https://github.com/nevir))

- Fix autocorrect for SpecialGlobalVars [\#565](https://github.com/bbatsov/rubocop/pull/565) ([nevir](https://github.com/nevir))

- Add Code Climate badge to README.md [\#563](https://github.com/bbatsov/rubocop/pull/563) ([noahd1](https://github.com/noahd1))

- \[Fix \#557\] Don't load configuration files for excluded files. [\#559](https://github.com/bbatsov/rubocop/pull/559) ([jonas054](https://github.com/jonas054))

- Created Output cop to check for output in Rails [\#539](https://github.com/bbatsov/rubocop/pull/539) ([daviddavis](https://github.com/daviddavis))

- Expand ~ in inherit\_from paths to home directory [\#583](https://github.com/bbatsov/rubocop/pull/583) ([sds](https://github.com/sds))

- Fix autocorrect for SpecialGlobalVars [\#564](https://github.com/bbatsov/rubocop/pull/564) ([nevir](https://github.com/nevir))

## [v0.14.1](https://github.com/bbatsov/rubocop/tree/v0.14.1) (2013-10-10)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.14.0...v0.14.1)

**Closed issues:**

- Cop for raise/fail arguments is too restrictive. [\#552](https://github.com/bbatsov/rubocop/issues/552)

- Parameter aligning with normal indent [\#548](https://github.com/bbatsov/rubocop/issues/548)

**Merged pull requests:**

- Highlight only first line if source spans multiple lines in clang formatter  [\#556](https://github.com/bbatsov/rubocop/pull/556) ([yujinakayama](https://github.com/yujinakayama))

- New cop  checks for braces in function calls with hash arguments. [\#551](https://github.com/bbatsov/rubocop/pull/551) ([dblock](https://github.com/dblock))

- Handle namespace classes in ClassLength and Documentation [\#550](https://github.com/bbatsov/rubocop/pull/550) ([yujinakayama](https://github.com/yujinakayama))

- avoid range error in clang formatter when source spans multiple lines [\#549](https://github.com/bbatsov/rubocop/pull/549) ([seanwalbran](https://github.com/seanwalbran))

- Extract ConfigLoader class [\#547](https://github.com/bbatsov/rubocop/pull/547) ([jonas054](https://github.com/jonas054))

- Fix typo in readme [\#546](https://github.com/bbatsov/rubocop/pull/546) ([promisedlandt](https://github.com/promisedlandt))

- Align hash special case [\#545](https://github.com/bbatsov/rubocop/pull/545) ([jonas054](https://github.com/jonas054))

## [v0.14.0](https://github.com/bbatsov/rubocop/tree/v0.14.0) (2013-10-07)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.13.1...v0.14.0)

**Implemented enhancements:**

- No spaces after block's left curly or before block's right curly  [\#529](https://github.com/bbatsov/rubocop/issues/529)

- Allow return with multiple return values [\#528](https://github.com/bbatsov/rubocop/issues/528)

- EvenOdd cop misses != expressions [\#527](https://github.com/bbatsov/rubocop/issues/527)

- raise shorthand [\#526](https://github.com/bbatsov/rubocop/issues/526)

- SignalException forces fail [\#525](https://github.com/bbatsov/rubocop/issues/525)

- Allow semicolon as a statement separator [\#524](https://github.com/bbatsov/rubocop/issues/524)

- Forbid method calls on multi-line blocks [\#491](https://github.com/bbatsov/rubocop/issues/491)

- Allow parsing files between line numbers [\#473](https://github.com/bbatsov/rubocop/issues/473)

- Allow enabling of Rails Cops in config file [\#456](https://github.com/bbatsov/rubocop/issues/456)

**Fixed bugs:**

- nil-reference exception in AlignHash [\#496](https://github.com/bbatsov/rubocop/issues/496)

- --auto-gen-config doesn't disable Syntax related offences [\#493](https://github.com/bbatsov/rubocop/issues/493)

- Auto-correction of argument indentation bug [\#448](https://github.com/bbatsov/rubocop/issues/448)

**Closed issues:**

- Autocorrect issue with do..end blocks [\#538](https://github.com/bbatsov/rubocop/issues/538)

- Cop to check for debugger calls [\#534](https://github.com/bbatsov/rubocop/issues/534)

- Clicking on link in repository descripting gives me a 404 [\#533](https://github.com/bbatsov/rubocop/issues/533)

- Incorrect useless assignment offense [\#531](https://github.com/bbatsov/rubocop/issues/531)

- Show the name of the cop so it can be easily disabled [\#523](https://github.com/bbatsov/rubocop/issues/523)

- Make StringLiterals cop configurable [\#520](https://github.com/bbatsov/rubocop/issues/520)

- Make HashSyntax cop configurable [\#519](https://github.com/bbatsov/rubocop/issues/519)

- Autocorrect Failure: Redundant `return` detected [\#516](https://github.com/bbatsov/rubocop/issues/516)

- Autocorrect Mangling Function Args, Produces Invalid Ruby [\#515](https://github.com/bbatsov/rubocop/issues/515)

- Error occurred with autocorrect [\#512](https://github.com/bbatsov/rubocop/issues/512)

- NumericLiterals shouldn't consider hex numbers [\#502](https://github.com/bbatsov/rubocop/issues/502)

- Indicate what was autocorrected [\#501](https://github.com/bbatsov/rubocop/issues/501)

- Rspec syntax [\#430](https://github.com/bbatsov/rubocop/issues/430)

**Merged pull requests:**

- Support Parser 2.0 \(non-beta\) [\#544](https://github.com/bbatsov/rubocop/pull/544) ([yujinakayama](https://github.com/yujinakayama))

- Move option parsing from CLI to a new class Options. [\#543](https://github.com/bbatsov/rubocop/pull/543) ([jonas054](https://github.com/jonas054))

- \[Fix \#538\] Fix bug in `Blocks` auto-correction. [\#541](https://github.com/bbatsov/rubocop/pull/541) ([jonas054](https://github.com/jonas054))

- Improve description of configuration in README.md. [\#540](https://github.com/bbatsov/rubocop/pull/540) ([jonas054](https://github.com/jonas054))

- Debugger Cop: Added cop to check for debug calls [\#537](https://github.com/bbatsov/rubocop/pull/537) ([daviddavis](https://github.com/daviddavis))

- \[Fix \#529\] Add EnforcedStyle config param to SpaceAroundBlockBraces. [\#535](https://github.com/bbatsov/rubocop/pull/535) ([jonas054](https://github.com/jonas054))

- Make SignalException find raise not only in begin sections. [\#530](https://github.com/bbatsov/rubocop/pull/530) ([jonas054](https://github.com/jonas054))

- Refactor specs [\#522](https://github.com/bbatsov/rubocop/pull/522) ([bquorning](https://github.com/bquorning))

- \[Fix \#520\] Make StringLiterals cop configurable. [\#521](https://github.com/bbatsov/rubocop/pull/521) ([jonas054](https://github.com/jonas054))

- \[Fix \#516\] Fix RedundantReturn auto-correction bug. [\#518](https://github.com/bbatsov/rubocop/pull/518) ([jonas054](https://github.com/jonas054))

- Fix alignment auto-correction bug [\#517](https://github.com/bbatsov/rubocop/pull/517) ([jonas054](https://github.com/jonas054))

- Fix alignment of the hash in one line [\#514](https://github.com/bbatsov/rubocop/pull/514) ([saks](https://github.com/saks))

- \[Fix \#512\] Fix bug causing crash in AndOr auto-correction. [\#513](https://github.com/bbatsov/rubocop/pull/513) ([jonas054](https://github.com/jonas054))

- Fix bug concerning different RunRailsCops in different directories. [\#511](https://github.com/bbatsov/rubocop/pull/511) ([jonas054](https://github.com/jonas054))

- Support disabling Syntax offences with warning severity [\#510](https://github.com/bbatsov/rubocop/pull/510) ([yujinakayama](https://github.com/yujinakayama))

- Indicate corrected offences in formatters [\#509](https://github.com/bbatsov/rubocop/pull/509) ([yujinakayama](https://github.com/yujinakayama))

- Fix a copy-paste error that put a comment in the wrong place. [\#508](https://github.com/bbatsov/rubocop/pull/508) ([jonas054](https://github.com/jonas054))

- Replace MethodAndVariableSnakeCase with MethodAndVariableNaming. [\#507](https://github.com/bbatsov/rubocop/pull/507) ([jonas054](https://github.com/jonas054))

- \[Fix \#448\] Auto-correct multi-line parameters in AlignParameters. [\#506](https://github.com/bbatsov/rubocop/pull/506) ([jonas054](https://github.com/jonas054))

- \[Fix \#456\] New configuration parameter AllCops/RunExtraRailsCops. [\#505](https://github.com/bbatsov/rubocop/pull/505) ([jonas054](https://github.com/jonas054))

- \[Fix \#491\] New cop MethodCalledOnDoEndBlock. [\#504](https://github.com/bbatsov/rubocop/pull/504) ([jonas054](https://github.com/jonas054))

- Fix crash in AlignHash cop. [\#499](https://github.com/bbatsov/rubocop/pull/499) ([jonas054](https://github.com/jonas054))

- Created new cop MethodCalledOnDoEndBlock [\#503](https://github.com/bbatsov/rubocop/pull/503) ([daviddavis](https://github.com/daviddavis))

- Add config option AllowMethodCalledOnBlock for MultilineBlockChain. [\#500](https://github.com/bbatsov/rubocop/pull/500) ([jonas054](https://github.com/jonas054))

## [v0.13.1](https://github.com/bbatsov/rubocop/tree/v0.13.1) (2013-09-19)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.13.0...v0.13.1)

**Closed issues:**

- Rubocop explodes :\ [\#497](https://github.com/bbatsov/rubocop/issues/497)

- Drop 1.8 support? [\#492](https://github.com/bbatsov/rubocop/issues/492)

- Crash in UselessSetterCall [\#485](https://github.com/bbatsov/rubocop/issues/485)

**Merged pull requests:**

- Handle multiple-assignment and op-assignment in UselessSetterCall [\#495](https://github.com/bbatsov/rubocop/pull/495) ([yujinakayama](https://github.com/yujinakayama))

- Update enabled.yml [\#489](https://github.com/bbatsov/rubocop/pull/489) ([guilhermesimoes](https://github.com/guilhermesimoes))

- Fix duplication in align\_ array/parameters and string/character \_literal [\#488](https://github.com/bbatsov/rubocop/pull/488) ([jonas054](https://github.com/jonas054))

- Refactor cli\_spec with more structure. [\#487](https://github.com/bbatsov/rubocop/pull/487) ([jonas054](https://github.com/jonas054))

- Fix crash on empty input file in FinalNewline. [\#486](https://github.com/bbatsov/rubocop/pull/486) ([jonas054](https://github.com/jonas054))

- Fix redundant self cop for arguments [\#484](https://github.com/bbatsov/rubocop/pull/484) ([mbj](https://github.com/mbj))

## [v0.13.0](https://github.com/bbatsov/rubocop/tree/v0.13.0) (2013-09-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.12.0...v0.13.0)

**Implemented enhancements:**

- Warn against statements like \(a = 3\)if a == 2 [\#467](https://github.com/bbatsov/rubocop/issues/467)

- rubocop doesn't warn if there are multiple blank lines at the end of the file [\#462](https://github.com/bbatsov/rubocop/issues/462)

- Warn about re-assigned but not re-used variables [\#458](https://github.com/bbatsov/rubocop/issues/458)

**Closed issues:**

- VariableInspector raises error on valid Ruby program [\#483](https://github.com/bbatsov/rubocop/issues/483)

- Trivial Accessor [\#482](https://github.com/bbatsov/rubocop/issues/482)

- Useless assignment doesn't handle re-assignment in conditionals [\#475](https://github.com/bbatsov/rubocop/issues/475)

- Support Jruby built-in global variables  [\#466](https://github.com/bbatsov/rubocop/issues/466)

- do not warn if using pattern matching in |a, e|, e.g |a, \(digest, ids\)| [\#463](https://github.com/bbatsov/rubocop/issues/463)

- Don't recommend attr\_\* for private methods [\#461](https://github.com/bbatsov/rubocop/issues/461)

- Unsure about correct alignment of block ends [\#447](https://github.com/bbatsov/rubocop/issues/447)

**Merged pull requests:**

- New cop: AlignArray [\#481](https://github.com/bbatsov/rubocop/pull/481) ([jonas054](https://github.com/jonas054))

- Fix highlighting in SpaceInsideHashLiteralBraces and SpaceAroundBraces. [\#480](https://github.com/bbatsov/rubocop/pull/480) ([jonas054](https://github.com/jonas054))

- New cop SpaceBeforeModifierKeyword. [\#479](https://github.com/bbatsov/rubocop/pull/479) ([jonas054](https://github.com/jonas054))

- Fix a false negative with reference in conditional in UselessAssignment [\#478](https://github.com/bbatsov/rubocop/pull/478) ([yujinakayama](https://github.com/yujinakayama))

- Align hash updates [\#477](https://github.com/bbatsov/rubocop/pull/477) ([jonas054](https://github.com/jonas054))

- Fix bug concerning table alignment of colon separated hash entries. [\#476](https://github.com/bbatsov/rubocop/pull/476) ([jonas054](https://github.com/jonas054))

- Add AlignHash cop. [\#471](https://github.com/bbatsov/rubocop/pull/471) ([jonas054](https://github.com/jonas054))

- Improve offence report of UselessAssignment [\#470](https://github.com/bbatsov/rubocop/pull/470) ([yujinakayama](https://github.com/yujinakayama))

- Track usage of every assignment in UnusedLocalVariable [\#469](https://github.com/bbatsov/rubocop/pull/469) ([yujinakayama](https://github.com/yujinakayama))

- Allow vim-style magic encoding comments [\#468](https://github.com/bbatsov/rubocop/pull/468) ([meatballhat](https://github.com/meatballhat))

- Refactor cop handling [\#464](https://github.com/bbatsov/rubocop/pull/464) ([yujinakayama](https://github.com/yujinakayama))

- Fix auto-correction in AlignParameters. [\#460](https://github.com/bbatsov/rubocop/pull/460) ([jonas054](https://github.com/jonas054))

- New cop: Multiline block chain [\#459](https://github.com/bbatsov/rubocop/pull/459) ([jonas054](https://github.com/jonas054))

- Don’t trigger HashSyntax on digit-starting keys [\#457](https://github.com/bbatsov/rubocop/pull/457) ([chastell](https://github.com/chastell))

- Allow dot-separated snake case symbols. [\#454](https://github.com/bbatsov/rubocop/pull/454) ([razielgn](https://github.com/razielgn))

- Add AllowAdjacentOneLineDefs config parameter for EmptyLineBetweenDefs. [\#453](https://github.com/bbatsov/rubocop/pull/453) ([jonas054](https://github.com/jonas054))

- Continue after parser warnings [\#452](https://github.com/bbatsov/rubocop/pull/452) ([jonas054](https://github.com/jonas054))

- Allow end to be aligned with the start of the line containing do. [\#451](https://github.com/bbatsov/rubocop/pull/451) ([jonas054](https://github.com/jonas054))

- failing spec for WhileUntilDo auto-correct [\#449](https://github.com/bbatsov/rubocop/pull/449) ([tamird](https://github.com/tamird))

- failing spec for AvoidPerlBackrefs, since no alternative exists for the case of String\#match [\#455](https://github.com/bbatsov/rubocop/pull/455) ([tamird](https://github.com/tamird))

- failing spec for EmptyLineBetweenDefs [\#450](https://github.com/bbatsov/rubocop/pull/450) ([tamird](https://github.com/tamird))

## [v0.12.0](https://github.com/bbatsov/rubocop/tree/v0.12.0) (2013-08-23)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.11.1...v0.12.0)

**Implemented enhancements:**

- Indentation cop [\#423](https://github.com/bbatsov/rubocop/issues/423)

**Fixed bugs:**

- File exclusion doesn't work properly w. version 0.10.0 [\#405](https://github.com/bbatsov/rubocop/issues/405)

**Closed issues:**

- Line continuation character \(/\) and block of text [\#445](https://github.com/bbatsov/rubocop/issues/445)

- 'Useless assignment' reported when setting atttribute on method parameter [\#438](https://github.com/bbatsov/rubocop/issues/438)

- False positive: Assigned but unused variable [\#437](https://github.com/bbatsov/rubocop/issues/437)

- Space between method name and parenthesis not detected [\#435](https://github.com/bbatsov/rubocop/issues/435)

- cop AccessControl does not check classes defined with Class.new [\#434](https://github.com/bbatsov/rubocop/issues/434)

- ConstantName and Structs [\#432](https://github.com/bbatsov/rubocop/issues/432)

**Merged pull requests:**

- Drop -s/--silent option [\#446](https://github.com/bbatsov/rubocop/pull/446) ([yujinakayama](https://github.com/yujinakayama))

- Fix MethodAndVariableSnakeCase concerning def and self assignments. [\#444](https://github.com/bbatsov/rubocop/pull/444) ([jonas054](https://github.com/jonas054))

- Accept setting attribute on method argument in UselessAssignment [\#443](https://github.com/bbatsov/rubocop/pull/443) ([yujinakayama](https://github.com/yujinakayama))

- Fix some ranges [\#442](https://github.com/bbatsov/rubocop/pull/442) ([jonas054](https://github.com/jonas054))

- Renamed CopCount formatter to OffenceCount formatter [\#441](https://github.com/bbatsov/rubocop/pull/441) ([petehamilton](https://github.com/petehamilton))

- Space after method name [\#440](https://github.com/bbatsov/rubocop/pull/440) ([jonas054](https://github.com/jonas054))

- Add a CopCount formatter [\#439](https://github.com/bbatsov/rubocop/pull/439) ([petehamilton](https://github.com/petehamilton))

- Support class/module defined with Class.new/Module.new in AccessControl [\#436](https://github.com/bbatsov/rubocop/pull/436) ([yujinakayama](https://github.com/yujinakayama))

- Suppress offences if rhs is block node in ConstantName cop [\#433](https://github.com/bbatsov/rubocop/pull/433) ([yujinakayama](https://github.com/yujinakayama))

- New cop IndentationWidth. [\#431](https://github.com/bbatsov/rubocop/pull/431) ([jonas054](https://github.com/jonas054))

- `--show-cops` CLI option [\#395](https://github.com/bbatsov/rubocop/pull/395) ([dirkbolte](https://github.com/dirkbolte))

## [v0.11.1](https://github.com/bbatsov/rubocop/tree/v0.11.1) (2013-08-12)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.11.0...v0.11.1)

**Closed issues:**

- undefined method source\_line for Parser::Source::Map [\#429](https://github.com/bbatsov/rubocop/issues/429)

- Rubocop should warn about wrong indenting [\#428](https://github.com/bbatsov/rubocop/issues/428)

- FavorUnlessOverNegatedIf triggered when using elsifs [\#427](https://github.com/bbatsov/rubocop/issues/427)

- cop ColonMethodCall shouldn't forbid constructor like calls [\#425](https://github.com/bbatsov/rubocop/issues/425)

- "Favor modifier if/unless usage" needs exceptions when checking for defined? [\#424](https://github.com/bbatsov/rubocop/issues/424)

**Merged pull requests:**

- Allow calling constructor methods with double colon. [\#426](https://github.com/bbatsov/rubocop/pull/426) ([markijbema](https://github.com/markijbema))

## [v0.11.0](https://github.com/bbatsov/rubocop/tree/v0.11.0) (2013-08-09)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.9.1...v0.11.0)

**Implemented enhancements:**

- Check for assignment to local variables on last line of method [\#383](https://github.com/bbatsov/rubocop/issues/383)

- Show proper location information [\#199](https://github.com/bbatsov/rubocop/issues/199)

- Add support for rewriting existing code [\#172](https://github.com/bbatsov/rubocop/issues/172)

- More cops\(rules\) [\#60](https://github.com/bbatsov/rubocop/issues/60)

**Fixed bugs:**

- EmptyLineBetweenDefs complaining when it shouldn't [\#400](https://github.com/bbatsov/rubocop/issues/400)

- False positive in AssignmentInCondition [\#399](https://github.com/bbatsov/rubocop/issues/399)

- DotPosition cop breaks on lambda call with '.\(\)' [\#394](https://github.com/bbatsov/rubocop/issues/394)

- BlockAlignment on chaining methods [\#393](https://github.com/bbatsov/rubocop/issues/393)

- weaken 'complex regex' cop [\#391](https://github.com/bbatsov/rubocop/issues/391)

- CommentAnnotation: an annotation keyword as a start of a sentence [\#390](https://github.com/bbatsov/rubocop/issues/390)

- Snake Case cop too strong : incompatible with private\_constant [\#389](https://github.com/bbatsov/rubocop/issues/389)

- 'encoding' comment should not count as top-level class/module documentation [\#388](https://github.com/bbatsov/rubocop/issues/388)

- autocorrect creates invalid code on 'or' replacement [\#387](https://github.com/bbatsov/rubocop/issues/387)

- Avoid using {...} for multi-line blocks in Rspec change block [\#376](https://github.com/bbatsov/rubocop/issues/376)

- RuntimeError for variable reference in begin-end-until [\#374](https://github.com/bbatsov/rubocop/issues/374)

- Cannot override preferred collection methods [\#340](https://github.com/bbatsov/rubocop/issues/340)

- Cannot exclude vendor/ folder [\#288](https://github.com/bbatsov/rubocop/issues/288)

- Overzealous autocorrect for single-quoted strings [\#283](https://github.com/bbatsov/rubocop/issues/283)

**Closed issues:**

- Whitelist for trivial accessors [\#421](https://github.com/bbatsov/rubocop/issues/421)

- Boolean method identified as trivial reader method [\#411](https://github.com/bbatsov/rubocop/issues/411)

- Do not hardcode specific parser dep as dependency [\#410](https://github.com/bbatsov/rubocop/issues/410)

- named capture group in statement modifier reports incorretly [\#409](https://github.com/bbatsov/rubocop/issues/409)

- Don't report trivial attr readers when method name doesn't match the variable's name [\#408](https://github.com/bbatsov/rubocop/issues/408)

- Check for useless comparisons [\#406](https://github.com/bbatsov/rubocop/issues/406)

- Just a joke with 'Extra blank line' [\#398](https://github.com/bbatsov/rubocop/issues/398)

- Upgrade parser to v2.0.0.pre3 [\#397](https://github.com/bbatsov/rubocop/issues/397)

- autocorrect creates invalid code on ' [\#385](https://github.com/bbatsov/rubocop/issues/385)

- Rails - rubocop doesn't like syntax for model scopes [\#373](https://github.com/bbatsov/rubocop/issues/373)

- Pending cops [\#369](https://github.com/bbatsov/rubocop/issues/369)

- Should parentheses be banned for conditions, even for ternaries? [\#364](https://github.com/bbatsov/rubocop/issues/364)

- Disabling cops does not work \(Windows problem ?\) [\#361](https://github.com/bbatsov/rubocop/issues/361)

- File list mode [\#357](https://github.com/bbatsov/rubocop/issues/357)

- ParenthesesAroundCondition doesn't allow safe assignment. [\#356](https://github.com/bbatsov/rubocop/issues/356)

- EndAlignment has problems with newline in LHS [\#350](https://github.com/bbatsov/rubocop/issues/350)

- False positive for character literal [\#349](https://github.com/bbatsov/rubocop/issues/349)

- Module\#const\_get always take a symbol but it can't be snake\_case [\#348](https://github.com/bbatsov/rubocop/issues/348)

- $SAFE not recognized as an environment global var [\#345](https://github.com/bbatsov/rubocop/issues/345)

- flycheck does not support rubocop 0.9.1 [\#339](https://github.com/bbatsov/rubocop/issues/339)

- End alignment with chained assignments [\#338](https://github.com/bbatsov/rubocop/issues/338)

- TrivialAccessors check problem [\#308](https://github.com/bbatsov/rubocop/issues/308)

- When file has Unicode BOM, AsciiIdentifiers reports warning on line 1 [\#256](https://github.com/bbatsov/rubocop/issues/256)

**Merged pull requests:**

- Trivial accessors whitelist [\#422](https://github.com/bbatsov/rubocop/pull/422) ([markijbema](https://github.com/markijbema))

- String literals cop should not complain for "\\\n" [\#420](https://github.com/bbatsov/rubocop/pull/420) ([vsakarov](https://github.com/vsakarov))

- Add autocorrect support in AlignParameters cop. [\#419](https://github.com/bbatsov/rubocop/pull/419) ([jonas054](https://github.com/jonas054))

- Print configuration file names with --debug option. [\#417](https://github.com/bbatsov/rubocop/pull/417) ([jonas054](https://github.com/jonas054))

- Ignore arguments to Module\#private\_constant in SymbolName cop. [\#416](https://github.com/bbatsov/rubocop/pull/416) ([jonas054](https://github.com/jonas054))

- Do autocorrect in AndOr only if it doesn't change meaning of code. [\#415](https://github.com/bbatsov/rubocop/pull/415) ([jonas054](https://github.com/jonas054))

- Update comments in config files. [\#414](https://github.com/bbatsov/rubocop/pull/414) ([jonas054](https://github.com/jonas054))

- Retract support for multiline chaining of blocks. [\#413](https://github.com/bbatsov/rubocop/pull/413) ([jonas054](https://github.com/jonas054))

- Upgrade parser gem dependency to 2.0.0.pre6 [\#412](https://github.com/bbatsov/rubocop/pull/412) ([dkubb](https://github.com/dkubb))

- Fix bug in favor\_modifier.rb regarding missed offences after else etc. [\#407](https://github.com/bbatsov/rubocop/pull/407) ([jonas054](https://github.com/jonas054))

- Fix bug concerning nested defs in `EmptyLineBetweenDefs` cop. [\#404](https://github.com/bbatsov/rubocop/pull/404) ([jonas054](https://github.com/jonas054))

- Allow assignment inside blocks in `AssignmentInCondition` cop. [\#403](https://github.com/bbatsov/rubocop/pull/403) ([jonas054](https://github.com/jonas054))

- Supplements to --auto-gen-config mode [\#402](https://github.com/bbatsov/rubocop/pull/402) ([yujinakayama](https://github.com/yujinakayama))

- Fix comment annotation [\#401](https://github.com/bbatsov/rubocop/pull/401) ([jonas054](https://github.com/jonas054))

- Fix bug in counting slashes in a regexp. [\#396](https://github.com/bbatsov/rubocop/pull/396) ([jonas054](https://github.com/jonas054))

- Update some outdated descriptions in the GitHub pages [\#392](https://github.com/bbatsov/rubocop/pull/392) ([yujinakayama](https://github.com/yujinakayama))

- Use send\_node.loc.begin to determine if called with parentheses. [\#386](https://github.com/bbatsov/rubocop/pull/386) ([jonas054](https://github.com/jonas054))

- Allow self. followed by any ruby keyword. [\#382](https://github.com/bbatsov/rubocop/pull/382) ([jonas054](https://github.com/jonas054))

- Add `and` and `or` to list of keywords for redundant\_self to skip [\#381](https://github.com/bbatsov/rubocop/pull/381) ([dkubb](https://github.com/dkubb))

- Add new formatter DisabledConfigFormatter. [\#380](https://github.com/bbatsov/rubocop/pull/380) ([jonas054](https://github.com/jonas054))

- Allow braces around multi-line blocks if do-end would change the meaning [\#378](https://github.com/bbatsov/rubocop/pull/378) ([jonas054](https://github.com/jonas054))

- Fix error at post condition loop [\#375](https://github.com/bbatsov/rubocop/pull/375) ([yujinakayama](https://github.com/yujinakayama))

- Also check for usage of 'validates\_uniqueness\_of' when using '--rails' [\#371](https://github.com/bbatsov/rubocop/pull/371) ([jawwad](https://github.com/jawwad))

- Remove self-check spec and add self-check command to .travis.yml [\#370](https://github.com/bbatsov/rubocop/pull/370) ([yujinakayama](https://github.com/yujinakayama))

- Restore autocorrect [\#368](https://github.com/bbatsov/rubocop/pull/368) ([edzhelyov](https://github.com/edzhelyov))

- Refactor token handling [\#367](https://github.com/bbatsov/rubocop/pull/367) ([yujinakayama](https://github.com/yujinakayama))

- Add comment explaining a Parser setting that is a workaround. [\#366](https://github.com/bbatsov/rubocop/pull/366) ([jonas054](https://github.com/jonas054))

- Additional parsing refactoring [\#365](https://github.com/bbatsov/rubocop/pull/365) ([yujinakayama](https://github.com/yujinakayama))

- Invoke cops' custom callback before processing the AST [\#363](https://github.com/bbatsov/rubocop/pull/363) ([edzhelyov](https://github.com/edzhelyov))

- End alignment [\#362](https://github.com/bbatsov/rubocop/pull/362) ([jonas054](https://github.com/jonas054))

- Extract source parsing logic to SourceParser [\#359](https://github.com/bbatsov/rubocop/pull/359) ([yujinakayama](https://github.com/yujinakayama))

- Custom rake task. [\#355](https://github.com/bbatsov/rubocop/pull/355) ([pmenglund](https://github.com/pmenglund))

- Get correct BOM handling by upgrading parser dependency to 2.0.0.pre2. [\#354](https://github.com/bbatsov/rubocop/pull/354) ([jonas054](https://github.com/jonas054))

- New cop: CommentAnnotation [\#353](https://github.com/bbatsov/rubocop/pull/353) ([jonas054](https://github.com/jonas054))

- Introduce commissioner [\#352](https://github.com/bbatsov/rubocop/pull/352) ([edzhelyov](https://github.com/edzhelyov))

- Extract target file finding logic to TargetFinder [\#351](https://github.com/bbatsov/rubocop/pull/351) ([yujinakayama](https://github.com/yujinakayama))

- Override config parameters rather than merging them. [\#347](https://github.com/bbatsov/rubocop/pull/347) ([jonas054](https://github.com/jonas054))

- Fix end alignment [\#344](https://github.com/bbatsov/rubocop/pull/344) ([jonas054](https://github.com/jonas054))

- Remove special handling of class\_eval in RedundantSelf [\#343](https://github.com/bbatsov/rubocop/pull/343) ([jonas054](https://github.com/jonas054))

- Change ConfigStore state handling from module to instance [\#342](https://github.com/bbatsov/rubocop/pull/342) ([yujinakayama](https://github.com/yujinakayama))

- New cop RedundantSelf. [\#341](https://github.com/bbatsov/rubocop/pull/341) ([jonas054](https://github.com/jonas054))

- Work with absolute Excludes paths internally. [\#337](https://github.com/bbatsov/rubocop/pull/337) ([jonas054](https://github.com/jonas054))

- Change encoding cop to accept utf comment by magic\_encoding gem [\#336](https://github.com/bbatsov/rubocop/pull/336) ([onemanstartup](https://github.com/onemanstartup))

- Add cop AvoidClassesWithoutInstances. [\#384](https://github.com/bbatsov/rubocop/pull/384) ([jonas054](https://github.com/jonas054))

- Allow braces around multi-line blocks if do-end would change the meaning. [\#377](https://github.com/bbatsov/rubocop/pull/377) ([jonas054](https://github.com/jonas054))

- Refactor autocorrect [\#372](https://github.com/bbatsov/rubocop/pull/372) ([edzhelyov](https://github.com/edzhelyov))

- Align block's end with the start of the line [\#358](https://github.com/bbatsov/rubocop/pull/358) ([edzhelyov](https://github.com/edzhelyov))

- exclude reader methods that ends with a question mark [\#326](https://github.com/bbatsov/rubocop/pull/326) ([pmenglund](https://github.com/pmenglund))

## [v0.9.1](https://github.com/bbatsov/rubocop/tree/v0.9.1) (2013-07-05)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.9.0...v0.9.1)

**Implemented enhancements:**

- Running cops in parallel [\#117](https://github.com/bbatsov/rubocop/issues/117)

**Closed issues:**

- ShadowingOuterLocalVariable and UnusedLocalVariable triggered by Regexp with named captures [\#332](https://github.com/bbatsov/rubocop/issues/332)

- Weaker form of AndOr [\#329](https://github.com/bbatsov/rubocop/issues/329)

- Different but consistent CollectionMethods [\#328](https://github.com/bbatsov/rubocop/issues/328)

- EndAlignment when assignment doesnt fit on line [\#327](https://github.com/bbatsov/rubocop/issues/327)

- What is the correct end alignment style in case of an affectation ? [\#325](https://github.com/bbatsov/rubocop/issues/325)

- "Missing top-level module documentation comment" should not be file-local  [\#323](https://github.com/bbatsov/rubocop/issues/323)

- \[Ruby 2.0\] \*\* operator causes errors in two cops [\#322](https://github.com/bbatsov/rubocop/issues/322)

- "Shadowing outer local variable" does not recognize \_ 'joker' variables [\#321](https://github.com/bbatsov/rubocop/issues/321)

- Commented line length  [\#319](https://github.com/bbatsov/rubocop/issues/319)

- EndAlignment valid? [\#318](https://github.com/bbatsov/rubocop/issues/318)

- LiteralInCondition valid? [\#317](https://github.com/bbatsov/rubocop/issues/317)

- MultilineIfThen raising NoMethodError `source\_buffer' for nil:NilClass [\#316](https://github.com/bbatsov/rubocop/issues/316)

- Changelog doesn't match rubygems dates [\#315](https://github.com/bbatsov/rubocop/issues/315)

**Merged pull requests:**

- Fix state leak in Cop.all [\#335](https://github.com/bbatsov/rubocop/pull/335) ([edzhelyov](https://github.com/edzhelyov))

- Support named captures in UnusedLocalVariables and ShadowingOuterLocalVariable [\#334](https://github.com/bbatsov/rubocop/pull/334) ([yujinakayama](https://github.com/yujinakayama))

- Skip ensure return check when ensure has no body [\#333](https://github.com/bbatsov/rubocop/pull/333) ([eitoball](https://github.com/eitoball))

- Fix end alignment of blocks that spawn on two lines [\#331](https://github.com/bbatsov/rubocop/pull/331) ([edzhelyov](https://github.com/edzhelyov))

- Handle block end alignments in method chains [\#330](https://github.com/bbatsov/rubocop/pull/330) ([edzhelyov](https://github.com/edzhelyov))

- Fix multiline if special case with postfix unless \#316 [\#324](https://github.com/bbatsov/rubocop/pull/324) ([edzhelyov](https://github.com/edzhelyov))

- Correct some special cases of block end alignment. [\#320](https://github.com/bbatsov/rubocop/pull/320) ([jonas054](https://github.com/jonas054))

## [v0.9.0](https://github.com/bbatsov/rubocop/tree/v0.9.0) (2013-07-01)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.8.3...v0.9.0)

**Implemented enhancements:**

- Feature request Line count exclude assert statements [\#286](https://github.com/bbatsov/rubocop/issues/286)

- Recognize the common idiom for safe assignment in conditional [\#284](https://github.com/bbatsov/rubocop/issues/284)

- Improve output of details formatter [\#274](https://github.com/bbatsov/rubocop/issues/274)

- 'Avoid parameter lists longer than 4 parameters.' with keyword arguments [\#260](https://github.com/bbatsov/rubocop/issues/260)

**Closed issues:**

- Inconsistent warnings on rspec "should" idiom [\#307](https://github.com/bbatsov/rubocop/issues/307)

- Documented flag does not appear to exist [\#306](https://github.com/bbatsov/rubocop/issues/306)

- Rubocop error with new hash syntax? [\#304](https://github.com/bbatsov/rubocop/issues/304)

- \# 229 not solved : still present on 0.8.3 [\#294](https://github.com/bbatsov/rubocop/issues/294)

- Integration with Spring [\#292](https://github.com/bbatsov/rubocop/issues/292)

- Inherit config from gems [\#290](https://github.com/bbatsov/rubocop/issues/290)

-  Do not use semicolons to terminate expressions wrongly triggered [\#287](https://github.com/bbatsov/rubocop/issues/287)

- SingleLineMethod bug appearing with Parser 2.0.0.beta6 [\#285](https://github.com/bbatsov/rubocop/issues/285)

- "Missing space after \#" warning is not compatible with RDoc markups \#++ and \#-- . [\#277](https://github.com/bbatsov/rubocop/issues/277)

- Column numbers for --format emacs should start at 1 [\#276](https://github.com/bbatsov/rubocop/issues/276)

- Two %r related cops [\#275](https://github.com/bbatsov/rubocop/issues/275)

- Block nesting [\#252](https://github.com/bbatsov/rubocop/issues/252)

- Document cop classes [\#208](https://github.com/bbatsov/rubocop/issues/208)

**Merged pull requests:**

- Extend details [\#314](https://github.com/bbatsov/rubocop/pull/314) ([jonas054](https://github.com/jonas054))

- Move the rails cops exclussion into the \#run method [\#313](https://github.com/bbatsov/rubocop/pull/313) ([edzhelyov](https://github.com/edzhelyov))

- Reorganize formatters [\#312](https://github.com/bbatsov/rubocop/pull/312) ([yujinakayama](https://github.com/yujinakayama))

- Fix exception at location.real\_column in the JSON formatter [\#311](https://github.com/bbatsov/rubocop/pull/311) ([yujinakayama](https://github.com/yujinakayama))

- Add checks for end alignment of blocks [\#310](https://github.com/bbatsov/rubocop/pull/310) ([edzhelyov](https://github.com/edzhelyov))

- Fix crash in Documentation on empty modules. [\#309](https://github.com/bbatsov/rubocop/pull/309) ([jonas054](https://github.com/jonas054))

- Refactor formatter handling [\#305](https://github.com/bbatsov/rubocop/pull/305) ([yujinakayama](https://github.com/yujinakayama))

- Remove 2 pending from specs and fix lib code to make specs pass. [\#303](https://github.com/bbatsov/rubocop/pull/303) ([jonas054](https://github.com/jonas054))

- Migrate to Parser 2.0.0.beta8 [\#302](https://github.com/bbatsov/rubocop/pull/302) ([yujinakayama](https://github.com/yujinakayama))

- Handle arrays with character literals in WordArray. [\#301](https://github.com/bbatsov/rubocop/pull/301) ([jonas054](https://github.com/jonas054))

- Set config in all cop classes before inspect is called. [\#300](https://github.com/bbatsov/rubocop/pull/300) ([jonas054](https://github.com/jonas054))

- Add new cop ShadowingOuterLocalVariable [\#299](https://github.com/bbatsov/rubocop/pull/299) ([yujinakayama](https://github.com/yujinakayama))

- Add class and module documentation where missing. [\#298](https://github.com/bbatsov/rubocop/pull/298) ([jonas054](https://github.com/jonas054))

- Fix Parser dependency to 2.0.0.beta6 [\#297](https://github.com/bbatsov/rubocop/pull/297) ([yujinakayama](https://github.com/yujinakayama))

- Let columns start at 1 instead of 0 in all output of column numbers. [\#296](https://github.com/bbatsov/rubocop/pull/296) ([jonas054](https://github.com/jonas054))

- Get config parameter AllCops/Excludes from highest config file in path. [\#295](https://github.com/bbatsov/rubocop/pull/295) ([jonas054](https://github.com/jonas054))

- Add UnusedLocalVariable cop [\#293](https://github.com/bbatsov/rubocop/pull/293) ([yujinakayama](https://github.com/yujinakayama))

- Fix broken specs with Parser 2.0.0.beta6 [\#291](https://github.com/bbatsov/rubocop/pull/291) ([yujinakayama](https://github.com/yujinakayama))

- Merge percent r cops [\#289](https://github.com/bbatsov/rubocop/pull/289) ([jonas054](https://github.com/jonas054))

## [v0.8.3](https://github.com/bbatsov/rubocop/tree/v0.8.3) (2013-06-18)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.8.2...v0.8.3)

**Implemented enhancements:**

- New feature : add versions to Rubocop report [\#236](https://github.com/bbatsov/rubocop/issues/236)

- Feature - Rails specific cops [\#224](https://github.com/bbatsov/rubocop/issues/224)

- Feature: JSON Output [\#186](https://github.com/bbatsov/rubocop/issues/186)

**Fixed bugs:**

- ignores \e as special character in quotes cop [\#239](https://github.com/bbatsov/rubocop/issues/239)

- ConstantName Cop error [\#235](https://github.com/bbatsov/rubocop/issues/235)

- Reopen \#225, not fixed, see comment there [\#234](https://github.com/bbatsov/rubocop/issues/234)

- Wrong on Windows : AccessControl: Keep a blank line before and after private/protected [\#229](https://github.com/bbatsov/rubocop/issues/229)

- Error parsing UTF-8 characters [\#219](https://github.com/bbatsov/rubocop/issues/219)

**Closed issues:**

- can't ignore \*.rb.swp files [\#272](https://github.com/bbatsov/rubocop/issues/272)

- False positive for SpaceInsideHashLiteralBraces [\#271](https://github.com/bbatsov/rubocop/issues/271)

- False positive for parentheses around condition of if [\#270](https://github.com/bbatsov/rubocop/issues/270)

- Exception in AssignmentInCondition [\#266](https://github.com/bbatsov/rubocop/issues/266)

- Edge case on if/unless modifier [\#264](https://github.com/bbatsov/rubocop/issues/264)

- Operator called with method syntax [\#263](https://github.com/bbatsov/rubocop/issues/263)

- \[Bug\]  Constant assignment with double pipe equals [\#259](https://github.com/bbatsov/rubocop/issues/259)

- Rubocop gives errors within heredocs [\#258](https://github.com/bbatsov/rubocop/issues/258)

- New Cop for BOM [\#254](https://github.com/bbatsov/rubocop/issues/254)

- attr Cop a bit toot restrictive [\#251](https://github.com/bbatsov/rubocop/issues/251)

- Coming again to the CRLF question [\#250](https://github.com/bbatsov/rubocop/issues/250)

- Ruby 1.9 Hash syntax [\#247](https://github.com/bbatsov/rubocop/issues/247)

- Double quotes are necessary for unicode escapes [\#246](https://github.com/bbatsov/rubocop/issues/246)

- Error while parsing money.rb [\#243](https://github.com/bbatsov/rubocop/issues/243)

**Merged pull requests:**

- Migrate all cops to new namespaces [\#282](https://github.com/bbatsov/rubocop/pull/282) ([lee-dohm](https://github.com/lee-dohm))

- Don't display "Offences:" if there's no offence with progress formatter [\#281](https://github.com/bbatsov/rubocop/pull/281) ([yujinakayama](https://github.com/yujinakayama))

- Update version number to match CHANGELOG and rubygems.org [\#280](https://github.com/bbatsov/rubocop/pull/280) ([lee-dohm](https://github.com/lee-dohm))

- Fix JRuby and Rubinius build [\#279](https://github.com/bbatsov/rubocop/pull/279) ([yujinakayama](https://github.com/yujinakayama))

- Always allow line breaks inside hash literal braces. [\#273](https://github.com/bbatsov/rubocop/pull/273) ([jonas054](https://github.com/jonas054))

- Do not check for space around operators called with method syntax. [\#269](https://github.com/bbatsov/rubocop/pull/269) ([jonas054](https://github.com/jonas054))

- Do not read excluded files for ruby shebang lines [\#268](https://github.com/bbatsov/rubocop/pull/268) ([chulkilee](https://github.com/chulkilee))

- Add a details formatter. [\#267](https://github.com/bbatsov/rubocop/pull/267) ([jonas054](https://github.com/jonas054))

- Fix code style and enable self-check [\#265](https://github.com/bbatsov/rubocop/pull/265) ([yujinakayama](https://github.com/yujinakayama))

- Print relative paths with the simple/progress formatter [\#262](https://github.com/bbatsov/rubocop/pull/262) ([yujinakayama](https://github.com/yujinakayama))

- Fix bugs in calls to add\_offence. [\#261](https://github.com/bbatsov/rubocop/pull/261) ([jonas054](https://github.com/jonas054))

- Additional API documentation [\#257](https://github.com/bbatsov/rubocop/pull/257) ([yujinakayama](https://github.com/yujinakayama))

- Fix README [\#255](https://github.com/bbatsov/rubocop/pull/255) ([yujinakayama](https://github.com/yujinakayama))

- JSON Formatter [\#253](https://github.com/bbatsov/rubocop/pull/253) ([yujinakayama](https://github.com/yujinakayama))

- Add progress formatter [\#249](https://github.com/bbatsov/rubocop/pull/249) ([yujinakayama](https://github.com/yujinakayama))

- Correct handling of unicode escapes within double quotes. [\#248](https://github.com/bbatsov/rubocop/pull/248) ([jonas054](https://github.com/jonas054))

- Handle multiple constant assignment in ConstantName cop. [\#245](https://github.com/bbatsov/rubocop/pull/245) ([jonas054](https://github.com/jonas054))

- Recognize a line with CR+LF as a blank line in AccessControl cop. [\#244](https://github.com/bbatsov/rubocop/pull/244) ([jonas054](https://github.com/jonas054))

- improved string quotes regex + fixed one pending test [\#242](https://github.com/bbatsov/rubocop/pull/242) ([ranmrdrakono](https://github.com/ranmrdrakono))

- Fix off-by-one error in favor\_modifier. [\#241](https://github.com/bbatsov/rubocop/pull/241) ([jonas054](https://github.com/jonas054))

- Fix random failure of interruption specs [\#238](https://github.com/bbatsov/rubocop/pull/238) ([yujinakayama](https://github.com/yujinakayama))

- Syntax check by parser [\#237](https://github.com/bbatsov/rubocop/pull/237) ([jonas054](https://github.com/jonas054))

- Move all the cops into namespaces based on type [\#278](https://github.com/bbatsov/rubocop/pull/278) ([lee-dohm](https://github.com/lee-dohm))

- string cop fixes  [\#240](https://github.com/bbatsov/rubocop/pull/240) ([ranmrdrakono](https://github.com/ranmrdrakono))

- Reintroduce old solution for invalid byte sequences. [\#223](https://github.com/bbatsov/rubocop/pull/223) ([jonas054](https://github.com/jonas054))

## [v0.8.2](https://github.com/bbatsov/rubocop/tree/v0.8.2) (2013-06-05)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.8.1...v0.8.2)

**Closed issues:**

- regexp detected as doublequoted string [\#232](https://github.com/bbatsov/rubocop/issues/232)

- modifier if/else cop false positive [\#231](https://github.com/bbatsov/rubocop/issues/231)

- Wrong diagnostic for ParenthesisAroudCondition [\#226](https://github.com/bbatsov/rubocop/issues/226)

- Trouble with Heredocs [\#225](https://github.com/bbatsov/rubocop/issues/225)

- Feature: Formatter [\#222](https://github.com/bbatsov/rubocop/issues/222)

- Solutions [\#161](https://github.com/bbatsov/rubocop/issues/161)

**Merged pull requests:**

- Fix an error in MultilineIfThen cop that occurs in some special cases. [\#230](https://github.com/bbatsov/rubocop/pull/230) ([jonas054](https://github.com/jonas054))

- Add new cop BlockNesting [\#228](https://github.com/bbatsov/rubocop/pull/228) ([emou](https://github.com/emou))

- Introduce formatter feature  [\#227](https://github.com/bbatsov/rubocop/pull/227) ([yujinakayama](https://github.com/yujinakayama))

- Fix calculation of whether a modifier version will fit. [\#221](https://github.com/bbatsov/rubocop/pull/221) ([jonas054](https://github.com/jonas054))

- Remove the on\_comment method. [\#220](https://github.com/bbatsov/rubocop/pull/220) ([jonas054](https://github.com/jonas054))

- Fix missing syntax warnings. [\#233](https://github.com/bbatsov/rubocop/pull/233) ([mestachs](https://github.com/mestachs))

## [v0.8.1](https://github.com/bbatsov/rubocop/tree/v0.8.1) (2013-05-30)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.8.0...v0.8.1)

**Closed issues:**

- does not detect while/until modifier [\#215](https://github.com/bbatsov/rubocop/issues/215)

- Wrong offence detected? [\#214](https://github.com/bbatsov/rubocop/issues/214)

- An error occurred while IfUnlessModifier... [\#213](https://github.com/bbatsov/rubocop/issues/213)

- Releax the Rubocop::Cop::TrivialAccessors [\#211](https://github.com/bbatsov/rubocop/issues/211)

- Don't check for double quoted string in regexp. [\#210](https://github.com/bbatsov/rubocop/issues/210)

- rubucop 0.8 : carriage return [\#206](https://github.com/bbatsov/rubocop/issues/206)

- rubocop 0.8 : wrong "spaces around operators" cop [\#205](https://github.com/bbatsov/rubocop/issues/205)

- rubucop 0.8 : wrong line numbers [\#204](https://github.com/bbatsov/rubocop/issues/204)

**Merged pull requests:**

- Fix SpaceInsideHashLiteralBraces to handle string interpolation right. [\#218](https://github.com/bbatsov/rubocop/pull/218) ([jonas054](https://github.com/jonas054))

- Make sure even disabled cops get their configuration set. [\#217](https://github.com/bbatsov/rubocop/pull/217) ([jonas054](https://github.com/jonas054))

- Fix errors [\#216](https://github.com/bbatsov/rubocop/pull/216) ([jonas054](https://github.com/jonas054))

- Specify dependency to parser in a better way. [\#212](https://github.com/bbatsov/rubocop/pull/212) ([jonas054](https://github.com/jonas054))

- Changed "See on GitHub" to "View on GitHub" [\#209](https://github.com/bbatsov/rubocop/pull/209) ([AlexanderEkdahl](https://github.com/AlexanderEkdahl))

## [v0.8.0](https://github.com/bbatsov/rubocop/tree/v0.8.0) (2013-05-28)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.7.2...v0.8.0)

**Fixed bugs:**

- ParenthesesAroundCondition bug [\#127](https://github.com/bbatsov/rubocop/issues/127)

**Closed issues:**

- Migrate to Parser 2.0 [\#195](https://github.com/bbatsov/rubocop/issues/195)

- Two cops still need to be ported to Parser [\#193](https://github.com/bbatsov/rubocop/issues/193)

- support jruby [\#191](https://github.com/bbatsov/rubocop/issues/191)

- Issue with AmpersandsPipesVsAndOr? [\#185](https://github.com/bbatsov/rubocop/issues/185)

- Rubocop shouldn't complain about Hash.new when followed by a block. [\#181](https://github.com/bbatsov/rubocop/issues/181)

- Always show syntax cop warnings [\#174](https://github.com/bbatsov/rubocop/issues/174)

- An error occurred while TrivialAccessors cop was inspecting... [\#169](https://github.com/bbatsov/rubocop/issues/169)

- Migrate cops to Parser [\#165](https://github.com/bbatsov/rubocop/issues/165)

- Evaluate a migration from Ripper to Parser [\#150](https://github.com/bbatsov/rubocop/issues/150)

- Release planning [\#148](https://github.com/bbatsov/rubocop/issues/148)

**Merged pull requests:**

- Change name of Rubocop::Config.validate! to validate. [\#203](https://github.com/bbatsov/rubocop/pull/203) ([jonas054](https://github.com/jonas054))

- Fixes based on review comments [\#202](https://github.com/bbatsov/rubocop/pull/202) ([jonas054](https://github.com/jonas054))

- fix typos in README [\#201](https://github.com/bbatsov/rubocop/pull/201) ([nikai3d](https://github.com/nikai3d))

- Update control flow recommendation message [\#200](https://github.com/bbatsov/rubocop/pull/200) ([lee-dohm](https://github.com/lee-dohm))

- Solve problem with too many parameters in inspect. [\#198](https://github.com/bbatsov/rubocop/pull/198) ([jonas054](https://github.com/jonas054))

- Port more cops to AST::Processor. [\#197](https://github.com/bbatsov/rubocop/pull/197) ([jonas054](https://github.com/jonas054))

- Port ascii comments and leading\_comment\_space [\#196](https://github.com/bbatsov/rubocop/pull/196) ([jonas054](https://github.com/jonas054))

- Fix --only option. [\#194](https://github.com/bbatsov/rubocop/pull/194) ([jonas054](https://github.com/jonas054))

- Port SpaceAfterControlKeyword to Parser. [\#192](https://github.com/bbatsov/rubocop/pull/192) ([jonas054](https://github.com/jonas054))

- Port favor unless over negated if [\#190](https://github.com/bbatsov/rubocop/pull/190) ([jonas054](https://github.com/jonas054))

- Port if\_then\_else to Parser. [\#189](https://github.com/bbatsov/rubocop/pull/189) ([jonas054](https://github.com/jonas054))

- Port FavorUnlessOverNegatedIf and FavorUntilOverNegatedWhile to Parser. [\#188](https://github.com/bbatsov/rubocop/pull/188) ([jonas054](https://github.com/jonas054))

- Port surrounding\_space cops to Parser. [\#187](https://github.com/bbatsov/rubocop/pull/187) ([jonas054](https://github.com/jonas054))

- Port space after comma etc [\#184](https://github.com/bbatsov/rubocop/pull/184) ([jonas054](https://github.com/jonas054))

- Port FavorSprintf cop to Parser. [\#183](https://github.com/bbatsov/rubocop/pull/183) ([jonas054](https://github.com/jonas054))

- Make rubocop survive exceptions from Parser. [\#182](https://github.com/bbatsov/rubocop/pull/182) ([jonas054](https://github.com/jonas054))

- Port FavorJoin cop to Parser. [\#180](https://github.com/bbatsov/rubocop/pull/180) ([jonas054](https://github.com/jonas054))

- Change file name of spec/.../avoid\_global\_vars.rb. [\#179](https://github.com/bbatsov/rubocop/pull/179) ([jonas054](https://github.com/jonas054))

- Refactor a bit [\#178](https://github.com/bbatsov/rubocop/pull/178) ([yujinakayama](https://github.com/yujinakayama))

- Rework SymbolSnakeCase cop into SymbolName [\#177](https://github.com/bbatsov/rubocop/pull/177) ([yujinakayama](https://github.com/yujinakayama))

- Improve performance in StringLiterals. [\#176](https://github.com/bbatsov/rubocop/pull/176) ([jonas054](https://github.com/jonas054))

- Port CaseIndentation to Parser. [\#171](https://github.com/bbatsov/rubocop/pull/171) ([jonas054](https://github.com/jonas054))

- Port MethodAndVariableSnakeCase to Parser [\#170](https://github.com/bbatsov/rubocop/pull/170) ([yujinakayama](https://github.com/yujinakayama))

- Fix crash of RescueException on rescue with no class specification [\#168](https://github.com/bbatsov/rubocop/pull/168) ([yujinakayama](https://github.com/yujinakayama))

- Fix broken spec [\#167](https://github.com/bbatsov/rubocop/pull/167) ([yujinakayama](https://github.com/yujinakayama))

- Port RescueException to Parser [\#166](https://github.com/bbatsov/rubocop/pull/166) ([yujinakayama](https://github.com/yujinakayama))

- Start porting RuboCop to Parser [\#164](https://github.com/bbatsov/rubocop/pull/164) ([bbatsov](https://github.com/bbatsov))

## [v0.7.2](https://github.com/bbatsov/rubocop/tree/v0.7.2) (2013-05-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.7.1...v0.7.2)

**Closed issues:**

- AvoidFor cop misses many violations [\#159](https://github.com/bbatsov/rubocop/issues/159)

- 'Do not use semicolons to terminate expressions.' is not implemented correctly [\#155](https://github.com/bbatsov/rubocop/issues/155)

- Ripper improvements [\#149](https://github.com/bbatsov/rubocop/issues/149)

**Merged pull requests:**

- Fix a crash in RescueException on rescue clauses like rescue \*ERRORS. [\#163](https://github.com/bbatsov/rubocop/pull/163) ([jonas054](https://github.com/jonas054))

- Fix bug in SymbolSnakeCase causing an exception for aliasing operators. [\#162](https://github.com/bbatsov/rubocop/pull/162) ([jonas054](https://github.com/jonas054))

- Correct a bug in Cop\#keywords. [\#160](https://github.com/bbatsov/rubocop/pull/160) ([jonas054](https://github.com/jonas054))

- OpMethod now handles definition of unary operators without crashing. [\#157](https://github.com/bbatsov/rubocop/pull/157) ([jonas054](https://github.com/jonas054))

- Fix for \#155. A bug in Semicolon\#index\_of\_first\_token\_on\_line. [\#156](https://github.com/bbatsov/rubocop/pull/156) ([jonas054](https://github.com/jonas054))

## [v0.7.1](https://github.com/bbatsov/rubocop/tree/v0.7.1) (2013-05-11)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.7.0...v0.7.1)

**Closed issues:**

- config directory missing in gemspec [\#154](https://github.com/bbatsov/rubocop/issues/154)

## [v0.7.0](https://github.com/bbatsov/rubocop/tree/v0.7.0) (2013-05-11)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.6.1...v0.7.0)

**Implemented enhancements:**

- Update tests to create directories in temporary directory [\#119](https://github.com/bbatsov/rubocop/issues/119)

- Configuration file problems [\#116](https://github.com/bbatsov/rubocop/issues/116)

**Fixed bugs:**

- SymbolArray is not disabled by default [\#126](https://github.com/bbatsov/rubocop/issues/126)

- TrivialAccessors Cop Error [\#125](https://github.com/bbatsov/rubocop/issues/125)

**Closed issues:**

- Don't print the unrecognized cop warning several times for the same .rubocop.yml [\#151](https://github.com/bbatsov/rubocop/issues/151)

- SingleLineMethods bug [\#144](https://github.com/bbatsov/rubocop/issues/144)

- SymbolArray is still not disabled by default in another case [\#137](https://github.com/bbatsov/rubocop/issues/137)

- TrivialAccessors incorrectly detects offence [\#136](https://github.com/bbatsov/rubocop/issues/136)

- Error in TrivialAccessors [\#133](https://github.com/bbatsov/rubocop/issues/133)

- Crash when no .rubocop.yml is found [\#132](https://github.com/bbatsov/rubocop/issues/132)

- ripper lib not supported on jruby [\#113](https://github.com/bbatsov/rubocop/issues/113)

- Hash literal braces check [\#108](https://github.com/bbatsov/rubocop/issues/108)

- SpaceAroundEqualsInParameterDefault doesn't work properly with empty string [\#101](https://github.com/bbatsov/rubocop/issues/101)

- Semicolon rule should be mitigated [\#96](https://github.com/bbatsov/rubocop/issues/96)

- Pass directories to excluded [\#94](https://github.com/bbatsov/rubocop/issues/94)

- One line methods [\#77](https://github.com/bbatsov/rubocop/issues/77)

**Merged pull requests:**

- Do more caching to avoid printing same warning many times. [\#153](https://github.com/bbatsov/rubocop/pull/153) ([jonas054](https://github.com/jonas054))

- Handle regexp back references in VariableInterpolation. [\#152](https://github.com/bbatsov/rubocop/pull/152) ([jonas054](https://github.com/jonas054))

- Display a list of errors in the summary. [\#147](https://github.com/bbatsov/rubocop/pull/147) ([jonas054](https://github.com/jonas054))

- Handle method names with a capital initial. [\#146](https://github.com/bbatsov/rubocop/pull/146) ([jonas054](https://github.com/jonas054))

- Fix \#136 [\#145](https://github.com/bbatsov/rubocop/pull/145) ([zeroed](https://github.com/zeroed))

- Add possibility to use inherit\_from in .rubocop.yml. [\#143](https://github.com/bbatsov/rubocop/pull/143) ([jonas054](https://github.com/jonas054))

- replaced if array.find {} with if array.any? {} [\#142](https://github.com/bbatsov/rubocop/pull/142) ([jurriaan](https://github.com/jurriaan))

- Fix SymbolArray cop is not disabled by default [\#141](https://github.com/bbatsov/rubocop/pull/141) ([yujinakayama](https://github.com/yujinakayama))

- Add --only option for running a single cop. [\#140](https://github.com/bbatsov/rubocop/pull/140) ([jonas054](https://github.com/jonas054))

- move cache responsibilities to config\_store.rb [\#139](https://github.com/bbatsov/rubocop/pull/139) ([bolandrm](https://github.com/bolandrm))

- fix \#133 [\#138](https://github.com/bbatsov/rubocop/pull/138) ([zeroed](https://github.com/zeroed))

- Refactor CLI spec [\#135](https://github.com/bbatsov/rubocop/pull/135) ([yujinakayama](https://github.com/yujinakayama))

- read\_source cleanup [\#134](https://github.com/bbatsov/rubocop/pull/134) ([jurriaan](https://github.com/jurriaan))

- isolating configuration [\#131](https://github.com/bbatsov/rubocop/pull/131) ([bolandrm](https://github.com/bolandrm))

- more fixing for \#125 [\#130](https://github.com/bbatsov/rubocop/pull/130) ([zeroed](https://github.com/zeroed))

- fixing \#125 [\#129](https://github.com/bbatsov/rubocop/pull/129) ([zeroed](https://github.com/zeroed))

- Refactor CLI [\#128](https://github.com/bbatsov/rubocop/pull/128) ([yujinakayama](https://github.com/yujinakayama))

- update include/exclude docs [\#124](https://github.com/bbatsov/rubocop/pull/124) ([bolandrm](https://github.com/bolandrm))

- Remove unneeded Report module wrap in CLI spec [\#123](https://github.com/bbatsov/rubocop/pull/123) ([yujinakayama](https://github.com/yujinakayama))

- Fixing Nil bug in the TrivialAccessors cop [\#122](https://github.com/bbatsov/rubocop/pull/122) ([zeroed](https://github.com/zeroed))

- Fix random failure spec [\#121](https://github.com/bbatsov/rubocop/pull/121) ([yujinakayama](https://github.com/yujinakayama))

- Issue warning when configuration contains an unrecognized name. [\#120](https://github.com/bbatsov/rubocop/pull/120) ([jonas054](https://github.com/jonas054))

- \[WiP\] Include/Exclude files and directories [\#118](https://github.com/bbatsov/rubocop/pull/118) ([jurriaan](https://github.com/jurriaan))

- \#60 : Use the attr family of functions to define trivial accessors or mutators. [\#115](https://github.com/bbatsov/rubocop/pull/115) ([zeroed](https://github.com/zeroed))

- New rule: use spaces inside hash literal braces, or don't. [\#114](https://github.com/bbatsov/rubocop/pull/114) ([jonas054](https://github.com/jonas054))

- Fixed BraceAfterPercent [\#112](https://github.com/bbatsov/rubocop/pull/112) ([jurriaan](https://github.com/jurriaan))

- Added ability to ignore directories [\#110](https://github.com/bbatsov/rubocop/pull/110) ([bolandrm](https://github.com/bolandrm))

- New rule: Avoid single-line methods. [\#109](https://github.com/bbatsov/rubocop/pull/109) ([jonas054](https://github.com/jonas054))

- Fix undefined method `\[\]' for nil:NilClass from rspec -e. [\#107](https://github.com/bbatsov/rubocop/pull/107) ([jonas054](https://github.com/jonas054))

- Fix coverage [\#106](https://github.com/bbatsov/rubocop/pull/106) ([yujinakayama](https://github.com/yujinakayama))

- Update changelog with relaxed semicolon rule. [\#104](https://github.com/bbatsov/rubocop/pull/104) ([jonas054](https://github.com/jonas054))

- Allow some semicolons for one line definitions. [\#103](https://github.com/bbatsov/rubocop/pull/103) ([jonas054](https://github.com/jonas054))

- Fix issue 101 [\#105](https://github.com/bbatsov/rubocop/pull/105) ([jonas054](https://github.com/jonas054))

## [v0.6.1](https://github.com/bbatsov/rubocop/tree/v0.6.1) (2013-04-28)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.6.0...v0.6.1)

**Closed issues:**

- Add cop name to offence output [\#102](https://github.com/bbatsov/rubocop/issues/102)

- barfs on `def <=\>` [\#100](https://github.com/bbatsov/rubocop/issues/100)

- Build fails [\#97](https://github.com/bbatsov/rubocop/issues/97)

- AsciiIdentifiersAndComments cop should be configurable [\#95](https://github.com/bbatsov/rubocop/issues/95)

- Issue with whitespace?': undefined method [\#93](https://github.com/bbatsov/rubocop/issues/93)

- Hash Literal breaks [\#92](https://github.com/bbatsov/rubocop/issues/92)

- Two cops crash when scanning code using super [\#90](https://github.com/bbatsov/rubocop/issues/90)

- Show code coverage results [\#89](https://github.com/bbatsov/rubocop/issues/89)

**Merged pull requests:**

- Don't look at tokens past EOF in SpaceAfterCommaEtc. [\#99](https://github.com/bbatsov/rubocop/pull/99) ([jonas054](https://github.com/jonas054))

- Remove Term::ANSIColor mixin from String. [\#98](https://github.com/bbatsov/rubocop/pull/98) ([jonas054](https://github.com/jonas054))

- Fix for method calls involving super. [\#91](https://github.com/bbatsov/rubocop/pull/91) ([jonas054](https://github.com/jonas054))

- Abort gracefully when interrupted with Ctrl-C [\#88](https://github.com/bbatsov/rubocop/pull/88) ([yujinakayama](https://github.com/yujinakayama))

## [v0.6.0](https://github.com/bbatsov/rubocop/tree/v0.6.0) (2013-04-23)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.5.0...v0.6.0)

**Implemented enhancements:**

- Feature Request: exclude certain folders [\#34](https://github.com/bbatsov/rubocop/issues/34)

**Closed issues:**

- Error - RescueException Cop [\#87](https://github.com/bbatsov/rubocop/issues/87)

- invalid byte sequence in UTF-8 [\#84](https://github.com/bbatsov/rubocop/issues/84)

- Ternary operator missing whitespace detection [\#79](https://github.com/bbatsov/rubocop/issues/79)

- Global variable `$INPUT\_RECORD\_SEPARATOR' not initialized on ruby 2.0.0-p0 [\#75](https://github.com/bbatsov/rubocop/issues/75)

- double alias problem [\#70](https://github.com/bbatsov/rubocop/issues/70)

- Version 0.5.0 fails to run [\#66](https://github.com/bbatsov/rubocop/issues/66)

- Suggests to convert symbols :==, :<=\> and the like to snake\_case [\#65](https://github.com/bbatsov/rubocop/issues/65)

- Takes a very long time if run with bundle exec [\#64](https://github.com/bbatsov/rubocop/issues/64)

**Merged pull requests:**

- MethodLength Cop - ignore one line methods [\#85](https://github.com/bbatsov/rubocop/pull/85) ([bolandrm](https://github.com/bolandrm))

- Better dependency management [\#83](https://github.com/bbatsov/rubocop/pull/83) ([yujinakayama](https://github.com/yujinakayama))

- enhance debug mode \(-d\) [\#82](https://github.com/bbatsov/rubocop/pull/82) ([bolandrm](https://github.com/bolandrm))

- Method Length Cop - Added option to ingore full line comments [\#81](https://github.com/bbatsov/rubocop/pull/81) ([bolandrm](https://github.com/bolandrm))

- Fix \#79 - Ternary operator missing whitespace detection [\#80](https://github.com/bbatsov/rubocop/pull/80) ([emou](https://github.com/emou))

- New rule: Use %r only for regexpes matching more than one '/'. [\#78](https://github.com/bbatsov/rubocop/pull/78) ([jonas054](https://github.com/jonas054))

- New Cop: Ensure that reduce arguments are |a, e| [\#76](https://github.com/bbatsov/rubocop/pull/76) ([bolandrm](https://github.com/bolandrm))

- New Cop - Number of LOC \(lines of code\) in method [\#74](https://github.com/bbatsov/rubocop/pull/74) ([bolandrm](https://github.com/bolandrm))

- New rule: Use only ascii symbols in identifiers and comments. [\#72](https://github.com/bbatsov/rubocop/pull/72) ([jonas054](https://github.com/jonas054))

- Support rubocop:disable and rubocop:enable comments. [\#68](https://github.com/bbatsov/rubocop/pull/68) ([jonas054](https://github.com/jonas054))

- Don't fail when unable to parse a file [\#67](https://github.com/bbatsov/rubocop/pull/67) ([bf4](https://github.com/bf4))

- Fix config files in ancestor dirs are ignored if another exists in home [\#62](https://github.com/bbatsov/rubocop/pull/62) ([yujinakayama](https://github.com/yujinakayama))

- Fix a spec example refers rspec command arguments [\#61](https://github.com/bbatsov/rubocop/pull/61) ([yujinakayama](https://github.com/yujinakayama))

- fix log exception [\#86](https://github.com/bbatsov/rubocop/pull/86) ([bolandrm](https://github.com/bolandrm))

- New rule: Prefer %w over literal array syntax for an array of strings. [\#73](https://github.com/bbatsov/rubocop/pull/73) ([jdanielnd](https://github.com/jdanielnd))

- Double alias problem [\#71](https://github.com/bbatsov/rubocop/pull/71) ([zeroed](https://github.com/zeroed))

- Add missing files to gemspec [\#69](https://github.com/bbatsov/rubocop/pull/69) ([bf4](https://github.com/bf4))

- Add processing of rubocop:disable and rubocop:enable comments. [\#63](https://github.com/bbatsov/rubocop/pull/63) ([jonas054](https://github.com/jonas054))

## [v0.5.0](https://github.com/bbatsov/rubocop/tree/v0.5.0) (2013-04-17)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.6...v0.5.0)

**Implemented enhancements:**

- Integration with flycheck [\#32](https://github.com/bbatsov/rubocop/issues/32)

**Fixed bugs:**

- Received malformed format string ArgumentError from rubocop [\#42](https://github.com/bbatsov/rubocop/issues/42)

**Closed issues:**

- Interpolated variables not enclosed in braces are not noticed [\#59](https://github.com/bbatsov/rubocop/issues/59)

**Merged pull requests:**

- Add extensionless files with shebang lines to the set of default files [\#58](https://github.com/bbatsov/rubocop/pull/58) ([lee-dohm](https://github.com/lee-dohm))

## [v0.4.6](https://github.com/bbatsov/rubocop/tree/v0.4.6) (2013-04-15)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.5...v0.4.6)

## [v0.4.5](https://github.com/bbatsov/rubocop/tree/v0.4.5) (2013-04-15)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.4...v0.4.5)

**Merged pull requests:**

- Reintroduce per directory configuration. [\#57](https://github.com/bbatsov/rubocop/pull/57) ([jonas054](https://github.com/jonas054))

## [v0.4.4](https://github.com/bbatsov/rubocop/tree/v0.4.4) (2013-04-14)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.3...v0.4.4)

**Closed issues:**

- method parameters ending with comma crash rubocop [\#54](https://github.com/bbatsov/rubocop/issues/54)

- Undefined method `captures' for nil:NilClass [\#50](https://github.com/bbatsov/rubocop/issues/50)

**Merged pull requests:**

- Deal with syntax errors in inspected files. [\#56](https://github.com/bbatsov/rubocop/pull/56) ([jonas054](https://github.com/jonas054))

## [v0.4.3](https://github.com/bbatsov/rubocop/tree/v0.4.3) (2013-04-14)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.2...v0.4.3)

**Closed issues:**

- Crash "missing brace not found" [\#51](https://github.com/bbatsov/rubocop/issues/51)

**Merged pull requests:**

- Handle extra comma at end of argument list without crashing. [\#55](https://github.com/bbatsov/rubocop/pull/55) ([jonas054](https://github.com/jonas054))

- Bail out if we can't find a "when ... ;" due to lack of tokens. [\#53](https://github.com/bbatsov/rubocop/pull/53) ([jonas054](https://github.com/jonas054))

- Correction of comments in config file [\#52](https://github.com/bbatsov/rubocop/pull/52) ([jonas054](https://github.com/jonas054))

## [v0.4.2](https://github.com/bbatsov/rubocop/tree/v0.4.2) (2013-04-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.1...v0.4.2)

**Fixed bugs:**

- Strange behavior for inline blocks [\#41](https://github.com/bbatsov/rubocop/issues/41)

**Closed issues:**

- Wrong version number printed by rubocop --version [\#49](https://github.com/bbatsov/rubocop/issues/49)

## [v0.4.1](https://github.com/bbatsov/rubocop/tree/v0.4.1) (2013-04-13)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.4.0...v0.4.1)

**Fixed bugs:**

- False positive: "Use def with parentheses when there are arguments" [\#36](https://github.com/bbatsov/rubocop/issues/36)

**Closed issues:**

- Landing page. [\#47](https://github.com/bbatsov/rubocop/issues/47)

- Comments shouldn't be part of the 80 characters rule [\#43](https://github.com/bbatsov/rubocop/issues/43)

- The 2.0.0 build fails [\#40](https://github.com/bbatsov/rubocop/issues/40)

- README improvements [\#31](https://github.com/bbatsov/rubocop/issues/31)

**Merged pull requests:**

- Added landing page for the project. [\#48](https://github.com/bbatsov/rubocop/pull/48) ([rafalchmiel](https://github.com/rafalchmiel))

- fix parsing of blocks containing interpolations [\#46](https://github.com/bbatsov/rubocop/pull/46) ([lloeki](https://github.com/lloeki))

- Typo fixed. [\#45](https://github.com/bbatsov/rubocop/pull/45) ([rafalchmiel](https://github.com/rafalchmiel))

- Added description to most settings. [\#44](https://github.com/bbatsov/rubocop/pull/44) ([rafalchmiel](https://github.com/rafalchmiel))

## [v0.4.0](https://github.com/bbatsov/rubocop/tree/v0.4.0) (2013-04-11)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.3.2...v0.4.0)

**Closed issues:**

- The 1.9.3 build fails [\#39](https://github.com/bbatsov/rubocop/issues/39)

- Migrate specs to expect syntax [\#37](https://github.com/bbatsov/rubocop/issues/37)

**Merged pull requests:**

- edit def\_parentheses for false positive [\#38](https://github.com/bbatsov/rubocop/pull/38) ([zeroed](https://github.com/zeroed))

## [v0.3.2](https://github.com/bbatsov/rubocop/tree/v0.3.2) (2013-04-06)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.3.1...v0.3.2)

**Closed issues:**

- Support for line numbers? [\#35](https://github.com/bbatsov/rubocop/issues/35)

**Merged pull requests:**

- Removed the exception to the snake\_case rule. [\#33](https://github.com/bbatsov/rubocop/pull/33) ([jonas054](https://github.com/jonas054))

- More rules [\#30](https://github.com/bbatsov/rubocop/pull/30) ([jonas054](https://github.com/jonas054))

- Write output in line number order. [\#29](https://github.com/bbatsov/rubocop/pull/29) ([jonas054](https://github.com/jonas054))

- Improvements [\#28](https://github.com/bbatsov/rubocop/pull/28) ([jonas054](https://github.com/jonas054))

- More rules [\#27](https://github.com/bbatsov/rubocop/pull/27) ([jonas054](https://github.com/jonas054))

## [v0.3.1](https://github.com/bbatsov/rubocop/tree/v0.3.1) (2013-02-28)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.3.0...v0.3.1)

**Closed issues:**

- Allow for additional line length configuration [\#25](https://github.com/bbatsov/rubocop/issues/25)

- How to integrate rubocop with Rake? [\#24](https://github.com/bbatsov/rubocop/issues/24)

**Merged pull requests:**

- More rules [\#26](https://github.com/bbatsov/rubocop/pull/26) ([jonas054](https://github.com/jonas054))

- More rules [\#23](https://github.com/bbatsov/rubocop/pull/23) ([jonas054](https://github.com/jonas054))

## [v0.3.0](https://github.com/bbatsov/rubocop/tree/v0.3.0) (2013-02-11)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.2.1...v0.3.0)

**Closed issues:**

- Mismatch: Offence.initalize\(severity, ...\) vs Offence.new\(filename, ...\) [\#14](https://github.com/bbatsov/rubocop/issues/14)

- Error while running "code converter not found \(UTF-8 to UTF-16\)" [\#11](https://github.com/bbatsov/rubocop/issues/11)

**Merged pull requests:**

- More rules [\#22](https://github.com/bbatsov/rubocop/pull/22) ([jonas054](https://github.com/jonas054))

- add --silent parameter to silence summary output [\#21](https://github.com/bbatsov/rubocop/pull/21) ([yaauie](https://github.com/yaauie))

- More rules [\#20](https://github.com/bbatsov/rubocop/pull/20) ([jonas054](https://github.com/jonas054))

- Simplified handling of enabled flag [\#19](https://github.com/bbatsov/rubocop/pull/19) ([jonas054](https://github.com/jonas054))

- Added coverage task, which runs simplecov. [\#18](https://github.com/bbatsov/rubocop/pull/18) ([jonas054](https://github.com/jonas054))

- The configuration property should be "Enabled", not "Enable". [\#17](https://github.com/bbatsov/rubocop/pull/17) ([jonas054](https://github.com/jonas054))

- The first argument to Cop\#add\_offence shall be "severity". [\#16](https://github.com/bbatsov/rubocop/pull/16) ([jonas054](https://github.com/jonas054))

- Option --config and file .rubocop.yml added. [\#15](https://github.com/bbatsov/rubocop/pull/15) ([jonas054](https://github.com/jonas054))

- when shebang is present on first line, encoding should be allowed on the next line. [\#13](https://github.com/bbatsov/rubocop/pull/13) ([yaauie](https://github.com/yaauie))

- Configurable [\#10](https://github.com/bbatsov/rubocop/pull/10) ([jonas054](https://github.com/jonas054))

## [v0.2.1](https://github.com/bbatsov/rubocop/tree/v0.2.1) (2013-01-12)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.2.0...v0.2.1)

**Merged pull requests:**

- Solution for issue \#11. Support for ruby 1.9.2. added. [\#12](https://github.com/bbatsov/rubocop/pull/12) ([jonas054](https://github.com/jonas054))

- More rules [\#9](https://github.com/bbatsov/rubocop/pull/9) ([jonas054](https://github.com/jonas054))

## [v0.2.0](https://github.com/bbatsov/rubocop/tree/v0.2.0) (2013-01-02)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.1.0...v0.2.0)

**Closed issues:**

- \[NoMethodError\] rubocop /path/to/file [\#1](https://github.com/bbatsov/rubocop/issues/1)

**Merged pull requests:**

- More rules [\#8](https://github.com/bbatsov/rubocop/pull/8) ([jonas054](https://github.com/jonas054))

- Classes [\#7](https://github.com/bbatsov/rubocop/pull/7) ([jonas054](https://github.com/jonas054))

- Optimization [\#6](https://github.com/bbatsov/rubocop/pull/6) ([jonas054](https://github.com/jonas054))

- More rules [\#5](https://github.com/bbatsov/rubocop/pull/5) ([jonas054](https://github.com/jonas054))

- More rules [\#4](https://github.com/bbatsov/rubocop/pull/4) ([jonas054](https://github.com/jonas054))

## [v0.1.0](https://github.com/bbatsov/rubocop/tree/v0.1.0) (2012-12-20)

[Full Changelog](https://github.com/bbatsov/rubocop/compare/v0.0.0...v0.1.0)

**Merged pull requests:**

- More rules [\#3](https://github.com/bbatsov/rubocop/pull/3) ([jonas054](https://github.com/jonas054))

- Emacs and unix integration [\#2](https://github.com/bbatsov/rubocop/pull/2) ([jonas054](https://github.com/jonas054))

## [v0.0.0](https://github.com/bbatsov/rubocop/tree/v0.0.0) (2012-05-03)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*