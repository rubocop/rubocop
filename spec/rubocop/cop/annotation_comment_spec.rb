# frozen_string_literal: true

RSpec.describe RuboCop::Cop::AnnotationComment do
  subject(:annotation) { described_class.new(comment, keywords) }

  let(:keywords) { %w[TODO FIXME] }
  let(:comment) { instance_double('Parser::Source::Comment', text: "# #{text}") }

  describe '#annotation?' do
    subject { annotation.annotation? }

    context 'when given a keyword followed by a colon' do
      let(:text) { 'TODO: note' }

      it { is_expected.to eq(true) }
    end

    context 'when given a keyword followed by a space' do
      let(:text) { 'TODO note' }

      it { is_expected.to eq(true) }
    end

    context 'when the keyword is not capitalized properly' do
      let(:text) { 'todo: note' }

      it { is_expected.to eq(true) }
    end

    context 'when annotated with a non keyword' do
      let(:text) { 'SOMETHING: note' }

      it { is_expected.to be_falsey }
    end

    context 'when given as the first word of a sentence' do
      let(:text) { 'Todo in the future' }

      it { is_expected.to be_falsey }
    end

    context 'when it includes a keyword' do
      let(:text) { 'TODO2' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#correct?' do
    shared_examples_for 'correct' do |text|
      let(:text) { text }

      it { is_expected.to be_truthy }
    end

    shared_examples_for 'incorrect' do |text|
      let(:text) { text }

      it { is_expected.to be_falsey }
    end

    context 'when a colon is required' do
      subject { annotation.correct?(colon: true) }

      it_behaves_like 'correct', 'TODO: text'
      it_behaves_like 'correct', 'FIXME: text'
      it_behaves_like 'incorrect', 'TODO: '
      it_behaves_like 'incorrect', 'TODO '
      it_behaves_like 'incorrect', 'TODO'
      it_behaves_like 'incorrect', 'TODOtext'
      it_behaves_like 'incorrect', 'TODO:text'
      it_behaves_like 'incorrect', 'TODO2: text'
      it_behaves_like 'incorrect', 'TODO text'
      it_behaves_like 'incorrect', 'todo text'
      it_behaves_like 'incorrect', 'UPDATE: text'
      it_behaves_like 'incorrect', 'UPDATE text'
    end

    context 'when no colon is required' do
      subject { annotation.correct?(colon: false) }

      it_behaves_like 'correct', 'TODO text'
      it_behaves_like 'correct', 'FIXME text'
      it_behaves_like 'incorrect', 'TODO: '
      it_behaves_like 'incorrect', 'TODO '
      it_behaves_like 'incorrect', 'TODO'
      it_behaves_like 'incorrect', 'TODOtext'
      it_behaves_like 'incorrect', 'TODO:text'
      it_behaves_like 'incorrect', 'TODO2 text'
      it_behaves_like 'incorrect', 'TODO: text'
      it_behaves_like 'incorrect', 'todo text'
      it_behaves_like 'incorrect', 'UPDATE: text'
      it_behaves_like 'incorrect', 'UPDATE text'
    end
  end
end
