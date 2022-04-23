# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleArgumentDig, :config do
  describe 'dig over literal' do
    context 'with single argument' do
      it 'registers an offense and corrects unsuitable use of dig' do
        expect_offense(<<~RUBY)
          { key: 'value' }.dig(:key)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `{ key: 'value' }[:key]` instead of `{ key: 'value' }.dig(:key)`.
        RUBY

        expect_correction(<<~RUBY)
          { key: 'value' }[:key]
        RUBY
      end
    end

    context 'with multiple arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          { key1: { key2: 'value' } }.dig(:key1, :key2)
        RUBY
      end
    end

    context 'when using dig with splat operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          { key1: { key2: 'value' } }.dig(*%i[key1 key2])
        RUBY
      end
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    context 'when using dig with arguments forwarding' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def foo(...)
            { key: 'value' }.dig(...)
          end
        RUBY
      end
    end
  end

  describe 'dig over a variable as caller' do
    context 'with single argument' do
      it 'registers an offense and corrects unsuitable use of dig' do
        expect_offense(<<~RUBY)
          data.dig(var)
          ^^^^^^^^^^^^^ Use `data[var]` instead of `data.dig(var)`.
        RUBY

        expect_correction(<<~RUBY)
          data[var]
        RUBY
      end
    end

    context 'with multiple arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          data.dig(var1, var2)
        RUBY
      end
    end

    context 'when using multiple `dig` in a method chain' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          data.dig(var1)[0].dig(var2)
          ^^^^^^^^^^^^^^ Use `data[var1]` instead of `data.dig(var1)`.
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `data.dig(var1)[0][var2]` instead of `data.dig(var1)[0].dig(var2)`.
        RUBY

        expect_correction(<<~RUBY)
          data.dig(var1)[0][var2]
        RUBY
      end
    end

    context 'when using dig with splat operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          data.dig(*[var1, var2])
        RUBY
      end
    end
  end

  context 'when without a receiver' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        dig(:key)
      RUBY
    end
  end
end
