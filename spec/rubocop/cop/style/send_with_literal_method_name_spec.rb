# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SendWithLiteralMethodName, :config do
  context 'when calling `public_send` with a symbol literal argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        obj.public_send(:foo)
            ^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo
      RUBY
    end

    context 'with safe navigation' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj&.public_send(:foo)
               ^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj&.foo
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a symbol literal argument and some arguments with parentheses' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        obj.public_send(:foo, bar, 42)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo(bar, 42)
      RUBY
    end

    context 'with safe navigation' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj&.public_send(:foo, bar, 42)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj&.foo(bar, 42)
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a symbol literal argument and some arguments without parentheses' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        obj.public_send :foo, bar, 42
            ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo bar, 42
      RUBY
    end

    context 'with safe navigation' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj&.public_send :foo, bar, 42
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj&.foo bar, 42
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a symbol literal argument without a receiver' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        public_send(:foo)
        ^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        foo
      RUBY
    end
  end

  context 'when calling `public_send` with a string literal argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        obj.public_send('foo')
            ^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.foo
      RUBY
    end

    context 'with safe navigation' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj&.public_send('foo')
               ^^^^^^^^^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj&.foo
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with underscore' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        obj.public_send("name_with_underscore")
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `name_with_underscore` method call directly instead.
      RUBY

      expect_correction(<<~RUBY)
        obj.name_with_underscore
      RUBY
    end

    context 'with safe navigation' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj&.public_send("name_with_underscore")
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `name_with_underscore` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj&.name_with_underscore
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with a variable argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send(variable)
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send(variable)
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with an interpolated string argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        obj.public_send("#{interpolated}string")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          obj&.public_send("#{interpolated}string")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with a space' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send("name with space")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send("name with space")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with a hyphen' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send("name-with-hyphen")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send("name-with-hyphen")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a writer method name' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send("name=")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send("name=")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with braces' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send("{brackets}")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send("{brackets}")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a method name with square brackets' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send("[square_brackets]")
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send("[square_brackets]")
        RUBY
      end
    end
  end

  context 'when calling `public_send` with a reserved word' do
    it 'does not register an offense' do
      described_class::RESERVED_WORDS.each do |reserved_word|
        expect_no_offenses(<<~RUBY)
          obj.public_send(:#{reserved_word})
        RUBY
      end
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        described_class::RESERVED_WORDS.each do |reserved_word|
          expect_no_offenses(<<~RUBY)
            obj&.public_send(:#{reserved_word})
          RUBY
        end
      end
    end
  end

  context 'when calling `public_send` with a integer literal argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send(42)
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send(42)
        RUBY
      end
    end
  end

  context 'when calling `public_send` without arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.public_send
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.public_send
        RUBY
      end
    end
  end

  context 'when calling another method other than `public_send`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        obj.foo
      RUBY
    end

    context 'with safe navigation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj&.foo
        RUBY
      end
    end
  end

  context 'when `AllowSend: true`' do
    let(:cop_config) { { 'AllowSend' => true } }

    context 'when calling `send` with a symbol literal argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj.send(:foo)
        RUBY
      end

      context 'with safe navigation' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            obj&.send(:foo)
          RUBY
        end
      end
    end

    context 'when calling `__send__` with a symbol literal argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          obj.__send__(:foo)
        RUBY
      end

      context 'with safe navigation' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            obj&.__send__(:foo)
          RUBY
        end
      end
    end
  end

  context 'when `AllowSend: false`' do
    let(:cop_config) { { 'AllowSend' => false } }

    context 'when calling `send` with a symbol literal argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj.send(:foo)
              ^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj.foo
        RUBY
      end

      context 'with safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            obj&.send(:foo)
                 ^^^^^^^^^^ Use `foo` method call directly instead.
          RUBY

          expect_correction(<<~RUBY)
            obj&.foo
          RUBY
        end
      end
    end

    context 'when calling `__send__` with a symbol literal argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          obj.__send__(:foo)
              ^^^^^^^^^^^^^^ Use `foo` method call directly instead.
        RUBY

        expect_correction(<<~RUBY)
          obj.foo
        RUBY
      end

      context 'with safe navigation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            obj&.__send__(:foo)
                 ^^^^^^^^^^^^^^ Use `foo` method call directly instead.
          RUBY

          expect_correction(<<~RUBY)
            obj&.foo
          RUBY
        end
      end
    end
  end
end
