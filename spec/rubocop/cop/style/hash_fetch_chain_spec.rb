# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashFetchChain, :config do
  context 'ruby >= 2.3' do
    context 'with chained `fetch` methods' do
      shared_examples 'fetch chain' do |argument|
        context "when the 2nd argument is `#{argument}`" do
          it 'does not register an offense when not chained' do
            expect_no_offenses(<<~RUBY)
              hash.fetch('foo', #{argument})
            RUBY
          end

          it 'registers an offense and corrects when the first argument is a string' do
            expect_offense(<<~RUBY, argument: argument)
              hash.fetch('foo', %{argument})&.fetch('bar', nil)
                   ^^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^^^ Use `dig('foo', 'bar')` instead.
            RUBY

            expect_correction(<<~RUBY)
              hash.dig('foo', 'bar')
            RUBY
          end

          it 'registers an offense and corrects when the first argument is a symbol' do
            expect_offense(<<~RUBY, argument: argument)
              hash.fetch(:foo, %{argument})&.fetch(:bar, nil)
                   ^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar)` instead.
            RUBY

            expect_correction(<<~RUBY)
              hash.dig(:foo, :bar)
            RUBY
          end

          it 'registers an offense and corrects for `send` arguments' do
            expect_offense(<<~RUBY, argument: argument)
              hash.fetch(foo, %{argument})&.fetch(bar, nil)
                   ^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^ Use `dig(foo, bar)` instead.
            RUBY

            expect_correction(<<~RUBY)
              hash.dig(foo, bar)
            RUBY
          end

          it 'registers an offense and corrects for mixed arguments' do
            expect_offense(<<~RUBY, argument: argument)
              hash.fetch('foo', %{argument})&.fetch(:bar, %{argument})&.fetch(baz, nil)
                   ^^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^ Use `dig('foo', :bar, baz)` instead.
            RUBY

            expect_correction(<<~RUBY)
              hash.dig('foo', :bar, baz)
            RUBY
          end

          it 'registers an offense and corrects with safe navigation' do
            expect_offense(<<~RUBY, argument: argument)
              hash&.fetch('foo', %{argument})&.fetch('bar', nil)
                    ^^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^^^ Use `dig('foo', 'bar')` instead.
            RUBY

            expect_correction(<<~RUBY)
              hash&.dig('foo', 'bar')
            RUBY
          end

          it 'registers an offense and corrects when chained onto other methods' do
            expect_offense(<<~RUBY, argument: argument)
              x.hash.fetch('foo', %{argument})&.fetch('bar', nil)
                     ^^^^^^^^^^^^^^{argument}^^^^^^^^^^^^^^^^^^^^ Use `dig('foo', 'bar')` instead.
            RUBY

            expect_correction(<<~RUBY)
              x.hash.dig('foo', 'bar')
            RUBY
          end
        end
      end

      context 'when there is only 1 argument' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            hash.fetch('foo').fetch('bar')
          RUBY
        end
      end

      context 'when a block is given to `fetch`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            hash.fetch('foo') { :default }.fetch('bar') { :default }
          RUBY
        end
      end

      context 'when no arguments are given to `fetch`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            hash.fetch
          RUBY
        end
      end

      context 'when the 2nd argument is not `nil` or `{}`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            hash.fetch('foo', bar).fetch('baz', quux)
          RUBY
        end
      end

      context 'when the chain ends with a non-nil value' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            hash.fetch('foo', {}).fetch('bar', {})
          RUBY
        end
      end

      it_behaves_like 'fetch chain', 'nil'
      it_behaves_like 'fetch chain', '{}'
      it_behaves_like 'fetch chain', 'Hash.new'
      it_behaves_like 'fetch chain', '::Hash.new'
    end

    context 'when split on multiple lines' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          hash
            .fetch('foo', nil)
             ^^^^^^^^^^^^^^^^^ Use `dig('foo', 'bar')` instead.
            .fetch('bar', nil)
        RUBY

        expect_correction(<<~RUBY)
          hash
            .dig('foo', 'bar')
        RUBY
      end
    end
  end

  context 'ruby 2.2', :ruby22, unsupported_on: :prism do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        hash.fetch('foo', {}).fetch('bar', nil)
      RUBY
    end
  end
end
