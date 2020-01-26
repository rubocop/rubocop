# frozen_string_literal: true

RSpec.describe RuboCop::SpellChecker do
  describe '.suggest' do
    let(:dictionary) { %w[foo foot bar] }
    let(:misspelled) { 'food' }

    let(:corrections) { described_class.suggest(misspelled, from: dictionary) }

    context 'when did_you_mean is disabled' do
      before do
        hide_const('DidYouMean')
      end

      it 'delivers no corrections' do
        expect(defined? DidYouMean::SpellChecker).to be_falsey

        expect(corrections).to eq %w[]
      end
    end

    context 'when did_you_mean is enabled' do
      it 'delivers corrections' do
        expect(defined? DidYouMean::SpellChecker).to be_truthy

        expect(corrections).to eq %w[foo foot]
      end
    end
  end
end
