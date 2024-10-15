# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeMatcherNaming, :config do
  it 'does not register an offense if a predicate node matcher has no captures' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :string?, '(str _)'
    RUBY
  end

  it 'does not register an offense if a non-predicate node matcher has captures' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :string, '(str $_)'
    RUBY
  end

  it 'registers an offense if a predicate matcher has captures' do
    expect_offense(<<~RUBY)
      def_node_matcher :string?, '(str $_)'
                       ^^^^^^^^ Node matcher with captures should not be a predicate.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :string, '(str $_)'
    RUBY
  end

  it 'registers an offense if a non-predicate matcher has no captures' do
    expect_offense(<<~RUBY)
      def_node_matcher :string, '(str _)'
                       ^^^^^^^ Node matcher without captures should be a predicate.
    RUBY

    expect_correction(<<~RUBY)
      def_node_matcher :string?, '(str _)'
    RUBY
  end
end
