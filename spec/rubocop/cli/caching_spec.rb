# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI options', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  include_context 'cli spec behavior'

  let(:rubocop) { "#{RuboCop::ConfigLoader::RUBOCOP_HOME}/exe/rubocop" }
  let(:env) { '__RUBOCOP_ASSUME_WE_ARE_NOT_A_GEM=true' }

  describe 'creating and reusing cache' do
    def cache_dirs
      Dir["#{Dir.home}/.cache/rubocop_cache/*"].map { |path| File.basename(path) }.sort
    end

    let(:options) { '--only Style/StringLiterals' }
    let(:a_hash) { a_string_matching(/\A\h{40}\z/) }

    before do
      create_file('example.rb', '"hello"')
    end

    it 'creates two top level cache directories when run for the first time' do
      expect do
        `#{env} ruby -I . "#{rubocop}" #{options}`
      end.to change { cache_dirs }.from([]).to(an_array_matching(['server', a_hash]))
    end

    it 'does not create new top level cache directory when run 2nd time with the same environment' do
      `#{env} ruby -I . "#{rubocop}" #{options}`
      expect do
        `#{env} ruby -I . "#{rubocop}" #{options}`
      end.not_to change { cache_dirs } # no new cache entry, cache should be reused
    end
  end
end
