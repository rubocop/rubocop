# MagicComments

## MagicComments/Encoding

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks whether the source file has a utf-8 encoding
comment or not.
Setting this check to "always" and "when_needed" makes sense only
for code that should support Ruby 1.9, since in 2.0+ utf-8 is the
default source file encoding. There are three styles:

when_needed - only enforce an encoding comment if there are non ASCII
              characters, otherwise report an offense
always - enforce encoding comment in all files
never - enforce no encoding comment in all files

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | never
SupportedStyles | when_needed, always, never
AutoCorrectEncodingComment | # encoding: utf-8


### References

* [https://github.com/bbatsov/ruby-style-guide#utf-8](https://github.com/bbatsov/ruby-style-guide#utf-8)

## MagicComments/FrozenStringLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop is designed to help upgrade to Ruby 3.0. It will add the
comment `# frozen_string_literal: true` to the top of files to
enable frozen string literals. Frozen string literals will be default
in Ruby 3.0. The comment will be added below a shebang and encoding
comment. The frozen string literal comment is only valid in Ruby 2.3+.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | when_needed
SupportedStyles | when_needed, always, never

