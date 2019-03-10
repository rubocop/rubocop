# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::AccessModifierIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    c = cop_config.merge('SupportedStyles' => %w[indent outdent])
    RuboCop::Config
      .new('Layout/AccessModifierIndentation' => c,
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }

  context 'when EnforcedStyle is set to indent' do
    let(:cop_config) { { 'EnforcedStyle' => 'indent' } }

    it 'registers an offense for misaligned private' do
      expect_offense(<<-RUBY.strip_indent)
        class Test

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned private in module' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

         private
         ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned module_function in module' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

         module_function
         ^^^^^^^^^^^^^^^ Indent access modifiers like `module_function`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for correct + opposite alignment' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

          public

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for opposite + correct alignment' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

        public
        ^^^^^^ Indent access modifiers like `public`.

          private

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned private in singleton class' do
      expect_offense(<<-RUBY.strip_indent)
        class << self

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned private in class ' \
       'defined with Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        Test = Class.new do

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for access modifiers in arbitrary blocks' do
      expect_offense(<<-RUBY.strip_indent)
        Test = func do

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned private in module ' \
       'defined with Module.new' do
      expect_offense(<<-RUBY.strip_indent)
        Test = Module.new do

        private
        ^^^^^^^ Indent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers an offense for misaligned protected' do
      expect_offense(<<-RUBY.strip_indent)
        class Test

        protected
        ^^^^^^^^^ Indent access modifiers like `protected`.

          def test; end
        end
      RUBY
    end

    it 'accepts properly indented private' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test

          private

          def test; end
        end
      RUBY
    end

    it 'accepts properly indented protected' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test

          protected

          def test; end
        end
      RUBY
    end

    it 'accepts properly indented private in module defined with Module.new' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Test = Module.new do

          private

          def test; end
        end
      RUBY
    end

    it 'accepts an empty class' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test
        end
      RUBY
    end

    it 'accepts methods with a body' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module Test
          def test
            foo
          end
        end
      RUBY
    end

    it 'handles properly nested classes' do
      expect_offense(<<-RUBY.strip_indent)
        class Test

          class Nested

          private
          ^^^^^^^ Indent access modifiers like `private`.

            def a; end
          end

          protected

          def test; end
        end
      RUBY
    end

    it 'accepts indented access modifiers with arguments in nested classes' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class A
          module Test
            private :test
          end
        end
      RUBY

      expect_no_offenses(<<-RUBY.strip_indent)
        class A
          class Test
            private :test
          end
        end
      RUBY

      expect_no_offenses(<<-RUBY.strip_indent)
        class A
          class << self
            private :test
          end
        end
      RUBY
    end

    it 'auto-corrects incorrectly indented access modifiers' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        class Test

        public
         private
           protected

          def test; end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class Test

          public
          private
          protected

          def test; end
        end
      RUBY
    end

    context 'when 4 spaces per indent level are used' do
      let(:indentation_width) { 4 }

      it 'accepts properly indented private' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test

              private

              def test; end
          end
        RUBY
      end
    end

    context 'when indentation width is overridden for this cop only' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'indent', 'IndentationWidth' => 4 }
      end

      it 'accepts properly indented private' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Test

              private

            def test; end
          end
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is set to outdent' do
    let(:cop_config) { { 'EnforcedStyle' => 'outdent' } }

    it 'registers offense for private indented to method depth in a class' do
      expect_offense(<<-RUBY.strip_indent)
        class Test

          private
          ^^^^^^^ Outdent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers offense for private indented to method depth in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

          private
          ^^^^^^^ Outdent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers offense for module fn indented to method depth in a module' do
      expect_offense(<<-RUBY.strip_indent)
        module Test

          module_function
          ^^^^^^^^^^^^^^^ Outdent access modifiers like `module_function`.

          def test; end
        end
      RUBY
    end

    it 'registers offense for private indented to method depth in singleton' \
       'class' do
      expect_offense(<<-RUBY.strip_indent)
        class << self

          private
          ^^^^^^^ Outdent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers offense for private indented to method depth in class ' \
       'defined with Class.new' do
      expect_offense(<<-RUBY.strip_indent)
        Test = Class.new do

          private
          ^^^^^^^ Outdent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'registers offense for private indented to method depth in module ' \
       'defined with Module.new' do
      expect_offense(<<-RUBY.strip_indent)
        Test = Module.new do

          private
          ^^^^^^^ Outdent access modifiers like `private`.

          def test; end
        end
      RUBY
    end

    it 'accepts private indented to the containing class indent level' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test

        private

          def test; end
        end
      RUBY
    end

    it 'accepts protected indented to the containing class indent level' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Test

        protected

          def test; end
        end
      RUBY
    end

    it 'handles properly nested classes' do
      expect_offense(<<-RUBY.strip_indent)
        class Test

          class Nested

            private
            ^^^^^^^ Outdent access modifiers like `private`.

            def a; end
          end

        protected

          def test; end
        end
      RUBY
    end

    it 'auto-corrects incorrectly indented access modifiers' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        module M
          class Test

        public
         private
             protected

            def test; end
          end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        module M
          class Test

          public
          private
          protected

            def test; end
          end
        end
      RUBY
    end

    it 'auto-corrects private in complicated case' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        class Hello
          def foo
            'hi'
          end

          def bar
            Module.new do

             private

              def hi
                'bye'
              end
            end
          end
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class Hello
          def foo
            'hi'
          end

          def bar
            Module.new do

            private

              def hi
                'bye'
              end
            end
          end
        end
      RUBY
    end
  end
end
