# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantMethodDispatchNode, :config do
  it 'registers an offense when using `node.send_node.method_name`' do
    expect_offense(<<~RUBY)
      node.send_node.method_name
          ^^^^^^^^^^ Remove the redundant `send_node`.
    RUBY

    expect_correction(<<~RUBY)
      node.method_name
    RUBY
  end

  it 'does not register an offense when using `node.method_name`' do
    expect_no_offenses(<<~RUBY)
      node.method_name
    RUBY
  end

  it 'registers an offense when using `node.send_node.receiver`' do
    expect_offense(<<~RUBY)
      node.send_node.receiver
          ^^^^^^^^^^ Remove the redundant `send_node`.
    RUBY

    expect_correction(<<~RUBY)
      node.receiver
    RUBY
  end

  it 'does not register an offense when using `node.receiver`' do
    expect_no_offenses(<<~RUBY)
      node.receiver
    RUBY
  end

  it 'does not register an offense when using `node.send_node.arguments?`' do
    expect_no_offenses(<<~RUBY)
      node.send_node.arguments?
    RUBY
  end

  it 'does not register an offense when using `send_node.method_name`' do
    expect_no_offenses(<<~RUBY)
      send_node.method_name
    RUBY
  end
end
