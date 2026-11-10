# Cop usage analysis tools

Throwaway research scripts for answering a recurring question: *what do real
projects actually do with RuboCop's defaults?* They mine public GitHub data so
we can ground decisions about the shipped `config/default.yml` in observed usage
rather than gut feeling.

Both are standalone Ruby scripts (no extra dependencies beyond a checkout and the
`gh` CLI, which must be authenticated via `gh auth login`). Output lands under
`tmp/` (gitignored). Runs are cached and resumable; kill and restart any time.

## `cop_usage_corpus.rb`

The main tool. Downloads a fork-free sample of the most-starred Ruby repos,
parses every `.rubocop.yml` (resolving local `inherit_from` chains and popular
`inherit_gem` base configs), reads any `.rubocop_todo.yml`, and greps the source
for inline directives. For every cop it records each way it can be turned off
(global disable, pending, exclude, department disable, todo backlog, inline
disable/todo) plus every overridden parameter, all from the same denominator. The
report flags thresholds that look too strict and styles where the community has a
strong non-default consensus.

```bash
bundle exec ruby tools/cop_usage_corpus.rb --repos 500   # collect + report
bundle exec ruby tools/cop_usage_corpus.rb --report-only # re-render from cache
```

## `cop_disable_stats.rb`

A lighter companion that counts inline `# rubocop:disable`/`:todo` directives per
cop across *all* of public GitHub via the code search API (forks included). Good
for raw scale; the corpus tool merges its numbers in as an extra column.

```bash
bundle exec ruby tools/cop_disable_stats.rb              # collect + report
bundle exec ruby tools/cop_disable_stats.rb --report-only
```

## Caveats

A parameter shows up only when a project *explicitly sets it*, and setting a value
almost always means disagreeing with the default - happy users stay silent. So
the distributions show the direction and strength of divergence among opinionated
projects, not a true majority vote. Thresholds are the most reliable signal
(people only ever raise limits); style preferences are noisier. Treat the output
as a conversation starter, not a verdict.
