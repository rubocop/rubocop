# AI Agent Guide for RuboCop

RuboCop is a Ruby static code analyzer and formatter.
Before contributing, read [CONTRIBUTING.md](CONTRIBUTING.md) and the
[development docs](https://docs.rubocop.org/rubocop/development.html).

## Essential Commands

```bash
bundle exec rake              # Full CI: codespell + doc syntax check + specs + self-lint
bundle exec rake spec         # Run specs (Parser)
bundle exec rake prism_spec   # Run specs (Prism parser)
bundle exec rake internal_investigation  # RuboCop linting itself
bundle exec rubocop --only Department/CopName  # Lint with a single cop
```

Always run `bundle exec rake` before opening a PR.

## Project Layout

```
lib/rubocop/cop/<department>/<cop_name>.rb   # Cop source
spec/rubocop/cop/<department>/<cop_name>_spec.rb  # Cop spec
config/default.yml                           # Default configuration for every cop
changelog/                                   # Pending changelog entries (one per file)
lib/rubocop.rb                               # Require list (auto-updated by generator)
```

Departments: `Bundler`, `Gemspec`, `Layout`, `Lint`, `Metrics`, `Migration`,
`Naming`, `Security`, `Style`, `InternalAffairs`.

## Creating a New Cop

Scaffold:

```bash
bundle exec rake 'new_cop[Department/CopName]'
```

This generates the source file, spec file, `config/default.yml` entry, and
`require` in `lib/rubocop.rb`. After generation:

1. Update the description in `config/default.yml`.
2. Implement the cop.
3. Write specs.
4. Add a changelog entry: `bundle exec rake changelog:new`.

### Cop Class Structure

```ruby
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # One-line summary starting with a verb (e.g. "Checks for …", "Enforces …").
      # Additional detail paragraph(s) if needed.
      #
      # @safety
      #   Explain why autocorrect may be unsafe, or delete this section.
      #
      # @example
      #   # bad
      #   bad_code
      #
      #   # good
      #   good_code
      #
      class MyCop < Base
        extend AutoCorrector

        MSG = 'Use `#good_method` instead of `#bad_method`.'
        RESTRICT_ON_SEND = %i[bad_method].freeze

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          (send nil? :bad_method ...)
        PATTERN

        def on_send(node)
          return unless bad_method?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, 'good_method')
          end
        end
        alias on_csend on_send
      end
    end
  end
end
```

Key conventions:

- **`RESTRICT_ON_SEND`** — list method names so `on_send` is only called for
  those methods (performance optimization). Required when using `on_send`.
- **`alias on_csend on_send`** — handle safe navigation (`&.`). Add this
  whenever you define `on_send`, unless the cop explicitly does not apply to
  safe navigation.
- **`alias on_numblock on_block`** and **`alias on_itblock on_block`** — handle
  numbered-parameter blocks (`_1`) and `it`-blocks. Add these whenever you
  define `on_block`.
- **`extend AutoCorrector`** — declare this when the cop provides autocorrect.
- **`def_node_matcher`** / **`def_node_search`** — DSL for AST pattern matching.
  Document with a `@!method` YARD tag above each matcher.
- **YARD `@example`** — every cop must have at least one `# bad` / `# good`
  example pair. Examples must be **valid Ruby syntax** (the CI doc-syntax check
  parses them).
- **Cop description** — the first line of the YARD comment must be a complete
  sentence starting with a verb and ending with a period.

## Writing Specs

```ruby
# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MyCop, :config do
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      bad_method(foo)
      ^^^^^^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
    RUBY

    expect_correction(<<~RUBY)
      good_method(foo)
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      good_method(foo)
    RUBY
  end
end
```

- **`expect_offense`** — `^` carets mark the offense range and must align
  exactly under the offending code. The message follows the last caret.
- **`expect_correction`** — expected source after autocorrect. Must follow
  `expect_offense` in the same example.
- **`expect_no_offenses`** — assert no violations.
- Use `%{variable}` in `expect_offense` heredocs to interpolate dynamic values.
- Use `_{variable}` for offense-range placeholders.
- Use RSpec metadata tags like `:ruby27`, `:ruby34` to set the target Ruby
  version for a test.
- Configuration: `let(:cop_config) { { 'EnforcedStyle' => 'bar' } }`.

## Changelog Entries

Every user-visible change needs a changelog entry:

```bash
bundle exec rake changelog:fix    # Bug fix
bundle exec rake changelog:new    # New feature
bundle exec rake changelog:change # Changed behavior
```

Format (single line):

```
* [#123](https://github.com/rubocop/rubocop/issues/123): Description. ([@username][])
```

- Must end with `([@username][])`.
- `spec/project_spec.rb` validates the format in CI.
- Skip the changelog only for purely internal changes (refactors with no
  user-visible effect).

## PR and Commit Conventions

- Prefix commit messages with `[Fix #N]` when an issue exists.
- Squash related commits.
- Run `bundle exec rake` and ensure it passes before pushing.

## Common Mistakes

1. **Missing `alias on_csend on_send`** — cops that check `on_send` must also
   handle safe navigation unless explicitly inapplicable.
2. **Missing `alias on_numblock on_block` / `alias on_itblock on_block`** —
   cops that check `on_block` must also handle numbered-parameter and
   `it`-parameter block forms.
3. **Invalid Ruby in YARD examples** — the CI `documentation_syntax_check` task
   parses every `@example` block. Use only valid syntax.
4. **Cop description not a sentence** — must start with a verb and end with a
   period (e.g. `# Checks for ...`, not `# Check for ...`).
5. **Missing `RESTRICT_ON_SEND`** — always define this when using `on_send`.
6. **Missing `@!method` YARD tag** — every `def_node_matcher` /
   `def_node_search` needs a `@!method` tag above it.
7. **Forgetting changelog entry** — CI will flag it.
8. **Manually creating changelog files** — use the rake tasks instead to get
   the correct filename format.
9. **Missing `extend AutoCorrector`** — required if the cop provides a
   `corrector` block in `add_offense`.
10. **Not running full `bundle exec rake`** — partial test runs miss lint and
    doc-syntax failures.
11. **Hardcoding node types instead of using node pattern matchers** — prefer
    `def_node_matcher` over manual `node.type == :send` checks.
12. **Not testing both `send` and `csend`** — if you alias `on_csend`, write
    specs that cover the `&.` operator.
