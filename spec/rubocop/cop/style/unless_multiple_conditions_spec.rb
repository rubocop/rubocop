# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnlessMultipleConditions do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `unless`' \
     'with multiple `and` conditions' do
    expect_offense(<<-RUBY.strip_indent)
      unless foo && bar
             ^^^^^^^^^^ Avoid using `unless` with multiple conditions.
        something
      end
    RUBY
  end

  it 'registers an offense when using `unless` with multiple `or` conditions' do
    expect_offense(<<-RUBY.strip_indent)
      unless foo || bar
             ^^^^^^^^^^ Avoid using `unless` with multiple conditions.
        something
      end
    RUBY
  end

  it 'does not register an offense when using `if`' \
     'with multiple `and` conditions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if !foo && !bar
        something
      end
    RUBY
  end

  it 'does not register an offense when using `if`' \
     'with multiple `or` conditions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if !foo || !bar
        something
      end
    RUBY
  end

  it 'does not register an offense when using `unless` with single condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      unless foo
        something
      end
    RUBY
  end
end
