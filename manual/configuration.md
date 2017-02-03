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

RuboCop supports inheriting configuration from one or more supplemental
configuration files at runtime. Settings in the file that inherits
override settings in the file that's inherited from. Configuration
parameter that are hashes, for example `PreferredMethods` in
`Style/CollectionMethods` are merged with the same parameter in the base
configuration, while other parameter, such as `AllCops` / `Include`, are
simply replaced by the local setting. If arrays were merged, there would
be no way to remove elements through overriding them in local
configuration.

#### Inheriting from another configuration file in the project

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

### Inheriting configuration from a remote URL

The optional `inherit_from` directive can contain a full url to a remote
file. This makes it possible to have common project settings stored on a http
server and shared between many projects.

The remote config file is cached locally and is only updated if:

- The file does not exist.
- The file has not been updated in the last 24 hours.
- The remote copy has a newer modification time than the local copy.

You can inherit from both remote and local files in the same config and the
same inheritance rules apply to remote URLs and inheriting from local
files where the first file in the list has the lowest precedence and the
last one has the highest. The format for multiple inheritance using URLs is:

```yaml
inherit_from:
  - http://www.example.com/rubocop.yml
  - ../.rubocop.yml
```

#### Inheriting configuration from a dependency gem

The optional `inherit_gem` directive is used to include configuration from
one or more gems external to the current project. This makes it possible to
inherit a shared dependency's RuboCop configuration that can be used from
multiple disparate projects.

Configurations inherited in this way will be essentially *prepended* to the
`inherit_from` directive, such that the `inherit_gem` configurations will be
loaded first, then the `inherit_from` relative file paths will be loaded
(overriding the configurations from the gems), and finally the remaining
directives in the configuration file will supersede any of the inherited
configurations. This means the configurations inherited from one or more gems
have the lowest precedence of inheritance.

The directive should be formatted as a YAML Hash using the gem name as the
key and the relative path within the gem as the value:

```yaml
inherit_gem:
  my-shared-gem: .rubocop.yml
  cucumber: conf/rubocop.yml
```

An array can also be used as the value to include multiple configuration files
from a single gem:

```yaml
inherit_gem:
  my-shared-gem:
    - default.yml
    - strict.yml
```

**Note**: If the shared dependency is declared using a [Bundler](http://bundler.io/)
Gemfile and the gem was installed using `bundle install`, it would be
necessary to also invoke RuboCop using Bundler in order to find the
dependency's installation path at runtime:

```
$ bundle exec rubocop <options...>
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

In `.rubocop.yml` and any other configuration file beginning with `.rubocop`,
files and directories are specified relative to the directory where the
configuration file is. In configuration files that don't begin with `.rubocop`,
e.g. `our_company_defaults.yml`, paths are relative to the directory where
`rubocop` is run.

**Note**: Patterns that are just a file name, e.g. `Rakefile`, will match
that file name in any directory, but this pattern style is deprecated. The
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
Rails/HasAndBelongsToMany:
  Include:
    - app/models/*.rb
```

Cops can also exclude only specific sets of files when that's needed (for
instance you might want to run some cop only on a specific file). All cops support the
`Exclude` param.

```yaml
Rails/HasAndBelongsToMany:
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

Most cops are enabled by default. Some cops, configured in
[config/disabled.yml](https://github.com/bbatsov/rubocop/blob/master/config/disabled.yml),
are disabled by default. The cop enabling process can be altered by
setting `DisabledByDefault` or `EnabledByDefault` (but not both) to `true`.

```yaml
AllCops:
  DisabledByDefault: true
```

All cops are then disabled by default, and only cops appearing in user
configuration files are enabled. `Enabled: true` does not have to be
set for cops in user configuration. They will be enabled anyway.

```yaml
AllCops:
  EnabledByDefault: true
```

All cops are then enabled by default, and only cops explicitly disabled
using `Enabled: false` in user configuration files are enabled.

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

#### Details

Individual cops can be embellished with extra details in offense messages:

```yaml
Metrics/LineLength:
  Details: >-
    If lines are too short, text becomes hard to read because you must
    constantly jump from one line to the next while reading. If lines are too
    long, the line jumping becomes too hard because you "lose the line" while
    going back to the start of the next line.  80 characters is a good
    compromise.
```

#### AutoCorrect

Cops that support the `--auto-correct` option can have that support
disabled. For example:

```yaml
Style/PerlBackrefs:
  AutoCorrect: false
```

### Setting the target Ruby version

Some checks are dependent on the version of the Ruby interpreter which the
inspected code must run on. For example, using Ruby 2.0+ keyword arguments
rather than an options hash can help make your code shorter and more
expressive... _unless_ it must run on Ruby 1.9.

If `.ruby-version` exists in the directory RuboCop is invoked in, RuboCop
will use the version specified by it. Otherwise, users may let RuboCop
know the oldest version of Ruby which your project supports with:

```yaml
AllCops:
  TargetRubyVersion: 1.9
```

### Automatically Generated Configuration

If you have a code base with an overwhelming amount of offenses, it can
be a good idea to use `rubocop --auto-gen-config` and add an
`inherit_from: .rubocop_todo.yml` in your `.rubocop.yml`. The generated
file `.rubocop_todo.yml` contains configuration to disable cops that
currently detect an offense in the code by excluding the offending
files, or disabling the cop altogether once a file count limit has been
reached.

By adding the option `--exclude-limit COUNT`, e.g., `rubocop
--auto-gen-config --exclude-limit 5`, you can change how many files are
excluded before the cop is entirely disabled. The default COUNT is 15.

Then you can start removing the entries in the generated
`.rubocop_todo.yml` file one by one as you work through all the offenses
in the code.

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
