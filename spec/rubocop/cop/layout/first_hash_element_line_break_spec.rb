# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstHashElementLineBreak do
  subject(:cop) { described_class.new }

  context 'elements listed on the first line' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        a = { a: 1,
              ^^^^ Add a line break before the first element of a multi-line hash.
              b: 2 }
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        a = { a: 1,
              b: 2 }
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        a = { 
        a: 1,
              b: 2 }
      RUBY
    end
  end

  context 'hash nested in a method call' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        method({ foo: 1,
                 ^^^^^^ Add a line break before the first element of a multi-line hash.
                 bar: 2 })
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        method({ foo: 1,
                 bar: 2 })
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        method({ 
        foo: 1,
                 bar: 2 })
      RUBY
    end
  end

  it 'ignores implicit hashes in method calls with parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      method(
        foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores implicit hashes in method calls without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      method foo: 1,
       bar: 2
    RUBY
  end

  it 'ignores implicit hashes in method calls that are improperly formatted' do
    # These are covered by Style/FirstMethodArgumentLineBreak
    expect_no_offenses(<<-RUBY.strip_indent)
      method(foo: 1,
        bar: 2)
    RUBY
  end

  it 'ignores elements listed on a single line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      b = {
        a: 1,
        b: 2 }
    RUBY
  end
end
