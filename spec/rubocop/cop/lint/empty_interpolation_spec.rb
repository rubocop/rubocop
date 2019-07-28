# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for #{} in interpolation' do
    expect_offense(<<-'RUBY'.strip_indent)
      "this is the #{}"
                   ^^^ Empty interpolation detected.
    RUBY
  end

  it 'registers an offense for #{ } in interpolation' do
    expect_offense(<<-'RUBY'.strip_indent)
      "this is the #{ }"
                   ^^^^ Empty interpolation detected.
    RUBY
  end

  it 'finds interpolations in string-like contexts' do
    expect_offense(<<-'RUBY'.strip_indent)
      /regexp #{}/
              ^^^ Empty interpolation detected.
      `backticks #{}`
                 ^^^ Empty interpolation detected.
      :"symbol #{}"
               ^^^ Empty interpolation detected.
    RUBY
  end

  it 'accepts non-empty interpolation' do
    expect_no_offenses('"this is #{top} silly"')
  end

  it 'autocorrects empty interpolation' do
    new_source = autocorrect_source('"this is the #{}"')
    expect(new_source).to eq('"this is the "')
  end

  it 'autocorrects empty interpolation containing a space' do
    new_source = autocorrect_source('"this is the #{ }"')
    expect(new_source).to eq('"this is the "')
  end
end
