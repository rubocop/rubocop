# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArgumentsForwarding, :config do
  context 'TargetRubyVersion <= 2.6', :ruby26 do
    it 'does not register an offense when using restarg with block arg' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args, &block)
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 2.7', :ruby27 do
    it 'registers an offense when using restarg and block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use arguments forwarding.
          bar(*args, &block)
              ^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs and block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when passing restarg and block arg in defs' do
      expect_offense(<<~RUBY)
        def self.foo(*args, &block)
                     ^^^^^^^^^^^^^ Use arguments forwarding.
          bar(*args, &block)
              ^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when the parentheses of arguments are omitted' do
      expect_offense(<<~RUBY)
        def foo *args, &block
                ^^^^^^^^^^^^^ Use arguments forwarding.
          bar *args, &block
              ^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      # A method definition that uses forwarding arguments without parentheses
      # is a syntax error. e.g. `def do_something ...`
      # Therefore it enforces parentheses with autocorrection.
      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when forwarding to a method in block' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use arguments forwarding.
          do_something do
            bar(*args, &block)
                ^^^^^^^^^^^^^ Use arguments forwarding.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          do_something do
            bar(...)
          end
        end
      RUBY
    end

    it 'registers an offense when delegating' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use arguments forwarding.
          obj.bar(*args, &block)
                  ^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg for `.()` call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use arguments forwarding.
          bar.(*args, &block)
               ^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar.(...)
        end
      RUBY
    end

    it 'does not register an offense when using arguments forwarding' do
      expect_no_offenses(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'does not register an offense when different arguments are used' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args)
        end
      RUBY
    end

    it 'does not register an offense when different argument names are used' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*arguments, &block)
        end
      RUBY
    end

    it 'does not register an offense when the restarg is overwritten' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          args = new_args
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when the kwarg is overwritten' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          kwargs = new_kwargs
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when the block arg is overwritten' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          block = new_block
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when using the restarg outside forwarding method arguments' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          args.do_something
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when assigning the restarg outside forwarding method arguments' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          var = args
          foo(*args, &block)
        end
      RUBY
    end

    it 'does not register an offense when referencing the restarg outside forwarding method arguments' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          args
          foo(*args, &block)
        end
      RUBY
    end

    it 'does not register an offense when body of method definition is empty' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
        end
      RUBY
    end

    context 'AllowOnlyRestArgument: true' do
      let(:cop_config) { { 'AllowOnlyRestArgument' => true } }

      it 'does not register an offense when using only rest arg' do
        expect_no_offenses(<<~RUBY)
          def foo(*args)
            bar(*args)
          end
        RUBY
      end

      it 'does not register an offense when using only kwrest arg' do
        expect_no_offenses(<<~RUBY)
          def foo(**kwargs)
            bar(**kwargs)
          end
        RUBY
      end
    end

    context 'AllowOnlyRestArgument: false' do
      let(:cop_config) { { 'AllowOnlyRestArgument' => false } }

      it 'registers an offense when using only rest arg' do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use arguments forwarding.
            bar(*args)
                ^^^^^ Use arguments forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(...)
            bar(...)
          end
        RUBY
      end

      it 'registers an offense when using only kwrest arg' do
        expect_offense(<<~RUBY)
          def foo(**kwargs)
                  ^^^^^^^^ Use arguments forwarding.
            bar(**kwargs)
                ^^^^^^^^ Use arguments forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(...)
            bar(...)
          end
        RUBY
      end

      it 'does not register an offense with default positional arguments' do
        expect_no_offenses(<<~RUBY)
          def foo(arg=1, *args)
            bar(*args)
          end
        RUBY
      end

      it 'does not register an offense with default keyword arguments' do
        expect_no_offenses(<<~RUBY)
          def foo(*args, arg: 1)
            bar(*args)
          end
        RUBY
      end
    end
  end

  context 'TargetRubyVersion >= 3.1', :ruby31 do
    it 'registers an offense when using restarg and anonymous block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &)
                ^^^^^^^^ Use arguments forwarding.
          bar(*args, &)
              ^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs, and anonymous block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &)
                ^^^^^^^^^^^^^^^^^^ Use arguments forwarding.
          bar(*args, **kwargs, &)
              ^^^^^^^^^^^^^^^^^^ Use arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end
  end
end
