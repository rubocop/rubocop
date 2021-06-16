# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineMemoization, :config do
  shared_examples 'with all enforced styles' do
    context 'with a single line memoization' do
      it 'allows expression on first line' do
        expect_no_offenses('foo ||= bar')
      end

      it 'allows expression on the following line' do
        expect_no_offenses(<<~RUBY)
          foo ||=
            bar
        RUBY
      end
    end

    context 'with a multiline memoization' do
      context 'without a `begin` and `end` block' do
        it 'allows with another block on the first line' do
          expect_no_offenses(<<~RUBY)
            foo ||= bar.each do |b|
              b.baz
              bb.ax
            end
          RUBY
        end

        it 'allows with another block on the following line' do
          expect_no_offenses(<<~RUBY)
            foo ||=
              bar.each do |b|
                b.baz
                b.bax
              end
          RUBY
        end

        it 'allows with a conditional on the first line' do
          expect_no_offenses(<<~RUBY)
            foo ||= if bar
                      baz
                    else
                      bax
                    end
          RUBY
        end

        it 'allows with a conditional on the following line' do
          expect_no_offenses(<<~RUBY)
            foo ||=
              if bar
                baz
              else
                bax
              end
          RUBY
        end
      end
    end
  end

  context 'EnforcedStyle: keyword' do
    let(:cop_config) { { 'EnforcedStyle' => 'keyword' } }

    include_examples 'with all enforced styles'

    context 'with a multiline memoization' do
      context 'without a `begin` and `end` block' do
        context 'when the expression is wrapped in parentheses' do
          it 'registers an offense when expression starts on first line' do
            expect_offense(<<~RUBY)
              foo ||= (
              ^^^^^^^^^ Wrap multiline memoization blocks in `begin` and `end`.
                bar
                baz
              )
            RUBY

            expect_correction(<<~RUBY)
              foo ||= begin
                bar
                baz
              end
            RUBY
          end

          it 'registers an offense when expression starts on following line' do
            expect_offense(<<~RUBY)
              foo ||=
              ^^^^^^^ Wrap multiline memoization blocks in `begin` and `end`.
                (
                  bar
                  baz
                )
            RUBY

            expect_correction(<<~RUBY)
              foo ||=
                begin
                  bar
                  baz
                end
            RUBY
          end

          it 'registers an offense with multiline expression' do
            expect_offense(<<~RUBY)
              foo ||= (bar ||
              ^^^^^^^^^^^^^^^ Wrap multiline memoization blocks in `begin` and `end`.
                        baz)
            RUBY

            expect_correction(<<~RUBY)
              foo ||= begin
                        bar ||
                        baz
                      end
            RUBY
          end
        end
      end
    end
  end

  context 'EnforcedStyle: braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    include_examples 'with all enforced styles'

    context 'with a multiline memoization' do
      context 'without braces' do
        context 'when the expression is wrapped in `begin` and `end` keywords' do
          it 'registers an offense for begin...end block on first line' do
            expect_offense(<<~RUBY)
              foo ||= begin
              ^^^^^^^^^^^^^ Wrap multiline memoization blocks in `(` and `)`.
                bar
                baz
              end
            RUBY

            expect_correction(<<~RUBY)
              foo ||= (
                bar
                baz
              )
            RUBY
          end

          it 'registers an offense for begin...end block on following line' do
            expect_offense(<<~RUBY)
              foo ||=
              ^^^^^^^ Wrap multiline memoization blocks in `(` and `)`.
                begin
                  bar
                  baz
                end
            RUBY

            expect_correction(<<~RUBY)
              foo ||=
                (
                  bar
                  baz
                )
            RUBY
          end
        end
      end
    end
  end
end
