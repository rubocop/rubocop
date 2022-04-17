# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommentAnnotation, :config do
  context 'with default RequireColon configuration (colon + space)' do
    let(:cop_config) { { 'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW] } }

    context 'missing colon' do
      it 'registers an offense and adds colon' do
        expect_offense(<<~RUBY)
          # TODO make better
            ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # TODO: make better
        RUBY
      end
    end

    context 'with configured keyword' do
      let(:cop_config) { { 'Keywords' => %w[ISSUE] } }

      it 'registers an offense for a missing colon after the word' do
        expect_offense(<<~RUBY)
          # ISSUE wrong order
            ^^^^^^ Annotation keywords like `ISSUE` should be all upper case, followed by a colon, and a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # ISSUE: wrong order
        RUBY
      end
    end

    context 'missing space after colon' do
      it 'registers an offense and adds space' do
        expect_offense(<<~RUBY)
          # TODO:make better
            ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # TODO: make better
        RUBY
      end
    end

    context 'lower case keyword' do
      it 'registers an offense and upcases' do
        expect_offense(<<~RUBY)
          # fixme: does not work
            ^^^^^^^ Annotation keywords like `fixme` should be all upper case, followed by a colon, and a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # FIXME: does not work
        RUBY
      end
    end

    context 'capitalized keyword' do
      it 'registers an offense and upcases' do
        expect_offense(<<~RUBY)
          # Optimize: does not work
            ^^^^^^^^^^ Annotation keywords like `Optimize` should be all upper case, followed by a colon, and a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # OPTIMIZE: does not work
        RUBY
      end
    end

    context 'upper case keyword with colon but no note' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~RUBY)
          # HACK:
            ^^^^^ Annotation comment, with keyword `HACK`, is missing a note.
        RUBY

        expect_no_corrections
      end
    end

    context 'upper case keyword with space but no note' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~RUBY)
          # HACK#{trailing_whitespace}
            ^^^^^ Annotation comment, with keyword `HACK`, is missing a note.
        RUBY

        expect_no_corrections
      end
    end

    it 'accepts upper case keyword with colon, space and note' do
      expect_no_offenses('# REVIEW: not sure about this')
    end

    it 'accepts upper case keyword alone' do
      expect_no_offenses('# OPTIMIZE')
    end

    it 'accepts a comment that is obviously a code example' do
      expect_no_offenses('# Todo.destroy(1)')
    end

    it 'accepts a keyword that is just the beginning of a sentence' do
      expect_no_offenses(<<~RUBY)
        # Optimize if you want. I wouldn't recommend it.
        # Hack is a fun game.
      RUBY
    end

    it 'accepts a keyword that is somewhere in a sentence' do
      expect_no_offenses(<<~RUBY)
        # Example: There are three reviews, with ranks 1, 2, and 3. A new
        # review is saved with rank 2. The two reviews that originally had
        # ranks 2 and 3 will have their ranks increased to 3 and 4.
      RUBY
    end

    context 'when a keyword is not in the configuration' do
      let(:cop_config) { { 'Keywords' => %w[FIXME OPTIMIZE HACK REVIEW] } }

      it 'accepts the word without colon' do
        expect_no_offenses('# TODO make better')
      end
    end

    context 'offenses in consecutive inline comments' do
      it 'registers each of them' do
        expect_offense(<<~RUBY)
          class ToBeDone
            ITEMS = [
              '', # TODO Item 1
                    ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
              '', # TODO Item 2
                    ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
            ].freeze
          end
        RUBY
      end
    end

    context 'multiline comment' do
      it 'only registers an offense on the first line' do
        expect_offense(<<~RUBY)
          # TODO line 1
            ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
          # TODO line 2
          # TODO line 3
        RUBY
      end
    end

    context 'with multiword keywords' do
      let(:cop_config) { { 'Keywords' => ['TODO', 'DO SOMETHING', 'TODO LATER'] } }

      it 'registers an offense for each matching keyword' do
        cop_config['Keywords'].each do |keyword|
          expect_offense(<<~RUBY, keyword: keyword)
            # #{keyword} blah blah blah
              ^{keyword}^ Annotation keywords like `#{keyword}` should be all upper case, followed by a colon, and a space, then a note describing the problem.
          RUBY
        end
      end
    end
  end

  context 'with RequireColon configuration set to false' do
    let(:cop_config) do
      {
        'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW],
        'RequireColon' => false
      }
    end

    context 'with colon' do
      it 'registers an offense and removes colon' do
        expect_offense(<<~RUBY)
          # TODO: make better
            ^^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # TODO make better
        RUBY
      end
    end

    context 'with configured keyword' do
      let(:cop_config) { { 'Keywords' => %w[ISSUE], 'RequireColon' => false } }

      it 'registers an offense for containing a colon after the word' do
        expect_offense(<<~RUBY)
          # ISSUE: wrong order
            ^^^^^^^ Annotation keywords like `ISSUE` should be all upper case, followed by a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # ISSUE wrong order
        RUBY
      end
    end

    context 'lower case keyword' do
      it 'registers an offense and upcases' do
        expect_offense(<<~RUBY)
          # fixme does not work
            ^^^^^^ Annotation keywords like `fixme` should be all upper case, followed by a space, then a note describing the problem.
        RUBY

        expect_correction(<<~RUBY)
          # FIXME does not work
        RUBY
      end
    end

    context 'upper case keyword with colon but no note' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~RUBY)
          # HACK:
            ^^^^^ Annotation comment, with keyword `HACK`, is missing a note.
        RUBY

        expect_no_corrections
      end
    end

    context 'upper case keyword with space but no note' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~RUBY)
          # HACK#{trailing_whitespace}
            ^^^^^ Annotation comment, with keyword `HACK`, is missing a note.
        RUBY

        expect_no_corrections
      end
    end

    it 'accepts upper case keyword with colon, space and note' do
      expect_no_offenses('# REVIEW not sure about this')
    end

    it 'accepts upper case keyword alone' do
      expect_no_offenses('# OPTIMIZE')
    end

    it 'accepts a comment that is obviously a code example' do
      expect_no_offenses('# Todo.destroy(1)')
    end

    it 'accepts a keyword that is just the beginning of a sentence' do
      expect_no_offenses(<<~RUBY)
        # Optimize if you want. I wouldn't recommend it.
        # Hack is a fun game.
      RUBY
    end

    it 'accepts a keyword that is somewhere in a sentence' do
      expect_no_offenses(<<~RUBY)
        # Example: There are three reviews, with ranks 1, 2, and 3. A new
        # review is saved with rank 2. The two reviews that originally had
        # ranks 2 and 3 will have their ranks increased to 3 and 4.
      RUBY
    end

    context 'when a keyword is not in the configuration' do
      let(:cop_config) do
        {
          'Keywords' => %w[FIXME OPTIMIZE HACK REVIEW],
          'RequireColon' => false
        }
      end

      it 'accepts the word with colon' do
        expect_no_offenses('# TODO: make better')
      end
    end

    context 'offenses in consecutive inline comments' do
      it 'registers each of them' do
        expect_offense(<<~RUBY)
          class ToBeDone
            ITEMS = [
              '', # TODO: Item 1
                    ^^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a space, then a note describing the problem.
              '', # TODO: Item 2
                    ^^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a space, then a note describing the problem.
            ].freeze
          end
        RUBY
      end
    end

    context 'multiline comment' do
      it 'only registers an offense on the first line' do
        expect_offense(<<~RUBY)
          # TODO: line 1
            ^^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a space, then a note describing the problem.
          # TODO: line 2
          # TODO: line 3
        RUBY
      end
    end
  end
end
