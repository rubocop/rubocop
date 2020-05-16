# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleArgumentDig do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

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

    context 'when using dig with splat operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          data.dig(*[var1, var2])
        RUBY
      end
    end
  end
end
