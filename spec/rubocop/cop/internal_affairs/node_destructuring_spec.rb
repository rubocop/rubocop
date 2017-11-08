# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::NodeDestructuring do
  subject(:cop) { described_class.new }

  context 'when destructuring using `node.children`' do
    it 'registers an offense when receiver is named `node`' do
      expect_offense(<<-RUBY, 'example_cop.rb')
        lhs, rhs = node.children
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use the methods provided with the node extensions, or destructure the node using `*`.
      RUBY
    end

    it 'registers an offense when receiver is named `send_node`' do
      expect_offense(<<-RUBY, 'example_cop.rb')
        lhs, rhs = send_node.children
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the methods provided with the node extensions, or destructure the node using `*`.
      RUBY
    end
  end

  it 'does not register an offense for a predicate node type check' do
    expect_no_offenses(<<-RUBY, 'example_spec.rb')
      lhs, rhs = *node
    RUBY
  end

  it 'does not register an offense when receiver is named `array`' do
    expect_no_offenses(<<-RUBY, 'example_spec.rb')
      lhs, rhs = array.children
    RUBY
  end
end
