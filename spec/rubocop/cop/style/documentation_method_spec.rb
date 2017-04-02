# frozen_string_literal: true

describe RuboCop::Cop::Style::DocumentationMethod, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([message])
      end
    end
  end

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

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

  let(:message) { described_class::MSG }

  context 'when declaring methods outside a class' do
    context 'without documentation comment' do
      context 'when method is public' do
        it_behaves_like 'code with offense', <<-CODE
                        def foo
                          puts 'bar'
                        end
        CODE

        it_behaves_like 'code with offense',
                        'def method; end'
      end

      context 'when method is private' do
        it_behaves_like 'code without offense', <<-CODE
                        private

                        def foo
                          puts 'bar'
                        end
        CODE

        it_behaves_like 'code without offense', <<-CODE
                        private

                        def foo; end
        CODE

        it_behaves_like 'code without offense', <<-CODE
                        private def foo
                          puts 'bar'
                        end
        CODE

        it_behaves_like 'code without offense',
                        'private def method; end'

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it_behaves_like 'code with offense', <<-CODE
                          private

                          def foo
                            puts 'bar'
                          end
          CODE

          it_behaves_like 'code with offense', <<-CODE
                          private

                          def foo; end
          CODE

          it_behaves_like 'code with offense', <<-CODE
                          private def foo
                            puts 'bar'
                          end
          CODE

          it_behaves_like 'code with offense',
                          'private def method; end'
        end
      end

      context 'when method is protected' do
        it_behaves_like 'code without offense', <<-CODE
                        protected

                        def foo
                          puts 'bar'
                        end
        CODE

        it_behaves_like 'code without offense', <<-CODE
                          protected def foo
                            puts 'bar'
                          end
        CODE

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it_behaves_like 'code with offense', <<-CODE
                          protected

                          def foo
                            puts 'bar'
                          end
          CODE

          it_behaves_like 'code with offense', <<-CODE
                          protected def foo
                            puts 'bar'
                          end
          CODE
        end
      end
    end

    context 'with documentation comment' do
      it_behaves_like 'code without offense', <<-CODE
                      # Documenation
                      def foo
                        puts 'bar'
                      end
      CODE

      it_behaves_like 'code without offense', <<-CODE
                      # Documentation
                      def foo; end
      CODE
    end

    context 'with both public and private methods' do
      it_behaves_like 'code with offense', <<-CODE
                      def foo
                        puts 'bar'
                      end

                      private

                      def baz
                        puts 'bar'
                      end
      CODE

      it_behaves_like 'code without offense', <<-CODE
                      # Documenation
                      def foo
                        puts 'bar'
                      end

                      private

                      def baz
                        puts 'bar'
                      end
      CODE

      context 'when required for non-public methods' do
        let(:require_for_non_public_methods) { true }

        it_behaves_like 'code with offense', <<-CODE
                        # Documenation
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

    context 'when declaring methods in a class' do
      context 'without documentation comment' do
        context 'wheh method is public' do
          it_behaves_like 'code with offense', <<-CODE
                          class Foo
                            def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code with offense', <<-CODE
                          class Foo
                            def method; end
                          end
          CODE
        end

        context 'when method is private' do
          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            private

                            def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            private def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            private

                            def bar; end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            private def bar; end
                          end
          CODE

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it_behaves_like 'code with offense', <<-CODE
                            class Foo
                              private

                              def bar
                                puts 'baz'
                              end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo
                              private def bar
                                puts 'baz'
                              end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo
                              private

                              def bar; end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo
                              private def bar; end
                            end
            CODE
          end
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            # Documentation
                            def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo
                            # Documentation
                            def bar; end
                          end
          CODE
        end
      end

      context 'with annotation comment' do
        it_behaves_like 'code with offense', <<-CODE
                        class Foo
                          # FIXME: offense
                          def bar
                            puts 'baz'
                          end
                        end
        CODE
      end

      context 'with directive comment' do
        it_behaves_like 'code with offense', <<-CODE
                        class Foo
                          # rubocop:disable Style/For
                          def bar
                            puts 'baz'
                          end
                        end
        CODE
      end

      context 'with both public and private methods' do
        it_behaves_like 'code with offense', <<-CODE
                        class Foo
                          def bar
                            puts 'baz'
                          end

                          private

                          def baz
                            puts 'baz'
                          end
                        end
        CODE

        it_behaves_like 'code without offense', <<-CODE
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

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it_behaves_like 'code with offense', <<-CODE
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
    end

    context 'when declaring methods in a module' do
      context 'without documentation comment' do
        context 'wheh method is public' do
          it_behaves_like 'code with offense', <<-CODE
                           module Foo
                             def bar
                               puts 'baz'
                             end
                           end
          CODE

          it_behaves_like 'code with offense', <<-CODE
                          module Foo
                            def method; end
                          end
          CODE
        end

        context 'when method is private' do
          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            private

                            def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            private def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            private

                            def bar; end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            private def bar; end
                          end
          CODE

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it_behaves_like 'code with offense', <<-CODE
                            module Foo
                              private

                              def bar
                                puts 'baz'
                              end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            module Foo
                              private def bar
                                puts 'baz'
                              end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            module Foo
                              private

                              def bar; end
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            module Foo
                              private def bar; end
                            end
            CODE
          end
        end
      end

      context 'with documentation comment' do
        context 'when method is public' do
          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            # Documentation
                            def bar
                              puts 'baz'
                            end
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          module Foo
                            # Documentation
                            def bar; end
                          end
          CODE
        end
      end

      context 'with both public and private methods' do
        it_behaves_like 'code with offense', <<-CODE
                        module Foo
                          def bar
                            puts 'baz'
                          end

                          private

                          def baz
                            puts 'baz'
                          end
                        end
        CODE

        it_behaves_like 'code without offense', <<-CODE
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

        context 'when required for non-public methods' do
          let(:require_for_non_public_methods) { true }

          it_behaves_like 'code with offense', <<-CODE
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
    end

    context 'when declaring methods for class instance' do
      context 'without documentation comment' do
        it_behaves_like 'code with offense', <<-CODE
                        class Foo; end

                        foo = Foo.new

                        def foo.bar
                          puts 'baz'
                        end
        CODE

        it_behaves_like 'code with offense', <<-CODE
                        class Foo; end

                        foo = Foo.new

                        def foo.bar; end
        CODE
      end

      context 'with documentation comment' do
        it_behaves_like 'code without offense', <<-CODE
                        class Foo; end

                        foo = Foo.new

                        # Documentation
                        def foo.bar
                          puts 'baz'
                        end
        CODE

        it_behaves_like 'code without offense', <<-CODE
                        class Foo; end

                        foo = Foo.new

                        # Documentation
                        def foo.bar; end
        CODE

        context 'when method is private' do
          it_behaves_like 'code without offense', <<-CODE
                          class Foo; end

                          foo = Foo.bar

                          private

                          def foo.bar; end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo; end

                          foo = Foo.new

                          private

                          def foo.bar
                            puts 'baz'
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo; end

                          foo = Foo.new

                          private def foo.bar; end
          CODE

          it_behaves_like 'code without offense', <<-CODE
                          class Foo; end

                          foo = Foo.new

                          private def foo.bar
                            puts 'baz'
                          end
          CODE

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it_behaves_like 'code with offense', <<-CODE
                            class Foo; end

                            foo = Foo.bar

                            private

                            def foo.bar; end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo; end

                            foo = Foo.new

                            private

                            def foo.bar
                              puts 'baz'
                            end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo; end

                            foo = Foo.new

                            private def foo.bar; end
            CODE

            it_behaves_like 'code with offense', <<-CODE
                            class Foo; end

                            foo = Foo.new

                            private def foo.bar
                              puts 'baz'
                            end
            CODE
          end
        end

        context 'with both public and private methods' do
          it_behaves_like 'code with offense', <<-CODE
                          class Foo; end

                          foo = Foo.new

                          def foo.bar
                            puts 'baz'
                          end

                          private

                          def foo.baz
                            puts 'baz'
                          end
          CODE

          it_behaves_like 'code without offense', <<-CODE
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

          context 'when required for non-public methods' do
            let(:require_for_non_public_methods) { true }

            it_behaves_like 'code with offense', <<-CODE
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
      end
    end
  end
end
