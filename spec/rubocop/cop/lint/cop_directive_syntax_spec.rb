# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::CopDirectiveSyntax, :config do
  describe 'autocorrection' do
    it 'inserts the missing comma between two cop names' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength Style/Encoding
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength, Style/Encoding
      RUBY
    end

    it 'marks a trailing comment with the `--` separator' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength this is why
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength -- this is why
      RUBY
    end

    it 'replaces a `#` comment separator with `--`' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength # this is why
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength -- this is why
      RUBY
    end

    it 'separates omitted cop names and a trailing comment' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength Style/Encoding this is why
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength, Style/Encoding -- this is why
      RUBY
    end

    it 'keeps a comment after a department name' do
      expect_offense(<<~RUBY)
        # rubocop:disable Style this is why
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Style -- this is why
      RUBY
    end

    it 'removes a stray trailing comma' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength,
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength
      RUBY
    end

    it 'removes stray trailing punctuation' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength:
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_correction(<<~RUBY)
        # rubocop:disable Layout/LineLength
      RUBY
    end

    it 'does not correct a second directive in the same comment' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength # rubocop:disable Style/Encoding
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
      RUBY

      expect_no_corrections
    end
  end

  it 'does not register an offense for a single cop name' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for a single cop department' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout
    RUBY
  end

  it 'does not register an offense for multiple cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength, Style/Encoding
    RUBY
  end

  it 'does not register an offense for `all` cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable all
    RUBY
  end

  it 'does not register an offense for enable directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:enable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for todo directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:todo Layout/LineLength
    RUBY
  end

  it 'registers an offense for multiple cops a without comma' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength Style/Encoding
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end

  it 'registers an offense for duplicate directives' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength # rubocop:disable Style/Encoding
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end

  it 'registers an offense for missing cop name' do
    expect_offense(<<~RUBY)
      # rubocop:disable
      ^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The cop name is missing.
    RUBY
  end

  it 'registers an offense for incorrect mode' do
    expect_offense(<<~RUBY)
      # rubocop:disabled Layout/LineLength
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The mode name must be one of `enable`, `disable`, `disable-next`, `todo`, `todo-next`, `push`, or `pop`.
    RUBY
  end

  it 'registers an offense if the mode name is missing' do
    expect_offense(<<~RUBY)
      # rubocop:
      ^^^^^^^^^^ Malformed directive comment detected. The mode name is missing.
    RUBY
  end

  it 'does not register an offense when a comment does not start with `# rubocop:`, which is not a directive comment' do
    expect_no_offenses(<<~RUBY)
      # "rubocop:disable Layout/LineLength"
    RUBY
  end

  it 'does not register an offense for duplicate comment out' do
    expect_no_offenses(<<~RUBY)
      # # rubocop:disable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for an extra trailing comment' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength -- This is a good comment.
    RUBY
  end

  it 'does not register an offense for a single line directive with trailing comment' do
    expect_no_offenses(<<~RUBY)
      a = 1 # rubocop:disable Layout/LineLength -- This is a good comment.
    RUBY
  end

  it 'registers an offense when trailing comment does not start with `--`' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength == This is a bad comment.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end

  context 'with `-next` directives' do
    it 'does not register an offense for a `disable-next` on its own line' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable-next Layout/LineLength
        foo
      RUBY
    end

    it 'does not register an offense for a `todo-next` with a trailing comment' do
      expect_no_offenses(<<~RUBY)
        # rubocop:todo-next Layout/LineLength -- reason
        foo
      RUBY
    end

    it 'registers an offense for a `disable-next` at the end of a code line' do
      expect_offense(<<~RUBY)
        foo # rubocop:disable-next Layout/LineLength
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ A `-next` directive must be on its own line, above the statement it applies to.
        bar
      RUBY
    end

    it 'registers an offense for an unknown cop name in a `disable-next`' do
      expect_offense(<<~RUBY)
        # rubocop:disable-next Layout/LineLenght
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown cop name `Layout/LineLenght` (did you mean `Layout/LineLength`?).
        foo
      RUBY
    end
  end

  context 'with a near-miss directive keyword' do
    it 'registers an offense for a typo in the keyword' do
      expect_offense(<<~RUBY)
        # rucocop:disable Layout/LineLength
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The directive keyword must be `rubocop`, not `rucocop`.
      RUBY
    end

    it 'registers an offense for a wrongly-cased keyword' do
      expect_offense(<<~RUBY)
        # RuboCop:disable Layout/LineLength
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The directive keyword must be `rubocop`, not `RuboCop`.
      RUBY
    end

    it 'registers an offense for a trailing near-miss directive' do
      expect_offense(<<~RUBY)
        a = 1 # robocop:disable Layout/LineLength
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The directive keyword must be `rubocop`, not `robocop`.
      RUBY
    end

    it 'does not register an offense for other tools directives' do
      expect_no_offenses(<<~RUBY)
        # pylint: disable=foo
      RUBY
    end

    it 'does not register an offense for prose mentioning a mode name after a colon' do
      expect_no_offenses(<<~RUBY)
        # TODO: disable the cop here eventually
      RUBY
    end
  end

  context 'with an unknown cop name' do
    it 'registers an offense with a suggestion for a misspelled cop name' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLenght
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown cop name `Layout/LineLenght` (did you mean `Layout/LineLength`?).
      RUBY
    end

    it 'registers an offense in a list of cop names' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/LineLength, Style/Encodingg
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown cop name `Style/Encodingg` (did you mean `Style/Encoding`?).
      RUBY
    end

    it 'registers an offense for an unknown cop name in an enable directive' do
      expect_offense(<<~RUBY)
        # rubocop:enable Layout/LineLenght
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unknown cop name `Layout/LineLenght` (did you mean `Layout/LineLength`?).
      RUBY
    end

    it 'does not register an offense for an unqualified cop name that resolves' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable LineLength
      RUBY
    end
  end
end
