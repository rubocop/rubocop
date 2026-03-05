# Presets Design Exploration

## The Problem

RuboCop ships 400+ cops enabled by default, which overwhelms new users and
generates hundreds of offenses on first run. The `pending` mechanism defers
enablement decisions but creates a growing backlog (currently 148 cops). Users
want to pick a level of enforcement that matches their project's needs without
manually configuring hundreds of cops.

Related: #14005, #10726, #12582, #14913.

## Naming

The feature needs a name that fits RuboCop's police theme. Options:

| Name | Metaphor | Usage example | Pros | Cons |
|------|----------|---------------|------|------|
| **Preset** | Generic | `preset: standard` | Familiar, self-explanatory | Boring, no theme |
| **Patrol** | Police patrol levels | `patrol: highway` | Fun, maps well to strictness tiers | Slightly whimsical |
| **Directive** | Police directive/order | `directive: standard` | Authoritative feel | Suggested in #14005 already |
| **Detail** | Police detail/assignment | `detail: standard` | Professional tone | Less intuitive |
| **Protocol** | Enforcement protocol | `protocol: standard` | Fits well, serious tone | Slightly clinical |
| **Precinct** | Police precinct | `precinct: downtown` | Fun organizational metaphor | Naming the levels gets weird |
| **Rank** | Officer ranks | `rank: sergeant` | Built-in hierarchy (cadet < officer < sergeant < captain) | Implies the user is "less" at lower levels |
| **Code** | Police codes (10-codes) | `code: ten-four` | Very on-theme | Confusingly overloaded with "source code" |
| **Beat** | Police beat (patrol area) | `beat: standard` | Simple, on-theme | Less obvious meaning |

**Recommendation:** "Patrol" strikes a nice balance between thematic and
understandable. The levels map naturally to police patrol types:

- `community` — light touch, only essential checks (bugs, security, syntax)
- `beat` — standard patrol, the recommended default for most projects
- `highway` — stricter enforcement, style guide compliance
- `tactical` — maximum enforcement, all cops enabled

Alternative: stick with the neutral "preset" and use thematic level names.

## Proposed Levels

Regardless of naming, we need to define what each level contains:

### Level 1: Essential / Community

Cops that catch real bugs, security issues, and broken code. Nobody would
disagree with these. Think: "if this cop fires, you almost certainly have a
problem."

- All `Lint/` cops (except highly opinionated ones like `Lint/EmptyBlock`)
- All `Security/` cops
- `Bundler/` and `Gemspec/` cops that catch deprecated/broken usage
- Critical `Style/` cops that prevent bugs (e.g., `Style/MutableConstant`)
- No layout or formatting cops
- ~150 cops

### Level 2: Standard / Beat (recommended default)

The "sensible defaults" level. Adds widely-accepted style and naming
conventions that most Ruby developers agree on. This is what new projects
should start with.

- Everything in Level 1
- Layout cops for consistent formatting (indentation, spacing, blank lines)
- Non-controversial `Style/` cops (`Style/StringLiterals`, `Style/FrozenStringLiteralComment`, etc.)
- Non-controversial `Naming/` cops
- Non-controversial `Metrics/` cops (reasonable method length, etc.)
- ~300 cops

### Level 3: Strict / Highway

Full Ruby Style Guide compliance. Adds opinionated cops that enforce the
community style guide comprehensively.

- Everything in Level 2
- Opinionated `Style/` cops (`Style/Documentation`, `Style/EndlessMethod`, etc.)
- Stricter `Metrics/` thresholds
- All pending cops that are ready for general use
- ~380 cops

### Level 4: Maximum / Tactical

Everything enabled. For teams that want maximum enforcement.

- All cops enabled
- Equivalent to current `AllCops: NewCops: enable` + `AllCops: DisabledByDefault: false`
- ~450+ cops

## Implementation Approaches

### Approach A: Cop-level metadata (tag each cop with its preset level)

Add a `Preset` field to each cop in `config/default.yml`:

```yaml
Style/FrozenStringLiteralComment:
  Enabled: true
  Preset: essential
  Description: '...'

Style/Documentation:
  Enabled: true
  Preset: strict
  Description: '...'
```

Usage in `.rubocop.yml`:

```yaml
AllCops:
  Preset: standard   # enable all cops at "standard" level and below
```

**Pros:**
- Single source of truth — each cop declares its level
- Simple mental model: `Preset: standard` means "enable everything at standard and below"
- Easy to query: `rubocop --list-cops --preset essential`
- Eliminates the `pending` state — new cops get a preset level immediately
- Clean merge semantics: user can override individual cops after choosing a preset
- No new files to maintain

**Cons:**
- Requires adding metadata to all 450+ cops in `config/default.yml`
- Preset level for each cop is a subjective decision that may generate debate
- Tightly couples cop definitions to preset classification
- Harder for extension gems to participate (they'd need to tag their cops too)

**Implementation:**
- Add `Preset` field to cop metadata in `config/default.yml`
- Define preset hierarchy in `ConfigLoader` (`essential < standard < strict < all`)
- In `Config#cop_enabled?`, check cop's preset against the configured level
- Pending cops become cops with a preset level but `Enabled: pending` goes away

### Approach B: Standalone preset config files

Ship preset configs as YAML files in `config/presets/`:

```
config/presets/essential.yml
config/presets/standard.yml
config/presets/strict.yml
config/presets/all.yml
```

Each file inherits from the level below and adds cops:

```yaml
# config/presets/standard.yml
inherit_from: essential.yml

Style/StringLiterals:
  Enabled: true
Layout/IndentationWidth:
  Enabled: true
# ... etc
```

Usage in `.rubocop.yml`:

```yaml
inherit_preset: standard

# User overrides:
Style/Documentation:
  Enabled: false
```

**Pros:**
- Uses existing inheritance machinery (`inherit_from` under the hood)
- Preset definitions are easy to read and diff
- Extension gems can ship their own preset files
- Users can create custom presets by inheriting from built-in ones
- No changes to cop metadata format

**Cons:**
- Multiple files to maintain, with cop lists that must stay in sync with `default.yml`
- Adding a new cop requires editing both `default.yml` and a preset file
- Merge order complexity: how does `inherit_preset` interact with `inherit_from`?
- `DisabledByDefault` interaction needs careful thought
- Risk of preset files drifting out of sync

**Implementation:**
- Add `inherit_preset` key to config format
- Resolve it early in `ConfigLoader`, before `inherit_from`
- Preset files use `DisabledByDefault: true` + explicitly enable their cops
- Each preset inherits from the one below it
- User config merges on top as usual

### Approach C: Hybrid — metadata + generated preset files

Tag cops with preset levels in `default.yml` (like Approach A), but also
generate standalone preset YAML files from those tags (for transparency and
for extension gems to reference).

```yaml
# config/default.yml
Style/FrozenStringLiteralComment:
  Enabled: true
  Preset: essential
```

A rake task generates:

```yaml
# config/presets/essential.yml (auto-generated, do not edit)
# Contains all cops tagged Preset: essential or lower
```

Usage: same as Approach A (`AllCops: Preset: standard`) or Approach B
(`inherit_preset: standard`), or both.

**Pros:**
- Single source of truth (cop metadata) with generated artifacts for transparency
- Combines the simplicity of A with the composability of B
- Generated files can be inspected, diffed, and used by extension gems
- Rake task catches drift automatically

**Cons:**
- Build step required (generated files must be kept up to date)
- Two representations of the same data (even if one is auto-generated)
- More complex than either A or B alone

### Approach D: Convention-based (departments as presets)

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

**Verdict:** Not recommended. Departments and presets are orthogonal concepts.

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
| Custom user presets | No | Yes | Yes | No |

## Recommendation

**Approach A (cop-level metadata)** is the simplest and cleanest for RuboCop's
core. It has a single source of truth, a clear mental model, and eliminates the
`pending` state entirely. The main downside — extension gem support — can be
addressed by having extension gems also tag their cops with `Preset` levels.

If custom user presets are a priority, **Approach C (hybrid)** gives the best
of both worlds at the cost of a build step.

**Approach B (standalone files)** is the most flexible but introduces
maintenance burden and drift risk that we've seen cause problems in other
projects.

## Open Questions

1. **Should presets replace `pending` entirely?** New cops could be assigned a
   preset level immediately. If your configured preset includes that level,
   you get the cop. No more "pending" state.

2. **How do presets interact with `NewCops: enable/disable`?** Probably:
   `NewCops` becomes irrelevant if presets replace pending. Or `NewCops` only
   applies to cops above your preset level.

3. **Can users define custom presets?** Approach A says no (but you can still
   override individual cops). Approach B/C say yes.

4. **Should the default change?** Currently RuboCop enables almost everything
   by default. With presets, the default could be `standard` instead of `all`,
   which would be a major improvement for new users but a breaking change for
   existing ones.

5. **How do extension gems participate?** They'd need to tag their cops with
   preset levels too. We'd need to define guidelines and possibly validate
   that extension cops have valid preset tags.

6. **What about `DisabledByDefault` / `EnabledByDefault`?** These global
   switches would need clear interaction semantics with presets. Probably:
   preset overrides these settings.

7. **Naming the levels.** The police-themed names are fun but need to be
   immediately understandable. A compromise: use descriptive names with
   optional aliases (`essential`, `standard`, `strict`, `all`).
