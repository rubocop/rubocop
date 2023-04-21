# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::RescuedExceptionsVariableName, :config do
  context 'with default config' do
    context 'with explicit rescue' do
      context 'with `Exception` variable' do
        it 'registers an offense when using `exc`' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue MyException => exc
                                  ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue MyException => e
              # do something
            end
          RUBY
        end

        it 'registers an offense when using `_exc`' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue MyException => _exc
                                  ^^^^ Use `_e` instead of `_exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue MyException => _e
              # do something
            end
          RUBY
        end

        it 'registers an offense when using `exc` and renames its usage' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue MyException => exc
                                  ^^^ Use `e` instead of `exc`.
              exc
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue MyException => e
              e
            end
          RUBY
        end

        it 'registers offenses when using `foo` and `bar` in multiple rescues' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue FooException => foo
                                   ^^^ Use `e` instead of `foo`.
              # do something
            rescue BarException => bar
                                   ^^^ Use `e` instead of `bar`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue FooException => e
              # do something
            rescue BarException => e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `e`' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue MyException => e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `_e`' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue MyException => _e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using _e followed by e' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue MyException => _e
              # do something
            rescue AnotherException => e
              # do something
            end
          RUBY
        end
      end

      context 'without `Exception` variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue MyException
              # do something
            end
          RUBY
        end
      end

      context 'shadowing an external variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            e = 'error message'
            begin
              something
            rescue StandardError => e1
              log(e, e1)
            end
          RUBY
        end
      end

      context 'with lower letters class name' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue my_exception
              # do something
            end
          RUBY
        end
      end

      context 'with method as `Exception`' do
        it 'does not register an offense without variable name' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue ActiveSupport::JSON.my_method
              # do something
            end
          RUBY
        end

        it 'does not register an offense with expected variable name' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue ActiveSupport::JSON.my_method => e
              # do something
            end
          RUBY
        end

        it 'registers an offense with unexpected variable name' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue ActiveSupport::JSON.my_method => exc
                                                    ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue ActiveSupport::JSON.my_method => e
              # do something
            end
          RUBY
        end
      end

      context 'with splat operator as `Exception` list' do
        it 'does not register an offense without variable name' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue *handled
              # do something
            end
          RUBY
        end

        it 'does not register an offense with expected variable name' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue *handled => e
              # do something
            end
          RUBY
        end

        it 'registers an offense with unexpected variable name' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue *handled => exc
                               ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue *handled => e
              # do something
            end
          RUBY
        end
      end
    end

    context 'with implicit rescue' do
      context 'with `Exception` variable' do
        it 'registers an offense when using `exc`' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue => exc
                      ^^^ Use `e` instead of `exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue => e
              # do something
            end
          RUBY
        end

        it 'registers an offense when using `_exc`' do
          expect_offense(<<~RUBY)
            begin
              something
            rescue => _exc
                      ^^^^ Use `_e` instead of `_exc`.
              # do something
            end
          RUBY

          expect_correction(<<~RUBY)
            begin
              something
            rescue => _e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `e`' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue => e
              # do something
            end
          RUBY
        end

        it 'does not register an offense when using `_e`' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue => _e
              # do something
            end
          RUBY
        end
      end

      context 'without `Exception` variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            begin
              something
            rescue
              # do something
            end
          RUBY
        end
      end
    end

    context 'with variable being referenced' do
      it 'renames the variable references when autocorrecting' do
        expect_offense(<<~RUBY)
          begin
            get something
          rescue ActiveResource::Redirection => redirection
                                                ^^^^^^^^^^^ Use `e` instead of `redirection`.
            redirect_to redirection.response['Location']
          end
        RUBY

        expect_correction(<<~RUBY)
          begin
            get something
          rescue ActiveResource::Redirection => e
            redirect_to e.response['Location']
          end
        RUBY
      end
    end

    context 'when the variable is reassigned' do
      it 'only corrects uses of the exception' do
        expect_offense(<<~RUBY)
          def main
            raise
          rescue StandardError => error
                                  ^^^^^ Use `e` instead of `error`.
            error = {
              error_message: error.message
            }
            puts error
          end
        RUBY

        expect_correction(<<~RUBY)
          def main
            raise
          rescue StandardError => e
            error = {
              error_message: e.message
            }
            puts error
          end
        RUBY
      end

      it 'only corrects the exception variable' do
        expect_offense(<<~RUBY)
          def main
            raise
          rescue StandardError => error
                                  ^^^^^ Use `e` instead of `error`.
            message = error.message
            puts message
          end
        RUBY

        expect_correction(<<~RUBY)
          def main
            raise
          rescue StandardError => e
            message = e.message
            puts message
          end
        RUBY
      end
    end

    context 'when the variable is reassigned using multiple assignment' do
      it 'only corrects uses of the exception' do
        expect_offense(<<~RUBY)
          def main
            raise
          rescue StandardError => error
                                  ^^^^^ Use `e` instead of `error`.
            error, foo = 1, error
            puts error
          end
        RUBY

        expect_correction(<<~RUBY)
          def main
            raise
          rescue StandardError => e
            error, foo = 1, e
            puts error
          end
        RUBY
      end
    end

    context 'with multiple branches' do
      it 'registers and corrects each offense' do
        expect_offense(<<~RUBY)
          begin
            something
          rescue MyException => exc
                                ^^^ Use `e` instead of `exc`.
            # do something
          rescue OtherException => exc
                                   ^^^ Use `e` instead of `exc`.
            # do something else
          end
        RUBY

        expect_correction(<<~RUBY)
          begin
            something
          rescue MyException => e
            # do something
          rescue OtherException => e
            # do something else
          end
        RUBY
      end
    end

    context 'with nested rescues' do
      it 'handles it' do
        expect_offense(<<~RUBY)
          begin
          rescue StandardError => e1
                                  ^^ Use `e` instead of `e1`.
            begin
              log(e1)
            rescue StandardError => e2
              log(e1, e2)
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          begin
          rescue StandardError => e
            begin
              log(e)
            rescue StandardError => e2
              log(e, e2)
            end
          end
        RUBY
      end
    end

    context 'when the variable is referenced after `rescue` statement' do
      it 'handles it' do
        expect_offense(<<~RUBY)
          begin
            something
          rescue StandardError => e1
                                  ^^ Use `e` instead of `e1`.
          end
          foo(e1)
        RUBY

        expect_correction(<<~RUBY)
          begin
            something
          rescue StandardError => e
          end
          foo(e)
        RUBY
      end
    end
  end

  context 'with the `PreferredName` setup' do
    let(:cop_config) { { 'PreferredName' => 'exception' } }

    it 'registers an offense when using `e`' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue MyException => e
                              ^ Use `exception` instead of `e`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          something
        rescue MyException => exception
          # do something
        end
      RUBY
    end

    it 'registers an offense when using `_e`' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue MyException => _e
                              ^^ Use `_exception` instead of `_e`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          something
        rescue MyException => _exception
          # do something
        end
      RUBY
    end

    it 'registers offenses when using `foo` and `bar` in multiple rescues' do
      expect_offense(<<~RUBY)
        begin
          something
        rescue FooException => foo
                               ^^^ Use `exception` instead of `foo`.
          # do something
        rescue BarException => bar
                               ^^^ Use `exception` instead of `bar`.
          # do something
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          something
        rescue FooException => exception
          # do something
        rescue BarException => exception
          # do something
        end
      RUBY
    end

    it 'does not register an offense when using `exception`' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue MyException => exception
          # do something
        end
      RUBY
    end

    it 'does not register an offense when using `_exception`' do
      expect_no_offenses(<<~RUBY)
        begin
          something
        rescue MyException => _exception
          # do something
        end
      RUBY
    end
  end
end
