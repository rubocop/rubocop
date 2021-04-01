# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeDestructuring, :config do
  context 'when destructuring using `node.children`' do
    it 'registers an offense when receiver is named `node`' do
      expect_offense(<<~RUBY, 'example_cop.rb')
        lhs, rhs = node.children
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use the methods provided with the node extensions instead of manually destructuring nodes.
      RUBY
    end

    it 'registers an offense when receiver is named `send_node`' do
      expect_offense(<<~RUBY, 'example_cop.rb')
        lhs, rhs = send_node.children
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the methods provided with the node extensions instead of manually destructuring nodes.
      RUBY
    end
  end

  it 'registers an offense when destructuring using a splat' do
    expect_offense(<<~RUBY, 'example_spec.rb')
      lhs, rhs = *node
      ^^^^^^^^^^^^^^^^ Use the methods provided with the node extensions instead of manually destructuring nodes.
    RUBY
  end

  it 'does not register an offense when receiver is named `array`' do
    expect_no_offenses(<<~RUBY, 'example_spec.rb')
      lhs, rhs = array.children
    RUBY
  end
end
