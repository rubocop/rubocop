# frozen_string_literal: true

# Helpers for examples tagged with `:project_index`. The before hook skips the
# example when the project-index gem cannot be loaded for the current Ruby;
# the included module provides the tmpdir/Runner plumbing that exercises the
# full project-index flow against a fixture project.
module ProjectIndexSpecHelpers
  DEFAULT_ALL_COPS = {
    'NewCops' => 'disable',
    # tmpdirs on macOS live under `/var/folders/...` which traverses the
    # `/var` -> `/private/var` symlink. ResultCache otherwise warns on every
    # save. The test isn't exercising symlink protection.
    'AllowSymlinksInCacheRootDirectory' => true
  }.freeze

  def write_rubocop_config(tmpdir, config)
    merged = config.dup
    merged['AllCops'] = DEFAULT_ALL_COPS.merge(merged.fetch('AllCops', {}))
    File.write(File.join(tmpdir, '.rubocop.yml'), YAML.dump(merged))
  end

  def project_index_offenses(tmpdir, cache_root: nil, paths: nil)
    output_path = File.join(tmpdir, 'offenses.json')
    Dir.chdir(tmpdir) do
      config_store = RuboCop::ConfigStore.new
      config_store.options_config = File.join(tmpdir, '.rubocop.yml')
      options = project_index_runner_options(output_path, cache_root)
      RuboCop::Runner.new(options, config_store).run(paths || [tmpdir])
    end
    JSON.load_file(output_path).fetch('files').flat_map { |f| f['offenses'] }
  end

  private

  def project_index_runner_options(output_path, cache_root)
    options = { formatters: [['json', output_path]] }
    options[:cache] = cache_root ? 'true' : 'false'
    options[:cache_root] = cache_root if cache_root
    options
  end
end

RSpec.configure do |config|
  config.include ProjectIndexSpecHelpers, :project_index

  config.before(:each, :project_index) do
    unless RuboCop::ProjectIndexLoader.available?
      minimum = RuboCop::ProjectIndexLoader::MINIMUM_RUBY_VERSION
      reason = if RuboCop::ProjectIndexLoader.supported_ruby?
                 'rubydex gem is not installed.'
               else
                 "rubydex requires Ruby #{minimum} or later."
               end
      skip reason
    end
  end
end
