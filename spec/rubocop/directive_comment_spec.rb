# frozen_string_literal: true

RSpec.describe RuboCop::DirectiveComment do
  subject(:directive_comment) { described_class.new(comment) }

  let(:comment) { instance_double(Parser::Source::Comment, text: text) }
  let(:comment_cop_names) { 'all' }
  let(:text) { "#rubocop:enable #{comment_cop_names}" }

  describe '#cops' do
    subject(:cops) { directive_comment.cops }

    context 'all' do
      let(:comment_cop_names) { 'all' }

      it 'returns [all]' do
        expect(cops).to eq(%w[all])
      end
    end

    context 'single cop' do
      let(:comment_cop_names) { 'Metrics/AbcSize' }

      it 'returns [Metrics/AbcSize]' do
        expect(cops).to eq(%w[Metrics/AbcSize])
      end
    end

    context 'single cop duplicated' do
      let(:comment_cop_names) { 'Metrics/AbcSize,Metrics/AbcSize' }

      it 'returns [Metrics/AbcSize]' do
        expect(cops).to eq(%w[Metrics/AbcSize])
      end
    end

    context 'multiple cops' do
      let(:comment_cop_names) { 'Style/Not, Metrics/AbcSize' }

      it 'returns the cops in alphabetical order' do
        expect(cops).to eq(%w[Metrics/AbcSize Style/Not])
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
  end
end
