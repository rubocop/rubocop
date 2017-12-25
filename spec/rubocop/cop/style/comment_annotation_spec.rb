# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommentAnnotation, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'Keywords' => %w[TODO FIXME OPTIMIZE HACK REVIEW] }
  end

  context 'missing colon' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        # TODO make better
          ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
      RUBY
    end

    it 'autocorrects' do
      corrected = autocorrect_source('# TODO make better')
      expect(corrected).to eq('# TODO: make better')
    end
  end

  context 'with configured keyword' do
    let(:cop_config) { { 'Keywords' => %w[ISSUE] } }

    it 'registers an offense for a missing colon after the word' do
      expect_offense(<<-RUBY.strip_indent)
        # ISSUE wrong order
          ^^^^^^ Annotation keywords like `ISSUE` should be all upper case, followed by a colon, and a space, then a note describing the problem.
      RUBY
    end

    it 'autocorrects a missing colon after keyword' do
      corrected = autocorrect_source('# ISSUE wrong order')
      expect(corrected).to eq('# ISSUE: wrong order')
    end
  end

  context 'missing space after colon' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        # TODO:make better
          ^^^^^ Annotation keywords like `TODO` should be all upper case, followed by a colon, and a space, then a note describing the problem.
      RUBY
    end

    it 'autocorrects' do
      corrected = autocorrect_source('# TODO:make better')
      expect(corrected).to eq('# TODO: make better')
    end
  end

  context 'lower case keyword' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        # fixme: does not work
          ^^^^^^^ Annotation keywords like `fixme` should be all upper case, followed by a colon, and a space, then a note describing the problem.
      RUBY
    end

    it 'autocorrects' do
      corrected = autocorrect_source('# fixme: does not work')
      expect(corrected).to eq('# FIXME: does not work')
    end
  end

  context 'capitalized keyword' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        # Optimize: does not work
          ^^^^^^^^^^ Annotation keywords like `Optimize` should be all upper case, followed by a colon, and a space, then a note describing the problem.
      RUBY
    end

    it 'autocorrects' do
      corrected = autocorrect_source('# Optimize: does not work')
      expect(corrected).to eq('# OPTIMIZE: does not work')
    end
  end

  context 'upper case keyword with colon by no note' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        # HACK:
          ^^^^^ Annotation comment, with keyword `HACK`, is missing a note.
      RUBY
    end

    it 'does not autocorrects' do
      source = '# HACK:'
      corrected = autocorrect_source(source)
      expect(corrected).to eq(source)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      # Optimize if you want. I wouldn't recommend it.
      # Hack is a fun game.
    RUBY
  end

  it 'accepts a keyword that is somewhere in a sentence' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # Example: There are three reviews, with ranks 1, 2, and 3. A new
      # review is saved with rank 2. The two reviews that originally had
      # ranks 2 and 3 will have their ranks increased to 3 and 4.
    RUBY
  end

  context 'when a keyword is not in the configuration' do
    let(:cop_config) do
      { 'Keywords' => %w[FIXME OPTIMIZE HACK REVIEW] }
    end

    it 'accepts the word without colon' do
      expect_no_offenses('# TODO make better')
    end
  end
end
