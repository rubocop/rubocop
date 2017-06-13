# frozen_string_literal: true

describe RuboCop::Cop::Style::StabbyLambdaParentheses, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common' do
    it 'does not check the old lambda syntax' do
      expect_no_offenses('lambda(&:nil?)')
    end

    it 'does not check a stabby lambda without arguments' do
      expect_no_offenses('-> { true }')
    end

    it 'does not check a method call named lambda' do
      expect_no_offenses('o.lambda')
    end
  end

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda without parentheses' do
      expect_offense(<<-RUBY.strip_indent)
        ->a,b,c { a + b + c }
          ^^^^^ Wrap stabby lambda arguments with parentheses.
      RUBY
    end

    it 'does not register an offense for a stabby lambda with parentheses' do
      expect_no_offenses('->(a,b,c) { a + b + c }')
    end

    it 'autocorrects when a stabby lambda has no parentheses' do
      corrected = autocorrect_source(['->a,b,c { a + b + c }'])
      expect(corrected).to eq '->(a,b,c) { a + b + c }'
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda with parentheses' do
      expect_offense(<<-RUBY.strip_indent)
        ->(a,b,c) { a + b + c }
          ^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
      RUBY
    end

    it 'autocorrects when a stabby lambda does not parentheses' do
      corrected = autocorrect_source(['->(a,b,c) { a + b + c }'])
      expect(corrected).to eq '->a,b,c { a + b + c }'
    end
  end
end
