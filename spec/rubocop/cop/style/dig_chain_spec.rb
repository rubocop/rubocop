# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DigChain, :config do
  it 'does not register an offense for unchained `dig` without a receiver' do
    expect_no_offenses(<<~RUBY)
      dig
    RUBY
  end

  it 'does not register an offense for `X::dig`' do
    expect_no_offenses(<<~RUBY)
      X::dig(:foo, :bar)
    RUBY
  end

  it 'does not register an offense for dig chained to something else' do
    expect_no_offenses(<<~RUBY)
      x.dig(:foo).bar
      x.bar.dig(:foo)
    RUBY
  end

  it 'does not register an offense when the chain is broken up' do
    expect_no_offenses(<<~RUBY)
      x.dig(:foo).first.dig(:bar)
    RUBY
  end

  it 'does not register an offense for dig without arguments' do
    expect_no_offenses(<<~RUBY)
      x.dig
    RUBY
  end

  it 'does not register an offense for chained dig without arguments' do
    expect_no_offenses(<<~RUBY)
      x.dig(:foo, :bar).dig
      x.dig.dig(:foo, :bar)
    RUBY
  end

  it 'does not register an offense for a hash' do
    expect_no_offenses(<<~RUBY)
      x.dig({ foo: 1, bar: 2 }).dig({ baz: 3, quux: 4 })
    RUBY
  end

  it 'does not register an offense for kwargs' do
    expect_no_offenses(<<~RUBY)
      x.dig(foo: 1, bar: 2).dig(baz: 3, quux: 4)
    RUBY
  end

  context 'with chained `dig` calls' do
    it 'registers an offense and corrects with single values' do
      expect_offense(<<~RUBY)
        x.dig(:foo).dig(:bar).dig(:baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, :bar, :baz)
      RUBY
    end

    it 'registers an offense and corrects when attached to a chain of non-dig receivers' do
      expect_offense(<<~RUBY)
        x.y.z.dig(:foo).dig(:bar).dig(:baz)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.y.z.dig(:foo, :bar, :baz)
      RUBY
    end

    it 'registers an offense and corrects with multiple values' do
      expect_offense(<<~RUBY)
        x.dig(:foo, :bar).dig(:baz, :quux)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz, :quux)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, :bar, :baz, :quux)
      RUBY
    end

    it 'registers an offense and corrects with safe navigation' do
      expect_offense(<<~RUBY)
        x.dig(:foo, :bar)&.dig(:baz, :quux)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz, :quux)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, :bar, :baz, :quux)
      RUBY
    end

    it 'registers an offense and corrects with safe navigation on the receiver' do
      expect_offense(<<~RUBY)
        x&.dig(:foo)&.dig(:bar)&.dig(:baz, :quux)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz, :quux)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x&.dig(:foo, :bar, :baz, :quux)
      RUBY
    end

    it 'registers an offense and corrects without a receiver' do
      expect_offense(<<~RUBY)
        dig(:foo, :bar).dig(:baz, :quux)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz, :quux)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        dig(:foo, :bar, :baz, :quux)
      RUBY
    end

    it 'registers an offense and corrects with `::` instead of dot' do
      expect_offense(<<~RUBY)
        x.dig(:foo, :bar)::dig(:baz, :quux)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz, :quux)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, :bar, :baz, :quux)
      RUBY
    end

    it 'registers an offense and corrects with splat' do
      expect_offense(<<~RUBY)
        x.dig(:foo).dig(*names).dig(:bar)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, *names, :bar)` instead of chaining.
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, *names, :bar)
      RUBY
    end

    it 'registers an offense and corrects when split over multiple lines' do
      expect_offense(<<~RUBY)
        x.dig(:foo)
          ^^^^^^^^^ Use `dig(:foo, :bar, :baz)` instead of chaining.
         .dig(:bar)
         .dig(:baz)
      RUBY

      expect_correction(<<~RUBY)
        x.dig(:foo, :bar, :baz)
      RUBY
    end

    it 'registers an offense and corrects when split over multiple lines with comments' do
      expect_offense(<<~RUBY)
        x.dig(:foo) # comment 1
          ^^^^^^^^^^^^^^^^^^^^^ Use `dig(:foo, :bar, :baz)` instead of chaining.
         .dig(:bar) # comment 2
         .dig(:baz) # comment 3
      RUBY

      expect_correction(<<~RUBY)
        # comment 1
        # comment 2
        x.dig(:foo, :bar, :baz) # comment 3
      RUBY
    end

    context '`...` argument forwarding' do
      it 'registers an offense and corrects with forwarded args' do
        expect_offense(<<~RUBY)
          def foo(...)
            x.dig(:foo).dig(...)
              ^^^^^^^^^^^^^^^^^^ Use `dig(:foo, ...)` instead of chaining.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(...)
            x.dig(:foo, ...)
          end
        RUBY
      end

      it 'does not register an offense when combining would add a syntax error' do
        expect_no_offenses(<<~RUBY)
          def foo(...)
            x.dig(...).dig(:foo)
            x.dig(...).dig(...)
          end
        RUBY
      end

      context 'Ruby >= 3.1', :ruby31 do
        it 'does not register an offense when `dig` is given a forwarded anonymous block' do
          expect_no_offenses(<<~RUBY)
            def foo(&)
              x.dig(&).dig(:foo)
            end
          RUBY
        end
      end

      context 'Ruby >= 3.2', :ruby32 do
        it 'registers an offense and corrects with forwarded anonymous splat' do
          expect_offense(<<~RUBY)
            def foo(*)
              x.dig(*).dig(*)
                ^^^^^^^^^^^^^ Use `dig(*, *)` instead of chaining.
            end
          RUBY

          expect_correction(<<~RUBY)
            def foo(*)
              x.dig(*, *)
            end
          RUBY
        end

        it 'does not register an offense with forwarded anonymous kwsplat' do
          expect_no_offenses(<<~RUBY)
            def foo(**)
              x.dig(**).dig(:foo)
            end
          RUBY
        end
      end
    end
  end
end
