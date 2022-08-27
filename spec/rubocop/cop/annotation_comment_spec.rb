# frozen_string_literal: true

RSpec.describe RuboCop::Cop::AnnotationComment do
  subject(:annotation) { described_class.new(comment, keywords) }

  let(:keywords) { ['TODO', 'FOR LATER', 'FIXME'] }
  let(:comment) { instance_double(Parser::Source::Comment, text: "# #{text}") }

  describe '#annotation?' do
    subject { annotation.annotation? }

    context 'when given a keyword followed by a colon' do
      let(:text) { 'TODO: note' }

      it { is_expected.to be(true) }
    end

    context 'when given a keyword followed by a space' do
      let(:text) { 'TODO note' }

      it { is_expected.to be(true) }
    end

    context 'when the keyword is not capitalized properly' do
      let(:text) { 'todo: note' }

      it { is_expected.to be(true) }
    end

    context 'when the keyword is multiple words' do
      let(:text) { 'FOR LATER: note' }

      it { is_expected.to be(true) }
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
    subject { annotation.correct?(colon: colon) }

    shared_examples_for 'correct' do |text|
      let(:text) { text }

      it { is_expected.to be_truthy }
    end

    shared_examples_for 'incorrect' do |text|
      let(:text) { text }

      it { is_expected.to be_falsey }
    end

    let(:colon) { true }

    context 'when a colon is required' do
      it_behaves_like 'correct', 'TODO: text'
      it_behaves_like 'correct', 'FIXME: text'
      it_behaves_like 'correct', 'FOR LATER: text'
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
      it_behaves_like 'incorrect', 'FOR LATER text'
    end

    context 'when no colon is required' do
      let(:colon) { false }

      it_behaves_like 'correct', 'TODO text'
      it_behaves_like 'correct', 'FIXME text'
      it_behaves_like 'correct', 'FOR LATER  text'
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
      it_behaves_like 'incorrect', 'FOR LATER: text'
    end

    context 'when there is duplication in the keywords' do
      context 'when the longer keyword is given first' do
        let(:keywords) { ['TODO LATER', 'TODO'] }

        it_behaves_like 'correct', 'TODO: text'
        it_behaves_like 'correct', 'TODO LATER: text'
        it_behaves_like 'incorrect', 'TODO text'
        it_behaves_like 'incorrect', 'TODO LATER text'
      end

      context 'when the shorter keyword is given first' do
        let(:keywords) { ['TODO', 'TODO LATER'] }

        it_behaves_like 'correct', 'TODO: text'
        it_behaves_like 'correct', 'TODO LATER: text'
        it_behaves_like 'incorrect', 'TODO text'
        it_behaves_like 'incorrect', 'TODO LATER text'
      end
    end
  end
end
