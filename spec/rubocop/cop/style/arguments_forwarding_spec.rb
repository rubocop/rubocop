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
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, &block)
              ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs and block arg with another method call' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(1, 2, 3)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
          baz(1, 2, 3)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs and block arg twice' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
          baz(...)
        end
      RUBY
    end

    it 'registers an offense when passing restarg and block arg in defs' do
      expect_offense(<<~RUBY)
        def self.foo(*args, &block)
                     ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, &block)
              ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar *args, &block
              ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          do_something do
            bar(*args, &block)
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          obj.bar(*args, &block)
                  ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg for `.()` call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar.(*args, &block)
               ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                  ^^^^^ Use shorthand syntax `...` for arguments forwarding.
            bar(*args)
                ^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                  ^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
            bar(**kwargs)
                ^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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

    it 'does not register an offense for restarg when passing block to separate call' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args).baz(&block)
        end
      RUBY
    end

    it 'does not register an offense for restarg and kwrestarg when passing block to separate call' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          bar(*args, **kwargs).baz(&block)
        end
      RUBY
    end

    it 'does not register an offense for restarg/kwrestarg/block passed to separate methods' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          bar(first(*args), second(**kwargs), third(&block))
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 3.1', :ruby31 do
    it 'registers an offense when using restarg and anonymous block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &)
                ^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, &)
              ^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
                ^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &)
              ^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 3.2', :ruby32 do
    it 'registers an offense when using restarg/kwrestarg forwarding without block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar(*args, **kwargs)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          bar(*, **)
        end
      RUBY
    end

    it 'registers an offense when using separate arg/kwarg forwarding' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(*args)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(**kwargs)
                      ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          args_only(*)
          kwargs_only(**)
        end
      RUBY
    end

    it 'registers an offense when using arg/kwarg forwarding with an additional arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(arg, *args, kwarg:, **kwargs)
                     ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                    ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(*args)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(**kwargs)
                      ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(arg, *, kwarg:, **)
          args_only(*)
          kwargs_only(**)
        end
      RUBY
    end

    it 'registers an offense when using arg/kwarg forwarding with additional forwarded arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(:another_arg, *args)
                                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
          args_only(*args, :another_arg)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(another: :kwarg, **kwargs)
                                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          kwargs_only(**kwargs, another: :kwarg)
                      ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          args_only(:another_arg, *)
          args_only(*, :another_arg)
          kwargs_only(another: :kwarg, **)
          kwargs_only(**, another: :kwarg)
        end
      RUBY
    end

    it 'registers an offense when using arg/kwarg forwarding when leading extra arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(1, *args)
                       ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(foo: :bar, **kwargs)
                                 ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          args_only(1, *)
          kwargs_only(foo: :bar, **)
        end
      RUBY
    end

    it 'registers an offense when using arg/kwarg forwarding with trailing extra arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(*args, 1)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(**kwargs, foo: :bar)
                      ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          args_only(*, 1)
          kwargs_only(**, foo: :bar)
        end
      RUBY
    end

    it 'registers an offense when using arg/kwarg forwarding with surrounding extra arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args_only(1, *args, 2)
                       ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs_only(foo: :bar, **kwargs, bar: :baz)
                                 ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          args_only(1, *, 2)
          kwargs_only(foo: :bar, **, bar: :baz)
        end
      RUBY
    end

    it 'registers an offense only for kwrestarg when using the restarg outside forwarding' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args.do_something
          bar(*args, **kwargs)
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, **)
          args.do_something
          bar(*args, **)
        end
      RUBY
    end

    it 'registers an offense only for kwrestarg when restarg is overwritten' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          args = new_args
          bar(*args, **kwargs)
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, **)
          args = new_args
          bar(*args, **)
        end
      RUBY
    end

    it 'registers an offense only for restarg when using the kwrestarg outside forwarding' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs.do_something
          bar(*args, **kwargs)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **kwargs)
          kwargs.do_something
          bar(*, **kwargs)
        end
      RUBY
    end

    it 'registers an offense only for restarg when kwrestarg is overwritten' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          kwargs = new_kwargs
          bar(*args, **kwargs)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **kwargs)
          kwargs = new_kwargs
          bar(*, **kwargs)
        end
      RUBY
    end

    it 'registers an offense for restarg and kwrestarg when using block outside forwarding' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          block = new_block
          bar(*args, **kwargs, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &block)
          block = new_block
          bar(*, **, &block)
        end
      RUBY
    end

    it 'registers an offense for restarg when passing block to separate call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar(*args).baz(&block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          bar(*).baz(&block)
        end
      RUBY
    end

    it 'registers an offense for restarg and kwrestarg when passing block to separate call' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar(*args, **kwargs).baz(&block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &block)
          bar(*, **).baz(&block)
        end
      RUBY
    end

    it 'registers an offense for restarg and kwrestarg when passing to separate calls' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar(first(*args), second(**kwargs), third(&block))
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                   ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &block)
          bar(first(*), second(**), third(&block))
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          bar(*, &block)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwrestarg and block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs and block arg with another method call' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(1, 2, 3)
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
          baz(1, 2, 3)
        end
      RUBY
    end

    it 'registers an offense when using restarg, kwargs and block arg twice' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(...)
          baz(...)
        end
      RUBY
    end

    it 'registers an offense when passing restarg and block arg in defs' do
      expect_offense(<<~RUBY)
        def self.foo(*args, &block)
                     ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.foo(*, &block)
          bar(*, &block)
        end
      RUBY
    end

    it 'registers an offense when the parentheses of restarg arguments are omitted' do
      expect_offense(<<~RUBY)
        def foo *args
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar *args
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*)
          bar(*)
        end
      RUBY
    end

    it 'registers an offense when the parentheses of kwrestarg arguments are omitted' do
      expect_offense(<<~RUBY)
        def foo **kwargs
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar **kwargs
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(**)
          bar(**)
        end
      RUBY
    end

    it 'registers an offense when the parentheses of restarg/kwrestarg arguments are omitted' do
      expect_offense(<<~RUBY)
        def foo *args, **kwargs
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar *args, **kwargs
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **)
          bar(*, **)
        end
      RUBY
    end

    it 'registers an offense when forwarding to a method in block' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          do_something do
            bar(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          do_something do
            bar(*, &block)
          end
        end
      RUBY
    end

    it 'registers an offense when delegating' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          obj.bar(*args, &block)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          obj.bar(*, &block)
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg for `.()` call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar.(*args, &block)
               ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          bar.(*, &block)
        end
      RUBY
    end

    it 'registers an offense when only forwarding a restarg' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar(*args)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &block)
          bar(*)
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

    it 'does not register an offense when different argument names are used' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*arguments, &block)
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

    context 'UseAnonymousForwarding: false' do
      let(:cop_config) { { 'UseAnonymousForwarding' => false } }

      it 'does not register an offense when using only rest arg' do
        expect_no_offenses(<<~RUBY)
          def foo(*args)
            bar(*args)
          end
        RUBY
      end

      it 'does not register an offense when using rest and block arg' do
        expect_no_offenses(<<~RUBY)
          def foo(*args, &block)
            bar(*args, &block)
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

      it 'does not register an offense when using kwrest and block arg' do
        expect_no_offenses(<<~RUBY)
          def foo(**kwargs, &block)
            bar(**kwargs, &block)
          end
        RUBY
      end

      it 'registers an offense when using restarg, kwrestarg and block arg' do
        expect_offense(<<~RUBY)
          def foo(*args, **kwargs, &block)
                  ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
            bar(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
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
end
