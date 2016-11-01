# Bundler

## Bundler/DuplicatedGem

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for duplicate gem entries in Gemfiles. Bundler currently
only prints a warning (unless there is a requirements conflict).

### Important attributes

Attribute | Value |
--- | --- |
Include | \*\*/Gemfile, \*\*/gems.rb |
