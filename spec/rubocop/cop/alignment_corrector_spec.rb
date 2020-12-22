# frozen_string_literal: true

RSpec.describe RuboCop::Cop::AlignmentCorrector, :config do
  let(:cop_class) { RuboCop::Cop::Test::AlignmentDirective }

  describe '#correct' do
    context 'simple indentation' do
      context 'with a positive column delta' do
        it 'indents' do
          expect_offense(<<~RUBY)
            # >> 2
              42
              ^^ Indent this node
          RUBY

          expect_correction(<<~RUBY, loop: false)
            # >> 2
                42
          RUBY
        end
      end

      context 'with a negative column delta' do
        it 'outdents' do
          expect_offense(<<~RUBY)
            # << 3
                42
                ^^ Indent this node
          RUBY

          expect_correction(<<~RUBY, loop: false)
            # << 3
             42
          RUBY
        end
      end
    end

    shared_examples 'heredoc indenter' do |start_heredoc, column_delta|
      let(:indentation) { ' ' * column_delta }
      let(:end_heredoc) { /\w+/.match(start_heredoc)[0] }

      it 'does not change indentation of here doc bodies and end markers' do
        expect_offense(<<~RUBY)
          # >> #{column_delta}
          begin
          ^^^^^ Indent this node
            #{start_heredoc}
          a
          b
          #{end_heredoc}
          end
        RUBY

        expect_correction(<<~RUBY, loop: false)
          # >> #{column_delta}
          #{indentation}begin
          #{indentation}  #{start_heredoc}
          a
          b
          #{end_heredoc}
          #{indentation}end
        RUBY
      end
    end

    context 'with large column deltas' do
      context 'with plain heredoc (<<)' do
        it_behaves_like 'heredoc indenter', '<<DOC', 20
      end

      context 'with heredoc in backticks (<<``)' do
        it_behaves_like 'heredoc indenter', '<<`DOC`', 20
      end
    end

    context 'with single-line here docs' do
      it 'does not indent body and end marker' do
        indentation = '  '
        expect_offense(<<~RUBY)
          # >> 2
          begin
          ^^^^^ Indent this node
            <<DOC
          single line
          DOC
          end
        RUBY

        expect_correction(<<~RUBY, loop: false)
          # >> 2
          #{indentation}begin
          #{indentation}  <<DOC
          single line
          DOC
          #{indentation}end
        RUBY
      end
    end

    context 'within string literals' do
      it 'does not insert whitespace' do
        expect_offense(<<~RUBY)
          # >> 2
          begin
          ^^^^^ Indent this node
            dstr =
          'a
          b
          c'
            xstr =
          `a
          b
          c`
          end
        RUBY

        expect_correction(<<~RUBY, loop: false)
          # >> 2
            begin
              dstr =
            'a
          b
          c'
              xstr =
            `a
          b
          c`
            end
        RUBY
      end
    end
  end
end
