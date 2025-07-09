# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessModifierDeclarations, :config do
  shared_examples 'always accepted' do |access_modifier|
    it "accepts when #{access_modifier} is a hash literal value" do
      expect_no_offenses(<<~RUBY)
        class Foo
          foo
          bar(key: #{access_modifier})
        end
      RUBY
    end

    context 'allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => true } }

      it "accepts when argument to #{access_modifier} is a symbol" do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} :bar
          end
        RUBY
      end

      it "accepts when argument to #{access_modifier} is multiple symbols" do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} :bar, :baz
          end
        RUBY
      end

      it "accepts when argument to #{access_modifier} is splat with a `%i` array literal" do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} *%i[bar baz]
          end
        RUBY
      end

      it "accepts when argument to #{access_modifier} is splat with a constant" do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} *METHOD_NAMES
          end
        RUBY
      end

      it "accepts when argument to #{access_modifier} is a splat with a method call" do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} *bar
          end
        RUBY
      end
    end

    context 'do not allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => false } }

      it "does not register an offense when argument to #{access_modifier} is a symbol and there is no surrounding scope" do
        expect_no_offenses(<<~RUBY)
          #{access_modifier} :foo
        RUBY
      end

      it "registers an offense when argument to #{access_modifier} is a symbol" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Foo
            foo
            %{access_modifier} :bar
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_no_corrections
      end

      context "when argument to #{access_modifier} is multiple symbols" do
        it 'registers an offense and does not autocorrect when methods are not defined' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Foo
              foo
              %{access_modifier} :bar, :baz
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_no_corrections
        end

        it 'registers an offense and autocorrects when methods are all defined in class' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            module Foo
              def bar; end
              def baz; end

              %{access_modifier} :bar, :baz
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo

            #{access_modifier}

            def bar; end
            def baz; end
            end
          RUBY
        end

        it 'registers an offense and autocorrects when methods are all defined in class and there is a comment' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            module Foo
              def bar; end
              def baz; end

              # comment
              %{access_modifier} :bar, :baz
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo

            #{access_modifier}

            # comment
            def bar; end
            def baz; end
            end
          RUBY
        end

        it 'registers an offense and autocorrects when methods are all defined in class and there is already a bare access modifier' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            module Foo
              def bar; end
              def baz; end

              %{access_modifier} :bar, :baz
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.

              %{access_modifier}
              def quux; end
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo


              #{access_modifier}

            def bar; end
            def baz; end
              def quux; end
            end
          RUBY
        end

        it 'registers an offense but does not correct when not all methods are defined in class' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            module Foo
              def bar; end

              %{access_modifier} :bar, :baz
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_no_corrections
        end
      end

      it "registers an offense when argument to #{access_modifier} is splat with a `%i` array literal" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Foo
            foo
            %{access_modifier} *%i[bar baz]
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_no_corrections
      end

      it "registers an offense when argument to #{access_modifier} is splat with a constant" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Foo
            foo
            %{access_modifier} *METHOD_NAMES
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_no_corrections
      end
    end

    context 'allow access modifiers on attrs' do
      let(:cop_config) { { 'AllowModifiersOnAttrs' => true } }

      it "accepts when argument to #{access_modifier} is an attr_*" do
        expect_no_offenses(<<~RUBY)
          class Foo
            #{access_modifier} attr_reader :foo
            #{access_modifier} attr_writer :bar
            #{access_modifier} attr_accessor :baz
            #{access_modifier} attr :qux
          end
        RUBY
      end

      it 'accepts multiple arguments on attrs' do
        expect_no_offenses(<<~RUBY)
          class Foo
            #{access_modifier} attr_reader :reader1, :reader2
            #{access_modifier} attr_writer :writer1, :writer2
            #{access_modifier} attr_accessor :accessor1, :accessor2
            #{access_modifier} attr :attr1, :attr2
          end
        RUBY
      end
    end

    context 'do not allow access modifiers on attrs' do
      let(:cop_config) { { 'AllowModifiersOnAttrs' => false } }

      %i[attr_reader attr_writer attr_accessor attr].each do |attr_method|
        context "for #{access_modifier} #{attr_method}" do
          it 'registers an offense for a single symbol' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              class Foo
                foo
                %{access_modifier} #{attr_method} :bar
                ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
              end
            RUBY

            expect_correction(<<~RUBY)
              class Foo
                foo
              #{access_modifier}

              #{attr_method} :bar
              end
            RUBY
          end

          it 'registers an offense for multiple symbols' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              class Foo
                foo
                %{access_modifier} #{attr_method} :bar, :baz
                ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
              end
            RUBY

            expect_correction(<<~RUBY)
              class Foo
                foo
              #{access_modifier}

              #{attr_method} :bar, :baz
              end
            RUBY
          end
        end
      end
    end

    context 'allow access modifiers on alias_method' do
      let(:cop_config) { { 'AllowModifiersOnAliasMethod' => true } }

      it "accepts when argument to #{access_modifier} is an alias_method" do
        expect_no_offenses(<<~RUBY)
          class Foo
            #{access_modifier} alias_method :bar, :foo
          end
        RUBY
      end
    end

    context 'do not allow access modifiers on alias_method' do
      let(:cop_config) { { 'AllowModifiersOnAliasMethod' => false } }

      it "registers an offense when argument to #{access_modifier} is an alias_method" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Foo
            #{access_modifier} alias_method :bar, :foo
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
          #{access_modifier}

          alias_method :bar, :foo
          end
        RUBY
      end
    end
  end

  context 'when `group` is configured' do
    let(:cop_config) { { 'EnforcedStyle' => 'group' } }

    %w[private protected public module_function].each do |access_modifier|
      it "offends when #{access_modifier} is inlined with a method" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Test
            %{access_modifier} def foo; end
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
          #{access_modifier}

          def foo; end
          end
        RUBY
      end

      it "offends when #{access_modifier} is inlined with a method on the top level" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          %{access_modifier} def foo; end
          ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
        RUBY

        expect_correction(<<~RUBY)
          #{access_modifier}

          def foo; end
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier}
          end
        RUBY
      end

      it "accepts when using only #{access_modifier}" do
        expect_no_offenses(<<~RUBY)
          #{access_modifier}
        RUBY
      end

      it "does not offend when #{access_modifier} is not inlined and has a comment" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} # hey
          end
        RUBY
      end

      it "registers an offense for correct + multiple opposite styles of #{access_modifier} usage" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class TestOne
            #{access_modifier}
          end

          class TestTwo
            #{access_modifier} def foo; end
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end

          class TestThree
            #{access_modifier} def foo; end
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_correction(<<~RUBY)
          class TestOne
            #{access_modifier}
          end

          class TestTwo
          #{access_modifier}

          def foo; end
          end

          class TestThree
          #{access_modifier}

          def foo; end
          end
        RUBY
      end

      context 'when method is modified by inline modifier' do
        it 'registers and autocorrects an offense' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier} def foo; end
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
            #{access_modifier}

            def foo; end
            end
          RUBY
        end
      end

      it "does not register an offense when using #{access_modifier} in a block" do
        expect_no_offenses(<<~RUBY)
          module MyModule
            singleton_methods.each { |method| #{access_modifier}(method) }
          end
        RUBY
      end

      it "does not register an offense when using #{access_modifier} in a numblock" do
        expect_no_offenses(<<~RUBY)
          module MyModule
            singleton_methods.each { #{access_modifier}(_1) }
          end
        RUBY
      end

      context 'when method is modified by inline modifier with disallowed symbol' do
        let(:cop_config) do
          { 'AllowModifiersOnSymbols' => false }
        end

        it 'registers and autocorrects an offense' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              def foo; end
              #{access_modifier} :foo
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
            #{access_modifier}

            def foo; end
            end
          RUBY
        end
      end

      context 'when non-existent method is modified by inline modifier with disallowed symbol' do
        let(:cop_config) do
          { 'AllowModifiersOnSymbols' => false }
        end

        it 'registers an offense but does not autocorrect it' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier} :foo
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_no_corrections
        end
      end

      %w[attr attr_reader attr_writer attr_accessor].each do |attr_method|
        context "when method is modified by inline modifier with disallowed #{attr_method}" do
          let(:cop_config) do
            { 'AllowModifiersOnAttrs' => false }
          end

          it 'registers and autocorrects an offense' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              class Test
                #{access_modifier} #{attr_method} :foo
                ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
              end
            RUBY

            expect_correction(<<~RUBY)
              class Test
              #{access_modifier}

              #{attr_method} :foo
              end
            RUBY
          end
        end
      end

      context 'when method is modified by inline modifier where group modifier already exists' do
        it 'registers and autocorrects an offense' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier} def foo; end
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.

              #{access_modifier}
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test

              #{access_modifier}

            def foo; end
            end
          RUBY
        end
      end

      context 'when method has comments' do
        it 'registers and autocorrects an offense' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              # comment
              #{access_modifier} def foo
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
                # comment
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
            #{access_modifier}

            # comment
            def foo
                # comment
              end
            end
          RUBY
        end
      end

      context "with #{access_modifier} within `if` node" do
        it "does not offend when #{access_modifier} does not have right sibling node" do
          expect_no_offenses(<<~RUBY)
            class Test
              #{access_modifier} :inspect if METHODS.include?(:inspect)
            end
          RUBY
        end

        it 'registers and autocorrects offense if conditional modifier is followed by a normal one' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier} get_method_name if get_method_name =~ /a/
              #{access_modifier} def bar; end
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
              #{access_modifier} get_method_name if get_method_name =~ /a/
            #{access_modifier}

            def bar; end
            end
          RUBY
        end

        it 'registers and autocorrects offense if conditional modifiers wrap a normal one' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier} get_method_name_1 if get_method_name_1 =~ /a/
              #{access_modifier} def bar; end
              ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
              #{access_modifier} get_method_name_2 if get_method_name_2 =~ /b/
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
              #{access_modifier} get_method_name_1 if get_method_name_1 =~ /a/
              #{access_modifier} get_method_name_2 if get_method_name_2 =~ /b/
            #{access_modifier}

            def bar; end
            end
          RUBY
        end
      end

      include_examples 'always accepted', access_modifier
    end

    it 'offends when multiple groupable access modifiers are defined' do
      expect_offense(<<~RUBY)
        class Test
          private def foo; end
          private def bar; end
          ^^^^^^^ `private` should not be inlined in method definitions.
          def baz; end
          QUX = ['qux']
        end
      RUBY

      expect_correction(<<~RUBY)
        class Test
          def baz; end
          QUX = ['qux']
        private

        def foo; end

        def bar; end
        end
      RUBY
    end
  end

  context 'when `inline` is configured' do
    let(:cop_config) { { 'EnforcedStyle' => 'inline' } }

    %w[private protected public module_function].each do |access_modifier|
      it "offends when #{access_modifier} is not inlined" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Test
            %{access_modifier}
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
            def foo; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "offends when #{access_modifier} is not inlined and has a comment" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Test
            %{access_modifier} # hey
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
            def foo; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a method" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "does not offend when #{access_modifier} is inlined with a symbol" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier} :foo

            def foo; end
          end
        RUBY
      end

      it "registers an offense for correct + multiple opposite styles of #{access_modifier} usage" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class TestOne
            #{access_modifier} def foo; end
          end

          class TestTwo
            #{access_modifier}
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
            def foo; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class TestOne
            #{access_modifier} def foo; end
          end

          class TestTwo
            #{access_modifier} def foo; end
          end
        RUBY
      end

      it "does not register an offense for #{access_modifier} without method definitions" do
        expect_no_offenses(<<~RUBY)
          #{access_modifier}
        RUBY
      end

      context 'when methods are modified by group modifier' do
        it 'registers and autocorrects an offense' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              #{access_modifier}
              ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.

              def foo; end

              def bar; end
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
              #{access_modifier} def foo; end

              #{access_modifier} def bar; end
            end
          RUBY
        end

        it 'registers an offense when using a grouped access modifier declaration' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            class Test
              def something_else; end

              def a_method_that_is_public; end

              #{access_modifier}
              ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.

              def my_other_private_method; end

              def bar; end
            end
          RUBY

          expect_correction(<<~RUBY)
            class Test
              def something_else; end

              def a_method_that_is_public; end

              #{access_modifier} def my_other_private_method; end

              #{access_modifier} def bar; end
            end
          RUBY
        end
      end

      context 'with `begin` parent node' do
        it 'registers an offense when modifier and method definition are on different lines' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            %{access_modifier};
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
            def foo
            end

            def bar
            end
          RUBY

          expect_correction(<<~RUBY)
            #{access_modifier} def foo
            end

            #{access_modifier} def bar
            end
          RUBY
        end

        it 'registers an offense when modifier and method definition are on the same line' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            %{access_modifier}; def foo; end
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          RUBY

          expect_correction(<<~RUBY)
            #{access_modifier} def foo; end
          RUBY
        end

        it 'registers an offense when modifier and method definitions are on the same line' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            %{access_modifier}; def foo; end; def bar; end
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          RUBY

          expect_correction(<<~RUBY)
            #{access_modifier} def foo; end; #{access_modifier} def bar; end
          RUBY
        end

        it 'registers an offense when modifier and method definitions and some other node are on the same line' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            %{access_modifier}; def foo; end; some_method; def bar; end
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          RUBY

          expect_correction(<<~RUBY)
            #{access_modifier} def foo; end; some_method; #{access_modifier} def bar; end
          RUBY
        end
      end

      include_examples 'always accepted', access_modifier
    end
  end
end
