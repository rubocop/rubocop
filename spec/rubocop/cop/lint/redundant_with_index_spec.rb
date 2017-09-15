# frozen_string_literal: true

describe RuboCop::Cop::Lint::RedundantWithIndex do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `ary.each_with_index { |v| v }`' do
    expect_offense(<<-RUBY.strip_indent)
      ary.each_with_index { |v| v }
          ^^^^^^^^^^^^^^^ Use `each` instead of `each_with_index`.
    RUBY
  end

  it 'registers an offense when using `ary.each.with_index { |v| v }`' do
    expect_offense(<<-RUBY.strip_indent)
      ary.each.with_index { |v| v }
               ^^^^^^^^^^ Remove redundant `with_index`.
    RUBY
  end

  it 'registers an offense when using `ary.each_with_object([]).with_index ' \
     '{ |v| v }`' do
    expect_offense(<<-RUBY.strip_indent)
      ary.each_with_object([]).with_index { |v| v }
                               ^^^^^^^^^^ Remove redundant `with_index`.
    RUBY
  end

  it 'autocorrects to ary.each from ary.each_with_index' do
    new_source = autocorrect_source('ary.each_with_index { |v| v }')

    expect(new_source).to eq 'ary.each { |v| v }'
  end

  it 'autocorrects to ary.each from ary.each.with_index' do
    new_source = autocorrect_source('ary.each.with_index { |v| v }')

    expect(new_source).to eq 'ary.each { |v| v }'
  end

  it 'autocorrects to ary.each from ary.each_with_object([]).with_index' do
    new_source = autocorrect_source('ary.each_with_object([]) { |v| v }')

    expect(new_source).to eq 'ary.each_with_object([]) { |v| v }'
  end

  it 'an index is used as a block argument' do
    expect_no_offenses('ary.each_with_index { |v, i| v; i }')
  end
end
