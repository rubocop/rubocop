# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NumericPredicate, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, expected|
    context "when checking #{code}" do
      let(:source) { code }

      let(:message) { "Use `#{expected}` instead of `#{code}`." }

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

  context 'when configured to enforce numeric predicate methods' do
    let(:cop_config) { { 'EnforcedStyle' => 'predicate' } }

    context 'when checking if a number is zero' do
      it_behaves_like 'code with offense',
                      'number == 0',
                      'number.zero?'

      it_behaves_like 'code with offense',
                      '0 == number',
                      'number.zero?'

      context 'with a complex expression' do
        it_behaves_like 'code with offense',
                        'foo - 1 == 0',
                        '(foo - 1).zero?'

        it_behaves_like 'code with offense',
                        '0 == foo - 1',
                        '(foo - 1).zero?'
      end
    end

    context 'with checking if a number is not zero' do
      it_behaves_like 'code with offense',
                      'number != 0',
                      'number.nonzero?'

      it_behaves_like 'code with offense',
                      '0 != number',
                      'number.nonzero?'

      context 'with a complex expression' do
        it_behaves_like 'code with offense',
                        'foo - 1 != 0',
                        '(foo - 1).nonzero?'

        it_behaves_like 'code with offense',
                        '0 != foo - 1',
                        '(foo - 1).nonzero?'
      end
    end

    context 'when checking if a number is positive' do
      context 'when target ruby version is 2.3 or higher', :ruby23, :ruby24 do
        it_behaves_like 'code with offense',
                        'number > 0',
                        'number.positive?'

        it_behaves_like 'code with offense',
                        '0 < number',
                        'number.positive?'

        context 'with a complex expression' do
          it_behaves_like 'code with offense',
                          'foo - 1 > 0',
                          '(foo - 1).positive?'

          it_behaves_like 'code with offense',
                          '0 < foo - 1',
                          '(foo - 1).positive?'
        end
      end

      context 'when target ruby version is 2.2 or lower', :ruby22 do
        it_behaves_like 'code without offense',
                        'number > 0'

        it_behaves_like 'code without offense',
                        '0 < number'
      end
    end

    context 'when checking if a number is negative' do
      context 'when target ruby version is 2.3 or higher', :ruby23, :ruby24 do
        it_behaves_like 'code with offense',
                        'number < 0',
                        'number.negative?'

        it_behaves_like 'code with offense',
                        '0 > number',
                        'number.negative?'

        context 'with a complex expression' do
          it_behaves_like 'code with offense',
                          'foo - 1 < 0',
                          '(foo - 1).negative?'

          it_behaves_like 'code with offense',
                          '0 > foo - 1',
                          '(foo - 1).negative?'
        end
      end

      context 'when target ruby version is 2.2 or lower', :ruby22 do
        it_behaves_like 'code without offense',
                        'number < 0'

        it_behaves_like 'code without offense',
                        '0 > number'
      end
    end
  end

  context 'when configured to enforce numeric comparison methods' do
    let(:cop_config) { { 'EnforcedStyle' => 'comparison' } }

    context 'when checking if a number is zero' do
      it_behaves_like 'code with offense',
                      'number.zero?',
                      'number == 0'
    end

    context 'with checking if a number is not zero' do
      it_behaves_like 'code with offense',
                      'number.nonzero?',
                      'number != 0'
    end

    context 'when checking if a number is positive' do
      it_behaves_like 'code with offense',
                      'number.positive?',
                      'number > 0'
    end

    context 'when checking if a number is negative' do
      it_behaves_like 'code with offense',
                      'number.negative?',
                      'number < 0'
    end
  end
end
