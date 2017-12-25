# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NilComparison do
  subject(:cop) { described_class.new }

  it 'registers an offense for == nil' do
    expect_offense(<<-RUBY.strip_indent)
      x == nil
        ^^ Prefer the use of the `nil?` predicate.
    RUBY
  end

  it 'registers an offense for === nil' do
    expect_offense(<<-RUBY.strip_indent)
      x === nil
        ^^^ Prefer the use of the `nil?` predicate.
    RUBY
  end

  it 'autocorrects by replacing == nil with .nil?' do
    corrected = autocorrect_source('x == nil')
    expect(corrected).to eq 'x.nil?'
  end

  it 'autocorrects by replacing === nil with .nil?' do
    corrected = autocorrect_source('x === nil')
    expect(corrected).to eq 'x.nil?'
  end
end
