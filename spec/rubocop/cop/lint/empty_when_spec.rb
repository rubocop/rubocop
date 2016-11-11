# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EmptyWhen, :config do
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

  context 'when a `when` body is missing' do
    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar then 1',
                     'when :baz',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar then 1',
                     'when :baz then',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar then 1',
                     'when :baz then',
                     'else 3',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar',
                     '  1',
                     'when :baz',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case foo',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '  ',
                     'else',
                     'end'].join("\n")

    it_behaves_like 'code with offense',
                    ['case',
                     'when :bar',
                     '  1',
                     'when :baz',
                     'else',
                     '  3',
                     'end'].join("\n")
  end

  context 'when a `when` body is present' do
    it_behaves_like 'code without offense',
                    ['case foo',
                     'when :bar then 1',
                     'when :baz then 2',
                     'end'].join("\n")

    it_behaves_like 'code without offense',
                    ['case foo',
                     'when :bar then 1',
                     'when :baz then 2',
                     'else 3',
                     'end'].join("\n")

    it_behaves_like 'code without offense',
                    ['case foo',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '  2',
                     'end'].join("\n")

    it_behaves_like 'code without offense',
                    ['case foo',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '  2',
                     'else',
                     '  3',
                     'end'].join("\n")
    it_behaves_like 'code without offense',
                    ['case',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '  2',
                     'else',
                     '  3',
                     'end'].join("\n")
    it_behaves_like 'code without offense',
                    ['case',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '  # nothing',
                     'else',
                     '  3',
                     'end'].join("\n")
    it_behaves_like 'code without offense',
                    ['case',
                     'when :bar',
                     '  1',
                     'when :baz',
                     '',
                     '  # nothing',
                     'else',
                     '  3',
                     'end'].join("\n")
  end
end
