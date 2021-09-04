# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SingleLineBlockChain, :config do
  it 'registers an offense for method call chained on the same line as a block' do
    expect_offense(<<~RUBY)
      example.select { |item| item.cond? }.join('-')
                                          ^^^^^ Put method call on a separate line if chained to a single line block.
    RUBY

    expect_correction(<<~RUBY)
      example.select { |item| item.cond? }
      .join('-')
    RUBY
  end

  it 'registers an offense for no selector method call chained on the same line as a block' do
    expect_offense(<<~RUBY)
      example.select { |item| item.cond? }.(42)
                                          ^^ Put method call on a separate line if chained to a single line block.
    RUBY

    expect_correction(<<~RUBY)
      example.select { |item| item.cond? }
      .(42)
    RUBY
  end

  it 'does not register an offense for method call chained on a new line after a single line block' do
    expect_no_offenses(<<~RUBY)
      example.select { |item| item.cond? }
             .join('-')
    RUBY
  end

  it 'does not register an offense for method call chained on a new line after a single line block with trailing dot' do
    expect_no_offenses(<<~RUBY)
      example.select { |item| item.cond? }.
              join('-')
    RUBY
  end

  it 'does not register an offense for method call chained without a dot' do
    expect_no_offenses(<<~RUBY)
      example.select { |item| item.cond? } + 2
    RUBY
  end

  it 'does not register an offense for method call chained on the same line as a multiline block' do
    expect_no_offenses(<<~RUBY)
      example.select do |item|
        item.cond?
      end.join('-')
    RUBY
  end
end
