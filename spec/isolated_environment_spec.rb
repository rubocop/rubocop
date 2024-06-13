# frozen_string_literal: true

RSpec.describe 'isolated environment', :isolated_environment, type: :feature do
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
  it 'is not affected by a config file above the work directory' do
    ignored_path = File.expand_path(File.join(RuboCop::FileFinder.root_level, '.rubocop.yml'))
    create_file(ignored_path, ['inherit_from: missing_file.yml'])

    RuboCop::FileFinder.root_level = File.join(RuboCop::FileFinder.root_level, 'work')

    create_file('ex.rb', ['# frozen_string_literal: true'])
    # A return value of 0 means that the erroneous config file was not read.
    expect(cli.run([])).to eq(0)
  end

  context 'bundler is isolated', :isolated_bundler do
    it 'has a Gemfile path in the temporary directory' do
      create_empty_file('Gemfile')
      expect(Bundler::SharedHelpers.root.to_s).to eq(Dir.pwd)
    end
  end
end
