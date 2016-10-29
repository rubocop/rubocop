# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EmptyExpression, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, expected = nil|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([message])
      end

      if expected
        it 'auto-corrects' do
          expect(autocorrect_source(cop, code)).to eq(expected)
        end
      else
        it 'does not auto-correct' do
          expect(autocorrect_source(cop, code)).to eq(code)
        end
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  let(:message) { described_class::MSG }

  context 'when used as a standalone expression' do
    it_behaves_like 'code with offense',
                    '()'

    context 'with nested empty expressions' do
      it_behaves_like 'code with offense',
                      '(())'
    end
  end

  context 'when used in a condition' do
    it_behaves_like 'code with offense',
                    'if (); end'

    it_behaves_like 'code with offense',
                    ['if foo',
                     '  1',
                     'elsif ()',
                     '  2',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case ()',
                     'when :foo then 1',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when () then 1',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    '() ? true : false'

    it_behaves_like 'code with offense',
                    'foo ? () : bar'
  end

  context 'when used as a return value' do
    it_behaves_like 'code with offense',
                    ['def foo',
                     '  ()',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['if foo',
                     '  ()',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar then ()',
                     'end'].join("\n")
  end

  context 'when used as an assignment' do
    it_behaves_like 'code with offense',
                    'foo = ()'
  end
end
