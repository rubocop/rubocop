# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::OffenseLocationKeyword do
  subject(:cop) { described_class.new }

  context 'when `node.loc.selector` is passed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent, 'example_cop.rb')
        add_offense(node, location: node.loc.selector)
                                    ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
      RUBY
    end

    it 'registers an offense if message argument is passed' do
      expect_offense(<<-RUBY.strip_indent, 'example_cop.rb')
        add_offense(
          node,
          message: 'message',
          location: node.loc.selector
                    ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
        )
      RUBY
    end
  end

  it 'does not register an offense when the `loc` is on a child node' do
    expect_no_offenses(<<-RUBY.strip_indent, 'example_cop.rb')
      add_offense(node, location: node.arguments.loc.selector)
    RUBY
  end

  it 'does not register an offense when the `loc` is on a different node' do
    expect_no_offenses(<<-RUBY.strip_indent, 'example_cop.rb')
      add_offense(node, location: other_node.loc.selector)
    RUBY
  end

  it 'auto-corrects `location` when it is the only keyword' do
    corrected =
      autocorrect_source('add_offense(node, location: node.loc.selector)')

    expect(corrected).to eq('add_offense(node, location: :selector)')
  end

  it 'auto-corrects `location` when there are other keywords' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      add_offense(
        node,
        message: 'foo',
        location: node.loc.selector,
        severity: :warning
      )
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      add_offense(
        node,
        message: 'foo',
        location: :selector,
        severity: :warning
      )
    RUBY
  end
end
