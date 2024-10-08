# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantMessageArgument, :config do
  context 'when `MSG` is passed' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'example_cop.rb')
        add_offense(node, message: MSG)
                          ^^^^^^^^^^^^ Redundant message argument to `#add_offense`.
      RUBY

      expect_correction(<<~RUBY)
        add_offense(node)
      RUBY
    end
  end

  it 'does not register an offense when formatted `MSG` is passed' do
    expect_no_offenses(<<~RUBY, 'example_cop.rb')
      add_offense(node, location: :expression, message: MSG % foo)
    RUBY
  end

  context 'when `#message` is passed' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        add_offense(
          node,
          location: :expression,
          message: message,
          severity: :error
        )
      RUBY
    end
  end

  context 'when `#message` with offending node is passed' do
    context 'when message is the only keyword argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'example_cop.rb')
          add_offense(node, message: message(node))
        RUBY
      end
    end

    context 'when there are others keyword arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'example_cop.rb')
          add_no_offenses(node,
                      location: :selector,
                      message: message(node),
                      severity: :fatal)
        RUBY
      end
    end
  end

  it 'does not register an offense when `#message` with another node is passed' do
    expect_no_offenses(<<~RUBY, 'example_cop.rb')
      add_offense(node, message: message(other_node))
    RUBY
  end
end
