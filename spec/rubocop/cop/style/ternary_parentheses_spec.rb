# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::TernaryParentheses, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, expected|
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

  context 'when configured to enforce parentheses inclusion' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    let(:message) { 'Use parentheses for ternary conditions.' }

    context 'with a simple condition' do
      it_behaves_like 'code with offense',
                      'foo = bar? ? a : b',
                      'foo = (bar?) ? a : b'
    end

    context 'with a complex condition' do
      it_behaves_like 'code with offense',
                      'foo = 1 + 1 == 2 ? a : b',
                      'foo = (1 + 1 == 2) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar && baz ? a : b',
                      'foo = (bar && baz) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar.baz? ? a : b',
                      'foo = (bar.baz?) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar && (baz || bar) ? a : b',
                      'foo = (bar && (baz || bar)) ? a : b'
    end

    context 'with an assignment condition' do
      it_behaves_like 'code with offense',
                      'foo = bar = baz ? a : b',
                      'foo = bar = (baz) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar = baz = find_baz ? a : b',
                      'foo = bar = baz = (find_baz) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar = baz == 1 ? a : b',
                      'foo = bar = (baz == 1) ? a : b'

      it_behaves_like 'code without offense',
                      'foo = (bar = baz = find_baz) ? a : b'
    end
  end

  context 'when configured to enforce parentheses omission' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    let(:message) { 'Omit parentheses for ternary conditions.' }

    context 'with a simple condition' do
      it_behaves_like 'code with offense',
                      'foo = (bar?) ? a : b',
                      'foo = bar? ? a : b'
    end

    context 'with a complex condition' do
      it_behaves_like 'code with offense',
                      'foo = (1 + 1 == 2) ? a : b',
                      'foo = 1 + 1 == 2 ? a : b'

      it_behaves_like 'code with offense',
                      'foo = (bar && baz) ? a : b',
                      'foo = bar && baz ? a : b'

      it_behaves_like 'code with offense',
                      'foo = (bar.baz?) ? a : b',
                      'foo = bar.baz? ? a : b'

      it_behaves_like 'code without offense',
                      'foo = bar && (baz || bar) ? a : b'
    end

    context 'with an assignment condition' do
      it_behaves_like 'code without offense',
                      'foo = (bar = find_bar) ? a : b'

      it_behaves_like 'code without offense',
                      'foo = bar = (baz = find_baz) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = bar = (baz == 1) ? a : b',
                      'foo = bar = baz == 1 ? a : b'

      it_behaves_like 'code without offense',
                      'foo = (bar = baz = find_baz) ? a : b'

      context 'when safe assignment is disabled' do
        let(:cop_config) do
          {
            'EnforcedStyle' => 'require_no_parentheses',
            'AllowSafeAssignment' => false
          }
        end

        it_behaves_like 'code with offense',
                        'foo = (bar = find_bar) ? a : b'

        it_behaves_like 'code with offense',
                        'foo = bar = (baz = find_baz) ? a : b'

        it_behaves_like 'code with offense',
                        'foo = (bar = baz = find_baz) ? a : b'
      end
    end

    context 'with an unparenthesized method call condition' do
      it_behaves_like 'code with offense',
                      'foo = (defined? bar) ? a : b',
                      'foo = (defined? bar) ? a : b'

      it_behaves_like 'code with offense',
                      'foo = (baz? bar) ? a : b',
                      'foo = (baz? bar) ? a : b'

      context 'when calling method on a receiver' do
        it_behaves_like 'code with offense',
                        'foo = (baz.foo? bar) ? a : b',
                        'foo = (baz.foo? bar) ? a : b'
      end

      context 'when calling method with multiple arguments' do
        it_behaves_like 'code with offense',
                        'foo = (baz.foo? bar, baz) ? a : b',
                        'foo = (baz.foo? bar, baz) ? a : b'
      end
    end
  end

  context 'when `RedundantParenthesis` would cause an infinite loop' do
    let(:config) do
      RuboCop::Config.new(
        'Style/RedundantParentheses' => { 'Enabled' => true },
        'Style/TernaryParentheses' => {
          'EnforcedStyle' => 'require_parentheses',
          'SupportedStyles' => %w(require_parentheses require_no_parentheses)
        }
      )
    end

    it_behaves_like 'code without offense',
                    'foo = bar? ? a : b'
  end
end
