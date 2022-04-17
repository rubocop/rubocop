# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RaiseArgs, :config do
  context 'when enforced style is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with a raise with 2 args' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          raise RuntimeError, msg
          ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          raise RuntimeError.new(msg)
        RUBY
      end
    end

    context 'with a raise with 2 args and exception object is assigned to a local variable' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          raise error_class, msg
          ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          raise error_class.new(msg)
        RUBY
      end
    end

    context 'with a raise with exception instantiation and message arguments' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          raise FooError.new, message
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          raise FooError.new(message)
        RUBY
      end
    end

    context 'when used in a ternary expression' do
      it 'registers an offense and autocorrects' do
        expect_offense(<<~RUBY)
          foo ? raise(Ex, 'error') : bar
                ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          foo ? raise(Ex.new('error')) : bar
        RUBY
      end
    end

    context 'when used in a logical and expression' do
      it 'registers an offense and autocorrects' do
        expect_offense(<<~RUBY)
          bar && raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          bar && raise(Ex.new('error'))
        RUBY
      end
    end

    context 'when used in a logical or expression' do
      it 'registers an offense and autocorrects' do
        expect_offense(<<~RUBY)
          bar || raise(Ex, 'error')
                 ^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_correction(<<~RUBY)
          bar || raise(Ex.new('error'))
        RUBY
      end
    end

    context 'with correct + opposite' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          if a
            raise RuntimeError, msg
            ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
          else
            raise Ex.new(msg)
          end
        RUBY

        expect_correction(<<~RUBY)
          if a
            raise RuntimeError.new(msg)
          else
            raise Ex.new(msg)
          end
        RUBY
      end

      it 'reports multiple offenses' do
        expect_offense(<<~RUBY)
          if a
            raise RuntimeError, msg
            ^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
          elsif b
            raise Ex.new(msg)
          else
            raise ArgumentError, msg
            ^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
          end
        RUBY

        expect_correction(<<~RUBY)
          if a
            raise RuntimeError.new(msg)
          elsif b
            raise Ex.new(msg)
          else
            raise ArgumentError.new(msg)
          end
        RUBY
      end
    end

    context 'with a raise with 3 args' do
      it 'reports an offense' do
        expect_offense(<<~RUBY)
          raise RuntimeError, msg, caller
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception object as an argument to `raise`.
        RUBY

        expect_no_corrections
      end
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end

    it 'accepts a raise with an exception argument' do
      expect_no_offenses('raise Ex.new(msg)')
    end

    it 'accepts exception constructor with keyword arguments and message argument' do
      expect_no_offenses('raise MyKwArgError.new(a: 1, b: 2), message')
    end
  end

  context 'when enforced style is exploded' do
    let(:cop_config) { { 'EnforcedStyle' => 'exploded' } }

    context 'with a raise with exception object' do
      context 'with one argument' do
        it 'reports an offense' do
          expect_offense(<<~RUBY)
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<~RUBY)
            raise Ex, msg
          RUBY
        end
      end

      context 'with no arguments' do
        it 'reports an offense' do
          expect_offense(<<~RUBY)
            raise Ex.new
            ^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<~RUBY)
            raise Ex
          RUBY
        end
      end

      context 'when used in a ternary expression' do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY)
            foo ? raise(Ex.new('error')) : bar
                  ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<~RUBY)
            foo ? raise(Ex, 'error') : bar
          RUBY
        end
      end

      context 'when used in a logical and expression' do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY)
            bar && raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<~RUBY)
            bar && raise(Ex, 'error')
          RUBY
        end
      end

      context 'when used in a logical or expression' do
        it 'registers an offense and autocorrects' do
          expect_offense(<<~RUBY)
            bar || raise(Ex.new('error'))
                   ^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          RUBY

          expect_correction(<<~RUBY)
            bar || raise(Ex, 'error')
          RUBY
        end
      end
    end

    context 'with opposite + correct' do
      it 'reports an offense for opposite + correct' do
        expect_offense(<<~RUBY)
          if a
            raise RuntimeError, msg
          else
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          end
        RUBY

        expect_correction(<<~RUBY)
          if a
            raise RuntimeError, msg
          else
            raise Ex, msg
          end
        RUBY
      end

      it 'reports multiple offenses' do
        expect_offense(<<~RUBY)
          if a
            raise RuntimeError, msg
          elsif b
            raise Ex.new(msg)
            ^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          else
            raise ArgumentError.new(msg)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          end
        RUBY

        expect_correction(<<~RUBY)
          if a
            raise RuntimeError, msg
          elsif b
            raise Ex, msg
          else
            raise ArgumentError, msg
          end
        RUBY
      end
    end

    context 'when an exception object is assigned to a local variable' do
      it 'autocorrects to exploded style' do
        expect_offense(<<~RUBY)
          def do_something
            klass = RuntimeError
            raise klass.new('hi')
            ^^^^^^^^^^^^^^^^^^^^^ Provide an exception class and message as arguments to `raise`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def do_something
            klass = RuntimeError
            raise klass, 'hi'
          end
        RUBY
      end
    end

    context 'when exception type is in AllowedCompactTypes' do
      before do
        stub_const('Ex1', StandardError)
        stub_const('Ex2', StandardError)
      end

      let(:cop_config) { { 'EnforcedStyle' => 'exploded', 'AllowedCompactTypes' => ['Ex1'] } }

      it 'accepts exception constructor with no arguments' do
        expect_no_offenses('raise Ex1.new')
      end

      context 'with one argument' do
        it 'accepts exception constructor' do
          expect_no_offenses('raise Ex1.new(msg)')
        end
      end

      context 'with more than one argument' do
        it 'accepts exception constructor' do
          expect_no_offenses('raise Ex1.new(arg1, arg2)')
        end
      end
    end

    it 'accepts exception constructor with more than 1 argument' do
      expect_no_offenses('raise MyCustomError.new(a1, a2, a3)')
    end

    it 'accepts exception constructor with keyword arguments' do
      expect_no_offenses('raise MyKwArgError.new(a: 1, b: 2)')
    end

    it 'accepts a raise with splatted arguments' do
      expect_no_offenses('raise MyCustomError.new(*args)')
    end

    it 'ignores a raise with an exception argument' do
      expect_no_offenses('raise Ex.new(entity), message')
    end

    it 'accepts a raise with 3 args' do
      expect_no_offenses('raise RuntimeError, msg, caller')
    end

    it 'accepts a raise with 2 args' do
      expect_no_offenses('raise RuntimeError, msg')
    end

    it 'accepts a raise when exception object is assigned to a local variable' do
      expect_no_offenses('raise error_class, msg')
    end

    it 'accepts a raise with msg argument' do
      expect_no_offenses('raise msg')
    end

    it 'accepts a raise with `new` method without receiver' do
      expect_no_offenses('raise new')
    end
  end
end
