# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyBlock, :config do
  let(:cop_config) { { 'AllowComments' => true, 'AllowEmptyLambdas' => true } }

  it 'registers an offense for empty block within method call' do
    expect_offense(<<~RUBY)
      items.each { |item| }
      ^^^^^^^^^^^^^^^^^^^^^ Empty block detected.
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

  it 'does not register an offense on an empty lambda' do
    expect_no_offenses(<<~RUBY)
      lambda do
      end
    RUBY
  end

  it 'does not register an offense on an empty stabby lambda' do
    expect_no_offenses(<<~RUBY)
      -> {}
    RUBY
  end

  it 'does not register an offense on an empty proc' do
    expect_no_offenses(<<~RUBY)
      proc do
      end
    RUBY
  end

  it 'does not register an offense on an empty Proc.new' do
    expect_no_offenses(<<~RUBY)
      Proc.new {}
    RUBY
  end

  it 'does not register an offense on an empty ::Proc.new' do
    expect_no_offenses(<<~RUBY)
      ::Proc.new {}
    RUBY
  end

  it 'registers an offense for an empty block given to a non-Kernel `proc` method' do
    expect_offense(<<~RUBY)
      Foo.proc {}
      ^^^^^^^^^^^ Empty block detected.
    RUBY
  end

  context 'when AllowComments is false' do
    let(:cop_config) { { 'AllowComments' => false } }

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

  context 'when AllowEmptyLambdas is false' do
    let(:cop_config) { { 'AllowEmptyLambdas' => false } }

    it 'registers an offense for an empty lambda' do
      expect_offense(<<~RUBY)
        lambda do
        ^^^^^^^^^ Empty block detected.
        end
      RUBY
    end

    it 'registers an offense for an empty stabby lambda' do
      expect_offense(<<~RUBY)
        -> {}
        ^^^^^ Empty block detected.
      RUBY
    end

    it 'registers an offense on an empty proc' do
      expect_offense(<<~RUBY)
        proc do
        ^^^^^^^ Empty block detected.
        end
      RUBY
    end

    it 'registers an offense on an empty Proc.new' do
      expect_offense(<<~RUBY)
        Proc.new {}
        ^^^^^^^^^^^ Empty block detected.
      RUBY
    end

    it 'registers an offense on an empty ::Proc.new' do
      expect_offense(<<~RUBY)
        ::Proc.new {}
        ^^^^^^^^^^^^^ Empty block detected.
      RUBY
    end
  end
end
