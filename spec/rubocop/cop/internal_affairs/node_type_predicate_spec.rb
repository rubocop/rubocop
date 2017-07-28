# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::NodeTypePredicate do
  subject(:cop) { described_class.new }

  context 'comparison node type check' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
      node.type == :send
      ^^^^^^^^^^^^^^^^^^ Use `#send_type?` to check node type.
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source('node.type == :send')

      expect(new_source).to eq('node.send_type?')
    end
  end

  it 'does not register an offense for a predicate node type check' do
    expect_no_offenses(<<-RUBY, 'example_spec.rb')
      node.send_type?
    RUBY
  end
end
