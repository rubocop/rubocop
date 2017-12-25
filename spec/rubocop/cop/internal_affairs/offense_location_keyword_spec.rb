# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::OffenseLocationKeyword do
  subject(:cop) { described_class.new }

  shared_examples 'auto-correction' do |name, old_source, new_source|
    it "auto-corrects #{name}" do
      corrected_source = autocorrect_source(old_source)

      expect(corrected_source).to eq(new_source)
    end
  end

  context 'when `node.loc.selector` is passed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
        add_offense(node, location: node.loc.selector)
                                    ^^^^^^^^^^^^^^^^^ Use `:selector` as the location argument to `#add_offense`.
      RUBY
    end

    it 'registers an offense if message argument is passed' do
      expect_offense(<<-RUBY, 'example_cop.rb')
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
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, location: node.arguments.loc.selector)
    RUBY
  end

  it 'does not register an offense when the `loc` is on a different node' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, location: other_node.loc.selector)
    RUBY
  end

  it_behaves_like(
    'auto-correction',
    'when there are no other kwargs but location',
    'add_offense(node, location: node.loc.selector)',
    'add_offense(node, location: :selector)'
  )

  it_behaves_like(
    'auto-correction',
    'when there are other kwargs',
    <<-RUBY,
      add_offense(
        node,
        message: 'foo',
        location: node.loc.selector,
        severity: :warning
      )
    RUBY
    <<-RUBY
      add_offense(
        node,
        message: 'foo',
        location: :selector,
        severity: :warning
      )
    RUBY
  )
end
