# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessModifierDeclarations, :config do
  shared_examples 'always accepted' do |access_modifier|
    it 'accepts when #{access_modifier} is a hash literal value' do
      expect_no_offenses(<<~RUBY)
        class Foo
          foo
          bar(key: #{access_modifier})
        end
      RUBY
    end

    context 'allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => true } }

      it 'accepts when argument to #{access_modifier} is a symbol' do
        expect_no_offenses(<<~RUBY)
          class Foo
            foo
            #{access_modifier} :bar
          end
        RUBY
      end
    end

    context 'do not allow access modifiers on symbols' do
      let(:cop_config) { { 'AllowModifiersOnSymbols' => false } }

      it 'accepts when argument to #{access_modifier} is a symbol' do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Foo
            foo
            %{access_modifier} :bar
            ^{access_modifier} `#{access_modifier}` should not be inlined in method definitions.
          end
        RUBY

        expect_no_corrections
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

      it "does not offend when #{access_modifier} is not inlined" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier}
          end
        RUBY
      end

      it 'accepts when using only #{access_modifier}' do
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

      it 'registers an offense for correct + multiple opposite styles of #{access_modifier} usage' do
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

      include_examples 'always accepted', access_modifier
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
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
          end
        RUBY
      end

      it "offends when #{access_modifier} is not inlined and has a comment" do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class Test
            %{access_modifier} # hey
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
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

      it 'registers an offense for correct + multiple opposite styles of #{access_modifier} usage' do
        expect_offense(<<~RUBY, access_modifier: access_modifier)
          class TestOne
            #{access_modifier} def foo; end
          end

          class TestTwo
            #{access_modifier}
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          end

          class TestThree
            #{access_modifier}
            ^{access_modifier} `#{access_modifier}` should be inlined in method definitions.
          end
        RUBY

        expect_correction(<<~RUBY)
          class TestOne
            #{access_modifier} def foo; end
          end

          class TestTwo
          end

          class TestThree
          end
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
      end

      include_examples 'always accepted', access_modifier
    end
  end
end
