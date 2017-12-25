# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::RedundantSortBy do
  subject(:cop) { described_class.new }

  it 'autocorrects array.sort_by { |x| x }' do
    new_source = autocorrect_source('array.sort_by { |x| x }')
    expect(new_source).to eq 'array.sort'
  end

  it 'autocorrects array.sort_by { |y| y }' do
    new_source = autocorrect_source('array.sort_by { |y| y }')
    expect(new_source).to eq 'array.sort'
  end

  it 'autocorrects array.sort_by do |x| x end' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      array.sort_by do |x|
        x
      end
    RUBY
    expect(new_source).to eq "array.sort\n"
  end

  it 'formats the error message correctly for array.sort_by { |x| x }' do
    expect_offense(<<-RUBY.strip_indent)
      array.sort_by { |x| x }
            ^^^^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { |x| x }`.
    RUBY
  end
end
