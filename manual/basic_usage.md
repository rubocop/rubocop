## Basic Usage

RuboCop has three primary uses:

1. Code style checker (a.k.a. linter)
1. A replacement for `ruby -w` (a subset of its linting capabilities)
1. Code formatter

In the next sections we'll briefly cover all of them.

### 1. Code style checker

Running `rubocop` with no arguments will check all Ruby source files
in the current directory:

```sh
$ rubocop
```

Alternatively you can pass `rubocop` a list of files and directories to check:

```sh
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

test.rb:1:1: C: Style/FrozenStringLiteralComment: Missing magic comment # frozen_string_literal: true.
def badName
^
test.rb:1:5: C: Naming/MethodName: Use snake_case for method names.
def badName
    ^^^^^^^
test.rb:2:3: C: Style/GuardClause: Use a guard clause instead of wrapping the code inside a conditional expression.
  if something
  ^^
test.rb:2:3: C: Style/IfUnlessModifier: Favor modifier if usage when having a single-line body. Another good alternative is the usage of control flow &&/||.
  if something
  ^^
test.rb:4:5: W: Layout/EndAlignment: end at 4, 4 is not aligned with if at 2, 2.
    end
    ^^^

1 file inspected, 5 offenses detected
```

#### Auto-correcting offenses

You can also run RuboCop in an auto-correct mode, where it will try to
automatically fix the problems it found in your code:

```sh
$ rubocop -a
```

See [Auto-correct](auto_correct.md).

### 2. RuboCop as a replacement for `ruby -w`

RuboCop natively implements almost all `ruby -w` lint warning checks, and then some. If you want you can use RuboCop
simply as a replacement for `ruby -w`:

```sh
$ rubocop -l
```

### 3. RuboCop as a formatter

There's a handy shortcut to run auto-correction only on code layout (a.k.a. formatting) offenses:

```sh
$ rubocop -x
```

This option was introduced in RuboCop 0.57.0.

## Command-line flags

For more details check the available command-line options:

```sh
$ rubocop -h
```

Command flag                    | Description
--------------------------------|------------------------------------------------------------
`-a/--auto-correct`             | Auto-correct certain offenses. *Experimental*, use with caution. See [Auto-correct](auto_correct.md).
`-c/--config`                   | Run with specified config file.
`-C/--cache`                    | Store and reuse results for faster operation.
`-d/--debug`                    | Displays some extra debug output.
`-D/--[no-]display-cop-names`   | Displays cop names in offense messages. Default is true.
`-E/--extra-details`            | Displays extra details in offense messages.
`-f/--format`                   | Choose a formatter, see [Formatters](formatters.md).
`-F/--fail-fast`                | Inspects in modification time order and stops after first file with offenses.
`-h/--help`                     | Print usage information.
`-l/--lint`                     | Run only lint cops.
`-L/--list-target-files`        | List all files RuboCop will inspect.
`-o/--out`                      | Write output to a file instead of STDOUT.
`-r/--require`                  | Require Ruby file (see [Loading Extensions](extensions.md#loading-extensions)).
`-R/--rails`                    | Run extra Rails cops.
`-s/--stdin`                    | Pipe source from STDIN. This is useful for editor integration. Takes one argument, a path, relative to the root of the project. RuboCop will use this path to determine which cops are enabled (via eg. Include/Exclude), and so that certain cops like Naming/FileName can be checked.
`-x/--fix-layout`               | Auto-correct only code layout (formatting) offenses.
`-v/--version`                  | Displays the current version and exits.
`-V/--verbose-version`          | Displays the current version plus the version of Parser and Ruby.
`--auto-gen-config`             | Generate a configuration file acting as a TODO list.
`--display-only-fail-level-offenses` | Only output offense messages at the specified `--fail-level` or above
`--except`                      | Run all cops enabled by configuration except the specified cop(s) and/or departments.
`--exclude-limit`               | Limit how many individual files `--auto-gen-config` can list in `Exclude` parameters, default is 15.
`--fail-level`                  | Minimum [severity](configuration.md#severity) for exit with error code. Full severity name or upper case initial can be given. Normally, auto-corrected offenses are ignored. Use `A` or `autocorrect` if you'd like them to trigger failure.
`--force-exclusion`             | Force excluding files specified in the configuration `Exclude` even if they are explicitly passed as arguments.
`--ignore-parent-exlusion`      | Ignores all Exclude: settings from all .rubocop.yml files present in parent folders. This is useful when you are importing submodules when you want to test them without being affected by the parent module's rubocop settings.
`--no-auto-gen-timestamp`       | Don't include the date and time when --auto-gen-config was run in the config file it generates
`--[no-]color`                  | Force color output on or off.
`--no-offense-counts`           | Don't show offense counts in config file generated by --auto-gen-config
`--only`                        | Run only the specified cop(s) and/or cops in the specified departments.
`--parallel`                    | Use available CPUs to execute inspection in parallel.
`--safe-auto-correct`           | Omit cops annotated as "not safe". See [Auto-correct](auto_correct.md).
`--show-cops`                   | Shows available cops and their configuration.

Default command-line options are loaded from `.rubocop` and `RUBOCOP_OPTS` and are combined with command-line options that are explicitly passed to `rubocop`.
Thus, the options have the following order of precedence (from highest to lowest):

1. Explicit command-line options
2. Options from `RUBOCOP_OPTS` environment variable
3. Options from `.rubocop` file.

## Exit codes

RuboCop exits with the following status codes:

- `0` if no offenses are found or if the severity of all offenses are less than
  `--fail-level`. (By default, if you use `--auto-correct`, offenses which are
  auto-corrected do not cause RuboCop to fail.)
- `1` if one or more offenses equal or greater to `--fail-level` are found. (By
  default, this is any offense which is not auto-corrected.)
- `2` if RuboCop terminates abnormally due to invalid configuration, invalid CLI
  options, or an internal error.
