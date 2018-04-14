# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideParens, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for spaces inside parens' do
      expect_offense(<<-RUBY.strip_indent)
        f( 3)
          ^ Space inside parentheses detected.
        g = (a + 3 )
                  ^ Space inside parentheses detected.
      RUBY
    end

    it 'accepts parentheses in block parameter list' do
      expect_no_offenses(<<-RUBY.strip_indent)
        list.inject(Tms.new) { |sum, (label, item)|
        }
      RUBY
    end

    it 'accepts parentheses with no spaces' do
      expect_no_offenses('split("\\n")')
    end

    it 'accepts parentheses with line break' do
      expect_no_offenses(<<-RUBY.strip_indent)
        f(
          1)
      RUBY
    end

    it 'accepts parentheses with comment and line break' do
      expect_no_offenses(<<-RUBY.strip_indent)
        f( # Comment
          1)
      RUBY
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        f( 3)
        g = ( a + 3 )
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        f(3)
        g = (a + 3)
      RUBY
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense for no spaces inside parens' do
      expect_offense(<<-RUBY.strip_indent)
        f( 3)
            ^ No space inside parentheses detected.
        g = (a + 3 )
             ^ No space inside parentheses detected.
        split("\\n")
              ^ No space inside parentheses detected.
                  ^ No space inside parentheses detected.
      RUBY
    end

    it 'accepts parentheses in block parameter list with no spaces' do
      expect_offense(<<-RUBY.strip_indent)
        list.inject( Tms.new ) { |sum, (label, item)|
                                        ^ No space inside parentheses detected.
                                                   ^ No space inside parentheses detected.
        }
      RUBY
    end

    it 'accepts parentheses with spaces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        f( 3 )
        g = ( a + 3 )
        split( "\\n" )
      RUBY
    end

    it 'accepts parentheses with line break' do
      expect_no_offenses(<<-RUBY.strip_indent)
        f(
          1 )
      RUBY
    end

    it 'accepts parentheses with comment and line break' do
      expect_no_offenses(<<-RUBY.strip_indent)
        f( # Comment
          1 )
      RUBY
    end

    it 'auto-corrects wanted space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        f(3)
        f( 3)
        f(3 )
        g = (a + 3)
        g = ( a + 3)
        g = (a + 3 )
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        f( 3 )
        f( 3 )
        f( 3 )
        g = ( a + 3 )
        g = ( a + 3 )
        g = ( a + 3 )
      RUBY
    end
  end
end
