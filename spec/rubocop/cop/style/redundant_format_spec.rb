# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantFormat, :config do
  %i[format sprintf].each do |method|
    context "with #{method}" do
      it 'registers an offense when called with only a single string argument' do
        expect_offense(<<~RUBY, method: method)
          %{method}('foo')
          ^{method}^^^^^^^ Redundant `%{method}` can be removed.
        RUBY

        expect_correction(<<~RUBY)
          'foo'
        RUBY
      end

      it 'registers an offense when called with only a single interpolated string argument' do
        expect_offense(<<~'RUBY', method: method)
          %{method}("#{foo}")
          ^{method}^^^^^^^^^^ Redundant `%{method}` can be removed.
        RUBY

        expect_correction(<<~'RUBY')
          "#{foo}"
        RUBY
      end

      it 'registers an offense when called with only a single string argument with `Kernel`' do
        expect_offense(<<~RUBY, method: method)
          Kernel.%{method}('foo')
          ^^^^^^^^{method}^^^^^^^ Redundant `%{method}` can be removed.
        RUBY

        expect_correction(<<~RUBY)
          'foo'
        RUBY
      end

      it 'registers an offense when called with only a single string argument with `::Kernel`' do
        expect_offense(<<~RUBY, method: method)
          ::Kernel.%{method}('foo')
          ^^^^^^^^^^{method}^^^^^^^ Redundant `%{method}` can be removed.
        RUBY

        expect_correction(<<~RUBY)
          'foo'
        RUBY
      end

      it 'does not register an offense when called with no arguments' do
        expect_no_offenses(<<~RUBY)
          #{method}
          #{method}()
        RUBY
      end

      it 'does not register an offense when called with additional arguments' do
        expect_no_offenses(<<~RUBY)
          #{method}('%s', foo)
        RUBY
      end

      it 'does not register an offense when called with a splat' do
        expect_no_offenses(<<~RUBY)
          #{method}(*args)
        RUBY
      end

      it 'does not register an offense when called on an object' do
        expect_no_offenses(<<~RUBY)
          foo.#{method}('bar')
        RUBY
      end
    end
  end
end
