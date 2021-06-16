# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::DefEndAlignment, :config do
  context 'when EnforcedStyleAlignWith is start_of_line' do
    let(:cop_config) { { 'EnforcedStyleAlignWith' => 'start_of_line', 'AutoCorrect' => true } }

    include_examples 'misaligned', <<~RUBY, false
      def test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.

      def Test.test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.
    RUBY

    include_examples 'aligned', "\xef\xbb\xbfdef", 'test', 'end'
    include_examples 'aligned', 'def',       'test',       'end'
    include_examples 'aligned', 'def',       'Test.test',  'end', 'defs'

    include_examples 'aligned', 'foo def', 'test', 'end'
    include_examples 'aligned', 'foo bar def', 'test', 'end'

    include_examples 'misaligned', <<~RUBY, :def
      foo def test
          end
          ^^^ `end` at 2, 4 is not aligned with `foo def` at 1, 0.
    RUBY

    context 'correct + opposite' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo def a
            a1
          end

          foo def b
                b1
              end
              ^^^ `end` at 7, 4 is not aligned with `foo def` at 5, 0.
        RUBY
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)

        expect_correction(<<~RUBY)
          foo def a
            a1
          end

          foo def b
                b1
          end
        RUBY
      end
    end

    context 'when using refinements and `private def`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          using Module.new {
            refine Hash do
              class << Hash
                private def _ruby2_keywords_hash(*args)
                end
              end
            end
          }
        RUBY
      end
    end

    context 'when including an anonymous module containing `private def`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          include Module.new {
            private def foo
            end
          }
        RUBY
      end
    end
  end

  context 'when EnforcedStyleAlignWith is def' do
    let(:cop_config) { { 'EnforcedStyleAlignWith' => 'def', 'AutoCorrect' => true } }

    include_examples 'misaligned', <<~RUBY, false
      def test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.

      def Test.test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.
    RUBY

    include_examples 'aligned', 'def', 'test',      'end'
    include_examples 'aligned', 'def', 'Test.test', 'end', 'defs'

    include_examples('aligned', 'foo def', 'test', '    end')

    include_examples 'misaligned', <<~RUBY, :start_of_line
      foo def test
      end
      ^^^ `end` at 2, 0 is not aligned with `def` at 1, 4.
    RUBY

    context 'correct + opposite' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo def a
            a1
          end
          ^^^ `end` at 3, 0 is not aligned with `def` at 1, 4.
          foo def b
                b1
              end
        RUBY

        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)

        expect_correction(<<~RUBY)
          foo def a
            a1
              end
          foo def b
                b1
              end
        RUBY
      end
    end
  end
end
