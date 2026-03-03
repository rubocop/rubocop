# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringLiteralsInInterpolation, :config do
  let(:other_cops) { { 'Lint/NestedDoubleQuotesInInterpolation' => { 'Enabled' => false } } }

  context 'when configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers an offense for double quotes within embedded expression in a string' do
      expect_offense(<<~'RUBY')
        "#{"A"}"
           ^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'A'}"
      RUBY
    end

    it 'registers an offense for double quotes within embedded expression in a symbol' do
      expect_offense(<<~'RUBY')
        :"#{"A"}"
            ^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        :"#{'A'}"
      RUBY
    end

    it 'registers an offense for double quotes within embedded expression in a heredoc string' do
      expect_offense(<<~'SOURCE')
        <<RUBY
        #{"A"}
          ^^^ Prefer single-quoted strings inside interpolations.
        RUBY
      SOURCE

      expect_correction(<<~'SOURCE')
        <<RUBY
        #{'A'}
        RUBY
      SOURCE
    end

    it 'registers an offense for double quotes within a regexp' do
      expect_offense(<<~'RUBY')
        /foo#{"sar".sub("s", 'b')}/
              ^^^^^ Prefer single-quoted strings inside interpolations.
                        ^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        /foo#{'sar'.sub('s', 'b')}/
      RUBY
    end

    it 'accepts double quotes on a static string' do
      expect_no_offenses('"A"')
    end

    it 'accepts double quotes on a broken static string' do
      expect_no_offenses(<<~'RUBY')
        "A" \
          "B"
      RUBY
    end

    it 'accepts double quotes on static strings within a method' do
      expect_no_offenses(<<~RUBY)
        def m
          puts "A"
          puts "B"
        end
      RUBY
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<~RUBY)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it 'can handle character literals' do
      expect_no_offenses('a = ?/')
    end

    it 'does not register an offense for double quotes in a backtick string' do
      expect_no_offenses(<<~'RUBY')
        `foo #{"bar"}`
      RUBY
    end

    it 'does not register an offense when the inner string contains a single quote' do
      expect_no_offenses(<<~'RUBY')
        "#{ "It's a trap!" }"
      RUBY
    end

    it 'does not register an offense for strings with control characters' do
      expect_no_offenses(<<~'RUBY')
        "#{ "\t" }"
      RUBY
    end

    it 'registers an offense and corrects double quotes with escaped quotes inside' do
      expect_offense(<<~'RUBY')
        "#{ "\"Valid\"" }"
            ^^^^^^^^^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{ '"Valid"' }"
      RUBY
    end

    it 'registers an offense and corrects an empty double-quoted string' do
      expect_offense(<<~'RUBY')
        "#{""}"
           ^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{''}"
      RUBY
    end

    it 'registers an offense for deeply nested interpolated strings' do
      expect_offense(<<~'RUBY')
        "A #{"B #{"C"}"}"
                  ^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "A #{"B #{'C'}"}"
      RUBY
    end

    it 'registers an offense for double quotes inside a %W array' do
      expect_offense(<<~'RUBY')
        %W(status_#{"UP"} method_#{"GET"})
                    ^^^^ Prefer single-quoted strings inside interpolations.
                                   ^^^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        %W(status_#{'UP'} method_#{'GET'})
      RUBY
    end
  end

  context 'when configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers an offense for single quotes within embedded expression in a string' do
      expect_offense(<<~'RUBY')
        "#{'A'}"
           ^^^ Prefer double-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"A"}"
      RUBY
    end

    it 'registers an offense for single quotes within embedded expression in a symbol' do
      expect_offense(<<~'RUBY')
        :"#{'A'}"
            ^^^ Prefer double-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        :"#{"A"}"
      RUBY
    end

    it 'registers an offense for single quotes within embedded expression in a heredoc string' do
      expect_offense(<<~'SOURCE')
        <<RUBY
        #{'A'}
          ^^^ Prefer double-quoted strings inside interpolations.
        RUBY
      SOURCE

      expect_correction(<<~'SOURCE')
        <<RUBY
        #{"A"}
        RUBY
      SOURCE
    end

    it 'does not register an offense for single quotes in a backtick string' do
      expect_no_offenses(<<~'RUBY')
        `foo #{'bar'}`
      RUBY
    end
  end

  context 'when Lint/NestedDoubleQuotesInInterpolation is enabled' do
    let(:other_cops) { { 'Lint/NestedDoubleQuotesInInterpolation' => { 'Enabled' => true } } }

    context 'with single quotes preferred' do
      let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

      it 'does not register an offense for double quotes in a double-quoted string' do
        expect_no_offenses(<<~'RUBY')
          "#{"A"}"
        RUBY
      end

      it 'does not register an offense for double quotes in an interpolated symbol' do
        expect_no_offenses(<<~'RUBY')
          :"#{"A"}"
        RUBY
      end

      it 'registers an offense for double quotes in a heredoc' do
        expect_offense(<<~'SOURCE')
          <<RUBY
          #{"A"}
            ^^^ Prefer single-quoted strings inside interpolations.
          RUBY
        SOURCE
      end

      it 'registers an offense for double quotes in a heredoc in a multi-statement context' do
        expect_offense(<<~'SOURCE')
          x = 1
          <<RUBY
          #{"A"}
            ^^^ Prefer single-quoted strings inside interpolations.
          RUBY
        SOURCE
      end

      it 'registers an offense for double quotes in a percent literal' do
        expect_offense(<<~'RUBY')
          %Q(#{"A"})
               ^^^ Prefer single-quoted strings inside interpolations.
        RUBY

        expect_correction(<<~'RUBY')
          %Q(#{'A'})
        RUBY
      end

      it 'registers an offense for double quotes in a regexp' do
        expect_offense(<<~'RUBY')
          /foo#{"bar"}/
                ^^^^^ Prefer single-quoted strings inside interpolations.
        RUBY

        expect_correction(<<~'RUBY')
          /foo#{'bar'}/
        RUBY
      end
    end

    context 'with double quotes preferred' do
      let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

      it 'does not register an offense for single quotes in a double-quoted string' do
        expect_no_offenses(<<~'RUBY')
          "#{'A'}"
        RUBY
      end

      it 'does not register an offense for single quotes in an interpolated symbol' do
        expect_no_offenses(<<~'RUBY')
          :"#{'A'}"
        RUBY
      end

      it 'registers an offense for single quotes in a heredoc' do
        expect_offense(<<~'SOURCE')
          <<RUBY
          #{'A'}
            ^^^ Prefer double-quoted strings inside interpolations.
          RUBY
        SOURCE
      end

      it 'registers an offense for single quotes in a heredoc in a multi-statement context' do
        expect_offense(<<~'SOURCE')
          x = 1
          <<RUBY
          #{'A'}
            ^^^ Prefer double-quoted strings inside interpolations.
          RUBY
        SOURCE
      end

      it 'registers an offense for single quotes in a percent literal' do
        expect_offense(<<~'RUBY')
          %Q(#{'A'})
               ^^^ Prefer double-quoted strings inside interpolations.
        RUBY

        expect_correction(<<~'RUBY')
          %Q(#{"A"})
        RUBY
      end

      it 'registers an offense for single quotes in a regexp' do
        expect_offense(<<~'RUBY')
          /foo#{'bar'}/
                ^^^^^ Prefer double-quoted strings inside interpolations.
        RUBY

        expect_correction(<<~'RUBY')
          /foo#{"bar"}/
        RUBY
      end
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { expect_no_offenses('a = "#{"b"}"') }.to raise_error(RuntimeError)
    end
  end
end
