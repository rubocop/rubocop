# frozen_string_literal: true

describe RuboCop::Cop::InternalAffairs::RedundantMessageArgument do
  subject(:cop) { described_class.new }

  context 'when `MSG` is passed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, MSG)
                                     ^^^ Redundant message argument to `#add_offense`.
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source('add_offense(node, :expression, MSG)')

      expect(new_source).to eq('add_offense(node, :expression)')
    end
  end

  it 'does not register an offense when formatted `MSG` is passed' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, MSG % foo)
    RUBY
  end

  context 'when `#message` is passed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message)
                                     ^^^^^^^ Redundant message argument to `#add_offense`.
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source('add_offense(node, :expression, message)')

      expect(new_source).to eq('add_offense(node, :expression)')
    end
  end

  context 'when `#message` with offending node is passed' do
    it 'registers an offense' do
      expect_offense(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message(node))
                                     ^^^^^^^^^^^^^ Redundant message argument to `#add_offense`.
      RUBY
    end

    it 'auto-corrects' do
      new_source =
        autocorrect_source('add_offense(node, :expression, message(node))')

      expect(new_source).to eq('add_offense(node, :expression)')
    end
  end

  it 'does not register an offense when `#message` with another node ' \
     ' is passed' do
    expect_no_offenses(<<-RUBY, 'example_cop.rb')
      add_offense(node, :expression, message(other_node))
    RUBY
  end
end
