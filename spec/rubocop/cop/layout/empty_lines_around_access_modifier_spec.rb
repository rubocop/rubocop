# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundAccessModifier, :config do
  context 'EnforcedStyle is `around`' do
    let(:cop_config) { { 'EnforcedStyle' => 'around' } }

    %w[private protected public module_function].each do |access_modifier|
      it "requires blank line before #{access_modifier}" do
        expect_offense(<<~RUBY)
          class Test
            something
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line before and after `#{access_modifier}`.

            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            something

            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it "requires blank line after #{access_modifier}" do
        expect_offense(<<~RUBY)
          class Test
            something

            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line before and after `#{access_modifier}`.
            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            something

            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it "ignores comment line before #{access_modifier}" do
        expect_no_offenses(<<~RUBY)
          class Test
            something

            # This comment is fine
            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it "ignores #{access_modifier} inside a method call" do
        expect_no_offenses(<<~RUBY)
          class Test
            def #{access_modifier}?
              #{access_modifier}
            end
          end
        RUBY
      end

      it "ignores an accessor with the same name as #{access_modifier} " \
         'above a method definition' do
        expect_no_offenses(<<~RUBY)
          class Test
            attr_reader #{access_modifier}
            def foo
            end
          end
        RUBY
      end

      it "ignores #{access_modifier} deep inside a method call" do
        expect_no_offenses(<<~RUBY)
          class Test
            def #{access_modifier}?
              if true
                #{access_modifier}
              end
            end
          end
        RUBY
      end

      it "ignores #{access_modifier} with a right-hand-side condition" do
        expect_no_offenses(<<~RUBY)
          class Test
            def #{access_modifier}?
              #{access_modifier} if true
            end
          end
        RUBY
      end

      it "ignores #{access_modifier} with block argument" do
        expect_no_offenses(<<~RUBY)
          def foo
            #{access_modifier} { do_something }
          end
        RUBY
      end

      it 'autocorrects blank line after #{access_modifier} with comment' do
        expect_offense(<<~RUBY)
          class Test
            something

            #{access_modifier} # let's modify the rest
            #{'^' * access_modifier.size} Keep a blank line before and after `#{access_modifier}`.
            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            something

            #{access_modifier} # let's modify the rest

            def test; end
          end
        RUBY
      end

      it 'accepts missing blank line when at the beginning of class' do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it 'accepts missing blank line when at the beginning of module' do
        expect_no_offenses(<<~RUBY)
          module Test
            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it 'accepts missing blank line when at the beginning of sclass' do
        expect_no_offenses(<<~RUBY)
          class << self
            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it 'accepts missing blank line when specifying a superclass that breaks the line' do
        expect_no_offenses(<<~RUBY)
          class Foo <
                Bar
            #{access_modifier}

            def do_something
            end
          end
        RUBY
      end

      it 'accepts missing blank line when specifying `self` that breaks the line' do
        expect_no_offenses(<<~RUBY)
          class <<
                self
            #{access_modifier}

            def do_something
            end
          end
        RUBY
      end

      it 'accepts missing blank line when at the beginning of file' \
         'when specifying a superclass that breaks the line' do
        expect_no_offenses(<<~RUBY)
          #{access_modifier}

          def do_something
          end
        RUBY
      end

      it "requires blank line after, but not before, #{access_modifier} " \
         'when at the beginning of class/module' do
        expect_offense(<<~RUBY)
          class Test
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line after `#{access_modifier}`.
            def test
            end
          end
        RUBY
      end

      it 'accepts missing blank line when at the beginning of file and preceded by a comment' do
        expect_no_offenses(<<~RUBY)
          # comment
          #{access_modifier}

          def do_something
          end
        RUBY
      end

      context 'at the beginning of block' do
        context 'for blocks defined with do' do
          it 'accepts missing blank line' do
            expect_no_offenses(<<~RUBY)
              included do
                #{access_modifier}

                def test; end
              end
            RUBY
          end

          it 'accepts missing blank line with arguments' do
            expect_no_offenses(<<~RUBY)
              included do |foo|
                #{access_modifier}

                def test; end
              end
            RUBY
          end

          it "requires blank line after, but not before, #{access_modifier}" do
            expect_offense(<<~RUBY)
              included do
                #{access_modifier}
                #{'^' * access_modifier.size} Keep a blank line after `#{access_modifier}`.
                def test
                end
              end
            RUBY
          end
        end

        context 'for blocks defined with {}' do
          it 'accepts missing blank line' do
            expect_no_offenses(<<~RUBY)
              included {
                #{access_modifier}

                def test; end
              }
            RUBY
          end

          it 'accepts missing blank line with arguments' do
            expect_no_offenses(<<~RUBY)
              included { |foo|
                #{access_modifier}

                def test; end
              }
            RUBY
          end
        end
      end

      it 'accepts missing blank line when at the end of block' do
        expect_no_offenses(<<~RUBY)
          class Test
            def test; end

            #{access_modifier}
          end
        RUBY
      end

      it 'accepts missing blank line when at the end of specifying a superclass' do
        expect_no_offenses(<<~RUBY)
          class Test < Base
            def test; end

            #{access_modifier}
          end
        RUBY
      end

      it 'accepts missing blank line when at the end of specifying `self`' do
        expect_no_offenses(<<~RUBY)
          class << self
            def test; end

            #{access_modifier}
          end
        RUBY
      end

      it 'requires blank line when next line started with end' do
        expect_offense(<<~RUBY)
          class Test
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line after `#{access_modifier}`.
            end_this!
          end
        RUBY
      end

      it 'recognizes blank lines with DOS style line endings' do
        expect_no_offenses(<<~RUBY)
          class Test\r
          \r
            #{access_modifier}\r
          \r
            def test; end\r
          end\r
        RUBY
      end

      it 'accepts only using access modifier' do
        expect_no_offenses(<<~RUBY)
          #{access_modifier}
        RUBY
      end

      it 'accepts when an access modifier and an expression are on the same line' do
        expect_no_offenses(<<~RUBY)
          #{access_modifier}; foo
          .bar
        RUBY
      end

      context 'inside an implicit `begin` node' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, access_modifier: access_modifier)
            foo
            %{access_modifier}
            ^{access_modifier} Keep a blank line before and after `%{access_modifier}`.
            bar
          RUBY

          expect_correction(<<~RUBY)
            foo

            #{access_modifier}

            bar
          RUBY
        end
      end

      context 'when `Layout/EmptyLinesAroundBlockBody` is configured with `EnforcedStyle: no_empty_lines`' do
        let(:other_cops) do
          { 'Layout/EmptyLinesAroundBlockBody' => { 'EnforcedStyle' => 'no_empty_lines' } }
        end

        context 'access modifier is the only child of the block' do
          it 'registers an offense but does not correct' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                %{access_modifier}
                ^{access_modifier} Keep a blank line after `%{access_modifier}`.
              end
            RUBY

            expect_no_corrections
          end
        end

        context 'access modifier is the first child of the block' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                %{access_modifier}
                ^{access_modifier} Keep a blank line after `%{access_modifier}`.
                foo
              end
            RUBY

            expect_correction(<<~RUBY)
              Module.new do
                #{access_modifier}

                foo
              end
            RUBY
          end
        end

        context 'access modifier is the last child of the block' do
          it 'registers an offense and partially corrects' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                foo
                %{access_modifier}
                ^{access_modifier} Keep a blank line before and after `%{access_modifier}`.
              end
            RUBY

            expect_correction(<<~RUBY)
              Module.new do
                foo

                #{access_modifier}
              end
            RUBY
          end
        end
      end

      context 'when `Layout/EmptyLinesAroundBlockBody` is configured with `EnforcedStyle: empty_lines`' do
        let(:other_cops) do
          { 'Layout/EmptyLinesAroundBlockBody' => { 'EnforcedStyle' => 'empty_lines' } }
        end

        context 'access modifier is the only child of the block' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                %{access_modifier}
                ^{access_modifier} Keep a blank line after `%{access_modifier}`.
              end
            RUBY

            expect_correction(<<~RUBY)
              Module.new do
                #{access_modifier}

              end
            RUBY
          end
        end

        context 'access modifier is the first child of the block' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                %{access_modifier}
                ^{access_modifier} Keep a blank line after `%{access_modifier}`.
                foo
              end
            RUBY

            expect_correction(<<~RUBY)
              Module.new do
                #{access_modifier}

                foo
              end
            RUBY
          end
        end

        context 'access modifier is the last child of the block' do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, access_modifier: access_modifier)
              Module.new do
                foo
                %{access_modifier}
                ^{access_modifier} Keep a blank line before and after `%{access_modifier}`.
              end
            RUBY

            expect_correction(<<~RUBY)
              Module.new do
                foo

                #{access_modifier}

              end
            RUBY
          end
        end
      end
    end
  end

  context 'EnforcedStyle is `only_before`' do
    let(:cop_config) { { 'EnforcedStyle' => 'only_before' } }

    %w[private protected].each do |access_modifier|
      it "accepts missing blank line after #{access_modifier}" do
        expect_no_offenses(<<~RUBY)
          class Test
            something

            #{access_modifier}
            def test; end
          end
        RUBY
      end

      it "registers an offense for blank line after #{access_modifier}" do
        expect_offense(<<~RUBY)
          class Test
            something

            #{access_modifier}
            #{'^' * access_modifier.size} Remove a blank line after `#{access_modifier}`.

            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            something

            #{access_modifier}
            def test; end
          end
        RUBY
      end

      it "does not register an offense when `end` immediately after #{access_modifier}" do
        expect_no_offenses(<<~RUBY)
          class Test
            #{access_modifier}
          end
        RUBY
      end
    end

    %w[public module_function].each do |access_modifier|
      it "accepts blank line after #{access_modifier}" do
        expect_no_offenses(<<~RUBY)
          module Kernel
            #{access_modifier}

            def do_something
            end
          end
        RUBY
      end
    end

    %w[private protected public module_function].each do |access_modifier|
      it "registers an offense for missing blank line before #{access_modifier}" do
        expect_offense(<<~RUBY)
          class Test
            something
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line before `#{access_modifier}`.
            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            something

            #{access_modifier}
            def test; end
          end
        RUBY
      end
    end
  end

  context 'Ruby 2.7', :ruby27 do
    %w[private protected public module_function].each do |access_modifier|
      it "registers an offense for missing around line before #{access_modifier}" do
        expect_offense(<<~RUBY)
          included do
            _1
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line before and after `#{access_modifier}`.
            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          included do
            _1

            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it "ignores #{access_modifier} with numblock argument" do
        expect_no_offenses(<<~RUBY)
          def foo
            #{access_modifier} { _1 }
          end
        RUBY
      end
    end
  end

  context 'Ruby 3.4', :ruby34, unsupported_on: :parser do
    %w[private protected public module_function].each do |access_modifier|
      it "registers an offense for missing around line before #{access_modifier}" do
        expect_offense(<<~RUBY)
          included do
            it
            #{access_modifier}
            #{'^' * access_modifier.size} Keep a blank line before and after `#{access_modifier}`.
            def test; end
          end
        RUBY

        expect_correction(<<~RUBY)
          included do
            it

            #{access_modifier}

            def test; end
          end
        RUBY
      end

      it "ignores #{access_modifier} with itblock argument" do
        expect_no_offenses(<<~RUBY)
          def foo
            #{access_modifier} { it }
          end
        RUBY
      end
    end
  end
end
