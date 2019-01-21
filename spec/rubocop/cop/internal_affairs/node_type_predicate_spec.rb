# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeTypePredicate do
  subject(:cop) { described_class.new }

  context 'comparison node type check' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<-RUBY.strip_indent)
        node.type == :send
        ^^^^^^^^^^^^^^^^^^ Use `#send_type?` to check node type.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        node.send_type?
      RUBY
    end
  end

  it 'does not register an offense for a predicate node type check' do
    expect_no_offenses(<<-RUBY.strip_indent, 'example_spec.rb')
      node.send_type?
    RUBY
  end
end
