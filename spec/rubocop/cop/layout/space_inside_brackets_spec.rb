# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideBrackets do
  subject(:cop) { described_class.new }

  it 'registers an offense for an array literal with spaces inside' do
    expect_offense(<<-RUBY.strip_indent)
      a = [1, 2 ]
               ^ Space inside square brackets detected.
      b = [ 1, 2]
           ^ Space inside square brackets detected.
    RUBY
  end

  it 'registers an offense for Hash#[] with symbol key and spaces inside' do
    expect_offense(<<-RUBY.strip_indent)
      a[ :key]
        ^ Space inside square brackets detected.
      b[:key ]
            ^ Space inside square brackets detected.
    RUBY
  end

  it 'registers an offense for Hash#[] with string key and spaces inside' do
    expect_offense(<<-RUBY.strip_indent)
      a[\'key\' ]
             ^ Space inside square brackets detected.
      b[ \'key\']
        ^ Space inside square brackets detected.
    RUBY
  end

  it 'accepts space inside strings within square brackets' do
    expect_no_offenses(<<-RUBY.strip_indent)
      ['Encoding:',
       '  Enabled: false']
    RUBY
  end

  it 'accepts space inside square brackets if on its own row' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a = [
           1, 2
          ]
    RUBY
  end

  it 'accepts space inside square brackets if with comment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a = [ # Comment
           1, 2
          ]
    RUBY
  end

  it 'accepts square brackets as method name' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def Vector.[](*array)
      end
    RUBY
  end

  it 'accepts square brackets called with method call syntax' do
    expect_no_offenses('subject.[](0)')
  end

  it 'only reports a single space once' do
    expect_offense(<<-RUBY.strip_indent)
      [ ]
       ^ Space inside square brackets detected.
    RUBY
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, <<-RUBY.strip_indent)
      a = [1, 2 ]
      b = [ 1, 2]
      c[ :key]
      d[:key ]
      e["key" ]
      f[ "key"]
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      a = [1, 2]
      b = [1, 2]
      c[:key]
      d[:key]
      e["key"]
      f["key"]
    RUBY
  end
end
