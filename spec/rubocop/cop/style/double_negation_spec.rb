# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleNegation, :config do
  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }

  shared_examples 'common' do
    it 'registers an offense and corrects for `!!` when not a return location' do
      expect_offense(<<~RUBY)
        def foo?
          foo
          !!test.something
          ^ Avoid the use of double negation (`!!`).
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          foo
          !test.something.nil?
          bar
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!`' do
      expect_offense(<<~RUBY)
        !!test.something
        ^ Avoid the use of double negation (`!!`).
      RUBY

      expect_correction(<<~RUBY)
        !test.something.nil?
      RUBY
    end

    it 'does not register an offense for !' do
      expect_no_offenses('!test.something')
    end

    it 'does not register an offense for `not not`' do
      expect_no_offenses('not not test.something')
    end
  end

  context 'when `EnforcedStyle: allowed_in_returns`' do
    let(:enforced_style) { 'allowed_in_returns' }

    include_examples 'common'

    it 'registers an offense and corrects for `!!` when not return location and using `unless`' do
      expect_offense(<<~RUBY)
        def foo?
          unless condition_foo?
            !!foo
            ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          unless condition_foo?
            !foo.nil?
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` when not return location' \
       'and using `if`, `elsif`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          if condition_foo?
            !!foo
            ^ Avoid the use of double negation (`!!`).
            do_something
          elsif condition_bar?
            !!bar
            ^ Avoid the use of double negation (`!!`).
            do_something
          else
            !!baz
            ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          if condition_foo?
            !foo.nil?
            do_something
          elsif condition_bar?
            !bar.nil?
            do_something
          else
            !baz.nil?
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with hash when not return location' \
       'and using `if`, `elsif`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          if condition_foo?
            { foo: !!foo0, bar: bar0, baz: baz0 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          elsif condition_bar?
            { foo: !!foo1, bar: bar1, baz: baz1 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          else
            { foo: !!foo2, bar: bar2, baz: baz2 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          if condition_foo?
            { foo: !foo0.nil?, bar: bar0, baz: baz0 }
            do_something
          elsif condition_bar?
            { foo: !foo1.nil?, bar: bar1, baz: baz1 }
            do_something
          else
            { foo: !foo2.nil?, bar: bar2, baz: baz2 }
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with array when not return location' \
       'and using `if`, `elsif`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          if condition_foo?
            [!!foo0, bar0, baz0]
             ^ Avoid the use of double negation (`!!`).
            do_something
          elsif condition_bar?
            [!!foo1, bar1, baz1]
             ^ Avoid the use of double negation (`!!`).
            do_something
          else
            [!!foo2, bar2, baz2]
             ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          if condition_foo?
            [!foo0.nil?, bar0, baz0]
            do_something
          elsif condition_bar?
            [!foo1.nil?, bar1, baz1]
            do_something
          else
            [!foo2.nil?, bar2, baz2]
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` when not return location' \
       'and using `case`, `when`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          case condition
          when foo
            !!foo
            ^ Avoid the use of double negation (`!!`).
            do_something
          when bar
            !!bar
            ^ Avoid the use of double negation (`!!`).
            do_something
          else
            !!baz
            ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          case condition
          when foo
            !foo.nil?
            do_something
          when bar
            !bar.nil?
            do_something
          else
            !baz.nil?
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with hash when not return location' \
       'and using `case`, `when`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          case condition
          when foo
            { foo: !!foo0, bar: bar0, baz: baz0 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          when bar
            { foo: !!foo1, bar: bar1, baz: baz1 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          else
            { foo: !!foo2, bar: bar2, baz: baz2 }
                   ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          case condition
          when foo
            { foo: !foo0.nil?, bar: bar0, baz: baz0 }
            do_something
          when bar
            { foo: !foo1.nil?, bar: bar1, baz: baz1 }
            do_something
          else
            { foo: !foo2.nil?, bar: bar2, baz: baz2 }
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with array when not return location' \
       'and using `case`, `when`, and `else`' do
      expect_offense(<<~RUBY)
        def foo?
          case condition
          when foo
            [!!foo0, bar0, baz0]
             ^ Avoid the use of double negation (`!!`).
            do_something
          when bar
            [!!foo1, bar1, baz1]
             ^ Avoid the use of double negation (`!!`).
            do_something
          else
            [!!foo2, bar2, baz2]
             ^ Avoid the use of double negation (`!!`).
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          case condition
          when foo
            [!foo0.nil?, bar0, baz0]
            do_something
          when bar
            [!foo1.nil?, bar1, baz1]
            do_something
          else
            [!foo2.nil?, bar2, baz2]
            do_something
          end
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with multi-line array at return location' do
      expect_offense(<<~RUBY)
        def foo
          [
            foo1,
            !!bar1,
            ^ Avoid the use of double negation (`!!`).
            !!baz1
            ^ Avoid the use of double negation (`!!`).
          ]
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          [
            foo1,
            !bar1.nil?,
            !baz1.nil?
          ]
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with single-line array at return location' do
      expect_offense(<<~RUBY)
        def foo
          [foo1, !!bar1, baz1]
                 ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          [foo1, !bar1.nil?, baz1]
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with multi-line hash at return location' do
      expect_offense(<<~RUBY)
        def foo
          {
            foo: foo1,
            bar: !!bar1,
                 ^ Avoid the use of double negation (`!!`).
            baz: !!baz1
                 ^ Avoid the use of double negation (`!!`).
          }
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          {
            foo: foo1,
            bar: !bar1.nil?,
            baz: !baz1.nil?
          }
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with single-line hash at return location' do
      expect_offense(<<~RUBY)
        def foo
          { foo: foo1, bar: !!bar1, baz: baz1 }
                            ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          { foo: foo1, bar: !bar1.nil?, baz: baz1 }
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with nested hash at return location' do
      expect_offense(<<~RUBY)
        def foo
          {
            foo: foo1,
            bar: { baz: !!quux }
                        ^ Avoid the use of double negation (`!!`).
          }
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          {
            foo: foo1,
            bar: { baz: !quux.nil? }
          }
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with nested array at return location' do
      expect_offense(<<~RUBY)
        def foo
          [
            foo1,
            [baz, !!quux]
                  ^ Avoid the use of double negation (`!!`).
          ]
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          [
            foo1,
            [baz, !quux.nil?]
          ]
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` with complex array at return location' do
      expect_offense(<<~RUBY)
        def foo
          [
            foo1,
            { baz: !!quux }
                   ^ Avoid the use of double negation (`!!`).
          ]
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          [
            foo1,
            { baz: !quux.nil? }
          ]
        end
      RUBY
    end

    # rubocop:disable RSpec/RepeatedExampleGroupDescription
    context 'Ruby >= 2.7', :ruby27 do
      # rubocop:enable RSpec/RepeatedExampleGroupDescription
      it 'registers an offense and corrects for `!!` when not return location' \
         'and using `case`, `in`, and `else`' do
        expect_offense(<<~RUBY)
          def foo?
            case pattern
            in foo
              !!foo
              ^ Avoid the use of double negation (`!!`).
              do_something
            in bar
              !!bar
              ^ Avoid the use of double negation (`!!`).
              do_something
            else
              !!baz
              ^ Avoid the use of double negation (`!!`).
              do_something
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo?
            case pattern
            in foo
              !foo.nil?
              do_something
            in bar
              !bar.nil?
              do_something
            else
              !baz.nil?
              do_something
            end
          end
        RUBY
      end
    end

    it 'does not register an offense for `!!` when return location' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        end
      RUBY
    end

    it 'does not register an offense for `!!` when using `return` keyword' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return !!bar.do_something if condition
          baz
          !!qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location by `define_method`' do
      expect_no_offenses(<<~RUBY)
        define_method :foo? do
          bar
          !!qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location by `define_singleton_method`' do
      expect_no_offenses(<<~RUBY)
        define_singleton_method :foo? do
          bar
          !!qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        ensure
          qux
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue` and `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        ensure
          corge
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `rescue`, `else`, and `ensure`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `unless`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          unless condition_foo?
            !!foo
          end
        end

        def bar?
          unless condition_bar?
            do_something
            !!bar
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `if`, `elsif`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          if condition_foo?
            !!foo
          elsif condition_bar?
            !!bar
          else
            !!baz
          end
        end

        def bar?
          if condition_foo?
            do_something
            !!foo
          elsif condition_bar?
            do_something
            !!bar
          else
            do_something
            !!baz
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` with hash when return location and using `if`, `elsif`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          if condition_foo?
            { foo: !!foo0, bar: bar0, baz: baz0 }
          elsif condition_bar?
            { foo: !!foo1, bar: bar1, baz: baz1 }
          else
            { foo: !!foo2, bar: bar2, baz: baz2 }
          end
        end

        def bar?
          if condition_foo?
            do_something
            { foo: !!foo0, bar: bar0, baz: baz0 }
          elsif condition_bar?
            do_something
            { foo: !!foo1, bar: bar1, baz: baz1 }
          else
            do_something
            { foo: !!foo2, bar: bar2, baz: baz2 }
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` with array when return location and using `if`, `elsif`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          if condition_foo?
            [!!foo0, bar0, baz0]
          elsif condition_bar?
            [!!foo1, bar1, baz1]
          else
            [!!foo2, bar2, baz2]
          end
        end

        def bar?
          if condition_foo?
            do_something
            [!!foo0, bar0, baz0]
          elsif condition_bar?
            do_something
            [!!foo1, bar1, baz1]
          else
            do_something
            [!!foo2, bar2, baz2]
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` when return location and using `case`, `when`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          case condition
          when foo
            !!foo
          when bar
            !!bar
          else
            !!baz
          end
        end

        def bar?
          case condition
          when foo
            do_something
            !!foo
          when bar
            do_something
            !!bar
          else
            do_something
            !!baz
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` with hash when return location and using `case`, `when`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          case condition
          when foo
            { foo: !!foo0, bar: bar0, baz: baz0 }
          when bar
            { foo: !!foo1, bar: bar1, baz: baz1 }
          else
            { foo: !!foo2, bar: bar2, baz: baz2 }
          end
        end

        def bar?
          case condition
          when foo
            do_something
            { foo: !!foo0, bar: bar0, baz: baz0 }
          when bar
            do_something
            { foo: !!foo1, bar: bar1, baz: baz1 }
          else
            do_something
            { foo: !!foo2, bar: bar2, baz: baz2 }
          end
        end
      RUBY
    end

    it 'does not register an offense for `!!` with array when return location and using `case`, `when`, and `else`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          case condition
          when foo
            [!!foo0, bar0, baz0]
          when bar
            [!!foo1, bar1, baz1]
          else
            [!!foo2, bar2, baz2]
          end
        end

        def foo?
          case condition
          when foo
            do_something
            [!!foo0, bar0, baz0]
          when bar
            do_something
            [!!foo1, bar1, baz1]
          else
            do_something
            [!!foo2, bar2, baz2]
          end
        end
      RUBY
    end

    # rubocop:disable RSpec/RepeatedExampleGroupDescription
    context 'Ruby >= 2.7', :ruby27 do
      # rubocop:enable RSpec/RepeatedExampleGroupDescription
      it 'does not register an offense for `!!` when return location and using `case`, `in`, and `else`' do
        expect_no_offenses(<<~RUBY)
          def foo?
            case condition
            in foo
              !!foo
            in bar
              !!bar
            else
              !!baz
            end
          end

          def bar?
            case condition
            in foo
              do_something
              !!foo
            in bar
              do_something
              !!bar
            else
              do_something
              !!baz
            end
          end
        RUBY
      end
    end
  end

  context 'when `EnforcedStyle: forbidden`' do
    let(:enforced_style) { 'forbidden' }

    include_examples 'common'

    it 'registers an offense and corrects for `!!` when return location' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        end
      RUBY
    end

    it 'registers an offense and corrects for `!!` when using `return` keyword' do
      expect_offense(<<~RUBY)
        def foo?
          return !!bar.do_something if condition
                 ^ Avoid the use of double negation (`!!`).
          baz
          !!bar
          ^ Avoid the use of double negation (`!!`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          return !bar.do_something.nil? if condition
          baz
          !bar.nil?
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        ensure
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        ensure
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue` and `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          baz
        ensure
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          baz
        ensure
          qux
        end
      RUBY
    end

    it 'registers an offense for `!!` when return location and using `rescue`, `else`, and `ensure`' do
      expect_offense(<<~RUBY)
        def foo?
          bar
          !!baz.do_something
          ^ Avoid the use of double negation (`!!`).
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          bar
          !baz.do_something.nil?
        rescue
          qux
        else
          quux
        ensure
          corge
        end
      RUBY
    end
  end
end
