# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnneededInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for "#{1 + 1}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{1 + 1}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "%|#{1 + 1}|"' do
    expect_offense(<<-'RUBY'.strip_indent)
      %|#{1 + 1}|
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "%Q(#{1 + 1})"' do
    expect_offense(<<-'RUBY'.strip_indent)
      %Q(#{1 + 1})
      ^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{1 + 1; 2 + 2}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{1 + 1; 2 + 2}"
      ^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{@var}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{@var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#@var"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#@var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{@@var}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{@@var}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#@@var"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#@@var"
      ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{$var}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{$var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#$var"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#$var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{$1}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{$1}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#$1"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#$1"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{$+}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#{$+}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#$+"' do
    expect_offense(<<-'RUBY'.strip_indent)
      "#$+"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for "#{var}"' do
    expect_offense(<<-'RUBY'.strip_indent)
      var = 1; "#{var}"
               ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'registers an offense for ["#{@var}"]' do
    expect_offense(<<-'RUBY'.strip_indent)
      ["#{@var}", 'foo']
       ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY
  end

  it 'accepts strings with characters before the interpolation' do
    expect_no_offenses('"this is #{@sparta}"')
  end

  it 'accepts strings with characters after the interpolation' do
    expect_no_offenses('"#{@sparta} this is"')
  end

  it 'accepts strings implicitly concatenated with a later string' do
    expect_no_offenses(%q("#{sparta}" ' this is'))
  end

  it 'accepts strings implicitly concatenated with an earlier string' do
    expect_no_offenses(%q('this is ' "#{sparta}"))
  end

  it 'accepts strings that are part of a %W()' do
    expect_no_offenses('%W(#{@var} foo)')
  end

  it 'autocorrects "#{1 + 1; 2 + 2}"' do
    corrected = autocorrect_source(['"#{1 + 1; 2 + 2}"'])
    expect(corrected).to eq '(1 + 1; 2 + 2).to_s'
  end

  it 'autocorrects "#@var"' do
    corrected = autocorrect_source(['"#@var"'])
    expect(corrected).to eq '@var.to_s'
  end

  it 'autocorrects "#{var}"' do
    corrected = autocorrect_source(['var = 1; "#{var}"'])
    expect(corrected).to eq 'var = 1; var.to_s'
  end

  it 'autocorrects "#{@var}"' do
    corrected = autocorrect_source(['"#{@var}"'])
    expect(corrected).to eq '@var.to_s'
  end
end
