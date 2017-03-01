# frozen_string_literal: true

describe RuboCop::Cop::Lint::InheritException, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'registers an offense' do |message|
    it 'registers an offense' do
      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq([message])
    end
  end

  shared_examples 'auto-correct' do |expected|
    it 'auto-corrects' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(expected)
    end
  end

  context 'when class inherits from `Exception`' do
    let(:source) do
      'class C < Exception; end'
    end

    context 'with enforced style set to `runtime_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'runtime_error' } }

      it_behaves_like 'registers an offense',
                      'Inherit from `RuntimeError` instead of `Exception`.'

      it_behaves_like 'auto-correct', 'class C < RuntimeError; end'
    end

    context 'with enforced style set to `standard_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'standard_error' } }

      it_behaves_like 'registers an offense',
                      'Inherit from `StandardError` instead of `Exception`.'

      it_behaves_like 'auto-correct', 'class C < StandardError; end'
    end
  end
end
