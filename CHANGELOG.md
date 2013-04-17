# Changelog

## master (unreleased)

### New features

* New cop `FavorSprintf` that checks for usages of `String#%`
* New cop `Semicolon` that checks for usages of `;` as expression separator
* New cop `VariableInterpolation` that checks for variable interpolation in double quoted strings
* New cop `Alias` that checks for uses of the keyword `alias`
* Automatically detect extensionless Ruby files with shebangs when search for Ruby source files in a directory

### Bugs fixed

* [#59](https://github.com/bbatsov/rubocop/issues/59) - Interpolated variables not enclosed in braces are not noticed
* [#42](https://github.com/bbatsov/rubocop/issues/42) - Received malformed format string ArgumentError from rubocop
