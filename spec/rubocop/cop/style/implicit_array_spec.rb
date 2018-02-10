# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ImplicitArray do
  subject(:cop) { described_class.new }

  context 'with missing brackets' do
    it 'registers offense for single-line statement' do
      expect_offense(<<-RUBY.strip_indent)
        a = 1, 2, 3
            ^^^^^^^ Explicitly initialize arrays with `[` and `]`.
      RUBY
    end

    it 'autocorrects single-line statement' do
      corrected = autocorrect_source('a = 1, 2, 3')
      expect(corrected).to eq('a = [1, 2, 3]')
    end

    it 'registers offense for multi-line statement' do
      expect_offense(<<-RUBY.strip_indent)
        a = 1,
            ^^ Explicitly initialize arrays with `[` and `]`.
          2,
          3
      RUBY
    end

    it 'autocorrects multi-line statement' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a = 1,
          2,
          3
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        a = [1,
          2,
          3]
      RUBY
    end
  end

  context 'with explicit brackets' do
    it 'does not register an offense for single-line statement' do
      expect_no_offenses('a = [1, 2, 3]')
    end

    it 'does not register offense for multi-line statement' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
          1,
          2,
          3
        ]
      RUBY
    end

    it 'does not register offense for statement with no parent' do
      expect_no_offenses('[1, 2, 3]')
    end
  end

  context 'possible false positives' do
    it 'does not trigger when initializing multiple variables' do
      expect_no_offenses('a, b, c = [1, 2, 3]')
    end

    it 'does not trigger for arrays with percent literals' do
      expect_no_offenses('a = %i(x y z)')
    end

    it 'does not trigger for implicit arrays of exceptions in rescue block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def foo
          bar
        rescue SomeException, SomeOtherException
          baz
        end
      RUBY
    end

    it 'does not trigger for splat operators' do
      expect_no_offenses('x = *y')
    end
  end
end
