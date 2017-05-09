# frozen_string_literal: true

describe RuboCop::Cop::Style::Send do
  subject(:cop) { described_class.new }

  context 'with send' do
    context 'and with a receiver' do
      it 'registers an offense for an invocation with args' do
        expect_offense(<<-RUBY.strip_indent)
          Object.send(:inspect)
                 ^^^^ Prefer `Object#__send__` or `Object#public_send` to `send`.
        RUBY
      end

      it 'does not register an offense for an invocation without args' do
        expect_no_offenses('Object.send')
      end
    end

    context 'and without a receiver' do
      it 'registers an offense for an invocation with args' do
        expect_offense(<<-RUBY.strip_indent)
          send(:inspect)
          ^^^^ Prefer `Object#__send__` or `Object#public_send` to `send`.
        RUBY
      end

      it 'does not register an offense for an invocation without args' do
        expect_no_offenses('send')
      end
    end
  end

  context 'with __send__' do
    after { expect(cop.offenses).to be_empty }

    context 'and with a receiver' do
      it 'does not register an offense for an invocation with args' do
        inspect_source(cop, 'Object.__send__(:inspect)')
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, 'Object.__send__')
      end
    end

    context 'and without a receiver' do
      it 'does not register an offense for an invocation with args' do
        inspect_source(cop, '__send__(:inspect)')
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, '__send__')
      end
    end
  end

  context 'with public_send' do
    after { expect(cop.offenses).to be_empty }

    context 'and with a receiver' do
      it 'does not register an offense for an invocation with args' do
        inspect_source(cop, 'Object.public_send(:inspect)')
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, 'Object.public_send')
      end
    end

    context 'and without a receiver' do
      it 'does not register an offense for an invocation with args' do
        inspect_source(cop, 'public_send(:inspect)')
      end

      it 'does not register an offense for an invocation without args' do
        inspect_source(cop, 'public_send')
      end
    end
  end
end
