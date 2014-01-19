[![Gem Version](https://badge.fury.io/rb/rubocop.png)](http://badge.fury.io/rb/rubocop)
[![Dependency Status](https://gemnasium.com/bbatsov/rubocop.png)](https://gemnasium.com/bbatsov/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.png?branch=master)](https://travis-ci.org/bbatsov/rubocop)
[![Coverage Status](https://coveralls.io/repos/bbatsov/rubocop/badge.png?branch=master)](https://coveralls.io/r/bbatsov/rubocop)
[![Code Climate](https://codeclimate.com/github/bbatsov/rubocop.png)](https://codeclimate.com/github/bbatsov/rubocop)

# RuboCop

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop

**RuboCop** is a Ruby static code analyzer. Out of the box it will
enforce many of the guidelines outlined in the community
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

Most aspects of its behavior can be tweaked via various
[configuration options](https://github.com/bbatsov/rubocop/blob/master/config/default.yml).

Apart from reporting problems in your code, RuboCop can also
automatically fix some of the problems for you.

- [Installation](#installation)
- [Basic Usage](#basic-usage)
	- [Cops](#cops)
		- [Style](#style)
		- [Lint](#lint)
		- [Rails](#rails)
- [Configuration](#configuration)
	- [Inheritance](#inheritance)
	- [Defaults](#defaults)
	- [Including/Excluding files](#includingexcluding-files)
	- [Automatically Generated Configuration](#automatically-generated-configuration)
- [Disabling Cops within Source Code](#disabling-cops-within-source-code)
- [Formatters](#formatters)
	- [Clang Formatter (default)](#clang-formatter-default)
	- [Emacs](#emacs)
	- [Simple](#simple)
	- [File List Formatter](#file-list-formatter)
	- [JSON Formatter](#json-formatter)
	- [OffenceCount Formatter](#offencecount-formatter)
	- [Custom Formatters](#custom-formatters)
		- [Creating Custom Formatter](#creating-custom-formatter)
		- [Using Custom Formatter in Command Line](#using-custom-formatter-in-command-line)
- [Compatibility](#compatibility)
- [Editor integration](#editor-integration)
	- [Emacs](#emacs-1)
	- [Vim](#vim)
	- [Sublime Text 2](#sublime-text-2)
	- [Brackets](#brackets)
	- [Other Editors](#other-editors)
- [Guard integration](#guard-integration)
- [Rake integration](#rake-integration)
- [Team](#team)
- [Contributors](#contributors)
- [Mailing List](#mailing-list)
- [Changelog](#changelog)
- [Copyright](#copyright)

## Installation

**RuboCop**'s installation is pretty standard:

```bash
$ gem install rubocop
```

## Basic Usage

Running `rubocop` with no arguments will check all Ruby source files
in the current directory:

```bash
$ rubocop
```

Alternatively you can pass `rubocop` a list of files and directories to check:

```bash
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
Offences:

test.rb:1:5: C: Use snake_case for methods and variables.
def badName
    ^^^^^^^
test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 3 offences detected
```

For more details check the available command-line options:

```bash
$ rubocop -h
```

Command flag              | Description
--------------------------|------------------------------------------------------------
`-v/--version`            | Displays the current version and exits
`-V/--verbose-version`    | Displays the current version plus the version of Parser and Ruby
`-d/--debug`              | Displays some extra debug output
`-D/--display-cop-names`  | Displays cop names in offence messages.
`-c/--config`             | Run with specified config file
`-f/--format`             | Choose a formatter
`-o/--out`                | Write output to a file instead of STDOUT
`-r/--require`            | Require Ruby file
`-R/--rails`              | Run extra Rails cops
`-l/--lint`               | Run only lint cops
`-a/--auto-correct`       | Auto-correct certain offences *Note:* Experimental - use with caution
`--only`                  | Run only the specified cop
`--auto-gen-config`       | Generate a configuration file acting as a TODO list
`--show-cops`             | Shows available cops and their configuration

### Cops

In RuboCop lingo the various checks performed on the code are called cops. There are several cop departments.

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

Disabling any of the lint cops in generally a bad idea.

#### Rails

Rails cops are specific to the Ruby on Rails framework. Unlike style
and lint cops they are not used by default and you have to request them
specifically:

```
$ rubocop -R
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

Encoding:
  Enabled: false

LineLength:
  Max: 99
```

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

RuboCop checks all files recursively within the directory it is run
on.  However, it only recognizes files ending with `.rb` or
extensionless files with a `#!.*ruby` declaration as Ruby files. If
you'd like it to check other files you'll need to manually pass them
in, or to add entries for them under `AllCops`/`Includes`.  Files and
directories can also be ignored through `AllCops`/`Excludes`.

Here is an example that might be used for a Rails project:

```yaml
AllCops:
  Includes:
    - Rakefile
    - config.ru
  Excludes:
    - db/**
    - config/**
    - script/**
    - !ruby/regexp /old_and_unused\.rb$/

# other configuration
# ...
```

Files and directories are specified relative to the `.rubocop.yml` file.

**Note**: The `Excludes` parameter is special. It is valid for the
directory tree starting where it is defined. It is not shadowed by the
setting of `Excludes` in other `.rubocop.yml` files in
subdirectories. This is different from all other parameters, who
follow RuboCop's general principle that configuration for an inspected
file is taken from the nearest `.rubocop.yml`, searching upwards.

Cops can be run only on specific sets of files when that's needed (for
instance you might want to run some Rails model checks only on files,
which paths match `app/models/*.rb`). All cops support the
`Include` param.

```yaml
DefaultScope:
  Include:
    - app/models
```

Cops can also exclude only specific sets of files when that's needed (for
instance you might want to run some cop only on a specific file). All cops support the
`Exclude` param.

```yaml
DefaultScope:
  Exclude:
    - app/models/problematic.rb
```

Specific cops can be disabled by setting `Enabled` to `false` for that specific cop.

```yaml
LineLength:
  Enabled: false
```

Cops can customize their severity level. All cops support the `Severity` param.

```yaml
CyclomaticComplexity:
  Severity: warning
```

### Automatically Generated Configuration

If you have a code base with an overwhelming amount of offences, it can be a
good idea to use `rubocop --auto-gen-config` and add an `inherit_from:
rubocop-todo.yml` in your `.rubocop.yml`. The generated file `rubocop-todo.yml`
contains configuration to disable all cops that currently detect an offence in
the code. Then you can start removing the entries in the generated file one by
one as you work through all the offences in the code.

## Disabling Cops within Source Code

One or more individual cops can be disabled locally in a section of a
file by adding a comment such as

```ruby
# rubocop:disable LineLength, StringLiterals
[...]
# rubocop:enable LineLength, StringLiterals
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
for x in (0..19) # rubocop:disable AvoidFor
```

## Formatters

### Clang Formatter (default)

The `Clang` formatter displays the offences in a manner similar to `clang`:

```
rubocop test.rb

Inspecting 1 file
W

Offences:

test.rb:1:1: C: Use snake_case for methods and variables.
def badName
^^^
test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^^^^
test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
    end
    ^^^

1 file inspected, 3 offences detected
```

### Emacs

The `Emacs` formatter displays the offences in a format suitable for consumption by `Emacs` (and possibly other tools).

```
rubocop --format emacs test.rb

/Users/bozhidar/projects/test.rb:1:1: C: Use snake_case for methods and variables.
/Users/bozhidar/projects/test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
/Users/bozhidar/projects/test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2

1 file inspected, 3 offences detected
```

### Simple

The name of the formatter says it all :-)

```
rubocop --format simple test.rb

== test.rb ==
C:  1:  1: Use snake_case for methods and variables.
C:  2:  3: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
W:  4:  5: end at 4, 4 is not aligned with if at 2, 2

1 file inspected, 3 offences detected
```

### File List Formatter

Sometimes you might want to just open all files with offences in your
favorite editor. This formatter outputs just the names of the files
with offences in them and makes it possible to do something like:

```
rubocop --format files | xargs vim
```

### JSON Formatter

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
      "offences": []
    }, {
      "path": "lib/bar.rb",
      "offences": [{
          "severity": "convention",
          "message": "Line is too long. [81/79]",
          "cop_name": "LineLength",
          "corrected": true,
          "location": {
            "line": 546,
            "column": 80
          }
        }, {
          "severity": "warning",
          "message": "Unreachable code detected.",
          "cop_name": "UnreachableCode",
          "corrected": false,
          "location": {
            "line": 15,
            "column": 9
          }
        }
      ]
    }
  ],
  "summary": {
    "offence_count": 2,
    "target_file_count": 2,
    "inspected_file_count": 2
  }
}
```

### OffenceCount Formatter

Sometimes when first applying RuboCop to a codebase, it's nice to be able to
see where most of your style cleanup is going to be spent.

With this in mind, you can use the offence count formatter to outline the offended
cops and the number of offences found for each by running:

```
rubocop --format offences

(87)  Documentation
(12)  DotPosition
(8)   AvoidGlobalVars
(7)   EmptyLines
(6)   AssignmentInCondition
(4)   Blocks
(4)   CommentAnnotation
(3)   BlockAlignment
(1)   IndentationWidth
(1)   AvoidPerlBackrefs
(1)   ColonMethodCall
```

### Custom Formatters

You can customize RuboCop's output format with custom formatter.

#### Creating Custom Formatter

To implement a custom formatter, you need to subclass
`Rubocop::Formatter::BaseFormatter` and override some methods,
or implement all formatter API methods by duck typing.

Please see the documents below for more formatter API details.

* [Rubocop::Formatter::BaseFormatter](http://rubydoc.info/gems/rubocop/Rubocop/Formatter/BaseFormatter)
* [Rubocop::Cop::Offence](http://rubydoc.info/gems/rubocop/Rubocop/Cop/Offence)
* [Parser::Source::Range](http://rubydoc.info/github/whitequark/parser/Parser/Source/Range)

#### Using Custom Formatter in Command Line

You can tell RuboCop to use your custom formatter with a combination of
`--format` and `--require` option.
For example, when you have defined `MyCustomFormatter` in
`./path/to/my_custom_formatter.rb`, you would type this command:

```bash
$ rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
```

Note: The path passed to `--require` is directly passed to `Kernel.require`.
If your custom formatter file is not in `$LOAD_PATH`,
you need to specify the path as relative path prefixed with `./` explicitly,
or absolute path.

## Compatibility

RuboCop supports the following Ruby implementations:

* MRI 1.9.2 ([until June 2014](https://www.ruby-lang.org/en/news/2013/12/17/maintenance-of-1-8-7-and-1-9-2/))
* MRI 1.9.3
* MRI 2.0
* MRI 2.1
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

### Other Editors

Here's one great opportunity to contribute to RuboCop - implement
RuboCop integration for your favorite editor.

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

Rubocop::RakeTask.new
```

The above will use default values

```ruby
require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['files']
  # don't abort rake on failure
  task.fail_on_error = false
end
```

## Team

Here's a list of RuboCop's core developers:

* [Bozhidar Batsov](https://github.com/bbatsov)
* [Jonas Arvidsson](https://github.com/jonas054)
* [Yuji Nakayama](https://github.com/yujinakayama)
* [Evgeni Dzhelyov](https://github.com/edzhelyov)

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

## Mailing List

If you're interested in everything regarding RuboCop's development,
consider joining its
[Google Group](https://groups.google.com/forum/?fromgroups#!forum/rubocop).

## Changelog

RuboCop's changelog is available [here](CHANGELOG.md).

## Copyright

Copyright (c) 2012-2013 Bozhidar Batsov. See [LICENSE.txt](LICENSE.txt) for
further details.
