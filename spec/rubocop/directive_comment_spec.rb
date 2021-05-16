# frozen_string_literal: true

RSpec.describe RuboCop::DirectiveComment do
  subject(:directive_comment) { described_class.new(comment) }

  let(:comment) { instance_double(Parser::Source::Comment, text: text) }
  let(:comment_cop_names) { 'all' }
  let(:text) { "#rubocop:enable #{comment_cop_names}" }

  describe '.before_comment' do
    subject { described_class.before_comment(text) }

    [
      ['when line has code', 'def foo # rubocop:disable all', 'def foo '],
      ['when line has NO code', '# rubocop:disable all', '']
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#match?' do
    subject(:match) { directive_comment.match?(cop_names) }

    let(:comment_cop_names) { 'Metrics/AbcSize, Metrics/PerceivedComplexity, Style/Not' }

    context 'no comment_cop_names' do
      let(:cop_names) { [] }

      it 'returns false' do
        expect(match).to eq(false)
      end
    end

    context 'same cop names as in the comment' do
      let(:cop_names) { %w[Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it 'returns true' do
        expect(match).to eq(true)
      end
    end

    context 'same cop names as in the comment in a different order' do
      let(:cop_names) { %w[Style/Not Metrics/AbcSize Metrics/PerceivedComplexity] }

      it 'returns true' do
        expect(match).to eq(true)
      end
    end

    context 'subset of names' do
      let(:cop_names) { %w[Metrics/AbcSize Style/Not] }

      it 'returns false' do
        expect(match).to eq(false)
      end
    end

    context 'superset of names' do
      let(:cop_names) { %w[Lint/Void Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it 'returns false' do
        expect(match).to eq(false)
      end
    end

    context 'duplicate names' do
      let(:cop_names) { %w[Metrics/AbcSize Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it 'returns true' do
        expect(match).to eq(true)
      end
    end

    context 'all' do
      let(:comment_cop_names) { 'all' }
      let(:cop_names) { %w[all] }

      it 'returns true' do
        expect(match).to eq(true)
      end
    end
  end

  describe '#match_captures' do
    subject { directive_comment.match_captures }

    [
      ['when disable', '# rubocop:disable all', ['disable', 'all', nil, nil]],
      ['when enable', '# rubocop:enable Foo/Bar', ['enable', 'Foo/Bar', nil, 'Foo/']],
      ['when todo', '# rubocop:todo all', ['todo', 'all', nil, nil]],
      ['when typo', '# rudocop:todo Dig/ThisMine', nil]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#single_line?' do
    subject { directive_comment.single_line? }

    [
      ['when relates to single line', 'def foo # rubocop:disable all', true],
      ['when does NOT relate to single line', '# rubocop:disable all', false]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#disabled?' do
    subject { directive_comment.disabled? }

    [
      ['when disable', '# rubocop:disable all', true],
      ['when enable', '# rubocop:enable Foo/Bar', false],
      ['when todo', '# rubocop:todo all', true]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#enabled?' do
    subject { directive_comment.enabled? }

    [
      ['when disable', '# rubocop:disable all', false],
      ['when enable', '# rubocop:enable Foo/Bar', true],
      ['when todo', '# rubocop:todo all', false]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#all_cops?' do
    subject { directive_comment.all_cops? }

    [
      ['when mentioned all', '# rubocop:disable all', true],
      ['when mentioned specific cops', '# rubocop:enable Foo/Bar', false]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#cop_names' do
    subject { directive_comment.cop_names }

    let(:all_cop_names) { %w[] }
    let(:department?) { false }
    let(:global) do
      instance_double(RuboCop::Cop::Registry, names: all_cop_names, department?: department?)
    end

    before { allow(RuboCop::Cop::Registry).to receive(:global).and_return(global) }

    context 'when only cop specified' do
      let(:comment_cop_names) { 'Foo/Bar' }

      it { is_expected.to eq %w[Foo/Bar] }
    end

    context 'when all cops mentioned' do
      let(:comment_cop_names) { 'all' }
      let(:all_cop_names) { %w[all_names Lint/RedundantCopDisableDirective] }

      it { is_expected.to eq %w[all_names] }
    end

    context 'when only department specified' do
      let(:comment_cop_names) { 'Foo' }
      let(:department?) { true }

      before do
        allow(global).to receive(:names_for_department).with('Foo').and_return(%w[Foo/Bar Foo/Baz])
      end

      it { is_expected.to eq %w[Foo/Bar Foo/Baz] }
    end

    context 'when couple departments specified' do
      let(:comment_cop_names) { 'Foo, Baz' }
      let(:department?) { true }

      before do
        allow(global).to receive(:names_for_department).with('Foo').and_return(%w[Foo/Bar Foo/Baz])
        allow(global).to receive(:names_for_department).with('Baz').and_return(%w[Baz/Bar])
      end

      it { is_expected.to eq %w[Foo/Bar Foo/Baz Baz/Bar] }
    end

    context 'when department and cops specified' do
      let(:comment_cop_names) { 'Foo, Baz/Cop' }

      before do
        allow(global).to receive(:department?).with('Foo').and_return(true)
        allow(global).to receive(:names_for_department).with('Foo').and_return(%w[Foo/Bar Foo/Baz])
      end

      it { is_expected.to eq %w[Foo/Bar Foo/Baz Baz/Cop] }
    end

    context 'when redundant directive cop department specified' do
      let(:comment_cop_names) { 'Lint' }
      let(:department?) { true }

      before do
        allow(global).to receive(:names_for_department)
          .with('Lint').and_return(%w[Lint/One Lint/Two Lint/RedundantCopDisableDirective])
      end

      it { is_expected.to eq %w[Lint/One Lint/Two] }
    end
  end

  describe '#department_names' do
    subject { directive_comment.department_names }

    let(:department?) { false }
    let(:global) { instance_double(RuboCop::Cop::Registry, department?: department?) }

    before { allow(RuboCop::Cop::Registry).to receive(:global).and_return(global) }

    context 'when only cop specified' do
      let(:comment_cop_names) { 'Foo/Bar' }

      it { is_expected.to eq [] }
    end

    context 'when all cops mentioned' do
      let(:comment_cop_names) { 'all' }

      it { is_expected.to eq [] }
    end

    context 'when only department specified' do
      let(:comment_cop_names) { 'Foo' }
      let(:department?) { true }

      it { is_expected.to eq %w[Foo] }
    end

    context 'when couple departments specified' do
      let(:comment_cop_names) { 'Foo, Baz' }
      let(:department?) { true }

      it { is_expected.to eq %w[Foo Baz] }
    end

    context 'when department and cops specified' do
      let(:comment_cop_names) { 'Foo, Baz/Cop' }

      before do
        allow(global).to receive(:department?).with('Foo').and_return(true)
      end

      it { is_expected.to eq %w[Foo] }
    end
  end

  describe '#line_number' do
    let(:comment) { instance_double(Parser::Source::Comment, text: text, loc: loc) }
    let(:loc) { instance_double(Parser::Source::Map, expression: expression) }
    let(:expression) { instance_double(Parser::Source::Range, line: 1) }

    it 'returns line number for directive' do
      expect(directive_comment.line_number).to be 1
    end
  end

  describe '#enabled_all?' do
    subject { directive_comment.enabled_all? }

    [
      ['when enabled all cops', 'def foo # rubocop:enable all', true],
      ['when enabled specific cops', '# rubocop:enable Foo/Bar', false],
      ['when disabled all cops', '# rubocop:disable all', false],
      ['when disabled specific cops', '# rubocop:disable Foo/Bar', false]
    ].each do |example|
      context example[0] do
        let(:text) { example[1] }

        it { is_expected.to eq example[2] }
      end
    end
  end

  describe '#disabled_all?' do
    subject { directive_comment.disabled_all? }

    context 'when enabled all cops' do
      let(:text) { 'def foo # rubocop:enable all' }

      it { is_expected.to eq false }
    end

    context 'when enabled specific cops' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to eq false }
    end

    context 'when disabled all cops' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to eq true }
    end

    context 'when disabled specific cops' do
      let(:text) { '# rubocop:disable Foo/Bar' }

      it { is_expected.to eq false }
    end
  end
end
