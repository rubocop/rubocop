# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::RedundantMessageArgument do
  subject(:cop) { described_class.new }

  it 'registers an offense when `MSG` is passed' do
    expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, MSG)
                                     ^^^ Redundant message argument to `#add_offense`.
    RUBY
  end

  it 'does not register an offense when formatted `MSG` is passed' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, MSG % foo)
    RUBY
  end

  it 'registers an offense when `#message` is passed' do
    expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message)
                                     ^^^^^^^ Redundant message argument to `#add_offense`.
    RUBY
  end

  it 'registers an offense when `#message` with offending node is passed' do
    expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message(node))
                                     ^^^^^^^^^^^^^ Redundant message argument to `#add_offense`.
    RUBY
  end

  it 'does not register an offense when `#message` with another node ' \
     ' is passed' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message(other_node))
    RUBY
  end
end
