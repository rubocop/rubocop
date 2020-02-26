## Versioning

RuboCop is stable between major versions, both in terms of API and cops.

New cops introduced between major versions are set to a special pending
status and are not enabled by default. A warning is emitted if such cops
are not explicitly enabled or disabled in the user configuration.
Please set `Enabled` to either `true` or `false` in your `.rubocop.yml` file.

`Style/ANewCop` is an example of a newly added pending cop:

```yaml
Style/ANewCop:
  Enabled: true
```

or

```yaml
Style/ANewCop:
  Enabled: false
```

On major version updates, pending cops are enabled in bulk.
