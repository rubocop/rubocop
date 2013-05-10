[![Gem Version](https://badge.fury.io/rb/rubocop.png)](http://badge.fury.io/rb/rubocop)
[![Build Status](https://travis-ci.org/bbatsov/rubocop.png?branch=master)](https://travis-ci.org/bbatsov/rubocop)
[![Coverage Status](https://coveralls.io/repos/bbatsov/rubocop/badge.png?branch=master)](https://coveralls.io/r/bbatsov/rubocop)

# RuboCop

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop

**RuboCop** is a Ruby code style checker based on the
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

## Installation

**RuboCop**'s installation is pretty standard:

```bash
$ gem install rubocop
```

## Basic Usage

Running `rubocop` with no arguments will check all Ruby source files
in the current folder:

```bash
$ rubocop
```

Alternatively you can pass `rubocop` a list of files and folders to check:

```bash
$ rubocop app spec lib/something.rb
```

For more details check the available command-line options:

```bash
$ rubocop -h
```

Command flag       | Description
-------------------|------------------------------------------------------------
`-v/--version`     | Displays the current version and exits
`-d/--debug`       | Displays some extra debug output
`-e/--emacs`       | Output the results in Emacs format
`-c/--config`      | Run with specified config file
`-s/--silent`      | Suppress the final summary
`--only`           | Run only the specified cop

## Configuration

The behavior of RuboCop can be controlled via the
[.rubocop.yml](https://github.com/bbatsov/rubocop/blob/master/.rubocop.yml)
configuration file. The file can be placed either in your home folder
or in some project folder.

RuboCop will start looking for the configuration file in the directory
where the inspected file is and continue its way up to the root folder.

The file has the following format:

```yaml
inherit_from: ../.rubocop.yml

Encoding:
  Enabled: true

LineLength:
  Enabled: true
  Max: 79
```

It allows to enable/disable certain cops (checks) and to alter their
behavior if they accept any parameters.

The optional `inherit_from` directive is used to include configuration
from one or more files. This makes it possible to have the common
project settings in the `.rubocop.yml` file at the project root, and
then only the deviations from those rules in the subdirectories. The
included files can be given with absolute paths or paths relative to
the file where they are referenced. The settings after an
`inherit_from` directive override any settings in the included
file(s). When multiple files are included, the first file in the list
has the lowest precedence and the last one has the highest. The format
for multiple inclusion is:

```yaml
inherit_from:
  - ../.rubocop.yml
  - ../conf/.rubocop.yml
```

### Defaults

The file `config/default.yml` under the RuboCop home directory
contains the default settings that all configurations inherit
from. Project and personal `.rubocop.yml` files need only make
settings that are different from the default ones. If there is no
`.rubocop.yml` file in the project or home direcotry,
`config/default.yml` will be used.

### Disabling Cops within Source Code

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

### Including/Excluding files

RuboCop checks all files recursively within the directory it is run
on.  However, it does not recognize some files as Ruby(only files
ending with `.rb` or extensionless files with a `#!.*ruby` declaration
are automatically detected) files, and if you'd like it to check these
you'll need to manually pass them in.  Files and directories can be
also be ignored through `.rubocop.yml`.

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

# other configuration
# ...
```

Note: Files and directories are specified relative to the `.rubocop.yml` file.

## Compatibility

Unfortunately every major Ruby implementation has its own code
analysis tooling, which makes the development of a portable code
analyzer a daunting task.

RuboCop currently supports MRI 1.9 and MRI 2.0. Support for JRuby and
Rubinius is not planned at this point.

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

### Sublime Text 2

If you're a ST2 user you might find the
[Sublime RuboCop plugin](https://github.com/pderichs/sublime_rubocop)
useful.

### Other Editors

Here's one great opportunity to contribute to RuboCop - implement
RuboCop integration for your favorite editor.

## Guard integration

If you're fond of [Guard](https://github.com/guard/guard) you might
like
[guard-rubocop](https://github.com/yujinakayama/guard-rubocop). It
allows you to automatically check Ruby code style with RuboCop when
files are modified.

## Contributors

Here's a [list](https://github.com/bbatsov/rubocop/contributors) of
all the people who have contributed to the development of RuboCop.

I'm extremely grateful to each and every one of them!

I'd like to single out [Jonas Arvidsson](https://github.com/jonas054)
for his many excellent code contributions as well as valuable feedback
and ideas!

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
