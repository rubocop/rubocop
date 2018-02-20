# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::DefEndAlignment, :config do
  subject(:cop) { described_class.new(config) }

  let(:source) do
    <<-RUBY.strip_indent
      foo def a
        a1
      end

      foo def b
            b1
          end
    RUBY
  end

  context 'when EnforcedStyleAlignWith is start_of_line' do
    let(:cop_config) do
      { 'EnforcedStyleAlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', <<-RUBY, false
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

    context 'in ruby 2.1 or later' do
      include_examples 'aligned', 'foo def', 'test', 'end'
      include_examples 'aligned', 'foo bar def', 'test', 'end'

      include_examples 'misaligned', <<-RUBY, :def
        foo def test
            end
            ^^^ `end` at 2, 4 is not aligned with `foo def` at 1, 0.
      RUBY
    end

    context 'correct + opposite' do
      it 'registers an offense' do
        inspect_source(source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages.first)
          .to eq('`end` at 7, 4 is not aligned with `foo def` at 5, 0.')
        expect(cop.highlights.first).to eq('end')
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'does auto-correction' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq(<<-RUBY.strip_indent)
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

  context 'when EnforcedStyleAlignWith is def' do
    let(:cop_config) do
      { 'EnforcedStyleAlignWith' => 'def', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', <<-RUBY, false
      def test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.

      def Test.test
        end
        ^^^ `end` at 2, 2 is not aligned with `def` at 1, 0.
    RUBY

    include_examples 'aligned', 'def', 'test',      'end'
    include_examples 'aligned', 'def', 'Test.test', 'end', 'defs'

    context 'in ruby 2.1 or later' do
      include_examples('aligned',
                       'foo def', 'test',
                       '    end')

      include_examples 'misaligned', <<-RUBY, :start_of_line
        foo def test
        end
        ^^^ `end` at 2, 0 is not aligned with `def` at 1, 4.
      RUBY

      context 'correct + opposite' do
        it 'registers an offense' do
          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages.first)
            .to eq('`end` at 3, 0 is not aligned with `def` at 1, 4.')
          expect(cop.highlights.first).to eq('end')
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'does auto-correction' do
          corrected = autocorrect_source(source)
          expect(corrected).to eq(<<-RUBY.strip_indent)
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
end
