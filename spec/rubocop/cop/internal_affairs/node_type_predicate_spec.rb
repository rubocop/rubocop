# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::NodeTypePredicate do
  subject(:cop) { described_class.new }

  it 'registers an offense for a comparison node type check' do
    expect_offense(<<-RUBY, 'example_cop.rb')
      node.type == :send
      ^^^^^^^^^^^^^^^^^^ Use `#send_type?` to check node type.
    RUBY
  end

  it 'does not register an offense for a predicate node type check' do
    expect_no_offenses(<<-RUBY, 'example_spec.rb')
      node.send_type?
    RUBY
  end
end
