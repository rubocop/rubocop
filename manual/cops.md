## Cops

In RuboCop lingo the various checks performed on the code are called cops. There are several cop departments.

You can also load [custom cops](extensions.md#custom-cops).

### Style

Most of the cops in RuboCop are so called style cops that check for
stylistic problems in your code. Almost all of the them are based on
the Ruby Style Guide. Many of the style cops have configurations
options allowing them to support different popular coding
conventions.

### Lint

Lint cops check for possible errors and very bad practices in your
code. RuboCop implements in a portable way all built-in MRI lint
checks (`ruby -wc`) and adds a lot of extra lint checks of its
own. You can run only the lint cops like this:

```sh
$ rubocop -l
```

The `-l`/`--lint` option can be used together with `--only` to run all the
enabled lint cops plus a selection of other cops.

Disabling any of the lint cops is generally a bad idea.

### Metrics

Metrics cops deal with properties of the source code that can be measured,
such as class length, method length, etc. Generally speaking, they have a
configuration parameter called `Max` and when running
`rubocop --auto-gen-config`, this parameter will be set to the highest value
found for the inspected code.

### Performance

Performance cops catch Ruby idioms which are known to be slower than another
equivalent (and equally readable) idiom.

### Rails

Rails cops are specific to the Ruby on Rails framework. Unlike all
other cop types they are not used by default and you have to request
them specifically:

```sh
$ rubocop -R
```

or add the following directive to your `.rubocop.yml`:

```yaml
Rails:
  Enabled: true
```
