# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantArguments, :config do
  subject(:cop) { described_class.new(config) }

  context 'join' do
    let(:cop_config) do
      { 'RedundantArguments' => { 'join' => '' } }
    end

    it 'registers an offense when using `#join` with empty string argument' do
      expect_offense(<<~RUBY)
        foo.join('')
        ^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'registers an offense when using `#join` with double quoted string' do
      expect_offense(<<~RUBY)
        foo.join("")
        ^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'registers an offense when using `#join` on literal arrays' do
      expect_offense(<<~RUBY)
        [1, 2, 3].join("")
        ^^^^^^^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'does not register an offense when using `#join` with no arguments' do
      expect_no_offenses(<<~RUBY)
        foo.join
      RUBY
    end

    it 'does not register an offense when using `#join` with array literals' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].join
      RUBY
    end

    it 'does not register an offense when using `#join` with separator' do
      expect_no_offenses(<<~RUBY)
        foo.join(',')
      RUBY
    end
  end

  context 'split' do
    let(:cop_config) do
      { 'RedundantArguments' => { 'split' => ' ' } }
    end

    it 'registers an offense when using `#split` with space' do
      expect_offense(<<~RUBY)
        foo.split(' ')
        ^^^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'registers an offense when using `#split` on string literal' do
      expect_offense(<<~RUBY)
        "first second".split(' ')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'registers an offense when using `#join` with double quoted string' do
      expect_offense(<<~RUBY)
        foo.split(" ")
        ^^^^^^^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'does not register an offense when using `#split` with no arguments' do
      expect_no_offenses(<<~RUBY)
        foo.split
      RUBY
    end

    it 'does not register an offense when using `#split` with string literal' do
      expect_no_offenses(<<~RUBY)
        "first second".split
      RUBY
    end

    it 'does not register an offense when using `#split` with separator' do
      expect_no_offenses(<<~RUBY)
        foo.split(',')
      RUBY
    end

    it 'does not register an offense when using `#split` with empty string' do
      expect_no_offenses(<<~RUBY)
        foo.split('')
      RUBY
    end
  end

  context 'non-builtin method' do
    let(:cop_config) do
      { 'RedundantArguments' => { 'foo' => 2 } }
    end

    it 'registers an offense with configured argument' do
      expect_offense(<<~RUBY)
        A.foo(2)
        ^^^^^^^^ Argument is redundant.
      RUBY
    end

    it 'does not register an offense with other argument' do
      expect_no_offenses(<<~RUBY)
        A.foo(5)
      RUBY
    end
  end
end
