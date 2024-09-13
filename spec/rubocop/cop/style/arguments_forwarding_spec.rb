# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArgumentsForwarding, :config do
  let(:cop_config) do
    {
      'RedundantRestArgumentNames' => redundant_rest_argument_names,
      'RedundantKeywordRestArgumentNames' => redundant_keyword_rest_argument_names,
      'RedundantBlockArgumentNames' => redundant_block_argument_names
    }
  end
  let(:redundant_rest_argument_names) { %w[args arguments] }
  let(:redundant_keyword_rest_argument_names) { %w[kwargs options opts] }
  let(:redundant_block_argument_names) { %w[blk block proc] }

  context 'TargetRubyVersion <= 2.6', :ruby26, unsupported_on: :prism do
    it 'does not register an offense when using restarg with block arg' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args, &block)
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 2.7', :ruby27 do
    it 'registers an offense when using restarg and block arg', unsupported_on: :prism do
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

    it 'registers an offense when passing restarg and block arg in defs', unsupported_on: :prism do
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

    it 'registers an offense when the parentheses of arguments are omitted', unsupported_on: :prism do
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

    it 'registers an offense when forwarding to a method in block', unsupported_on: :prism do
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

    it 'registers an offense when delegating', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          obj.bar(*args, &block)
                  ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg for `.()` call', unsupported_on: :prism do
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

    it 'does not register an offense when using block arg', :ruby30, unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(&block)
          bar(&block)
        end
      RUBY
    end

    it 'registers an offense when using block arg', :ruby31 do
      expect_offense(<<~RUBY)
        def foo(&block)
                ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(&block)
              ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(&)
          bar(&)
        end
      RUBY
    end

    it 'does not register an offense when naming block arg `&`', :ruby31 do
      expect_no_offenses(<<~RUBY)
        def foo(&)
          bar(&)
        end
      RUBY
    end

    it 'does not register an offense when using block arg in nested method definitions', :ruby32 do
      expect_no_offenses(<<~RUBY)
        def foo(x)
          class << x
            def bar(y, &)
              baz.qux(&)
            end
          end
        end
      RUBY
    end

    context 'when `RedundantBlockArgumentNames: [meaningless_block_name]`' do
      let(:redundant_block_argument_names) { ['meaningless_block_name'] }

      it 'registers an offense when using restarg and block arg', unsupported_on: :prism do
        expect_offense(<<~RUBY)
          def foo(*args, &meaningless_block_name)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
            bar(*args, &meaningless_block_name)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(...)
            bar(...)
          end
        RUBY
      end

      it 'does not register an offense when using restarg and unconfigured block arg', unsupported_on: :prism do
        expect_no_offenses(<<~RUBY)
          def foo(*args, &block)
            bar(*args, &block)
          end
        RUBY
      end

      it 'registers an offense when using restarg and block arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args, &meaningless_block_name)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
                         ^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous block arguments forwarding (`&`).
            bar(*args, &meaningless_block_name)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous block arguments forwarding (`&`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*, &)
            bar(*, &)
          end
        RUBY
      end

      it 'registers an offense when using restarg and unconfigured block arg', :ruby32 do
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
    end

    it 'does not register an offense when using arguments forwarding' do
      expect_no_offenses(<<~RUBY)
        def foo(...)
          bar(...)
        end
      RUBY
    end

    it 'does not register an offense when different arguments are used', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args)
        end
      RUBY
    end

    it 'does not register an offense when different argument names are used' do
      expect_no_offenses(<<~RUBY)
        def foo(arg)
          bar(argument)
        end
      RUBY
    end

    it 'does not register an offense when different splat argument names are used', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*arguments, &block)
        end
      RUBY
    end

    it 'does not register an offense when different kwrest argument names are used', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(**kwargs, &block)
          bar(**kwarguments, &block)
        end
      RUBY
    end

    it 'does not register an offense when the restarg is overwritten', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          args = new_args
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when the kwarg is overwritten', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          kwargs = new_kwargs
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when the block arg is overwritten', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          block = new_block
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when using the restarg outside forwarding method arguments', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          args.do_something
          bar(*args, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when assigning the restarg outside forwarding method arguments', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          var = args
          foo(*args, &block)
        end
      RUBY
    end

    it 'does not register an offense when referencing the restarg outside forwarding method arguments', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          args
          foo(*args, &block)
        end
      RUBY
    end

    it 'does not register an offense when not always passing the block as well as restarg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args, &block)
          baz(*args)
        end
      RUBY
    end

    it 'does not register an offense when not always passing the block as well as kwrestarg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(**kwargs, &block)
          bar(**kwargs, &block)
          baz(**kwargs)
        end
      RUBY
    end

    it 'does not register an offense when not always forwarding all', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          bar(*args, **kwargs, &block)
          bar(*args, &block)
          bar(**kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense when always forwarding the block but not other args', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args, &block)
          bar(&block)
        end
      RUBY
    end

    it 'does not register an offense when body of method definition is empty' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
        end
      RUBY
    end

    it 'does not register an offense with arg destructuring', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo((bar, baz), **kwargs)
          forwarded(bar, baz, **kwargs)
        end
      RUBY
    end

    it 'does not register an offense with an additional kwarg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(first:, **kwargs, &block)
          forwarded(**kwargs, &block)
        end
      RUBY
    end

    context 'AllowOnlyRestArgument: true' do
      let(:cop_config) { { 'AllowOnlyRestArgument' => true } }

      it 'does not register an offense when using only rest arg', unsupported_on: :prism do
        expect_no_offenses(<<~RUBY)
          def foo(*args)
            bar(*args)
          end
        RUBY
      end

      it 'does not register an offense when using only kwrest arg', unsupported_on: :prism do
        expect_no_offenses(<<~RUBY)
          def foo(**kwargs)
            bar(**kwargs)
          end
        RUBY
      end

      it 'registers an offense when using only rest arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*)
            bar(*)
          end
        RUBY
      end

      it 'registers an offense when using only kwrest arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(**kwargs)
                  ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
            bar(**kwargs)
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(**)
            bar(**)
          end
        RUBY
      end
    end

    context 'AllowOnlyRestArgument: false' do
      let(:cop_config) { { 'AllowOnlyRestArgument' => false } }

      it 'registers an offense when using only rest arg', unsupported_on: :prism do
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

      it 'registers an offense when using only kwrest arg', unsupported_on: :prism do
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

      it 'does not register an offense with default positional arguments', unsupported_on: :prism do
        expect_no_offenses(<<~RUBY)
          def foo(arg=1, *args)
            bar(*args)
          end
        RUBY
      end

      it 'does not register an offense with default keyword arguments', unsupported_on: :prism do
        expect_no_offenses(<<~RUBY)
          def foo(*args, arg: 1)
            bar(*args)
          end
        RUBY
      end

      it 'registers an offense when using only rest arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*)
            bar(*)
          end
        RUBY
      end

      it 'registers an offense when using only rest arg in `yield`', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            yield(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*)
            yield(*)
          end
        RUBY
      end

      it 'registers an offense when using only rest arg in brackets', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar[*args]
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*)
            bar[*]
          end
        RUBY
      end

      it 'registers an offense when using only kwrest arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(**kwargs)
                  ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
            bar(**kwargs)
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(**)
            bar(**)
          end
        RUBY
      end

      it 'registers an offense with default positional arguments', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(arg=1, *args)
                         ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(arg=1, *)
            bar(*)
          end
        RUBY
      end

      it 'registers an offense with default keyword arguments', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args, arg: 1)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*, arg: 1)
            bar(*)
          end
        RUBY
      end
    end

    it 'does not register an offense for restarg when passing block to separate call', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          bar(*args).baz(&block)
        end
      RUBY
    end

    it 'does not register an offense for restarg and kwrestarg when passing block to separate call', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          bar(*args, **kwargs).baz(&block)
        end
      RUBY
    end

    it 'does not register an offense for restarg/kwrestarg/block passed to separate methods', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs, &block)
          bar(first(*args), second(**kwargs), third(&block))
        end
      RUBY
    end

    it 'does not register an offense if an additional positional parameter is present', unsupported_on: :prism do
      # Technically, forward-all supports leading additional arguments in Ruby >= 2.7.3, but for
      # simplicity we do not correct for any Ruby < 3.0
      # https://github.com/rubocop/rubocop/issues/12087#issuecomment-1662972732
      expect_no_offenses(<<~RUBY)
        def method_missing(m, *args, **kwargs, &block)
          if @template.respond_to?(m)
            @template.send(m, *args, **kwargs, &block)
          else
            super
          end
        end
      RUBY
    end

    it 'registers an offense if an additional positional parameter is present', :ruby30 do
      expect_offense(<<~RUBY)
        def method_missing(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          if @template.respond_to?(m)
            @template.send(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          else
            super
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def method_missing(m, ...)
          if @template.respond_to?(m)
            @template.send(m, ...)
          else
            super
          end
        end
      RUBY
    end

    it 'registers an offense if an additional positional parameter is present in method forwarding with safe navigation', :ruby30 do
      expect_offense(<<~RUBY)
        def method_missing(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          obj.foo(m, *args, **kwargs, &block)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method_missing(m, ...)
          obj.foo(m, ...)
        end
      RUBY
    end

    it 'registers an offense if an additional positional parameter is present in `super`', :ruby30 do
      expect_offense(<<~RUBY)
        def method_missing(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          super(m, *args, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method_missing(m, ...)
          super(m, ...)
        end
      RUBY
    end

    it 'does not register an offense if kwargs are forwarded with a positional parameter', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, **kwargs, &block)
          bar(m, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense if args are forwarded with a positional parameter last', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, &block)
          bar(*args, m, &block)
        end
      RUBY
    end

    it 'does not register an offense if args/kwargs are forwarded with a positional parameter', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
          bar(m, *args, **kwargs, &block)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with a positional parameter', :ruby30 do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(m, *args, **kwargs, &block)
                 ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, ...)
          bar(m, ...)
        end
      RUBY
    end

    it 'does not register an offense when forwarding args/kwargs with an additional arg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def self.get(*args, **kwargs, &block)
          CanvasHttp.request(Net::HTTP::Get, *args, **kwargs, &block)
        end
      RUBY
    end

    it 'registers an offense when forwarding args/kwargs with an additional arg', :ruby30 do
      expect_offense(<<~RUBY)
        def self.get(*args, **kwargs, &block)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          CanvasHttp.request(Net::HTTP::Get, *args, **kwargs, &block)
                                             ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.get(...)
          CanvasHttp.request(Net::HTTP::Get, ...)
        end
      RUBY
    end

    it 'does not register an offense when forwarding args with an additional arg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def post(*args, &block)
          future_on(executor, *args, &block)
        end
      RUBY
    end

    it 'registers an offense when args are forwarded at several call sites' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(*args, **kwargs, &block)
              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.

          if something?
            baz(*args, **kwargs, &block)
                ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          baz(...)

          if something?
            baz(...)
          end
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 3.0', :ruby30 do
    it 'does not register an offense if args are forwarded with a positional parameter last', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, &block)
          bar(*args, m, &block)
        end
      RUBY
    end

    it 'does not register an offense with an additional required kwarg that is not forwarded', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(first:, **kwargs, &block)
          forwarded(**kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense with an additional required kwarg that is forwarded', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(first:, **kwargs, &block)
          forwarded(first: first, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense with an additional optional kwarg that is not forwarded', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(first: nil, **kwargs, &block)
          forwarded(**kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense with an additional optional kwarg that is forwarded', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(first: nil, **kwargs, &block)
          forwarded(first: first, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense if args/kwargs are forwarded with a positional parameter last', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
          bar(*args, m, **kwargs, &block)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with a positional parameter' do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(m, *args, **kwargs, &block)
                 ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, ...)
          bar(m, ...)
        end
      RUBY
    end

    it 'registers an offense when args are forwarded at several call sites' do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(m, *args, **kwargs, &block)
                 ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.

          if something?
            baz(m, *args, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, ...)
          baz(m, ...)

          if something?
            baz(m, ...)
          end
        end
      RUBY
    end

    it 'does not register an offense if args/kwargs are forwarded with additional pre-kwarg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
          bar(m, *args, extra: :kwarg, **kwargs, &block)
        end
      RUBY
    end

    it 'does not register an offense if args/kwargs are forwarded with additional post-kwarg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
          bar(m, *args, **kwargs, extra: :kwarg, &block)
        end
      RUBY
    end

    it 'registers an offense when forwarding args after dropping an additional arg', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(x, *args, &block)
                   ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(*args, &block)
              ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, ...)
          bar(...)
        end
      RUBY
    end

    it 'registers no offense when forwarding args with a leading default arg', unsupported_on: :prism do
      expect_no_offenses(<<~RUBY)
        def foo(x, y = 42, *args, &block)
          bar(x, y, *args, &block)
        end
      RUBY
    end

    it 'registers an offense when forwarding args with an additional arg', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def post(*args, &block)
                 ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          future_on(executor, *args, &block)
                              ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def post(...)
          future_on(executor, ...)
        end
      RUBY
    end

    it 'registers an offense when forwarding args/kwargs with an additional arg' do
      expect_offense(<<~RUBY)
        def self.get(*args, **kwargs, &block)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          CanvasHttp.request(Net::HTTP::Get, *args, **kwargs, &block)
                                             ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.get(...)
          CanvasHttp.request(Net::HTTP::Get, ...)
        end
      RUBY
    end

    it 'registers an offense when forwarding kwargs/block arg', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(**kwargs, &block)
                ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(**kwargs, &block)
              ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          baz(...)
        end
      RUBY
    end

    it 'registers an offense when forwarding kwargs/block arg and an additional arg', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(x, **kwargs, &block)
                   ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          baz(x, **kwargs, &block)
                 ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, ...)
          baz(x, ...)
        end
      RUBY
    end

    it 'registers an offense when forwarding kwargs/block arg with non-matching additional args', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(**kwargs, &block)
                ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(baz, 'qux', quux&.corge, @grault, 42, **kwargs, &block)
                                                    ^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(...)
          bar(baz, 'qux', quux&.corge, @grault, 42, ...)
        end
      RUBY
    end

    context 'AllowOnlyRestArgument: false' do
      let(:cop_config) { { 'AllowOnlyRestArgument' => false } }

      it 'registers an offense when using only rest arg', unsupported_on: :prism do
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

      it 'registers an offense when using only rest arg', :ruby32 do
        expect_offense(<<~RUBY)
          def foo(*args)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            bar(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*)
            bar(*)
          end
        RUBY
      end
    end
  end

  context 'TargetRubyVersion 3.1', :ruby31, unsupported_on: :prism do
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

    it 'registers an offense when using block arg forwarding with positional arguments forwarding' do
      expect_offense(<<~RUBY)
        def baz(qux, quuz, &block)
                           ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(qux, quuz, &block)
                         ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def baz(qux, quuz, &)
          bar(qux, quuz, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding args with a leading default arg', unsupported_on: :prism do
      expect_offense(<<~RUBY)
        def foo(x, y = 42, *args, &block)
                           ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          bar(x, y, *args, &block)
                    ^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, y = 42, ...)
          bar(x, y, ...)
        end
      RUBY
    end

    # `anonymous block parameter is also used within block (SyntaxError)` occurs in Ruby 3.3.0:
    it 'does not register an offense when using block arg forwarding with positional arguments forwarding to within block' do
      expect_no_offenses(<<~RUBY)
        def baz(qux, quuz, &block)
          with_block do
            bar(qux, quuz, &block)
          end
        end
      RUBY
    end

    it 'registers an offense when using block arg forwarding with no forwarding arguments' do
      expect_offense(<<~RUBY)
        def before_transition(options = {}, &block)
                                            ^^^^^^ Use anonymous block arguments forwarding (`&`).
          add_callback(type: :before, callback_class: Callback, from: options[:from], to: options[:to], &block)
                                                                                                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def before_transition(options = {}, &)
          add_callback(type: :before, callback_class: Callback, from: options[:from], to: options[:to], &)
        end
      RUBY
    end
  end

  context 'TargetRubyVersion >= 3.2', :ruby32 do
    it 'registers an offense when the parentheses of arguments are omitted' do
      expect_offense(<<~RUBY)
        def foo *args, &block
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar *args, &block
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*, &)
        end
      RUBY
    end

    it 'registers an offense when using block arg' do
      expect_offense(<<~RUBY)
        def foo(&block)
                ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(&block)
              ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(&)
          bar(&)
        end
      RUBY
    end

    it 'registers an offense when the restarg is overwritten' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          args = new_args
          bar(*args, **kwargs, &block)
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                               ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, **, &)
          args = new_args
          bar(*args, **, &)
        end
      RUBY
    end

    it 'registers an offense when the kwarg is overwritten' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          kwargs = new_kwargs
          bar(*args, **kwargs, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                               ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **kwargs, &)
          kwargs = new_kwargs
          bar(*, **kwargs, &)
        end
      RUBY
    end

    it 'registers an offense when using the restarg outside forwarding method arguments' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          args.do_something
          bar(*args, **kwargs, &block)
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                               ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, **, &)
          args.do_something
          bar(*args, **, &)
        end
      RUBY
    end

    it 'registers an offense if kwargs are forwarded with a positional parameter' do
      expect_offense(<<~RUBY)
        def foo(m, **kwargs, &block)
                   ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                             ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(m, **kwargs, &block)
                 ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                           ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, **, &)
          bar(m, **, &)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with a positional parameter last' do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                    ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, m, **kwargs, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                        ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                  ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, **, &)
          bar(*, m, **, &)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with additional pre-kwarg' do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                    ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(m, *args, extra: :kwarg, **kwargs, &block)
                 ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, **, &)
          bar(m, *, extra: :kwarg, **, &)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with additional post-kwarg' do
      expect_offense(<<~RUBY)
        def foo(m, *args, **kwargs, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                    ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(m, *args, **kwargs, extra: :kwarg, &block)
                 ^^^^^ Use anonymous positional arguments forwarding (`*`).
                        ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, **, &)
          bar(m, *, **, extra: :kwarg, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding args after dropping an additional arg' do
      expect_offense(<<~RUBY)
        def foo(x, *args, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, *, &)
          bar(*, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding args with a leading default arg' do
      expect_offense(<<~RUBY)
        def foo(x, y = 42, *args, &block)
                           ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                  ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(x, y, *args, &block)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
                           ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, y = 42, *, &)
          bar(x, y, *, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding kwargs/block arg' do
      expect_offense(<<~RUBY)
        def foo(**kwargs, &block)
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          baz(**kwargs, &block)
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(**, &)
          baz(**, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding kwargs/block arg and an additional arg' do
      expect_offense(<<~RUBY)
        def foo(x, **kwargs, &block)
                   ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                             ^^^^^^ Use anonymous block arguments forwarding (`&`).
          baz(x, **kwargs, &block)
                 ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                           ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(x, **, &)
          baz(x, **, &)
        end
      RUBY
    end

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

    it 'registers an offense when using restarg and anonymous block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          bar(*args, &)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*, &)
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

    it 'registers an offense when an additional positional parameter is present without block' do
      expect_offense(<<~RUBY)
        def method_missing(m, *args, **kwargs)
                              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          if @template.respond_to?(m)
            @template.send(m, *args, **kwargs)
                              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          else
            super
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def method_missing(m, *, **)
          if @template.respond_to?(m)
            @template.send(m, *, **)
          else
            super
          end
        end
      RUBY
    end

    it 'registers an offense when an additional positional parameter is present' do
      expect_offense(<<~RUBY)
        def method_missing(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          if @template.respond_to?(m)
            @template.send(m, *args, **kwargs, &block)
                              ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          else
            super
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def method_missing(m, ...)
          if @template.respond_to?(m)
            @template.send(m, ...)
          else
            super
          end
        end
      RUBY
    end

    it 'registers an offense when args are forwarded with a positional parameter last' do
      expect_offense(<<~RUBY)
        def foo(m, *args, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, m, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, &)
          bar(*, m, &)
        end
      RUBY
    end

    it 'registers an offense when args are forwarded with a positional parameter last in method forwarding with safe navigation' do
      expect_offense(<<~RUBY)
        def foo(m, *args, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          obj&.bar(*args, m, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                             ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, &)
          obj&.bar(*, m, &)
        end
      RUBY
    end

    it 'registers an offense when args are forwarded with a positional parameter last in `super`' do
      expect_offense(<<~RUBY)
        def foo(m, *args, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          super(*args, m, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, &)
          super(*, m, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding args with an additional arg' do
      expect_offense(<<~RUBY)
        def post(*args, &block)
                 ^^^^^ Use anonymous positional arguments forwarding (`*`).
                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
          future_on(executor, *args, &block)
                              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def post(*, &)
          future_on(executor, *, &)
        end
      RUBY
    end

    it 'registers an offense when forwarding args/kwargs with an additional arg' do
      expect_offense(<<~RUBY)
        def self.get(*args, **kwargs, &block)
                     ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
          CanvasHttp.request(Net::HTTP::Get, *args, **kwargs, &block)
                                             ^^^^^^^^^^^^^^^^^^^^^^^ Use shorthand syntax `...` for arguments forwarding.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.get(...)
          CanvasHttp.request(Net::HTTP::Get, ...)
        end
      RUBY
    end

    it 'registers an offense if args/kwargs are forwarded with additional arg/kwarg' do
      expect_offense(<<~RUBY)
        def foo(m, *args, foo:, **kwargs, &block)
                   ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(m, *args, foo:, extra: :kwarg, **kwargs, &block)
                 ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                             ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(m, *, foo:, **, &)
          bar(m, *, foo:, extra: :kwarg, **, &)
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

    it 'registers an offense for kwarg forwarding with arg destructuring' do
      expect_offense(<<~RUBY)
        def foo((bar, baz), **kwargs)
                            ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          forwarded(bar, baz, **kwargs)
                              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo((bar, baz), **)
          forwarded(bar, baz, **)
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

    it 'registers an offense when not always passing the block as well as restarg' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
          baz(*args)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*, &)
          baz(*)
        end
      RUBY
    end

    it 'registers an offense when not always passing the block as well as kwrestarg' do
      expect_offense(<<~RUBY)
        def foo(**kwargs, &block)
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          bar(**kwargs, &block)
                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          baz(**kwargs)
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(**, &)
          bar(**, &)
          baz(**)
        end
      RUBY
    end

    it 'registers an offense when not always forwarding all' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, **kwargs, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                               ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(**kwargs, &block)
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                        ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &)
          bar(*, **, &)
          bar(*, &)
          bar(**, &)
        end
      RUBY
    end

    it 'registers an offense when always forwarding the block but not other args' do
      expect_offense(<<~RUBY)
        def foo(*, &block)
                   ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*, &block)
                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(&block)
              ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*, &)
          bar(&)
        end
      RUBY
    end

    it 'registers an offense when args are forwarded at several call sites' do
      expect_offense(<<~RUBY)
        def foo(bar, *args)
                     ^^^^^ Use anonymous positional arguments forwarding (`*`).
          baz(*args)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).

          if something?
            baz(*args)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(bar, *)
          baz(*)

          if something?
            baz(*)
          end
        end
      RUBY
    end

    it 'registers an offense when kwargs are forwarded at several call sites' do
      expect_offense(<<~RUBY)
        def foo(bar, **kwargs)
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          baz(**kwargs)
              ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).

          if something?
            baz(**kwargs)
                ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(bar, **)
          baz(**)

          if something?
            baz(**)
          end
        end
      RUBY
    end

    it 'registers an offense for restarg when passing block to separate call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args).baz(&block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                         ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*).baz(&)
        end
      RUBY
    end

    it 'registers an offense for restarg and kwrestarg when passing block to separate call' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, **kwargs).baz(&block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                   ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &)
          bar(*, **).baz(&)
        end
      RUBY
    end

    it 'registers an offense for restarg and kwrestarg when passing to separate calls' do
      expect_offense(<<~RUBY)
        def foo(*args, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                 ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(first(*args), second(**kwargs), third(&block))
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                   ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                                    ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, **, &)
          bar(first(*), second(**), third(&))
        end
      RUBY
    end

    it 'registers an offense with an additional required kwarg that is not forwarded' do
      expect_offense(<<~RUBY)
        def foo(first:, **kwargs, &block)
                        ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                  ^^^^^^ Use anonymous block arguments forwarding (`&`).
          forwarded(**kwargs, &block)
                    ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                              ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(first:, **, &)
          forwarded(**, &)
        end
      RUBY
    end

    it 'registers an offense with an additional required kwarg that is forwarded' do
      expect_offense(<<~RUBY)
        def foo(first:, **kwargs, &block)
                        ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                  ^^^^^^ Use anonymous block arguments forwarding (`&`).
          forwarded(first: first, **kwargs, &block)
                                  ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                            ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(first:, **, &)
          forwarded(first: first, **, &)
        end
      RUBY
    end

    it 'registers an offense with an additional optional kwarg that is not forwarded' do
      expect_offense(<<~RUBY)
        def foo(first: nil, **kwargs, &block)
                            ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                      ^^^^^^ Use anonymous block arguments forwarding (`&`).
          forwarded(first:, **kwargs, &block)
                            ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                      ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(first: nil, **, &)
          forwarded(first:, **, &)
        end
      RUBY
    end

    it 'registers an offense with an additional optional kwarg that is forwarded' do
      expect_offense(<<~RUBY)
        def foo(first: nil, **kwargs, &block)
                            ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                      ^^^^^^ Use anonymous block arguments forwarding (`&`).
          forwarded(first: first, **kwargs, &block)
                                  ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                            ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(first: nil, **, &)
          forwarded(first: first, **, &)
        end
      RUBY
    end

    it 'registers an offense with an arg and additional optional kwarg that is forwarded' do
      expect_offense(<<~RUBY)
        def foo(*args, first: nil, **kwargs, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                   ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                             ^^^^^^ Use anonymous block arguments forwarding (`&`).
          forwarded(*args, first: first, **kwargs, &block)
                    ^^^^^ Use anonymous positional arguments forwarding (`*`).
                                         ^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
                                                   ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, first: nil, **, &)
          forwarded(*, first: first, **, &)
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar(*, &)
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
                            ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*args, &block)
              ^^^^^ Use anonymous positional arguments forwarding (`*`).
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.foo(*, &)
          bar(*, &)
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

    it 'does not register an offense when rest arguments forwarding to a method in block' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          do_something do
            bar(*args, &block)
          end
        end
      RUBY
    end

    it 'does not register an offense when rest arguments forwarding to a method in numbered block' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, &block)
          do_something do
            bar(*args, &block)
            baz(_1)
          end
        end
      RUBY
    end

    it 'does not register an offense when keyword rest arguments forwarding to a method in block' do
      expect_no_offenses(<<~RUBY)
        def foo(**kwargs, &block)
          do_something do
            bar(**kwargs, &block)
          end
        end
      RUBY
    end

    it 'does not register an offense when keyword rest arguments forwarding to a method in numbered block' do
      expect_no_offenses(<<~RUBY)
        def foo(**kwargs, &block)
          do_something do
            bar(**kwargs, &block)
            baz(_1)
          end
        end
      RUBY
    end

    it 'does not register an offense when rest arguments and keyword rest arguments forwarding to a method in block' do
      expect_no_offenses(<<~RUBY)
        def foo(*args, **kwargs)
          block_method do
            bar(*args, **kwargs)
          end
        end
      RUBY
    end

    it 'registers an offense when delegating' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          obj.bar(*args, &block)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
                         ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          obj.bar(*, &)
        end
      RUBY
    end

    it 'registers an offense when using restarg and block arg for `.()` call' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                ^^^^^ Use anonymous positional arguments forwarding (`*`).
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar.(*args, &block)
               ^^^^^ Use anonymous positional arguments forwarding (`*`).
                      ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*, &)
          bar.(*, &)
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
        def foo(arg)
          bar(argument)
        end
      RUBY
    end

    it 'registers an offense when different splat argument names are used' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(*arguments, &block)
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, &)
          bar(*arguments, &)
        end
      RUBY
    end

    it 'registers an offense when different kwrest argument names are used' do
      expect_offense(<<~RUBY)
        def foo(**kwargs, &block)
                          ^^^^^^ Use anonymous block arguments forwarding (`&`).
          bar(**kwarguments, &block)
                             ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(**kwargs, &)
          bar(**kwarguments, &)
        end
      RUBY
    end

    it 'registers an offense when assigning the restarg outside forwarding method arguments' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          var = args
          foo(*args, &block)
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, &)
          var = args
          foo(*args, &)
        end
      RUBY
    end

    it 'registers an offense when referencing the restarg outside forwarding method arguments' do
      expect_offense(<<~RUBY)
        def foo(*args, &block)
                       ^^^^^^ Use anonymous block arguments forwarding (`&`).
          args
          foo(*args, &block)
                     ^^^^^^ Use anonymous block arguments forwarding (`&`).
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args, &)
          args
          foo(*args, &)
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

      it 'does not register an offense when using only block arg' do
        expect_no_offenses(<<~RUBY)
          def foo(&block)
            bar(&block)
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

      it 'does not register an offense when using restarg, kwrestarg and block arg' do
        expect_no_offenses(<<~RUBY)
          def foo(*args, **kwargs, &block)
            args_nly(*args)
            kwargs_nly(**kwargs)
            block_nly(&block)
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

    context 'when `RedundantRestArgumentNames: [meaningless_restarg_name]`' do
      let(:redundant_rest_argument_names) { ['meaningless_restarg_name'] }

      it 'registers an offense when using separate arg/kwarg forwarding' do
        expect_offense(<<~RUBY)
          def foo(*meaningless_restarg_name, **options)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous positional arguments forwarding (`*`).
                                             ^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
            args_only(*meaningless_restarg_name)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous positional arguments forwarding (`*`).
            kwargs_only(**options)
                        ^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*, **)
            args_only(*)
            kwargs_only(**)
          end
        RUBY
      end

      it 'registers an offense when using separate unconfigured arg/kwarg forwarding' do
        expect_offense(<<~RUBY)
          def foo(*args, **options)
                         ^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
            args_only(*args)
            kwargs_only(**options)
                        ^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*args, **)
            args_only(*args)
            kwargs_only(**)
          end
        RUBY
      end
    end

    context 'when `RedundantKeywordRestArgumentNames: [meaningless_kwrestarg_name]`' do
      let(:redundant_keyword_rest_argument_names) { ['meaningless_kwrestarg_name'] }

      it 'registers an offense when using separate arg/kwarg forwarding' do
        expect_offense(<<~RUBY)
          def foo(*args, **meaningless_kwrestarg_name)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
            args_only(*args)
                      ^^^^^ Use anonymous positional arguments forwarding (`*`).
            kwargs_only(**meaningless_kwrestarg_name)
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use anonymous keyword arguments forwarding (`**`).
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*, **)
            args_only(*)
            kwargs_only(**)
          end
        RUBY
      end

      it 'registers an offense when using separate arg/unconfigured kwarg forwarding' do
        expect_offense(<<~RUBY)
          def foo(*args, **options)
                  ^^^^^ Use anonymous positional arguments forwarding (`*`).
            args_only(*args)
                      ^^^^^ Use anonymous positional arguments forwarding (`*`).
            kwargs_only(**options)
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(*, **options)
            args_only(*)
            kwargs_only(**options)
          end
        RUBY
      end
    end
  end
end
