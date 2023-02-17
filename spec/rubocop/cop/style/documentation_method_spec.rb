# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DocumentationMethod, :config do
  let(:require_for_non_public_methods) { false }

  let(:config) do
    RuboCop::Config.new(
      'Style/CommentAnnotation' => {
        'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW]
      },
      'Style/DocumentationMethod' => {
        'RequireForNonPublicMethods' => require_for_non_public_methods
      }
    )
  end

  context 'when declaring methods outside a class' do
    context 'without documentation comment' do
      context 'when method is public' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
          RUBY
        end

        it 'registers an offense with `end` on the same line' do
          expect_offense(<<~RUBY)
            def method; end
            ^^^^^^^^^^^^^^^ Missing method documentation comment.
          RUBY
        end

        it 'registers an offense when method is public, but there were private methods before' do
          expect_offense(<<~RUBY)
            class Foo
                private

                def baz
                end

                public

                def foo
                ^^^^^^^ Missing method documentation comment.
                  puts 'bar'
                end
            end
          RUBY
        end
      end

      context 'when `initialize` method' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            def initialize
            end
          RUBY
        end
      end

      context 'when method is private' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            private

            def foo
              puts 'bar'
            end
          RUBY
        end

        it 'does not register an offense with `end` on the same line' do
          expect_no_offenses(<<~RUBY)
            private

            def foo; end
          RUBY
        end

        it 'does not register an offense with inline `private`' do
          expect_no_offenses(<<~RUBY)
            private def foo
              puts 'bar'
            end
          RUBY
        end

        it 'does not register an offense with inline `private` and `end`' do
          expect_no_offenses('private def method; end')
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<~RUBY)
              private

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            RUBY
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<~RUBY)
              private

              def foo; end
              ^^^^^^^^^^^^ Missing method documentation comment.
            RUBY
          end

          it 'registers an offense with inline `private`' do
            expect_offense(<<~RUBY)
              private def foo
                      ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            RUBY
          end

          it 'registers an offense with inline `private` and `end`' do
            expect_offense(<<~RUBY)
              private def method; end
                      ^^^^^^^^^^^^^^^ Missing method documentation comment.
            RUBY
          end
        end
      end

      context 'when method is protected' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            protected

            def foo
              puts 'bar'
            end
          RUBY
        end

        it 'does not register an offense with inline `protected`' do
          expect_no_offenses(<<~RUBY)
            protected def foo
              puts 'bar'
            end
          RUBY
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<~RUBY)
              protected

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            RUBY
          end

          it 'registers an offense with inline `protected`' do
            expect_offense(<<~RUBY)
              protected def foo
                        ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            RUBY
          end
        end
      end
    end

    context 'with documentation comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # Documentation
          def foo
            puts 'bar'
          end
        RUBY
      end

      it 'does not register an offense with `end` on the same line' do
        expect_no_offenses(<<~RUBY)
          # Documentation
          def foo; end
        RUBY
      end
    end

    context 'with both public and private methods' do
      context 'when the public method has no documentation' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
          RUBY
        end
      end

      context 'when the public method has documentation' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
          RUBY
        end
      end

      context 'when required for non-public methods' do
        let(:require_for_non_public_methods) { true }

        it 'registers an offense' do
          expect_offense(<<~RUBY)
            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
          RUBY
        end
      end
    end

    context 'when declaring methods in a class' do
      context 'without documentation comment' do
        context 'when method is public' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              class Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<~RUBY)
              class Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
            RUBY
          end
        end

        context 'when method is private' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              class Foo
                private

                def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<~RUBY)
              class Foo
                private def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<~RUBY)
              class Foo
                private

                def bar; end
              end
            RUBY
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<~RUBY)
              class Foo
                private def bar; end
              end
            RUBY
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<~RUBY)
                class Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              RUBY
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<~RUBY)
                class Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              RUBY
            end

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<~RUBY)
                class Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
              RUBY
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<~RUBY)
                class Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
              RUBY
            end
          end
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY)
              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<~RUBY)
              class Foo
                # Documentation
                def bar; end
              end
            RUBY
          end
        end
      end

      context 'with annotation comment' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Foo
              # FIXME: offense
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
          RUBY
        end
      end

      context 'with directive comment' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Foo
              # rubocop:disable Style/For
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
          RUBY
        end
      end

      context 'with both public and private methods' do
        context 'when the public method has no documentation' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              class Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
            RUBY
          end
        end

        context 'when the public method has documentation' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
            RUBY
          end
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<~RUBY)
              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            RUBY
          end
        end
      end
    end

    context 'when declaring methods in a module' do
      context 'without documentation comment' do
        context 'when method is public' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<~RUBY)
              module Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
            RUBY
          end
        end

        context 'when method is private' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              module Foo
                private

                def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<~RUBY)
              module Foo
                private def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<~RUBY)
              module Foo
                private

                def bar; end
              end
            RUBY
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<~RUBY)
              module Foo
                private def bar; end
              end
            RUBY
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<~RUBY)
                module Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              RUBY
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<~RUBY)
                module Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              RUBY
            end

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<~RUBY)
                module Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
              RUBY
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<~RUBY)
                module Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
              RUBY
            end
          end
        end

        context 'when method is module_function' do
          it 'registers an offense for inline def' do
            expect_offense(<<~RUBY)
              module Foo
                module_function def bar
                ^^^^^^^^^^^^^^^^^^^^^^^ Missing method documentation comment.
                end
              end
            RUBY
          end

          it 'registers an offense for separate def' do
            expect_offense(<<~RUBY)
              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                end

                module_function :bar
              end
            RUBY
          end
        end

        it 'registers an offense for inline def with ruby2_keywords' do
          expect_offense(<<~RUBY)
            module Foo
              ruby2_keywords def bar
              ^^^^^^^^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
            end
          RUBY
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
            RUBY
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<~RUBY)
              module Foo
                # Documentation
                def bar; end
              end
            RUBY
          end
        end

        context 'when method is module_function' do
          it 'does not register an offense for inline def' do
            expect_no_offenses(<<~RUBY)
              module Foo
                # Documentation
                module_function def bar; end
              end
            RUBY
          end

          it 'does not register an offense for separate def' do
            expect_no_offenses(<<~RUBY)
              module Foo
                # Documentation
                def bar; end

                module_function :bar
              end
            RUBY
          end
        end

        it 'does not register an offense for inline def with ruby2_keywords' do
          expect_no_offenses(<<~RUBY)
            module Foo
              # Documentation
              ruby2_keywords def bar
              end
            end
          RUBY
        end
      end

      context 'with both public and private methods' do
        context 'when the public method has no documentation' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
            RUBY
          end
        end

        context 'when the public method has documentation' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                  puts 'baz'
                end
              end
            RUBY
          end
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<~RUBY)
              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end

                private

                def baz
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            RUBY
          end
        end
      end
    end

    context 'when declaring methods for class instance' do
      context 'without documentation comment' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            class Foo; end

            foo = Foo.new

            def foo.bar
            ^^^^^^^^^^^ Missing method documentation comment.
              puts 'baz'
            end
          RUBY
        end

        it 'registers an offense with `end` on the same line' do
          expect_offense(<<~RUBY)
            class Foo; end

            foo = Foo.new

            def foo.bar; end
            ^^^^^^^^^^^^^^^^ Missing method documentation comment.
          RUBY
        end
      end

      context 'with documentation comment' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar
              puts 'baz'
            end
          RUBY
        end

        it 'does not register an offense with `end` on the same line' do
          expect_no_offenses(<<~RUBY)
            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar; end
          RUBY
        end

        context 'when method is private' do
          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<~RUBY)
              class Foo; end

              foo = Foo.bar

              private

              def foo.bar; end
            RUBY
          end

          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              class Foo; end

              foo = Foo.new

              private

              def foo.bar
                puts 'baz'
              end
            RUBY
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<~RUBY)
              class Foo; end

              foo = Foo.new

              private def foo.bar; end
            RUBY
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<~RUBY)
              class Foo; end

              foo = Foo.new

              private def foo.bar
                puts 'baz'
              end
            RUBY
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.bar

                private

                def foo.bar; end
                ^^^^^^^^^^^^^^^^ Missing method documentation comment.
              RUBY
            end

            it 'registers an offense' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.new

                private

                def foo.bar
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              RUBY
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.new

                private def foo.bar; end
                        ^^^^^^^^^^^^^^^^ Missing method documentation comment.
              RUBY
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.new

                private def foo.bar
                        ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              RUBY
            end
          end
        end

        context 'with both public and private methods' do
          context 'when the public method has no documentation' do
            it 'registers an offense' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.new

                def foo.bar
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end

                private

                def foo.baz
                  puts 'baz'
                end
              RUBY
            end
          end

          context 'when the public method has documentation' do
            it 'does not register an offense' do
              expect_no_offenses(<<~RUBY)
                class Foo; end

                foo = Foo.new

                # Documentation
                def foo.bar
                  puts 'baz'
                end

                private

                def foo.baz
                  puts 'baz'
                end
              RUBY
            end
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<~RUBY)
                class Foo; end

                foo = Foo.new

                # Documentation
                def foo.bar
                  puts 'baz'
                end

                private

                def foo.baz
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              RUBY
            end
          end
        end
      end
    end
  end
end
