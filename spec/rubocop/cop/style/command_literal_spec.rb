# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommandLiteral, :config do
  let(:config) do
    supported_styles = { 'SupportedStyles' => %w[backticks percent_x mixed] }
    RuboCop::Config.new('Style/PercentLiteralDelimiters' =>
                          percent_literal_delimiters_config,
                        'Style/CommandLiteral' =>
                          cop_config.merge(supported_styles))
  end
  let(:percent_literal_delimiters_config) { { 'PreferredDelimiters' => { '%x' => '()' } } }

  describe '%x commands with other delimiters than parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        %x$ls$
        ^^^^^^ Use backticks around command string.
      RUBY
    end
  end

  describe 'when PercentLiteralDelimiters is configured with curly braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }
    let(:percent_literal_delimiters_config) { { 'PreferredDelimiters' => { '%x' => '[]' } } }

    it 'respects the configuration when autocorrecting' do
      expect_offense(<<~RUBY)
        `ls`
        ^^^^ Use `%x` around command string.
      RUBY

      expect_correction(<<~RUBY)
        %x[ls]
      RUBY
    end
  end

  describe 'when PercentLiteralDelimiters only has a default' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }
    let(:percent_literal_delimiters_config) do
      { 'PreferredDelimiters' => { 'default' => '()' } }
    end

    it 'respects the configuration when autocorrecting' do
      expect_offense(<<~RUBY)
        `ls`
        ^^^^ Use `%x` around command string.
      RUBY

      expect_correction(<<~RUBY)
        %x(ls)
      RUBY
    end
  end

  describe 'when PercentLiteralDelimiters is configured and a default exists' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }
    let(:percent_literal_delimiters_config) do
      { 'PreferredDelimiters' => { '%x' => '[]', 'default' => '()' } }
    end

    it 'ignores the default when autocorrecting' do
      expect_offense(<<~RUBY)
        `ls`
        ^^^^ Use `%x` around command string.
      RUBY

      expect_correction(<<~RUBY)
        %x[ls]
      RUBY
    end
  end

  describe 'heredoc commands' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    it 'is ignored' do
      expect_no_offenses(<<~RUBY)
        <<`COMMAND`
          ls
        COMMAND
      RUBY
    end
  end

  context 'when EnforcedStyle is set to backticks' do
    let(:cop_config) { { 'EnforcedStyle' => 'backticks' } }

    describe 'a single-line ` string without backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = `ls`')
      end
    end

    describe 'a single-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
        RUBY

        expect_no_corrections
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          expect_no_offenses('foo = `echo \\`ls\\``')
        end
      end
    end

    describe 'a multi-line ` string without backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = `
            ls
            ls -l
          `
        RUBY
      end
    end

    describe 'a multi-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
        RUBY

        expect_no_corrections
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          expect_no_offenses(<<~'RUBY')
            foo = `
              echo \`ls\`
              echo \`ls -l\`
            `
          RUBY
        end
      end
    end

    describe 'a single-line %x string without backticks' do
      it 'registers an offense and corrects to backticks' do
        expect_offense(<<~RUBY)
          foo = %x(ls)
                ^^^^^^ Use backticks around command string.
        RUBY

        expect_correction(<<~RUBY)
          foo = `ls`
        RUBY
      end
    end

    describe 'a single-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = %x(echo `ls`)')
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense without autocorrection' do
          expect_offense(<<~RUBY)
            foo = %x(echo `ls`)
                  ^^^^^^^^^^^^^ Use backticks around command string.
          RUBY

          expect_no_corrections
        end
      end
    end

    describe 'a multi-line %x string without backticks' do
      it 'registers an offense and corrects to backticks' do
        expect_offense(<<~RUBY)
          foo = %x(
                ^^^ Use backticks around command string.
            ls
            ls -l
          )
        RUBY

        expect_correction(<<~RUBY)
          foo = `
            ls
            ls -l
          `
        RUBY
      end
    end

    describe 'a multi-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = %x(
            echo `ls`
            echo `ls -l`
          )
        RUBY
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense without autocorrection' do
          expect_offense(<<~RUBY)
            foo = %x(
                  ^^^ Use backticks around command string.
              echo `ls`
              echo `ls -l`
            )
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  context 'when EnforcedStyle is set to percent_x' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_x' } }

    describe 'a single-line ` string without backticks' do
      it 'registers an offense and corrects to %x' do
        expect_offense(<<~RUBY)
          foo = `ls`
                ^^^^ Use `%x` around command string.
        RUBY

        expect_correction(<<~RUBY)
          foo = %x(ls)
        RUBY
      end
    end

    describe 'a single-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
        RUBY

        expect_no_corrections
      end
    end

    describe 'a multi-line ` string without backticks' do
      it 'registers an offense and corrects to %x' do
        expect_offense(<<~RUBY)
          foo = `
                ^ Use `%x` around command string.
            ls
            ls -l
          `
        RUBY

        expect_correction(<<~RUBY)
          foo = %x(
            ls
            ls -l
          )
        RUBY
      end
    end

    describe 'a multi-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
        RUBY

        expect_no_corrections
      end
    end

    describe 'a single-line %x string without backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = %x(ls)')
      end
    end

    describe 'a single-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = %x(echo `ls`)')
      end
    end

    describe 'a multi-line %x string without backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = %x(
            ls
            ls -l
          )
        RUBY
      end
    end

    describe 'a multi-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = %x(
            echo `ls`
            echo `ls -l`
          )
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is set to mixed' do
    let(:cop_config) { { 'EnforcedStyle' => 'mixed' } }

    describe 'a single-line ` string without backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = `ls`')
      end
    end

    describe 'a single-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `echo \`ls\``
                ^^^^^^^^^^^^^ Use `%x` around command string.
        RUBY

        expect_no_corrections
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'is accepted' do
          expect_no_offenses('foo = `echo \\`ls\\``')
        end
      end
    end

    describe 'a multi-line ` string without backticks' do
      it 'registers an offense and corrects to %x' do
        expect_offense(<<~RUBY)
          foo = `
                ^ Use `%x` around command string.
            ls
            ls -l
          `
        RUBY

        expect_correction(<<~RUBY)
          foo = %x(
            ls
            ls -l
          )
        RUBY
      end
    end

    describe 'a multi-line ` string with backticks' do
      it 'registers an offense without autocorrection' do
        expect_offense(<<~'RUBY')
          foo = `
                ^ Use `%x` around command string.
            echo \`ls\`
            echo \`ls -l\`
          `
        RUBY

        expect_no_corrections
      end
    end

    describe 'a single-line %x string without backticks' do
      it 'registers an offense and corrects to backticks' do
        expect_offense(<<~RUBY)
          foo = %x(ls)
                ^^^^^^ Use backticks around command string.
        RUBY

        expect_correction(<<~RUBY)
          foo = `ls`
        RUBY
      end
    end

    describe 'a single-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses('foo = %x(echo `ls`)')
      end

      describe 'when configured to allow inner backticks' do
        before { cop_config['AllowInnerBackticks'] = true }

        it 'registers an offense without autocorrection' do
          expect_offense(<<~RUBY)
            foo = %x(echo `ls`)
                  ^^^^^^^^^^^^^ Use backticks around command string.
          RUBY

          expect_no_corrections
        end
      end
    end

    describe 'a multi-line %x string without backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = %x(
            ls
            ls -l
          )
        RUBY
      end
    end

    describe 'a multi-line %x string with backticks' do
      it 'is accepted' do
        expect_no_offenses(<<~RUBY)
          foo = %x(
            echo `ls`
            echo `ls -l`
          )
        RUBY
      end
    end
  end
end
