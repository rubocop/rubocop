## Versioning

RuboCop is stable between major versions, both in terms of API and cops.

New cops introduced between major versions are set to a special pending
status and are not enabled by default. A warning is emitted if such cops
and are not explicitly enabled or disabled in the user configuration.

On major version updates, pending cops are enabled in bulk.
