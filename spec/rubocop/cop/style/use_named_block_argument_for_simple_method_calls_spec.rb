# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UseNamedBlockArgumentForSimpleMethodCalls do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context '>= Ruby 2.7', :ruby27 do
    it 'registers an offense when using `_1.method` in block' do
      expect_offense(<<~RUBY)
        bar { _1.method }
        ^^^^^^^^^^^^^^^^^ Use `{ |it| it.method }` instead of `{ _1.method }`.
      RUBY

      expect_correction(<<~RUBY)
        bar { |it| it.method }
      RUBY
    end

    it 'registers an offense when using `_1.method` in block on object`' do
      expect_offense(<<~RUBY)
        foo.bar { _1.method }
        ^^^^^^^^^^^^^^^^^^^^^ Use `{ |it| it.method }` instead of `{ _1.method }`.
      RUBY

      expect_correction(<<~RUBY)
        foo.bar { |it| it.method }
      RUBY
    end

    it 'does not register an offense when using `_1 + _2`' do
      expect_no_offenses(<<~RUBY)
        foo.bar { _1 + _2 }
      RUBY
    end

    it 'does not register an offense when using `_1.method(123)`' do
      expect_no_offenses(<<~RUBY)
        foo.bar { _1.method(123) }
      RUBY
    end

    it 'registers an offense when block is used with method call with args' do
      expect_offense(<<~RUBY)
        method(one, 2) { _1.test }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `{ |it| it.method }` instead of `{ _1.method }`.
      RUBY

      expect_correction(<<~RUBY)
        method(one, 2) { |it| it.test }
      RUBY
    end
  end
end
