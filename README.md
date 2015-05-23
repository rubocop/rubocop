[![Gem Version](https://badge.fury.io/rb/rubocop.svg)](http://badge.fury.io/rb/rubocop)
[![Dependency Status](https://gemnasium.com/bbatsov/rubocop.svg)](https://gemnasium.com/bbatsov/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.svg?branch=master)](https://travis-ci.org/bbatsov/rubocop)
[![Coverage Status](http://img.shields.io/coveralls/bbatsov/rubocop/master.svg)](https://coveralls.io/r/bbatsov/rubocop)
[![Code Climate](https://codeclimate.com/github/bbatsov/rubocop/badges/gpa.svg)](https://codeclimate.com/github/bbatsov/rubocop)
[![Inline docs](http://inch-ci.org/github/bbatsov/rubocop.svg)](http://inch-ci.org/github/bbatsov/rubocop)
[![Gratipay](http://img.shields.io/gratipay/bbatsov.svg)](https://www.gratipay.com/bbatsov/)

<p align="center">
  <img src="https://raw.github.com/bbatsov/rubocop/master/logo/rubo-logo-horizontal.png" alt="RuboCop Logo"/>
</p>

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop

**RuboCop** is a Ruby static code analyzer. Out of the box it will
enforce many of the guidelines outlined in the community
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

Most aspects of its behavior can be tweaked via various
[configuration options](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Apart from reporting problems in your code, RuboCop can also
automatically fix some of the problems for you.

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/bbatsov/rubocop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

You can support my work on RuboCop and [all my other projects](https://github.com/bbatsov) via [gratipay](https://www.gratipay.com/bbatsov).

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/bbatsov)

**This documentation tracks the `master` branch of RuboCop. Some of
the features and settings discussed here might not be available in
older releases (including the current stable release). Please, consult
the relevant git tag (e.g. v0.30.0) if you need documentation for a
specific RuboCop release.**

- [Installation](#installation)
- [Basic Usage](#basic-usage)
    - [Cops](#cops)
        - [Style](#style)
        - [Lint](#lint)
        - [Metrics](#metrics)
        - [Rails](#rails)
- [Configuration](#configuration)
    - [Inheritance](#inheritance)
    - [Defaults](#defaults)
    - [Including/Excluding files](#includingexcluding-files)
    - [Generic configuration parameters](#generic-configuration-parameters)
    - [Automatically Generated Configuration](#automatically-generated-configuration)
- [Disabling Cops within Source Code](#disabling-cops-within-source-code)
- [Formatters](#formatters)
    - [Progress Formatter (default)](#progress-formatter-default)
    - [Clang Style Formatter](#clang-style-formatter)
    - [Fuubar Style Formatter](#fuubar-style-formatter)
    - [Emacs Style Formatter](#emacs-style-formatter)
    - [Simple Formatter](#simple-formatter)
    - [File List Formatter](#file-list-formatter)
    - [JSON Formatter](#json-formatter)
    - [Offense Count Formatter](#offense-count-formatter)
    - [HTML Formatter](#html-formatter)
- [Compatibility](#compatibility)
- [Editor integration](#editor-integration)
    - [Emacs](#emacs)
    - [Vim](#vim)
    - [Sublime Text](#sublime-text)
    - [Brackets](#brackets)
    - [TextMate2](#textmate2)
    - [Atom](#atom)
    - [LightTable](#lighttable)
    - [RubyMine](#rubymine)
    - [Other Editors](#other-editors)
- [Git pre-commit hook integration](#git-pre-commit-hook-integration)
- [Guard integration](#guard-integration)
- [Rake integration](#rake-integration)
- [Extensions](#extensions)
  - [Loading Extensions](#loading-extensions)
  - [Custom Cops](#custom-cops)
    - [Known Custom Cops](#known-custom-cops)
  - [Custom Formatters](#custom-formatters)
    - [Creating Custom Formatter](#creating-custom-formatter)
    - [Using Custom Formatter in Command Line](#using-custom-formatter-in-command-line)
- [Team](#team)
- [Logo](#logo)
- [Contributors](#contributors)
- [Mailing List](#mailing-list)
- [Changelog](#changelog)
- [Copyright](#copyright)

## Installation

**RuboCop**'s installation is pretty standard:

```
$ gem install rubocop
```

If you'd rather install RuboCop using `bundler`, don't require it in your `Gemfile`:

```
gem 'rubocop', require: false
```

## Basic Usage

Running `rubocop` with no arguments will check all Ruby source files
in the current directory:

```
$ rubocop
```

Alternatively you can pass `rubocop` a list of files and directories to check:

```
$ rubocop app spec lib/something.rb
```

Here's RuboCop in action. Consider the following Ruby source code:

```ruby
def badName
  if something
    test
    end
end
```

Running RuboCop on it (assuming it's in a file named `test.rb`) would produce the following report:

```
Inspecting 1 file
W

Offenses:

test.rb:1:5: C: Use snake_case for method names.
def badName
    ^^^^^^^
test.rb:2:3: C: Use a guard clause instead of wrapping the code inside a conditional expression.
  if something
  ^^
test.rb:2:3: C: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 4 offenses detected
```

For more details check the available command-line options:

```
$ rubocop -h
```

Command flag              | Description
--------------------------|------------------------------------------------------------
`-v/--version`            | Displays the current version and exits.
`-V/--verbose-version`    | Displays the current version plus the version of Parser and Ruby.
`-F/--fail-fast`          | Inspects in modification time order and stops after first file with offenses.
`-d/--debug`              | Displays some extra debug output.
`-D/--display-cop-names`  | Displays cop names in offense messages.
`-c/--config`             | Run with specified config file.
`-f/--format`             | Choose a formatter.
`-o/--out`                | Write output to a file instead of STDOUT.
`-r/--require`            | Require Ruby file (see [Loading Extensions](#loading-extensions)).
`-R/--rails`              | Run extra Rails cops.
`-l/--lint`               | Run only lint cops.
`-a/--auto-correct`       | Auto-correct certain offenses. *Note:* Experimental - use with caution.
`--only`                  | Run only the specified cop(s) and/or cops in the specified departments.
`--except`                | Run all cops enabled by configuration except the specified cop(s) and/or departments.
`--auto-gen-config`       | Generate a configuration file acting as a TODO list.
`--show-cops`             | Shows available cops and their configuration.
`--fail-level`            | Minimum [severity](#severity) for exit with error code. Full severity name or upper case initial can be given. Normally, auto-corrected offenses are ignored. Use `A` or `autocorrect` if you'd like them to trigger failure.

### Cops

In RuboCop lingo the various checks performed on the code are called cops. There are several cop departments.

You can also load [custom cops](#custom-cops).

#### Style

Most of the cops in RuboCop are so called style cops that check for
stylistics problems in your code. Almost all of the them are based on
the Ruby Style Guide. Many of the style cops have configurations
options allowing them to support different popular coding
conventions.

#### Lint

Lint cops check for possible errors and very bad practices in your
code. RuboCop implements in a portable way all built-in MRI lint
checks (`ruby -wc`) and adds a lot of extra lint checks of its
own. You can run only the lint cops like this:

```
$ rubocop -l
```

The `-l`/`--lint` option can be used together with `--only` to run all the
enabled lint cops plus a selection of other cops.

Disabling any of the lint cops is generally a bad idea.

#### Metrics

Metrics cops deal with properties of the source code that can be measured,
such as class length, method length, etc. Generally speaking, they have a
configuration parameter called `Max` and when running
`rubocop --auto-gen-config`, this parameter will be set to the highest value
found for the inspected code.

#### Rails

Rails cops are specific to the Ruby on Rails framework. Unlike style
and lint cops they are not used by default and you have to request them
specifically:

```
$ rubocop -R
```

or add the following directive to your `.rubocop.yml`:

```yaml
AllCops:
  RunRailsCops: true
```

## Configuration

The behavior of RuboCop can be controlled via the
[.rubocop.yml](https://github.com/bbatsov/rubocop/blob/master/.rubocop.yml)
configuration file. It makes it possible to enable/disable certain cops
(checks) and to alter their behavior if they accept any parameters. The file
can be placed either in your home directory or in some project directory.

RuboCop will start looking for the configuration file in the directory
where the inspected file is and continue its way up to the root directory.

The file has the following format:

```yaml
inherit_from: ../.rubocop.yml

Style/Encoding:
  Enabled: false

Metrics/LineLength:
  Max: 99
```

**Note**: Qualifying cop name with its type, e.g., `Style`, is recommended,
  but not necessary as long as the cop name is unique across all types.

### Inheritance

The optional `inherit_from` directive is used to include configuration
from one or more files. This makes it possible to have the common
project settings in the `.rubocop.yml` file at the project root, and
then only the deviations from those rules in the subdirectories. The
files can be given with absolute paths or paths relative to the file
where they are referenced. The settings after an `inherit_from`
directive override any settings in the file(s) inherited from. When
multiple files are included, the first file in the list has the lowest
precedence and the last one has the highest. The format for multiple
inheritance is:

```yaml
inherit_from:
  - ../.rubocop.yml
  - ../conf/.rubocop.yml
```

### Defaults

The file
[config/default.yml](https://github.com/bbatsov/rubocop/blob/master/config/default.yml)
under the RuboCop home directory contains the default settings that
all configurations inherit from. Project and personal `.rubocop.yml`
files need only make settings that are different from the default
ones. If there is no `.rubocop.yml` file in the project or home
directory, `config/default.yml` will be used.

### Including/Excluding files

RuboCop checks all files found by a recursive search starting from the
directory it is run in, or directories given as command line
arguments.  However, it only recognizes files ending with `.rb` or
extensionless files with a `#!.*ruby` declaration as Ruby files.
Hidden directories (i.e., directories whose names start with a dot)
are not searched by default.  If you'd like it to check files that are
not included by default, you'll need to pass them in on the command
line, or to add entries for them under `AllCops`/`Include`.  Files and
directories can also be ignored through `AllCops`/`Exclude`.

Here is an example that might be used for a Rails project:

```yaml
AllCops:
  Include:
    - '**/Rakefile'
    - '**/config.ru'
  Exclude:
    - 'db/**/*'
    - 'config/**/*'
    - 'script/**/*'
    - !ruby/regexp /old_and_unused\.rb$/

# other configuration
# ...
```

Files and directories are specified relative to the `.rubocop.yml` file.

**Note**: Patterns that are just a file name, e.g. `Rakefile`, will match
that file name in any directory, but this pattern style deprecated. The
correct way to match the file in any directory, including the current, is
`**/Rakefile`.

**Note**: The pattern `config/**` will match any file recursively under
`config`, but this pattern style is deprecated and should be replaced by
`config/**/*`.

**Note**: The `Include` and `Exclude` parameters are special. They are
valid for the directory tree starting where they are defined. They are not
shadowed by the setting of `Include` and `Exclude` in other `.rubocop.yml`
files in subdirectories. This is different from all other parameters, who
follow RuboCop's general principle that configuration for an inspected file
is taken from the nearest `.rubocop.yml`, searching upwards.

Cops can be run only on specific sets of files when that's needed (for
instance you might want to run some Rails model checks only on files whose
paths match `app/models/*.rb`). All cops support the
`Include` param.

```yaml
Rails/DefaultScope:
  Include:
    - app/models/*.rb
```

Cops can also exclude only specific sets of files when that's needed (for
instance you might want to run some cop only on a specific file). All cops support the
`Exclude` param.

```yaml
Rails/DefaultScope:
  Exclude:
    - app/models/problematic.rb
```

### Generic configuration parameters

In addition to `Include` and `Exclude`, the following parameters are available
for every cop.

#### Enabled

Specific cops can be disabled by setting `Enabled` to `false` for that specific cop.

```yaml
Metrics/LineLength:
  Enabled: false
```

#### Severity

Each cop has a default severity level based on which department it belongs
to. The level is `warning` for `Lint` and `convention` for all the others.
Cops can customize their severity level. Allowed params are `refactor`,
`convention`, `warning`, `error` and `fatal`.

There is one exception from the general rule above and that is `Lint/Syntax`, a
special cop that checks for syntax errors before the other cops are invoked. It
can not be disabled and its severity (`fatal`) can not be changed in
configuration.

```yaml
Metrics/CyclomaticComplexity:
  Severity: warning
```

#### AutoCorrect

Cops that support the `--auto-correct` option can have that support
disabled. For example:

```yaml
Style/PerlBackrefs:
  AutoCorrect: false
```

### Automatically Generated Configuration

If you have a code base with an overwhelming amount of offenses, it can
be a good idea to use `rubocop --auto-gen-config` and add an
`inherit_from: .rubocop_todo.yml` in your `.rubocop.yml`. The generated
file `.rubocop_todo.yml` contains configuration to disable all cops that
currently detect an offense in the code. Then you can start removing the
entries in the generated file one by one as you work through all the
offenses in the code.

## Disabling Cops within Source Code

One or more individual cops can be disabled locally in a section of a
file by adding a comment such as

```ruby
# rubocop:disable Metrics/LineLength, Style/StringLiterals
[...]
# rubocop:enable Metrics/LineLength, Style/StringLiterals
```

You can also disable *all* cops with

```ruby
# rubocop:disable all
[...]
# rubocop:enable all
```

One or more cops can be disabled on a single line with an end-of-line
comment.

```ruby
for x in (0..19) # rubocop:disable Style/AvoidFor
```

## Formatters

You can change the output format of RuboCop by specifying formatters with the `-f/--format` option.
RuboCop ships with several built-in formatters, and also you can create your custom formatter.

Additionally the output can be redirected to a file instead of `$stdout` with the `-o/--out` option.

Some of the built-in formatters produce **machine-parsable** output
and they are considered public APIs.
The rest of the formatters are for humans, so parsing their outputs is discouraged.

You can enable multiple formatters at the same time by specifying `-f/--format` multiple times.
The `-o/--out` option applies to the previously specified `-f/--format`,
or the default `progress` format if no `-f/--format` is specified before the `-o/--out` option.

```bash
# Simple format to $stdout.
$ rubocop --format simple

# Progress (default) format to the file result.txt.
$ rubocop --out result.txt

# Both progress and offense count formats to $stdout.
# The offense count formatter outputs only the final summary,
# so you'll mostly see the outputs from the progress formatter,
# and at the end the offense count summary will be outputted.
$ rubocop --format progress --format offenses

# Progress format to $stdout, and JSON format to the file rubocop.json.
$ rubocop --format progress --format json --out rubocop.json
#         ~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~
#                 |               |_______________|
#              $stdout

# Progress format to result.txt, and simple format to $stdout.
$ rubocop --output result.txt --format simple
#         ~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~
#                  |                 |
#           default format        $stdout
```

You can also load [custom formatters](#custom-formatters).

### Progress Formatter (default)

The default `progress` formatter outputs a character for each inspected file,
and at the end it displays all detected offenses in the `clang` format.
A `.` represents a clean file, and each of the capital letters means
the severest offense (convention, warning, error or fatal) found in a file.

```
$ rubocop
Inspecting 26 files
..W.C....C..CWCW.C...WC.CC

Offenses:

lib/foo.rb:6:5: C: Missing top-level class documentation comment.
    class Foo
    ^^^^^

...

26 files inspected, 46 offenses detected
```

### Clang Style Formatter

The `clang` formatter displays the offenses in a manner similar to `clang`:

```
$ rubocop test.rb
Inspecting 1 file
W

Offenses:

test.rb:1:5: C: Use snake_case for method names.
def badName
    ^^^^^^^
test.rb:2:3: C: Use a guard clause instead of wrapping the code inside a conditional expression.
  if something
  ^^
test.rb:2:3: C: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 4 offenses detected
```

### Fuubar Style Formatter

The `fuubar` style formatter displays a progress bar
and shows details of offenses in the `clang` format as soon as they are detected.
This is inspired by the [Fuubar](https://github.com/jeffkreeftmeijer/fuubar) formatter for RSpec.

```
$ rubocop --format fuubar
lib/foo.rb.rb:1:1: C: Use snake_case for methods and variables.
def badName
    ^^^^^^^
lib/bar.rb:13:14: W: File.exists? is deprecated in favor of File.exist?.
        File.exists?(path)
             ^^^^^^^
 22/53 files |======== 43 ========>                           |  ETA: 00:00:02
```

### Emacs Style Formatter

**Machine-parsable**

The `emacs` formatter displays the offenses in a format suitable for consumption by `Emacs` (and possibly other tools).

```
$ rubocop --format emacs test.rb
/Users/bozhidar/projects/test.rb:1:1: C: Use snake_case for methods and variables.
/Users/bozhidar/projects/test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
/Users/bozhidar/projects/test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
```

### Simple Formatter

The name of the formatter says it all :-)

```
$ rubocop --format simple test.rb
== test.rb ==
C:  1:  5: Use snake_case for method names.
C:  2:  3: Use a guard clause instead of wrapping the code inside a conditional expression.
C:  2:  3: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
W:  4:  5: end at 4, 4 is not aligned with if at 2, 2

1 file inspected, 4 offenses detected
```

### File List Formatter

 **Machine-parsable**

Sometimes you might want to just open all files with offenses in your
favorite editor. This formatter outputs just the names of the files
with offenses in them and makes it possible to do something like:

```
$ rubocop --format files | xargs vim
```

### JSON Formatter

**Machine-parsable**

You can get RuboCop's inspection result in JSON format by passing `--format json` option in command line.
The JSON structure is like the following example:

```javascript
{
  "metadata": {
    "rubocop_version": "0.9.0",
    "ruby_engine": "ruby",
    "ruby_version": "2.0.0",
    "ruby_patchlevel": "195",
    "ruby_platform": "x86_64-darwin12.3.0"
  },
  "files": [{
      "path": "lib/foo.rb",
      "offenses": []
    }, {
      "path": "lib/bar.rb",
      "offenses": [{
          "severity": "convention",
          "message": "Line is too long. [81/80]",
          "cop_name": "LineLength",
          "corrected": true,
          "location": {
            "line": 546,
            "column": 80,
            "length": 4
          }
        }, {
          "severity": "warning",
          "message": "Unreachable code detected.",
          "cop_name": "UnreachableCode",
          "corrected": false,
          "location": {
            "line": 15,
            "column": 9,
            "length": 10
          }
        }
      ]
    }
  ],
  "summary": {
    "offense_count": 2,
    "target_file_count": 2,
    "inspected_file_count": 2
  }
}
```

### Offense Count Formatter

Sometimes when first applying RuboCop to a codebase, it's nice to be able to
see where most of your style cleanup is going to be spent.

With this in mind, you can use the offense count formatter to outline the offended
cops and the number of offenses found for each by running:

```
$ rubocop --format offenses

87   Documentation
12   DotPosition
8    AvoidGlobalVars
7    EmptyLines
6    AssignmentInCondition
4    Blocks
4    CommentAnnotation
3    BlockAlignment
1    IndentationWidth
1    AvoidPerlBackrefs
1    ColonMethodCall
--
134  Total
```

### HTML Formatter

Useful for CI environments. It will create an HTML report like [this](http://f.cl.ly/items/0M3029412x3O091a1X1R/expected.html).

```
$ rubocop --format html -o rubocop.html
```

## Compatibility

RuboCop supports the following Ruby implementations:

* MRI 1.9.3
* MRI 2.0
* MRI 2.1
* MRI 2.2
* JRuby in 1.9 mode
* Rubinius 2.0+

## Editor integration

### Emacs

[rubocop.el](https://github.com/bbatsov/rubocop-emacs) is a simple
Emacs interface for RuboCop. It allows you to run RuboCop inside Emacs
and quickly jump between problems in your code.

[flycheck](https://github.com/lunaryorn/flycheck) > 0.9 also supports
RuboCop and uses it by default when available.

### Vim

The [vim-rubocop](https://github.com/ngmy/vim-rubocop) plugin runs
RuboCop and displays the results in Vim.

There's also a RuboCop checker in
[syntastic](https://github.com/scrooloose/syntastic).

### Sublime Text

If you're a ST user you might find the
[Sublime RuboCop plugin](https://github.com/pderichs/sublime_rubocop)
useful.

### Brackets

The [brackets-rubocop](https://github.com/smockle/brackets-rubocop)
extension displays RuboCop results in Brackets.
It can be installed via the extension manager in Brackets.

### TextMate2

The [textmate2-rubocop](https://github.com/mrdougal/textmate2-rubocop)
bundle displays formatted RuboCop results in a new window.
Installation instructions can be found [here](https://github.com/mrdougal/textmate2-rubocop#installation).

### Atom

The [atom-lint](https://github.com/yujinakayama/atom-lint) package
runs RuboCop and highlights the offenses in Atom.

You can also use the [linter-rubocop](https://github.com/AtomLinter/linter-rubocop)
plugin for Atom's [linter](https://github.com/AtomLinter/Linter).

### LightTable

The [lt-rubocop](https://github.com/seancaffery/lt-rubocop) plugin
provides LightTable integration.

### RubyMine

The [rubocop-for-rubymine](https://github.com/sirlantis/rubocop-for-rubymine) plugin
provides basic RuboCop integration for RubyMine/IntelliJ IDEA.

### Other Editors

Here's one great opportunity to contribute to RuboCop - implement
RuboCop integration for your favorite editor.

## Git pre-commit hook integration

[overcommit](https://github.com/brigade/overcommit) is a fully configurable and
extendable Git commit hook manager. To use RuboCop with overcommit, add the
following to your `.overcommit.yml` file:

```yaml
PreCommit:
  RuboCop:
    enabled: true
```

## Guard integration

If you're fond of [Guard](https://github.com/guard/guard) you might
like
[guard-rubocop](https://github.com/yujinakayama/guard-rubocop). It
allows you to automatically check Ruby code style with RuboCop when
files are modified.


## Rake integration

To use RuboCop in your `Rakefile` add the following:

```ruby
require 'rubocop/rake_task'

RuboCop::RakeTask.new
```

If you run `rake -T`, the following two RuboCop tasks should show up:

```sh
rake rubocop                                  # Run RuboCop
rake rubocop:auto_correct                     # Auto-correct RuboCop offenses
```

The above will use default values

```ruby
require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['files']
  # don't abort rake on failure
  task.fail_on_error = false
end
```

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
relative path prefixed with `./` explicitly, or absolute path.

### Custom Cops

You can configure the custom cops in your `.rubocop.yml` just like any
other cop.

#### Known Custom Cops

* [rubocop-rspec](https://github.com/nevir/rubocop-rspec) -
  RSpec-specific analysis

### Custom Formatters

You can customize RuboCop's output format with custom formatters.

#### Creating Custom Formatter

To implement a custom formatter, you need to subclass
`RuboCop::Formatter::BaseFormatter` and override some methods,
or implement all formatter API methods by duck typing.

Please see the documents below for more formatter API details.

* [RuboCop::Formatter::BaseFormatter](http://rubydoc.info/gems/rubocop/RuboCop/Formatter/BaseFormatter)
* [RuboCop::Cop::Offense](http://rubydoc.info/gems/rubocop/RuboCop/Cop/Offense)
* [Parser::Source::Range](http://rubydoc.info/github/whitequark/parser/Parser/Source/Range)

#### Using Custom Formatter in Command Line

You can tell RuboCop to use your custom formatter with a combination of
`--format` and `--require` option.
For example, when you have defined `MyCustomFormatter` in
`./path/to/my_custom_formatter.rb`, you would type this command:

```
$ rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
```

## Team

Here's a list of RuboCop's core developers:

* [Bozhidar Batsov](https://github.com/bbatsov)
* [Jonas Arvidsson](https://github.com/jonas054)
* [Yuji Nakayama](https://github.com/yujinakayama)
* [Evgeni Dzhelyov](https://github.com/edzhelyov)

## Logo

RuboCop's logo was created by [Dimiter Petrov](https://www.chadomoto.com/). You can find the logo in various
formats [here](https://github.com/bbatsov/rubocop/tree/master/logo).

The logo is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/deed.en_GB).

## Contributors

Here's a [list](https://github.com/bbatsov/rubocop/contributors) of
all the people who have contributed to the development of RuboCop.

I'm extremely grateful to each and every one of them!

If you'd like to contribute to RuboCop, please take the time to go
through our short
[contribution guidelines](CONTRIBUTING.md).

Converting more of the Ruby Style Guide into RuboCop cops is our top
priority right now. Writing a new cop is a great way to dive into RuboCop!

Of course, bug reports and suggestions for improvements are always
welcome. GitHub pull requests are even better! :-)

You can also support my work on RuboCop and
[all my other projects](https://github.com/bbatsov) via
[gratipay](https://www.gratipay.com/bbatsov).

[![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.1.3/dist/gratipay.png)](https://gratipay.com/bbatsov)

## Mailing List

If you're interested in everything regarding RuboCop's development,
consider joining its
[Google Group](https://groups.google.com/forum/?fromgroups#!forum/rubocop).

## Freenode

If you're into IRC you can visit the `#rubocop` channel on Freenode.

## Changelog

RuboCop's changelog is available [here](CHANGELOG.md).

## Copyright

Copyright (c) 2012-2015 Bozhidar Batsov. See [LICENSE.txt](LICENSE.txt) for
further details.
