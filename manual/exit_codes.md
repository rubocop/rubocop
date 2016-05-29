## Exit codes

RuboCop exits with the following status codes:

- 0 if no offenses are found, or if the severity of all offenses are less than
  `--fail-level`. (By default, if you use `--auto-correct`, offenses which are
  auto-corrected do not cause RuboCop to fail.)
- 1 if one or more offenses equal or greater to `--fail-level` are found. (By
  default, this is any offense which is not auto-corrected.)
- 2 if RuboCop terminates abnormally due to invalid configuration, invalid CLI
  options, or an internal error.
