# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantConditionInFilterMap, :config do
  let(:cop) { cop_class.new(config) }

  it 'registers an offense and corrects when condition matches the value in a block with arguments' do
    expect_offense(<<~RUBY)
      items.filter_map { |foo| foo['bar'] if foo['bar'] }
                               ^^^^^^^^^^^^^^^^^^^^^^^^ Condition is redundant when equal to the value in `filter_map`.
    RUBY

    expect_correction(<<~RUBY)
      items.filter_map { |foo| foo['bar'] }
    RUBY
  end

  it 'registers an offense and corrects when condition matches the value in an it-block' do
    expect_offense(<<~RUBY)
      items.filter_map { it['foo'] if it['foo'] }
                         ^^^^^^^^^^^^^^^^^^^^^^ Condition is redundant when equal to the value in `filter_map`.
    RUBY

    expect_correction(<<~RUBY)
      items.filter_map { it['foo'] }
    RUBY
  end

  it 'registers an offense and corrects when condition matches the value in a block with numbered arguments' do
    expect_offense(<<~RUBY)
      items.filter_map { _1 if _1 }
                         ^^^^^^^^ Condition is redundant when equal to the value in `filter_map`.
    RUBY

    expect_correction(<<~RUBY)
      items.filter_map { _1 }
    RUBY
  end

  it 'does not register an offense when condition differs from the value' do
    expect_no_offenses(<<~RUBY)
      items.filter_map { it['foo'] if it['bar'] }
    RUBY
  end

  it 'does not register an offense when there is no if statement' do
    expect_no_offenses(<<~RUBY)
      items.filter_map { it['foo'] }
    RUBY
  end
end
