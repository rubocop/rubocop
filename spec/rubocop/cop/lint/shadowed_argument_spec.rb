# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ShadowedArgument, :config do
  let(:cop_config) { { 'IgnoreImplicitReferences' => false } }

  describe 'method argument shadowing' do
    context 'when a single argument is shadowed' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          def do_something(foo)
            foo = 42
            ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
            puts foo
          end
        RUBY
      end

      context 'when zsuper is used' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def do_something(foo)
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              super
            end
          RUBY
        end

        context 'when argument was shadowed by zsuper' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              def select_fields(query, current_time)
                query = super
                ^^^^^^^^^^^^^ Argument `query` was shadowed by a local variable before it was used.
                query.select('*')
              end
            RUBY
          end
        end

        context 'when IgnoreImplicitReferences config option is set to true' do
          let(:cop_config) { { 'IgnoreImplicitReferences' => true } }

          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                foo = 42
                super
              end
            RUBY
          end

          context 'when argument was shadowed by zsuper' do
            it 'does not register an offense' do
              expect_no_offenses(<<~RUBY)
                def select_fields(query, current_time)
                  query = super
                  query.select('*')
                end
              RUBY
            end
          end
        end
      end

      context 'when argument was used in shorthand assignment' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            def do_something(bar)
              bar = 'baz' if foo
              bar ||= {}
            end
          RUBY
        end
      end

      context 'when a splat argument is shadowed' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def do_something(*items)
              *items, last = [42, 42]
               ^^^^^ Argument `items` was shadowed by a local variable before it was used.
              puts items
            end
          RUBY
        end
      end

      context 'when reassigning to splat variable' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            def do_something(*items)
              *items, last = items
              puts items
            end
          RUBY
        end
      end

      context 'when binding is used' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def do_something(foo)
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              binding
            end
          RUBY
        end

        context 'when IgnoreImplicitReferences config option is set to true' do
          let(:cop_config) { { 'IgnoreImplicitReferences' => true } }

          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                foo = 42
                binding
              end
            RUBY
          end
        end
      end

      context 'and the argument is not used' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            def do_something(foo)
              puts 'done something'
            end
          RUBY
        end
      end

      context 'and shadowed within a conditional' do
        it 'registers an offense without specifying where the reassignment took place' do
          expect_offense(<<~RUBY)
            def do_something(foo)
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              if bar
                foo = 43
              end
              foo = 42
              puts foo
            end
          RUBY
        end

        context 'and was used before shadowing' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                if bar
                  puts foo
                  foo = 43
                end
                foo = 42
                puts foo
              end
            RUBY
          end
        end

        context 'and the argument was not shadowed outside the conditional' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                if bar
                  foo = 42
                end

                puts foo
              end
            RUBY
          end
        end

        context 'and the conditional occurs after the reassignment' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  foo = 42
                end
                puts foo
              end
            RUBY
          end
        end

        context 'and the conditional is nested within a conditional' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                def do_something(foo)
                  if bar
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end

        context 'and the conditional is nested within a lambda' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                lambda do
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                def do_something(foo)
                  lambda do
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end
      end

      context 'and shadowed within a block' do
        it 'registers an offense without specifying where the reassignment took place' do
          expect_offense(<<~RUBY)
            def do_something(foo)
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              something { foo = 43 }

              foo = 42
              puts foo
            end
          RUBY
        end

        context 'and was used before shadowing' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                lambda do
                  puts foo
                  foo = 43
                end

                foo = 42
                puts foo
              end
            RUBY
          end
        end

        context 'and the argument was not shadowed outside the block' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def do_something(foo)
                something { foo = 43 }

                puts foo
              end
            RUBY
          end
        end

        context 'and the block occurs after the reassignment' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                something { foo = 42 }
                puts foo
              end
            RUBY
          end
        end

        context 'and the block is nested within a block' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                something do
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                def do_something(foo)
                  lambda do
                    puts foo

                    something do
                      foo = 43
                    end
                  end

                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end

        context 'and the block is nested within a conditional' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              def do_something(foo)
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if baz
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                def do_something(foo)
                  if baz
                    puts foo
                    lambda do
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end
      end
    end

    context 'when multiple arguments are shadowed' do
      context 'and one of them shadowed within a lambda while another is shadowed outside' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def do_something(foo, bar)
              lambda do
                bar = 42
              end

              foo = 43
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              puts(foo, bar)
            end
          RUBY
        end
      end
    end
  end

  describe 'block argument shadowing' do
    context 'when a block local variable is assigned but no argument is shadowed' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          numbers = [1, 2, 3]
          numbers.each do |i; j|
            j = i * 2
            puts j
          end
        RUBY
      end
    end

    context 'when a single argument is shadowed' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          do_something do |foo|
            foo = 42
            ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
            puts foo
          end
        RUBY
      end

      context 'when zsuper is used' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            do_something do |foo|
              foo = 42
              super
            end
          RUBY
        end
      end

      context 'when binding is used' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            do_something do |foo|
              foo = 42
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              binding
            end
          RUBY
        end

        context 'when IgnoreImplicitReferences config option is set to true' do
          let(:cop_config) { { 'IgnoreImplicitReferences' => true } }

          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              do_something do |foo|
                foo = 42
                binding
              end
            RUBY
          end
        end
      end

      context 'and the argument is not used' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            do_something do |foo|
              puts 'done something'
            end
          RUBY
        end
      end

      context 'and shadowed within a conditional' do
        it 'registers an offense without specifying where the reassignment took place' do
          expect_offense(<<~RUBY)
            do_something do |foo|
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              if bar
                foo = 43
              end
              foo = 42
              puts foo
            end
          RUBY
        end

        context 'and was used before shadowing' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              do_something do |foo|
                if bar
                  puts foo
                  foo = 43
                end
                foo = 42
                puts foo
              end
            RUBY
          end
        end

        context 'and the argument was not shadowed outside the conditional' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              do_something do |foo|
                if bar
                  foo = 42
                end

                puts foo
              end
            RUBY
          end
        end

        context 'and the conditional occurs after the reassignment' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  foo = 42
                end
                puts foo
              end
            RUBY
          end
        end

        context 'and the conditional is nested within a conditional' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if bar
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                do_something do |foo|
                  if bar
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end

        context 'and the conditional is nested within a lambda' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                lambda do
                  if baz
                    foo = 43
                  end
                end
                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                do_something do |foo|
                  lambda do
                    puts foo
                    if baz
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end
      end

      context 'and shadowed within a block' do
        it 'registers an offense without specifying where the reassignment took place' do
          expect_offense(<<~RUBY)
            do_something do |foo|
                             ^^^ Argument `foo` was shadowed by a local variable before it was used.
              something { foo = 43 }

              foo = 42
              puts foo
            end
          RUBY
        end

        context 'and was used before shadowing' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              do_something do |foo|
                lambda do
                  puts foo
                  foo = 43
                end

                foo = 42
                puts foo
              end
            RUBY
          end
        end

        context 'and the argument was not shadowed outside the block' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              do_something do |foo|
                something { foo = 43 }

                puts foo
              end
            RUBY
          end
        end

        context 'and the block occurs after the reassignment' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                foo = 43
                ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
                something { foo = 42 }
                puts foo
              end
            RUBY
          end
        end

        context 'and the block is nested within a block' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                something do
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                do_something do |foo|
                  lambda do
                    puts foo

                    something do
                      foo = 43
                    end
                  end

                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end

        context 'and the block is nested within a conditional' do
          it 'registers an offense without specifying where the reassignment took place' do
            expect_offense(<<~RUBY)
              do_something do |foo|
                               ^^^ Argument `foo` was shadowed by a local variable before it was used.
                if baz
                  lambda do
                    foo = 43
                  end
                end

                foo = 42
                puts foo
              end
            RUBY
          end

          context 'and the argument was used before shadowing' do
            it 'accepts' do
              expect_no_offenses(<<~RUBY)
                do_something do |foo|
                  if baz
                    puts foo
                    lambda do
                      foo = 43
                    end
                  end
                  foo = 42
                  puts foo
                end
              RUBY
            end
          end
        end
      end
    end

    context 'when multiple arguments are shadowed' do
      context 'and one of them shadowed within a lambda while another is shadowed outside' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            do_something do |foo, bar|
              lambda do
                bar = 42
              end

              foo = 43
              ^^^^^^^^ Argument `foo` was shadowed by a local variable before it was used.
              puts(foo, bar)
            end
          RUBY
        end
      end
    end
  end
end
