# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::Tab do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w[spaces tabs]
    }
    RuboCop::Config.new(
      'Layout/IndentationWidth' => { 'Width' => 2 },
      'Layout/Tab' => cop_config.merge(supported_styles)
    )
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'spaces' } }

    it 'registers an offense for a line indented with tab' do
      expect_offense(<<~RUBY)
        	x = 0
        ^ Tab detected.
      RUBY
    end

    it 'registers an offense for a line indented with multiple tabs' do
      expect_offense(<<~RUBY)
        			x = 0
        ^^^ Tab detected.
      RUBY
    end

    it 'registers an offense for a line indented with mixed whitespace' do
      expect_offense(<<-'RUBY')
         	x = 0
         ^ Tab detected.
      RUBY
    end

    it 'registers offenses before __END__ but not after' do
      expect_offense(<<~RUBY)
        \tx = 0
        ^ Tab detected.
        __END__
        \tx = 0
      RUBY
    end

    it 'registers an offense for a tab other than indentation' do
      expect_offense(<<~RUBY)
        foo \t bar
            ^ Tab detected.
      RUBY
    end

    it 'registers an offense for tabs between string literals' do
      expect_offense(<<~RUBY)
        'foo'\t'bar'
             ^ Tab detected.
      RUBY
    end

    it 'accepts a line with tab in a string' do
      expect_no_offenses("(x = \"\t\")")
    end

    it 'accepts a line which begins with tab in a string' do
      expect_no_offenses("x = '\n\thello'")
    end

    it 'accepts a line which begins with tab in a heredoc' do
      expect_no_offenses("x = <<HELLO\n\thello\nHELLO")
    end

    it 'accepts a line which begins with tab in a multiline heredoc' do
      expect_no_offenses("x = <<HELLO\n\thello\n\t\n\t\t\nhello\nHELLO")
    end

    it 'auto-corrects a line indented with tab' do
      new_source = autocorrect_source("\tx = 0")
      expect(new_source).to eq('  x = 0')
    end

    it 'auto-corrects a line indented with multiple tabs' do
      new_source = autocorrect_source("\t\t\tx = 0")
      expect(new_source).to eq('      x = 0')
    end

    it 'auto-corrects a line indented with mixed whitespace' do
      new_source = autocorrect_source(" \tx = 0")
      expect(new_source).to eq('   x = 0')
    end

    it 'auto-corrects a line with tab in a string indented with tab' do
      new_source = autocorrect_source("\t(x = \"\t\")")
      expect(new_source).to eq("  (x = \"\t\")")
    end

    it 'auto-corrects a line with tab other than indentation' do
      new_source = autocorrect_source("foo \t bar")
      expect(new_source).to eq('foo    bar')
    end

    context 'custom indentation width' do
      let(:cop_config) do
        { 'IndentationWidth' => 3, 'EnforcedStyle' => 'spaces' }
      end

      it 'uses the configured number of spaces to replace a tab' do
        new_source = autocorrect_source("\tx = 0")

        expect(new_source).to eq('   x = 0')
      end
    end
  end

  context 'when EnforcedStyle is tab' do
    let(:cop_config) { { 'EnforcedStyle' => 'tabs' } }

    it 'registers an offense for a line indented with space' do
      expect_offense(<<~RUBY)
          x = 0
        ^^ Space detected in indentation.
      RUBY
    end

    it 'registers an offense for a line indented with multiple spaces' do
      expect_offense(<<~RUBY)
              x = 0
        ^^^^^^ Space detected in indentation.
      RUBY
    end

    it 'registers an offense for a line indented with mixed whitespace' do
      expect_offense(<<~'RUBY')
         	x = 0
        ^ Space detected in indentation.
      RUBY
    end

    it 'registers offenses before __END__ but not after' do
      expect_offense(<<~RUBY)
          x = 0
        ^^ Space detected in indentation.
        __END__
          x = 0
      RUBY
    end

    it 'registers an offense for a tab other than indentation' do
      expect_offense(<<~RUBY)
        \tfoo \t bar
           ^^^ Tab detected outside of indentation.
      RUBY
    end

    it 'registers an offense for tabs between string literals' do
      expect_offense(<<~RUBY)
        'foo'\t'bar'
            ^^ Tab detected outside of indentation.
      RUBY
    end

    it 'accepts a line with tab in a string' do
      expect_no_offenses("(x = \"\t\")")
    end

    it 'accepts a line which begins with tab in a string' do
      expect_no_offenses("x = '\n\thello'")
    end

    it 'accepts a line which begins with tab in a heredoc' do
      expect_no_offenses("x = <<HELLO\n\thello\nHELLO")
    end

    it 'accepts a line which begins with tab in a multiline heredoc' do
      expect_no_offenses("x = <<HELLO\n\thello\n\t\n\t\t\nhello\nHELLO")
    end

    it 'auto-corrects a line indented with space' do
      new_source = autocorrect_source('  x = 0')
      expect(new_source).to eq("\tx = 0")
    end

    it 'auto-corrects a line indented with multiple spaces' do
      new_source = autocorrect_source('      x = 0')
      expect(new_source).to eq("\t\t\tx = 0")
    end

    it 'auto-corrects a line indented with fractional number of'\
      'indentation groups by rounding down' do
      new_source = autocorrect_source('   x = 0')
      expect(new_source).to eq("\tx = 0")
    end

    it 'auto-corrects a line indented with mixed whitespace' do
      new_source = autocorrect_source(" \tx = 0")
      expect(new_source).to eq("\tx = 0")
    end

    it 'auto-corrects a line with tab in a string indented with space' do
      new_source = autocorrect_source("  (x = \"\t\")")
      expect(new_source).to eq("\t(x = \"\t\")")
    end

    it 'auto-corrects a line with tab other than indentation' do
      new_source = autocorrect_source("\tfoo \t bar")
      expect(new_source).to eq("\tfoo    bar")
    end

    context 'custom indentation width' do
      let(:cop_config) do
        { 'IndentationWidth' => 3, 'EnforcedStyle' => 'tabs' }
      end

      it 'uses the configured number of spaces to replace with a tab' do
        new_source = autocorrect_source('      x = 0')

        expect(new_source).to eq("\t\tx = 0")
      end
    end
  end
end
