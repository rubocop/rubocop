# frozen_string_literal: true

RSpec.describe 'isolated environment', type: :feature do
  include_context 'cli spec behavior'

  let(:cli) { RuboCop::CLI.new }

  # Configuration files above the work directory shall not disturb the
  # tests. This is especially important on Windows where the temporary
  # directory is under the user's home directory. On any platform we don't want
  # a .rubocop.yml file in the temporary directory to affect the outcome of
  # rspec.
  #
  # For this test, we shift the root_level down to the work directory so we
  # can place a file above the root_level and ensure it is not loaded.
  it 'is not affected by a config file above the work directory', :isolated_environment do
    ignored_path = File.expand_path(File.join(RuboCop::FileFinder.root_level, '.rubocop.yml'))
    create_file(ignored_path, ['inherit_from: missing_file.yml'])

    RuboCop::FileFinder.root_level = File.join(RuboCop::FileFinder.root_level, 'work')

    create_file('ex.rb', ['# frozen_string_literal: true'])
    # A return value of 0 means that the erroneous config file was not read.
    expect(cli.run([])).to eq(0)
  end

  context 'bundler is isolated', :isolated_bundler, :isolated_environment do
    it 'has a Gemfile path in the temporary directory' do
      create_empty_file('Gemfile')
      expect(Bundler::SharedHelpers.root.to_s).to eq(Dir.pwd)
    end
  end

  # `XDG_CACHE_HOME` and `RUBOCOP_CACHE_ROOT` are set on some CI runners.
  # If the isolated environment left them in place, the result cache root would resolve to
  # a fixed directory shared across examples and parallel test-queue workers,
  # letting one example's cache leak into another and making cache-sensitive specs
  # (e.g. `--auto-gen-config`) intermittently fail. Each ambient value is set from
  # an outer `around` so it is in place before the isolated environment is entered,
  # and the assertion fails if the isolation stops stripping it.
  {
    'XDG_CACHE_HOME' => '/tmp/ambient-xdg-cache',
    'RUBOCOP_CACHE_ROOT' => '/tmp/ambient-rubocop-cache'
  }.each do |env_var, ambient_path|
    context "when #{env_var} is set in the ambient environment" do
      around do |example|
        original = ENV.fetch(env_var, nil)
        ENV[env_var] = ambient_path
        begin
          example.run
        ensure
          ENV[env_var] = original
        end
      end

      it 'resolves the cache root under the isolated home, not the ambient path', :isolated_environment do
        cache_root = RuboCop::CacheConfig.root_dir_from_toplevel_config

        expect(cache_root).to eq(File.join(File.realpath(Dir.home), '.cache', 'rubocop_cache'))
      end
    end
  end
end
