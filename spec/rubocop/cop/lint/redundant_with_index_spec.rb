# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantWithIndex do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for `ary.each_with_index { |v| v }` ' \
    'and corrects to `ary.each`' do
    expect_offense(<<~RUBY)
      ary.each_with_index { |v| v }
          ^^^^^^^^^^^^^^^ Use `each` instead of `each_with_index`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each { |v| v }
    RUBY
  end

  it 'registers an offense when using `ary.each.with_index { |v| v }` ' \
    'and corrects to `ary.each`' do
    expect_offense(<<~RUBY)
      ary.each.with_index { |v| v }
               ^^^^^^^^^^ Remove redundant `with_index`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each { |v| v }
    RUBY
  end

  it 'registers an offense when using `ary.each.with_index(1) { |v| v }` ' \
    'and correct to `ary.each { |v| v }`' do
    expect_offense(<<~RUBY)
      ary.each.with_index(1) { |v| v }
               ^^^^^^^^^^^^^ Remove redundant `with_index`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each { |v| v }
    RUBY
  end

  it 'registers an offense when using ' \
    '`ary.each_with_object([]).with_index { |v| v }` ' \
    'and corrects to `ary.each_with_object([]) { |v| v }`' do
    expect_offense(<<~RUBY)
      ary.each_with_object([]).with_index { |v| v }
                               ^^^^^^^^^^ Remove redundant `with_index`.
    RUBY

    expect_correction(<<~RUBY)
      ary.each_with_object([]) { |v| v }
    RUBY
  end

  it 'accepts an index is used as a block argument' do
    expect_no_offenses('ary.each_with_index { |v, i| v; i }')
  end
end
