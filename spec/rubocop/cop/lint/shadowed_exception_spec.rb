# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ShadowedException, :config do
  context 'modifier rescue' do
    it 'accepts rescue in its modifier form' do
      expect_no_offenses('foo rescue nil')
    end
  end

  context 'single rescue' do
    it 'accepts an empty rescue' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing a single exception' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Exception
          handle_exception
        end
      RUBY
    end

    it 'rescue a exception without causing constant name deprecation warning' do
      expect do
        expect_no_offenses(<<~RUBY)
          def foo
            something
          rescue TimeoutError
            handle_exception
          end
        RUBY
      end.not_to output(/.*TimeoutError is deprecated/).to_stderr
    end

    it 'accepts rescuing a single custom exception' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue NonStandardException
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing a custom exception and a standard exception' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Error, NonStandardException
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing multiple custom exceptions' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue CustomError, NonStandardException
          handle_exception
        end
      RUBY
    end

    it 'accepts rescue containing multiple same error code exceptions' do
      # System dependent error code depends on runtime environment.
      stub_const('Errno::EAGAIN::Errno', 35)
      stub_const('Errno::EWOULDBLOCK::Errno', 35)
      stub_const('Errno::ECONNABORTED::Errno', 53)

      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::ECONNABORTED
          handle_exception
        end
      RUBY
    end

    it 'registers an offense rescuing exceptions that are ancestors of each other' do
      expect_offense(<<~RUBY)
        def
          something
        rescue StandardError, RuntimeError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_exception
        end
      RUBY
    end

    it 'registers an offense rescuing Exception with any other error or exception' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue NonStandardError, Exception
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing a single exception that is assigned to a variable' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Exception => e
          handle_exception(e)
        end
      RUBY
    end

    it 'accepts rescuing a single exception that has an ensure' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Exception
          handle_exception
        ensure
          everything_is_ok
        end
      RUBY
    end

    it 'accepts rescuing a single exception that has an else' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue Exception
          handle_exception
        else
          handle_non_exception
        end
      RUBY
    end

    it 'accepts rescuing a multiple exceptions that are not ancestors that have an else' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue NoMethodError, ZeroDivisionError
          handle_exception
        else
          handle_non_exception
        end
      RUBY
    end

    context 'when there are multiple levels of exceptions in the same rescue' do
      it 'registers an offense for two exceptions' do
        expect_offense(<<~RUBY)
          begin
            something
          rescue StandardError, NameError
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
            foo
          end
        RUBY
      end

      it 'registers an offense for more than two exceptions' do
        expect_offense(<<~RUBY)
          begin
            something
          rescue StandardError, NameError, NoMethodError
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
            foo
          end
        RUBY
      end
    end

    it 'registers an offense for the same exception multiple times' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue NameError, NameError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          foo
        end
      RUBY
    end

    it 'accepts splat arguments passed to rescue' do
      expect_no_offenses(<<~RUBY)
        begin
          a
        rescue *FOO
          b
        end
      RUBY
    end
  end

  context 'multiple rescues' do
    it 'registers an offense when a higher level exception is rescued before ' \
       'a lower level exception' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue NoMethodError
          handle_no_method_error
        rescue Exception
        ^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_exception
        rescue StandardError
          handle_standard_error
        end
      RUBY
    end

    it 'registers an offense when a higher level exception is rescued before ' \
       'a lower level exception when there are multiple exceptions ' \
       'rescued in a group' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue Exception
        ^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_exception
        rescue NoMethodError, ZeroDivisionError
          handle_standard_error
        end
      RUBY
    end

    it 'registers an offense for two exceptions when there are ' \
       'multiple levels of exceptions in the same rescue' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue ZeroDivisionError
          handle_exception
        rescue NoMethodError, StandardError
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_standard_error
        end
      RUBY
    end

    it 'registers an offense rescuing out of order exceptions when there is an ensure' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue Exception
        ^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          handle_exception
        rescue StandardError
          handle_standard_error
        ensure
          everything_is_ok
        end
      RUBY
    end

    it 'accepts rescuing exceptions in order of level' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue StandardError
          handle_standard_error
        rescue Exception
          handle_exception
        end
      RUBY
    end

    it 'accepts many (>= 7) rescue groups' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue StandardError
          handle_error
        rescue ErrorA
          handle_error
        rescue ErrorB
          handle_error
        rescue ErrorC
          handle_error
        rescue ErrorD
          handle_error
        rescue ErrorE
          handle_error
        rescue ErrorF
          handle_error
        end
      RUBY
    end

    it 'accepts rescuing exceptions in order of level with multiple exceptions in a group' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue NoMethodError, ZeroDivisionError
          handle_standard_error
        rescue Exception
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing exceptions in order of level with multiple ' \
       'exceptions in a group with custom exceptions' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue NonStandardError, NoMethodError
          handle_standard_error
        rescue Exception
          handle_exception
        end
      RUBY
    end

    it 'accepts rescuing custom exceptions in multiple rescue groups' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue NonStandardError, OtherError
          handle_standard_error
        rescue CustomError
          handle_exception
        end
      RUBY
    end

    context 'splat arguments' do
      it 'accepts splat arguments passed to multiple rescues' do
        expect_no_offenses(<<~RUBY)
          begin
            a
          rescue *FOO
            b
          rescue *BAR
            c
          end
        RUBY
      end

      it 'does not register an offense for splat arguments rescued after ' \
         'rescuing a known exception' do
        expect_no_offenses(<<~RUBY)
          begin
            a
          rescue StandardError
            b
          rescue *BAR
            c
          end
        RUBY
      end

      it 'registers an offense for splat arguments rescued after rescuing Exception' do
        expect_offense(<<~RUBY)
          begin
            a
          rescue Exception
          ^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
            b
          rescue *BAR
            c
          end
        RUBY
      end
    end

    context 'exceptions from different ancestry chains' do
      it 'accepts rescuing exceptions in one order' do
        expect_no_offenses(<<~RUBY)
          begin
            a
          rescue ArgumentError
            b
          rescue Interrupt
            c
          end
        RUBY
      end

      it 'accepts rescuing exceptions in another order' do
        expect_no_offenses(<<~RUBY)
          begin
            a
          rescue Interrupt
            b
          rescue ArgumentError
            c
          end
        RUBY
      end
    end

    it 'accepts rescuing a known exception after an unknown exceptions' do
      expect_no_offenses(<<~RUBY)
        begin
          a
        rescue UnknownException
          b
        rescue StandardError
          c
        end
      RUBY
    end

    it 'accepts rescuing a known exception before an unknown exceptions' do
      expect_no_offenses(<<~RUBY)
        begin
          a
        rescue StandardError
          b
        rescue UnknownException
          c
        end
      RUBY
    end

    it 'accepts rescuing a known exception between unknown exceptions' do
      expect_no_offenses(<<~RUBY)
        begin
          a
        rescue UnknownException
          b
        rescue StandardError
          c
        rescue AnotherUnknownException
          d
        end
      RUBY
    end

    it 'registers an offense rescuing Exception before an unknown exceptions' do
      expect_offense(<<~RUBY)
        begin
          a
        rescue Exception
        ^^^^^^^^^^^^^^^^ Do not shadow rescued Exceptions.
          b
        rescue UnknownException
          c
        end
      RUBY
    end

    it 'ignores expressions of non-const' do
      expect_no_offenses(<<~RUBY)
        begin
          a
        rescue foo
          b
        rescue [bar]
          c
        end
      RUBY
    end

    context 'last rescue does not specify exception class' do
      it 'highlights range ending at rescue keyword' do
        expect_no_offenses(<<~RUBY)
          begin
          rescue A, B
            do_something
          rescue C
            do_something
          rescue
            do_something
          end
        RUBY
      end
    end
  end
end
