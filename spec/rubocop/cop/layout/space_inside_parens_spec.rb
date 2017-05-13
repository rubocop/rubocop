# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideParens do
  subject(:cop) { described_class.new }

  it 'registers an offense for spaces inside parens' do
    expect_offense(<<-END.strip_indent)
      f( 3)
        ^ Space inside parentheses detected.
      g = (a + 3 )
                ^ Space inside parentheses detected.
    END
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
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      f( 3)
      g = ( a + 3 )
    END
    expect(new_source).to eq(<<-END.strip_indent)
      f(3)
      g = (a + 3)
    END
  end
end
