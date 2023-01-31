# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::LineEndStringConcatenationIndentation, :config do
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Layout/LineEndStringConcatenationIndentation']
             .merge(cop_config)
             .merge('Enabled' => true)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Layout/LineEndStringConcatenationIndentation' => merged,
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Layout/IndentationWidth

  shared_examples 'common' do
    it 'accepts single line string literal concatenation' do
      expect_no_offenses(<<~'RUBY')
        text = 'offense'
        puts 'This probably should not be '"an #{text}"
      RUBY
    end

    it 'accepts string literal with line break concatenated with other string' do
      expect_no_offenses(<<~'RUBY')
        text = 'offense'
        puts 'This probably
              should not be '"an #{text}"
      RUBY
    end

    it 'accepts a multiline string literal' do
      expect_no_offenses(<<~RUBY)
        puts %(
          foo
          bar
        )
      RUBY
    end

    it 'accepts indented strings in implicit return statement of a block' do
      expect_no_offenses(<<~'RUBY')
        some_method do
          'a' \
            'b' \
            'c'
        end
      RUBY
    end

    it 'accepts indented strings in implicit return statement of a method definition' do
      expect_no_offenses(<<~'RUBY')
        def some_method
          'a' \
            'b' \
            'c'
        end
      RUBY
    end

    it 'registers an offense for aligned strings in an if/elsif/else statement' do
      expect_offense(<<~'RUBY')
        if cond1
          'a' \
          'b'
          ^^^ Indent the first part of a string concatenated with backslash.
        elsif cond2
          'c' \
          'd'
          ^^^ Indent the first part of a string concatenated with backslash.
        else
          'e' \
          'f'
          ^^^ Indent the first part of a string concatenated with backslash.
        end
      RUBY

      expect_correction(<<~'RUBY')
        if cond1
          'a' \
            'b'
        elsif cond2
          'c' \
            'd'
        else
          'e' \
            'f'
        end
      RUBY
    end

    it 'accepts indented strings in implicit return statement of a singleton method definition' do
      expect_no_offenses(<<~'RUBY')
        def self.some_method
          'a' \
            'b' \
            'c'
        end
      RUBY
    end

    it 'accepts indented strings in implicit return statement of a method definition after other statement' do
      expect_no_offenses(<<~'RUBY')
        def some_method
          b = 'b'
          'a' \
            "#{b}" \
            'c'
        end
      RUBY
    end

    it 'accepts indented strings in ordinary statement' do
      expect_no_offenses(<<~'RUBY')
        'a' \
          'b' \
          'c'
      RUBY
    end

    it 'accepts a heredoc string with interpolation' do
      expect_no_offenses(<<~'RUBY')
        warn <<~TEXT
          A #{b}
        TEXT
      RUBY
    end

    it 'accepts a heredoc string ...' do
      expect_no_offenses(<<~RUBY)
        let(:source) do
          <<~CODE
            func({
              @abc => 0,
              @xyz => 1
            })
            func(
              {
                abc: 0
              }
            )
            func(
              {},
              {
                xyz: 1
              }
            )
          CODE
        end
      RUBY
    end

    it 'accepts an empty heredoc string with interpolation' do
      expect_no_offenses(<<~RUBY)
        puts(<<~TEXT)
        TEXT
      RUBY
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    it 'accepts aligned strings in method call' do
      expect_no_offenses(<<~'RUBY')
        puts 'a' \
             'b'
      RUBY
    end

    ['X =', '$x =', '@x =', 'x =', 'x +=', 'x ||='].each do |lhs_and_operator|
      context "for assignment with #{lhs_and_operator}" do
        let(:aligned_strings) do
          [%(#{lhs_and_operator} "a" \\), "#{' ' * lhs_and_operator.length} 'b'", ''].join("\n")
        end

        it 'accepts aligned strings' do
          expect_no_offenses(aligned_strings)
        end

        it 'registers an offense for indented strings' do
          expect_offense([%(#{lhs_and_operator} "a" \\),
                          "  'b'",
                          '  ^^^ Align parts of a string concatenated with backslash.',
                          ''].join("\n"))

          expect_correction(aligned_strings)
        end
      end
    end

    it 'registers an offense for unaligned strings in hash literal values' do
      expect_offense(<<~'RUBY')
        MESSAGES = { KeyAlignment => 'Align the keys of a hash literal if ' \
          'they span more than one line.',
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align parts of a string concatenated with backslash.
                     SeparatorAlignment => 'Align the separators of a hash ' \
                       'literal if they span more than one line.',
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align parts of a string concatenated with backslash.
                     TableAlignment => 'Align the keys and values of a hash ' \
                       'literal if they span more than one line.' }.freeze
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Align parts of a string concatenated with backslash.
      RUBY

      expect_correction(<<~'RUBY')
        MESSAGES = { KeyAlignment => 'Align the keys of a hash literal if ' \
                                     'they span more than one line.',
                     SeparatorAlignment => 'Align the separators of a hash ' \
                                           'literal if they span more than one line.',
                     TableAlignment => 'Align the keys and values of a hash ' \
                                       'literal if they span more than one line.' }.freeze
      RUBY
    end

    it 'registers an offense for indented string' do
      expect_offense(<<~'RUBY')
        puts 'a' \
          "b" \
          ^^^ Align parts of a string concatenated with backslash.
          'c'
      RUBY

      expect_correction(<<~'RUBY')
        puts 'a' \
             "b" \
             'c'
      RUBY
    end

    it 'registers an offense for third part of a string if it is aligned only with the first' do
      expect_offense(<<~'RUBY')
        puts 'a' \
          'b' \
          ^^^ Align parts of a string concatenated with backslash.
             'c'
             ^^^ Align parts of a string concatenated with backslash.
      RUBY

      expect_correction(<<~'RUBY')
        puts 'a' \
             'b' \
             'c'
      RUBY
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'

    it 'accepts indented strings' do
      expect_no_offenses(<<~'RUBY')
        puts 'a' \
          'b'
      RUBY
    end

    ['X =', '$x =', '@x =', 'x =', 'x +=', 'x ||='].each do |lhs_and_operator|
      context "for assignment with #{lhs_and_operator}" do
        let(:indented_strings) do
          [%(#{lhs_and_operator} "a" \\), "  'b'", ''].join("\n")
        end

        it 'accepts indented strings' do
          expect_no_offenses(indented_strings)
        end

        it 'registers an offense for aligned strings' do
          margin = "#{' ' * lhs_and_operator.length}  " # Including spaces around operator.
          expect_offense(
            [%(#{lhs_and_operator} "a" \\),
             "#{margin}'b'",
             "#{margin}^^^ Indent the first part of a string concatenated with backslash.",
             ''].join("\n")
          )

          expect_correction(indented_strings)
        end
      end
    end

    it 'registers an offense for aligned strings in hash literal values' do
      expect_offense(<<~'RUBY')
        MESSAGES = { KeyAlignment => 'Align the keys of a hash literal if ' \
                                     'they span more than one line.',
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Indent the first part of a string concatenated with backslash.
                     SeparatorAlignment => 'Align the separators of a hash ' \
                                           'literal if they span more than one line.',
                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Indent the first part of a string concatenated with backslash.
                     TableAlignment => 'Align the keys and values of a hash ' \
                                       'literal if they span more than one line.' }.freeze
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Indent the first part of a string concatenated with backslash.
      RUBY

      expect_correction(<<~'RUBY')
        MESSAGES = { KeyAlignment => 'Align the keys of a hash literal if ' \
                       'they span more than one line.',
                     SeparatorAlignment => 'Align the separators of a hash ' \
                       'literal if they span more than one line.',
                     TableAlignment => 'Align the keys and values of a hash ' \
                       'literal if they span more than one line.' }.freeze
      RUBY
    end

    it 'registers an offense for aligned string' do
      expect_offense(<<~'RUBY')
        puts %Q(a) \
             'b' \
             ^^^ Indent the first part of a string concatenated with backslash.
             'c'
      RUBY

      expect_correction(<<~'RUBY')
        puts %Q(a) \
          'b' \
          'c'
      RUBY
    end

    it 'registers an offense for unaligned third part of string' do
      expect_offense(<<~'RUBY')
        puts 'a' \
          "#{b}" \
             "#{c}"
             ^^^^^^ Align parts of a string concatenated with backslash.
      RUBY

      expect_correction(<<~'RUBY')
        puts 'a' \
          "#{b}" \
          "#{c}"
      RUBY
    end

    context 'when IndentationWidth is 1' do
      let(:cop_indent) { 1 }

      it 'accepts indented strings' do
        expect_no_offenses(<<~'RUBY')
          puts 'a' \
           'b'
        RUBY
      end
    end
  end
end
