# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyBlock, :config do
  let(:cop_config) do
    { 'AllowComments' => true }
  end

  it 'registers an offense for empty block within method call' do
    expect_offense(<<~RUBY)
      items.each { |item| }
      ^^^^^^^^^^^^^^^^^^^^^ Empty block detected.
    RUBY
  end

  it 'registers an offense for empty block within lambda' do
    expect_offense(<<~RUBY)
      lambda { |item| }
      ^^^^^^^^^^^^^^^^^ Empty block detected.
    RUBY
  end

  it 'does not register an offense for empty block with inner comments' do
    expect_no_offenses(<<~RUBY)
      items.each do |item|
        # TODO: implement later
      end
    RUBY
  end

  it 'does not register an offense for empty block with inline comments' do
    expect_no_offenses(<<~RUBY)
      items.each { |item| } # TODO: implement later
    RUBY
  end

  it 'does not register an offense when block is not empty' do
    expect_no_offenses(<<~RUBY)
      items.each { |item| puts item }
    RUBY
  end

  context 'when AllowComments is false' do
    let(:cop_config) do
      { 'AllowComments' => false }
    end

    it 'registers an offense for empty block with inner comments' do
      expect_offense(<<~RUBY)
        items.each do |item|
        ^^^^^^^^^^^^^^^^^^^^ Empty block detected.
          # TODO: implement later
        end
      RUBY
    end

    it 'registers an offense for empty block with inline comments' do
      expect_offense(<<~RUBY)
        items.each { |item| } # TODO: implement later
        ^^^^^^^^^^^^^^^^^^^^^ Empty block detected.
      RUBY
    end
  end
end
