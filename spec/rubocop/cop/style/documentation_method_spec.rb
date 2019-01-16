# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DocumentationMethod, :config do
  subject(:cop) { described_class.new(config) }

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
          expect_offense(<<-CODE.strip_indent)
            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
          CODE
        end

        it 'registers an offense with `end` on the same line' do
          expect_offense(<<-CODE.strip_indent)
            def method; end
            ^^^^^^^^^^^^^^^ Missing method documentation comment.
          CODE
        end
      end

      context 'when method is private' do
        it 'does not register an offense' do
          expect_no_offenses(<<-CODE.strip_indent)
            private

            def foo
              puts 'bar'
            end
          CODE
        end

        it 'does not register an offense with `end` on the same line' do
          expect_no_offenses(<<-CODE.strip_indent)
            private

            def foo; end
          CODE
        end

        it 'does not register an offense with inline `private`' do
          expect_no_offenses(<<-CODE.strip_indent)
            private def foo
              puts 'bar'
            end
          CODE
        end

        it 'does not register an offense with inline `private` and `end`' do
          expect_no_offenses('private def method; end')
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
              private

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            CODE
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<-CODE.strip_indent)
              private

              def foo; end
              ^^^^^^^^^^^^ Missing method documentation comment.
            CODE
          end

          it 'registers an offense with inline `private`' do
            expect_offense(<<-CODE.strip_indent)
              private def foo
                      ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            CODE
          end

          it 'registers an offense with inline `private` and `end`' do
            expect_offense(<<-CODE.strip_indent)
              private def method; end
                      ^^^^^^^^^^^^^^^ Missing method documentation comment.
            CODE
          end
        end
      end

      context 'when method is protected' do
        it 'does not register an offense' do
          expect_no_offenses(<<-CODE.strip_indent)
            protected

            def foo
              puts 'bar'
            end
          CODE
        end

        it 'does not register an offense with inline `protected`' do
          expect_no_offenses(<<-CODE.strip_indent)
            protected def foo
              puts 'bar'
            end
          CODE
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
              protected

              def foo
              ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            CODE
          end

          it 'registers an offense with inline `protected`' do
            expect_offense(<<-CODE.strip_indent)
              protected def foo
                        ^^^^^^^ Missing method documentation comment.
                puts 'bar'
              end
            CODE
          end
        end
      end
    end

    context 'with documentation comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<-CODE.strip_indent)
          # Documentation
          def foo
            puts 'bar'
          end
        CODE
      end

      it 'does not register an offense with `end` on the same line' do
        expect_no_offenses(<<-CODE.strip_indent)
          # Documentation
          def foo; end
        CODE
      end
    end

    context 'with both public and private methods' do
      context 'when the public method has no documentation' do
        it 'registers an offense' do
          expect_offense(<<-CODE.strip_indent)
            def foo
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
          CODE
        end
      end

      context 'when the public method has documentation' do
        it 'does not register an offense' do
          expect_no_offenses(<<-CODE.strip_indent)
            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
              puts 'bar'
            end
          CODE
        end
      end

      context 'when required for non-public methods' do
        let(:require_for_non_public_methods) { true }

        it 'registers an offense' do
          expect_offense(<<-CODE.strip_indent)
            # Documentation
            def foo
              puts 'bar'
            end

            private

            def baz
            ^^^^^^^ Missing method documentation comment.
              puts 'bar'
            end
          CODE
        end
      end
    end

    context 'when declaring methods in a class' do
      context 'without documentation comment' do
        context 'wheh method is public' do
          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
              class Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            CODE
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<-CODE.strip_indent)
              class Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
            CODE
          end
        end

        context 'when method is private' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo
                private

                def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo
                private def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo
                private

                def bar; end
              end
            CODE
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo
                private def bar; end
              end
            CODE
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<-CODE.strip_indent)
                class Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              CODE
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<-CODE.strip_indent)
                class Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              CODE
            end

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<-CODE.strip_indent)
                class Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
              CODE
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<-CODE.strip_indent)
                class Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
              CODE
            end
          end
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE)
              class Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo
                # Documentation
                def bar; end
              end
            CODE
          end
        end
      end

      context 'with annotation comment' do
        it 'registers an offense' do
          expect_offense(<<-CODE.strip_indent)
            class Foo
              # FIXME: offense
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
          CODE
        end
      end

      context 'with directive comment' do
        it 'registers an offense' do
          expect_offense(<<-CODE.strip_indent)
            class Foo
              # rubocop:disable Style/For
              def bar
              ^^^^^^^ Missing method documentation comment.
                puts 'baz'
              end
            end
          CODE
        end
      end

      context 'with both public and private methods' do
        context 'when the public method has no documentation' do
          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
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
            CODE
          end
        end

        context 'when the public method has documentation' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
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
            CODE
          end
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
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
            CODE
          end
        end
      end
    end

    context 'when declaring methods in a module' do
      context 'without documentation comment' do
        context 'when method is public' do
          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              end
            CODE
          end

          it 'registers an offense with `end` on the same line' do
            expect_offense(<<-CODE.strip_indent)
              module Foo
                def method; end
                ^^^^^^^^^^^^^^^ Missing method documentation comment.
              end
            CODE
          end
        end

        context 'when method is private' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                private

                def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                private def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                private

                def bar; end
              end
            CODE
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                private def bar; end
              end
            CODE
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<-CODE.strip_indent)
                module Foo
                  private

                  def bar
                  ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              CODE
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<-CODE.strip_indent)
                module Foo
                  private def bar
                          ^^^^^^^ Missing method documentation comment.
                    puts 'baz'
                  end
                end
              CODE
            end

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<-CODE.strip_indent)
                module Foo
                  private

                  def bar; end
                  ^^^^^^^^^^^^ Missing method documentation comment.
                end
              CODE
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<-CODE.strip_indent)
                module Foo
                  private def bar; end
                          ^^^^^^^^^^^^ Missing method documentation comment.
                end
              CODE
            end
          end
        end

        context 'when method is module_function' do
          it 'registers an offense for inline def' do
            expect_offense(<<-CODE.strip_indent)
              module Foo
                module_function def bar
                ^^^^^^^^^^^^^^^^^^^^^^^ Missing method documentation comment.
                end
              end
            CODE
          end

          it 'registers an offense for separate def' do
            expect_offense(<<-CODE.strip_indent)
              module Foo
                def bar
                ^^^^^^^ Missing method documentation comment.
                end

                module_function :bar
              end
            CODE
          end
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                # Documentation
                def bar
                  puts 'baz'
                end
              end
            CODE
          end

          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                # Documentation
                def bar; end
              end
            CODE
          end
        end

        context 'when method is module_function' do
          it 'does not register an offense for inline def' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                # Documentation
                module_function def bar; end
              end
            CODE
          end

          it 'does not register an offense for separate def' do
            expect_no_offenses(<<-CODE.strip_indent)
              module Foo
                # Documentation
                def bar; end

                module_function :bar
              end
            CODE
          end
        end
      end

      context 'with both public and private methods' do
        context 'when the public method has no documentation' do
          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
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
            CODE
          end
        end

        context 'when the public method has documentation' do
          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
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
            CODE
          end
        end

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it 'registers an offense' do
            expect_offense(<<-CODE.strip_indent)
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
            CODE
          end
        end
      end
    end

    context 'when declaring methods for class instance' do
      context 'without documentation comment' do
        it 'registers an offense' do
          expect_offense(<<-CODE.strip_indent)
            class Foo; end

            foo = Foo.new

            def foo.bar
            ^^^^^^^^^^^ Missing method documentation comment.
              puts 'baz'
            end
          CODE
        end

        it 'registers an offense with `end` on the same line' do
          expect_offense(<<-CODE.strip_indent)
            class Foo; end

            foo = Foo.new

            def foo.bar; end
            ^^^^^^^^^^^^^^^^ Missing method documentation comment.
          CODE
        end
      end

      context 'with documentation comment' do
        it 'does not register an offense' do
          expect_no_offenses(<<-CODE.strip_indent)
            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar
              puts 'baz'
            end
          CODE
        end

        it 'does not register an offense with `end` on the same line' do
          expect_no_offenses(<<-CODE.strip_indent)
            class Foo; end

            foo = Foo.new

            # Documentation
            def foo.bar; end
          CODE
        end

        context 'when method is private' do
          it 'does not register an offense with `end` on the same line' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo; end

              foo = Foo.bar

              private

              def foo.bar; end
            CODE
          end

          it 'does not register an offense' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo; end

              foo = Foo.new

              private

              def foo.bar
                puts 'baz'
              end
            CODE
          end

          it 'does not register an offense with inline `private` and `end`' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo; end

              foo = Foo.new

              private def foo.bar; end
            CODE
          end

          it 'does not register an offense with inline `private`' do
            expect_no_offenses(<<-CODE.strip_indent)
              class Foo; end

              foo = Foo.new

              private def foo.bar
                puts 'baz'
              end
            CODE
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense with `end` on the same line' do
              expect_offense(<<-CODE.strip_indent)
                class Foo; end

                foo = Foo.bar

                private

                def foo.bar; end
                ^^^^^^^^^^^^^^^^ Missing method documentation comment.
              CODE
            end

            it 'registers an offense' do
              expect_offense(<<-CODE.strip_indent)
                class Foo; end

                foo = Foo.new

                private

                def foo.bar
                ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              CODE
            end

            it 'registers an offense with inline `private` and `end`' do
              expect_offense(<<-CODE.strip_indent)
                class Foo; end

                foo = Foo.new

                private def foo.bar; end
                        ^^^^^^^^^^^^^^^^ Missing method documentation comment.
              CODE
            end

            it 'registers an offense with inline `private`' do
              expect_offense(<<-CODE.strip_indent)
                class Foo; end

                foo = Foo.new

                private def foo.bar
                        ^^^^^^^^^^^ Missing method documentation comment.
                  puts 'baz'
                end
              CODE
            end
          end
        end

        context 'with both public and private methods' do
          context 'when the public method has no documentation' do
            it 'registers an offense' do
              expect_offense(<<-CODE.strip_indent)
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
              CODE
            end
          end

          context 'when the public method has documentation' do
            it 'does not register an offense' do
              expect_no_offenses(<<-CODE.strip_indent)
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
              CODE
            end
          end

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it 'registers an offense' do
              expect_offense(<<-CODE.strip_indent)
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
              CODE
            end
          end
        end
      end
    end
  end
end
