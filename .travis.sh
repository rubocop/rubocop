#!/bin/bash

set -eo pipefail

run() {
  run_main_task
  documentation
  check_requiring_libraries
}

# Check requiring libraries successfully.
# See https://github.com/rubocop-hq/rubocop/pull/4523#issuecomment-309136113
check_requiring_libraries() {
  logged ruby -I lib -r rubocop -e 'exit 0'
}

# Running YARD under jruby crashes so skip checking the manual.
documentation() {
  if ! is_jruby; then
    logged bundle exec rake documentation_syntax_check generate_cops_documentation
  fi
}

is_jruby() {
  [ "$(ruby -e "puts RUBY_ENGINE == 'jruby'")" = 'true' ]
}

run_main_task() {
  logged bundle exec rake "$TASK"
}

logged() {
  echo "$ $*"
  time "$@"
}

is_test() {
  [ "$TASK" != 'internal_investigation' ]
}

run
