# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::OffenseLocationKeyword, :config do
  context 'when `node.loc.selector` is passed' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        add_offense(node, location: node.loc.selector)
                                    ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
      RUBY

      expect_correction(<<~RUBY)
        add_offense(node, location: :selector)
      RUBY
    end

    it 'registers an offense if message argument is passed' do
      expect_offense(<<~RUBY)
        add_offense(
          node,
          message: 'message',
          location: node.loc.selector
                    ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
        )
      RUBY

      expect_correction(<<~RUBY)
        add_offense(
          node,
          message: 'message',
          location: :selector
        )
      RUBY
    end
  end

  it 'does not register an offense when the `loc` is on a child node' do
    expect_no_offenses(<<~RUBY, 'example_cop.rb')
      add_offense(node, location: node.arguments.loc.selector)
    RUBY
  end

  it 'does not register an offense when the `loc` is on a different node' do
    expect_no_offenses(<<~RUBY, 'example_cop.rb')
      add_offense(node, location: other_node.loc.selector)
    RUBY
  end
end
