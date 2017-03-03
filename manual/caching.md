## Caching

Large projects containing hundreds or even thousands of files can take
a really long time to inspect, but RuboCop has functionality to
mitigate this problem. There's a caching mechanism that stores
information about offenses found in inspected files.

### Cache Validity

Later runs will be able to retrieve this information and present the
stored information instead of inspecting the file again. This will be
done if the cache for the file is still valid, which it is if there
are no changes in:

* the contents of the inspected file
* RuboCop configuration for the file
* the options given to `rubocop`, with some exceptions that have no
  bearing on which offenses are reported
* the Ruby version used to invoke `rubocop`
* version of the `rubocop` program (or to be precise, anything in the
  source code of the invoked `rubocop` program)

### Enabling and Disabling the Cache

The caching functionality is enabled if the configuration parameter
`AllCops: UseCache` is `true`, which it is by default. The command
line option `--cache false` can be used to turn off caching, thus
overriding the configuration parameter. If `AllCops: UseCache` is set
to `false` in the local `.rubocop.yml`, then it's `--cache true` that
overrides the setting.

### Cache Path

By default, the cache is stored in a subdirectory of the temporary
directory, `/tmp/rubocop_cache/` on Unix-like systems. The
configuration parameter `AllCops: CacheRootDirectory` can be used to
set it to a different path. One reason to use this option could be
that there's a network disk where users on different machines want to
have a common RuboCop cache. Another could be that a Continuous
Integration system allows directories, but not a temporary directory,
to be saved between runs.

### Cache Pruning

Each time a file has changed, its offenses will be stored under a new
key in the cache. This means that the cache will continue to grow
until we do something to stop it. The configuration parameter
`AllCops: MaxFilesInCache` sets a limit, and when the number of files
in the cache exceeds that limit, the oldest files will be automatically
removed from the cache.
