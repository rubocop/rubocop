# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::OffenseLocationKeyword do
  subject(:cop) { described_class.new }

  it 'registers an offense when `node.loc.expression` is passed' do
    expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, node.loc.selector)
                        ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
    RUBY
  end

  it 'does not register an offense when the `loc` is on a child node' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, node.arguments.loc.selector)
    RUBY
  end

  it 'does not register an offense when the `loc` is on a different node' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, oher_node.loc.selector)
    RUBY
  end
end
