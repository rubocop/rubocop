# frozen_string_literal: true

RSpec.describe RuboCop::DirectiveComment do
  let(:directive_comment) { described_class.new(comment, cop_registry) }
  let(:comment) { instance_double(Parser::Source::Comment, text: text) }
  let(:cop_registry) do
    instance_double(RuboCop::Cop::Registry, names: all_cop_names, department?: department?)
  end
  let(:text) { '#rubocop:enable all' }
  let(:all_cop_names) { %w[] }
  let(:department?) { false }

  describe '.before_comment' do
    subject { described_class.before_comment(text) }

    context 'when line has code' do
      let(:text) { 'def foo # rubocop:disable all' }

      it { is_expected.to eq('def foo ') }
    end

    context 'when line has NO code' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to eq('') }
    end
  end

  describe '#match?' do
    subject { directive_comment.match?(cop_names) }

    let(:text) { '#rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Style/Not' }

    context 'when there are no cop names' do
      let(:cop_names) { [] }

      it { is_expected.to be(false) }
    end

    context 'when cop names are same as in the comment' do
      let(:cop_names) { %w[Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it { is_expected.to be(true) }
    end

    context 'when cop names are same but in a different order' do
      let(:cop_names) { %w[Style/Not Metrics/AbcSize Metrics/PerceivedComplexity] }

      it { is_expected.to be(true) }
    end

    context 'when cop names are subset of names' do
      let(:cop_names) { %w[Metrics/AbcSize Style/Not] }

      it { is_expected.to be(false) }
    end

    context 'when cop names are superset of names' do
      let(:cop_names) { %w[Lint/Void Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it { is_expected.to be(false) }
    end

    context 'when cop names are same but have duplicated names' do
      let(:cop_names) { %w[Metrics/AbcSize Metrics/AbcSize Metrics/PerceivedComplexity Style/Not] }

      it { is_expected.to be(true) }
    end

    context 'when disabled all cops' do
      let(:text) { '#rubocop:enable all' }
      let(:cop_names) { %w[all] }

      it { is_expected.to be(true) }
    end
  end

  describe '#match_captures' do
    subject { directive_comment.match_captures }

    context 'when disable' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to eq(%w[disable all]) }
    end

    context 'when enable' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to eq(['enable', 'Foo/Bar']) }
    end

    context 'when todo' do
      let(:text) { '# rubocop:todo all' }

      it { is_expected.to eq(%w[todo all]) }
    end

    context 'when typo' do
      let(:text) { '# rudocop:todo Dig/ThisMine' }

      it { is_expected.to be_nil }
    end
  end

  describe '#single_line?' do
    subject { directive_comment.single_line? }

    context 'when relates to single line' do
      let(:text) { 'def foo # rubocop:disable all' }

      it { is_expected.to be(true) }
    end

    context 'when does NOT relate to single line' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(false) }
    end
  end

  describe '#disabled?' do
    subject { directive_comment.disabled? }

    context 'when disable' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(true) }
    end

    context 'when enable' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end

    context 'when todo' do
      let(:text) { '# rubocop:todo all' }

      it { is_expected.to be(true) }
    end
  end

  describe '#enabled?' do
    subject { directive_comment.enabled? }

    context 'when disable' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(false) }
    end

    context 'when enable' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(true) }
    end

    context 'when todo' do
      let(:text) { '# rubocop:todo all' }

      it { is_expected.to be(false) }
    end
  end

  describe '#all_cops?' do
    subject { directive_comment.all_cops? }

    context 'when mentioned all' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(true) }
    end

    context 'when mentioned specific cops' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end
  end

  describe '#cop_names' do
    subject { directive_comment.cop_names }

    context 'when only cop specified' do
      let(:text) { '#rubocop:enable Foo/Bar' }

      it { is_expected.to eq(%w[Foo/Bar]) }
    end

    context 'when all cops mentioned' do
      let(:text) { '#rubocop:enable all' }
      let(:all_cop_names) { %w[all_names Lint/RedundantCopDisableDirective] }

      it { is_expected.to eq(%w[all_names]) }
    end

    context 'when only department specified' do
      let(:text) { '#rubocop:enable Foo' }
      let(:department?) { true }

      before do
        allow(cop_registry).to receive(:names_for_department)
          .with('Foo').and_return(%w[Foo/Bar Foo/Baz])
      end

      it { is_expected.to eq(%w[Foo/Bar Foo/Baz]) }
    end

    context 'when couple departments specified' do
      let(:text) { '#rubocop:enable Foo, Baz' }
      let(:department?) { true }

      before do
        allow(cop_registry).to receive(:names_for_department).with('Baz').and_return(%w[Baz/Bar])
        allow(cop_registry).to receive(:names_for_department)
          .with('Foo').and_return(%w[Foo/Bar Foo/Baz])
      end

      it { is_expected.to eq(%w[Foo/Bar Foo/Baz Baz/Bar]) }
    end

    context 'when department and cops specified' do
      let(:text) { '#rubocop:enable Foo, Baz/Cop' }

      before do
        allow(cop_registry).to receive(:department?).with('Foo').and_return(true)
        allow(cop_registry).to receive(:names_for_department)
          .with('Foo').and_return(%w[Foo/Bar Foo/Baz])
      end

      it { is_expected.to eq(%w[Foo/Bar Foo/Baz Baz/Cop]) }
    end

    context 'when redundant directive cop department specified' do
      let(:text) { '#rubocop:enable Lint' }
      let(:department?) { true }

      before do
        allow(cop_registry).to receive(:names_for_department)
          .with('Lint').and_return(%w[Lint/One Lint/Two Lint/RedundantCopDisableDirective])
      end

      it { is_expected.to eq(%w[Lint/One Lint/Two]) }
    end
  end

  describe '#department_names' do
    subject { directive_comment.department_names }

    context 'when only cop specified' do
      let(:text) { '#rubocop:enable Foo/Bar' }

      it { is_expected.to eq([]) }
    end

    context 'when all cops mentioned' do
      let(:text) { '#rubocop:enable all' }

      it { is_expected.to eq([]) }
    end

    context 'when only department specified' do
      let(:text) { '#rubocop:enable Foo' }
      let(:department?) { true }

      it { is_expected.to eq(%w[Foo]) }
    end

    context 'when couple departments specified' do
      let(:text) { '#rubocop:enable Foo, Baz' }
      let(:department?) { true }

      it { is_expected.to eq(%w[Foo Baz]) }
    end

    context 'when department and cops specified' do
      let(:text) { '#rubocop:enable Foo, Baz/Cop' }

      before do
        allow(cop_registry).to receive(:department?).with('Foo').and_return(true)
      end

      it { is_expected.to eq(%w[Foo]) }
    end
  end

  describe '#line_number' do
    let(:source_range) do
      instance_double(Parser::Source::Range, line: 1)
    end

    before { allow(comment).to receive(:source_range).and_return(source_range) }

    it 'returns line number for directive' do
      expect(directive_comment.line_number).to eq(1)
    end
  end

  describe '#enabled_all?' do
    subject { directive_comment.enabled_all? }

    context 'when enabled all cops' do
      let(:text) { 'def foo # rubocop:enable all' }

      it { is_expected.to be(true) }
    end

    context 'when enabled specific cops' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end

    context 'when disabled all cops' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(false) }
    end

    context 'when disabled specific cops' do
      let(:text) { '# rubocop:disable Foo/Bar' }

      it { is_expected.to be(false) }
    end
  end

  describe '#disabled_all?' do
    subject { directive_comment.disabled_all? }

    context 'when enabled all cops' do
      let(:text) { 'def foo # rubocop:enable all' }

      it { is_expected.to be(false) }
    end

    context 'when enabled specific cops' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end

    context 'when disabled all cops' do
      let(:text) { '# rubocop:disable all' }

      it { is_expected.to be(true) }
    end

    context 'when disabled specific cops' do
      let(:text) { '# rubocop:disable Foo/Bar' }

      it { is_expected.to be(false) }
    end
  end

  describe '#directive_count' do
    subject { directive_comment.directive_count }

    context 'when few cops used' do
      let(:text) { '# rubocop:enable Foo/Bar, Foo/Baz' }

      it { is_expected.to eq(2) }
    end

    context 'when few department used' do
      let(:text) { '# rubocop:enable Foo, Bar, Baz' }

      it { is_expected.to eq(3) }
    end

    context 'when cops and departments used' do
      let(:text) { '# rubocop:enable Foo/Bar, Foo/Baz, Bar, Baz' }

      it { is_expected.to eq(4) }
    end
  end

  describe '#in_directive_department?' do
    subject { directive_comment.in_directive_department?('Foo/Bar') }

    context 'when cop department disabled' do
      let(:text) { '# rubocop:enable Foo' }
      let(:department?) { true }

      it { is_expected.to be(true) }
    end

    context 'when another department disabled' do
      let(:text) { '# rubocop:enable Bar' }
      let(:department?) { true }

      it { is_expected.to be(false) }
    end

    context 'when cop disabled' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end
  end

  describe '#overridden_by_department?' do
    subject { directive_comment.overridden_by_department?('Foo/Bar') }

    before do
      allow(cop_registry).to receive(:department?).with('Foo').and_return(true)
    end

    context "when cop is overridden by it's department" do
      let(:text) { '# rubocop:enable Foo, Foo/Bar' }

      it { is_expected.to be(true) }
    end

    context "when cop is not overridden by it's department" do
      let(:text) { '# rubocop:enable Bar, Foo/Bar' }

      it { is_expected.to be(false) }
    end

    context 'when there are no departments' do
      let(:text) { '# rubocop:enable Foo/Bar' }

      it { is_expected.to be(false) }
    end

    context 'when there are no cops' do
      let(:text) { '# rubocop:enable Foo' }

      it { is_expected.to be(false) }
    end
  end

  describe '#raw_cop_names' do
    subject { directive_comment.raw_cop_names }

    context 'when there are departments' do
      let(:text) { '# rubocop:enable Style, Lint/Void' }

      it { is_expected.to eq(%w[Style Lint/Void]) }
    end
  end
end
