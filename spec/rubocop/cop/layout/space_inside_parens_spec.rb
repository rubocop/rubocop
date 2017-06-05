# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideParens do
  subject(:cop) { described_class.new }

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
    new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
      f( 3)
      g = ( a + 3 )
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      f(3)
      g = (a + 3)
    RUBY
  end
end
