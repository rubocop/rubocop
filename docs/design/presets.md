# Enforcement Levels — Design Exploration

## The Problem

RuboCop ships 400+ cops enabled by default, which overwhelms new users and
generates hundreds of offenses on first run. The `pending` mechanism defers
enablement decisions but creates a growing backlog (currently 148 cops). Users
want to pick a level of enforcement that matches their project's needs without
manually configuring hundreds of cops.

Related: #14005, #10726, #12582, #14913.

## Naming

We considered many police-themed alternatives (patrol, directive, protocol,
jurisdiction, squad, dispatch, etc.) and settled on **enforcement** — it's
self-documenting, on-theme, and requires no explanation.

Usage:

```yaml
AllCops:
  Enforcement: standard
```

## Enforcement Levels

### Level 1: `essential`

Cops that catch real bugs, security issues, and broken code. Nobody would
disagree with these. Think: "if this cop fires, you almost certainly have a
problem."

- All `Lint/` cops (except highly opinionated ones like `Lint/EmptyBlock`)
- All `Security/` cops
- `Bundler/` and `Gemspec/` cops that catch deprecated/broken usage
- Critical `Style/` cops that prevent bugs (e.g., `Style/MutableConstant`)
- No layout or formatting cops
- ~150 cops

### Level 2: `standard` (recommended default)

The "sensible defaults" level. Adds widely-accepted style and naming
conventions that most Ruby developers agree on. This is what new projects
should start with.

- Everything in `essential`
- Layout cops for consistent formatting (indentation, spacing, blank lines)
- Non-controversial `Style/` cops (`Style/StringLiterals`, `Style/FrozenStringLiteralComment`, etc.)
- Non-controversial `Naming/` cops
- Non-controversial `Metrics/` cops (reasonable method length, etc.)
- ~300 cops

### Level 3: `strict`

Full Ruby Style Guide compliance. Adds opinionated cops that enforce the
community style guide comprehensively.

- Everything in `standard`
- Opinionated `Style/` cops (`Style/Documentation`, `Style/EndlessMethod`, etc.)
- Stricter `Metrics/` thresholds
- All pending cops that are ready for general use
- ~380 cops

### Level 4: `all`

Everything enabled. For teams that want maximum enforcement.

- All cops enabled
- Equivalent to current `AllCops: NewCops: enable` + `AllCops: DisabledByDefault: false`
- ~450+ cops

## Implementation Approaches

### Approach A: Cop-level metadata (tag each cop with its enforcement level)

Add an `Enforcement` field to each cop in `config/default.yml`:

```yaml
Style/FrozenStringLiteralComment:
  Enabled: true
  Enforcement: essential
  Description: '...'

Style/Documentation:
  Enabled: true
  Enforcement: strict
  Description: '...'
```

Usage in `.rubocop.yml`:

```yaml
AllCops:
  Enforcement: standard   # enable all cops at "standard" level and below
```

**Pros:**
- Single source of truth — each cop declares its level
- Simple mental model: `Enforcement: standard` means "enable everything at standard and below"
- Easy to query: `rubocop --list-cops --enforcement essential`
- Eliminates the `pending` state — new cops get an enforcement level immediately
- Clean merge semantics: user can override individual cops after choosing a level
- No new files to maintain

**Cons:**
- Requires adding metadata to all 450+ cops in `config/default.yml`
- Enforcement level for each cop is a subjective decision that may generate debate
- Tightly couples cop definitions to enforcement classification
- Harder for extension gems to participate (they'd need to tag their cops too)

**Implementation:**
- Add `Enforcement` field to cop metadata in `config/default.yml`
- Define level hierarchy in `ConfigLoader` (`essential < standard < strict < all`)
- In `Config#cop_enabled?`, check cop's enforcement level against the configured level
- Pending cops become cops with an enforcement level — `Enabled: pending` goes away

### Approach B: Standalone enforcement config files

Ship enforcement level configs as YAML files in `config/enforcement/`:

```
config/enforcement/essential.yml
config/enforcement/standard.yml
config/enforcement/strict.yml
config/enforcement/all.yml
```

Each file inherits from the level below and adds cops:

```yaml
# config/enforcement/standard.yml
inherit_from: essential.yml

Style/StringLiterals:
  Enabled: true
Layout/IndentationWidth:
  Enabled: true
# ... etc
```

Usage in `.rubocop.yml`:

```yaml
AllCops:
  Enforcement: standard

# User overrides:
Style/Documentation:
  Enabled: false
```

**Pros:**
- Uses existing inheritance machinery (`inherit_from` under the hood)
- Level definitions are easy to read and diff
- Extension gems can ship their own enforcement level files
- Users can create custom levels by inheriting from built-in ones
- No changes to cop metadata format

**Cons:**
- Multiple files to maintain, with cop lists that must stay in sync with `default.yml`
- Adding a new cop requires editing both `default.yml` and an enforcement file
- Merge order complexity: how does `Enforcement` interact with `inherit_from`?
- `DisabledByDefault` interaction needs careful thought
- Risk of enforcement files drifting out of sync

**Implementation:**
- Add `AllCops: Enforcement` key to config format
- Resolve it early in `ConfigLoader`, before `inherit_from`
- Enforcement files use `DisabledByDefault: true` + explicitly enable their cops
- Each level inherits from the one below it
- User config merges on top as usual

### Approach C: Hybrid — metadata + generated enforcement files

Tag cops with enforcement levels in `default.yml` (like Approach A), but also
generate standalone YAML files from those tags (for transparency and for
extension gems to reference).

```yaml
# config/default.yml
Style/FrozenStringLiteralComment:
  Enabled: true
  Enforcement: essential
```

A rake task generates:

```yaml
# config/enforcement/essential.yml (auto-generated, do not edit)
# Contains all cops tagged Enforcement: essential or lower
```

Usage: same as Approach A (`AllCops: Enforcement: standard`).

**Pros:**
- Single source of truth (cop metadata) with generated artifacts for transparency
- Combines the simplicity of A with the composability of B
- Generated files can be inspected, diffed, and used by extension gems
- Rake task catches drift automatically

**Cons:**
- Build step required (generated files must be kept up to date)
- Two representations of the same data (even if one is auto-generated)
- More complex than either A or B alone

### Approach D: Convention-based (departments as enforcement levels)

Instead of a new mechanism, reorganize cops into departments that map to
strictness levels. For example, move bug-catching cops to `Lint/`, rename
`Style/` to only contain the standard-tier cops, and create a new
`StyleGuide/` department for the strict tier.

**Pros:**
- No new config machinery needed
- Uses existing department enable/disable (`Style: { Enabled: false }`)

**Cons:**
- Massive breaking change (renaming hundreds of cops)
- Departments serve a different purpose (categorization by _type_, not _strictness_)
- Many cops don't fit neatly into one strictness level
- Essentially a non-starter for existing users

**Verdict:** Not recommended. Departments and enforcement levels are orthogonal
concepts.

## Comparison Matrix

| Criteria | A (metadata) | B (files) | C (hybrid) | D (departments) |
|----------|:---:|:---:|:---:|:---:|
| Single source of truth | Yes | No | Yes | N/A |
| No new files to maintain | Yes | No | Partial | Yes |
| Extension gem support | Medium | Good | Good | Poor |
| Uses existing config machinery | No | Yes | Partial | Yes |
| Simple mental model | Yes | Yes | Medium | Yes |
| Migration effort | Medium | Medium | High | Very High |
| Risk of drift | None | High | Low | None |
| Custom user levels | No | Yes | Yes | No |

## Recommendation

**Approach A (cop-level metadata)** is the simplest and cleanest for RuboCop's
core. It has a single source of truth, a clear mental model, and eliminates the
`pending` state entirely. The main downside — extension gem support — can be
addressed by having extension gems also tag their cops with enforcement levels.

If custom user levels are a priority, **Approach C (hybrid)** gives the best
of both worlds at the cost of a build step.

**Approach B (standalone files)** is the most flexible but introduces
maintenance burden and drift risk that we've seen cause problems in other
projects.

## Open Questions

1. **Should enforcement levels replace `pending` entirely?** New cops could be
   assigned an enforcement level immediately. If your configured level includes
   it, you get the cop. No more "pending" state.

2. **How do enforcement levels interact with `NewCops: enable/disable`?**
   Probably: `NewCops` becomes irrelevant if enforcement levels replace
   pending. Or `NewCops` only applies to cops above your configured level.

3. **Can users define custom enforcement levels?** Approach A says no (but you
   can still override individual cops). Approach B/C say yes.

4. **Should the default change?** Currently RuboCop enables almost everything
   by default. With enforcement levels, the default could be `standard` instead
   of `all`, which would be a major improvement for new users but a breaking
   change for existing ones.

5. **How do extension gems participate?** They'd need to tag their cops with
   enforcement levels too. We'd need to define guidelines and possibly validate
   that extension cops have valid levels.

6. **What about `DisabledByDefault` / `EnabledByDefault`?** These global
   switches would need clear interaction semantics with enforcement levels.
   Probably: enforcement level overrides these settings.

7. **CLI support.** Should `rubocop --enforcement essential` work as a one-off
   override? Useful for CI pipelines that want different levels for different
   stages (e.g., `essential` for PRs, `strict` for main branch).

8. **Migration path.** For 2.0, we could:
   - Default `Enforcement` to `standard` (breaking change, but the whole point)
   - Provide `rubocop --init` that generates `.rubocop.yml` with `Enforcement: all`
     for teams that want the current behavior
   - Print a one-time migration notice explaining the change
