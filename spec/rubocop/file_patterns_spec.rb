# frozen_string_literal: true

# `be_match` here calls `FilePatterns#match?(path)`, which is unrelated to the
# RSpec-builtin `match` matcher (regex/pattern), so the predicate matcher is
# not redundant in this file.
# rubocop:disable RSpec/RedundantPredicateMatcher
RSpec.describe RuboCop::FilePatterns do
  describe '#match?' do
    let(:patterns) { ['lib/**/*.rb', 'README.md'] }
    let(:file_patterns) { described_class.new(patterns) }

    it 'matches exact-string patterns via the Set fast path' do
      expect(file_patterns).to be_match('README.md')
    end

    it 'matches glob patterns via fnmatch' do
      expect(file_patterns).to be_match('lib/foo/bar.rb')
    end

    it 'returns false when no pattern matches' do
      expect(file_patterns).not_to be_match('spec/foo_spec.rb')
    end

    it 'memoizes positive results per path' do
      expect(RuboCop::PathUtil).to receive(:match_path?).once.and_call_original
      2.times { file_patterns.match?('lib/foo.rb') }
    end

    it 'memoizes negative results per path' do
      expect(RuboCop::PathUtil).to receive(:match_path?).once.and_call_original
      2.times { file_patterns.match?('other/foo.rb') }
    end

    it 'caches independently per path' do
      expect(RuboCop::PathUtil).to receive(:match_path?).twice.and_call_original
      file_patterns.match?('lib/a.rb')
      file_patterns.match?('lib/b.rb')
    end
  end

  describe '.from' do
    it 'returns the same instance for the same patterns array (by identity)' do
      patterns = ['lib/**/*.rb']
      expect(described_class.from(patterns)).to equal(described_class.from(patterns))
    end

    it 'returns different instances for different patterns arrays' do
      lib = described_class.from(['lib/**/*.rb'])
      spec = described_class.from(['spec/**/*.rb'])
      expect(lib).not_to equal(spec)
    end

    it 'returns different instances when one patterns array is a subset of the other' do
      subset = described_class.from(['lib/**/*.rb'])
      superset = described_class.from(['lib/**/*.rb', 'spec/**/*.rb'])
      expect(subset).not_to equal(superset)
    end
  end
end
# rubocop:enable RSpec/RedundantPredicateMatcher
