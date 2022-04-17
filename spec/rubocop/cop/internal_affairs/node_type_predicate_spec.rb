# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeTypePredicate, :config do
  context 'comparison node type check' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        node.type == :send
        ^^^^^^^^^^^^^^^^^^ Use `#send_type?` to check node type.
      RUBY

      expect_correction(<<~RUBY)
        node.send_type?
      RUBY
    end
  end

  it 'does not register an offense for a predicate node type check' do
    expect_no_offenses(<<~RUBY, 'example_spec.rb')
      node.send_type?
    RUBY
  end
end
