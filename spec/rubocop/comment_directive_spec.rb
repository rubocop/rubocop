# frozen_string_literal: true

describe RuboCop::CommentDirective do
  let(:comment) { parse_source(source).comments.first }
  let(:source) { '' } # overridden in lower contexts

  shared_examples_for 'valid CommentDirective' do |keyword, cop_names|
    it 'is a valid CommentDirective' do
      expect(subject.keyword).to eq(keyword)
      expect(subject.cop_names).to match_array(cop_names) if cop_names
      expect(subject.source_range.source).to eq(source)
    end
  end

  describe '.from_comment' do
    subject { described_class.from_comment(comment) }

    context 'when comment is nil' do
      let(:comment) { nil }
      it { is_expected.to be_nil }
    end

    context 'when comment has no directive' do
      let(:source) { '# no directive to see here' }
      it { is_expected.to be_nil }
    end

    context 'when comment has an invalid directive keyword' do
      let(:source) { '# rubocop:blahblahblah Test/SomeCop' }
      it { is_expected.to be_nil }
    end

    context 'when a comment has a disable directive' do
      context 'with one cop' do
        let(:source) { '# rubocop:disable Test/SomeCop' }
        include_examples 'valid CommentDirective', :disable, ['Test/SomeCop']
      end

      context 'with one cop and a comment' do
        let(:source) { '# rubocop:disable Test/SomeCop with a comment' }
        include_examples 'valid CommentDirective', :disable, ['Test/SomeCop']
      end

      context 'with two cops' do
        let(:source) { '# rubocop:disable Test/SomeCop, Test/SomeOtherCop' }
        include_examples 'valid CommentDirective', :disable, %w[
          Test/SomeCop
          Test/SomeOtherCop
        ]
      end

      context 'with two cops and a comment' do
        let(:source) do
          '# rubocop:disable Test/SomeCop, Test/SomeOtherCop plus comment'
        end
        include_examples 'valid CommentDirective', :disable, %w[
          Test/SomeCop
          Test/SomeOtherCop
        ]
      end

      context 'with disable all' do
        let(:source) { '# rubocop:disable all' }
        include_examples 'valid CommentDirective', :disable

        it 'includes all cops' do
          expect(subject.cop_names.length).to be >= 300
        end
      end
    end

    context 'when a comment has an enable directive' do
      context 'with one cop' do
        let(:source) { '# rubocop:enable Test/SomeCop' }
        include_examples 'valid CommentDirective', :enable, ['Test/SomeCop']
      end
    end
  end
end
