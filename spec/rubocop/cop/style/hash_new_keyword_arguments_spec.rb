# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashNewKeywordArguments, :config do
  context 'when default value is passed as a Hash literal to `Hash.new`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        Hash.new({ foo: 1 })
      RUBY
    end
  end

  context 'when default value is passed to `Hash.new` as keyword arguments' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        Hash.new(foo: 1)
                 ^^^^^^ Avoid passing default value to `Hash.new` as keyword arguments.
      RUBY

      expect_correction(<<~RUBY)
        Hash.new({ foo: 1 })
      RUBY
    end
  end

  context 'when default value is passed as keyword arguments to `::Hash.new`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        ::Hash.new(foo: 1)
                   ^^^^^^ Avoid passing default value to `Hash.new` as keyword arguments.
      RUBY

      expect_correction(<<~RUBY)
        ::Hash.new({ foo: 1 })
      RUBY
    end
  end
end
