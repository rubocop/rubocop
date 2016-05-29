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

```sh
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

```sh
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

```sh
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
This is inspired by the [Fuubar](https://github.com/thekompanee/fuubar) formatter for RSpec.

```sh
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

```sh
$ rubocop --format emacs test.rb
/Users/bozhidar/projects/test.rb:1:1: C: Use snake_case for methods and variables.
/Users/bozhidar/projects/test.rb:2:3: C: Favor modifier if/unless usage when you have a single-line body. Another good alternative is the usage of control flow &&/||.
/Users/bozhidar/projects/test.rb:4:5: W: end at 4, 4 is not aligned with if at 2, 2
```

### Simple Formatter

The name of the formatter says it all :-)

```sh
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

```sh
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

```sh
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

### Worst Offenders Formatter

Similar to the Offense Count formatter, but lists the files which need the most attention:

```sh
$ rubocop --format worst

89  this/file/is/really/bad.rb
2   much/better.rb
--
91  Total
```

### HTML Formatter

Useful for CI environments. It will create an HTML report like [this](http://f.cl.ly/items/0M3029412x3O091a1X1R/expected.html).

```sh
$ rubocop --format html -o rubocop.html
```
