# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeBrackets, :config do
  context 'when referencing' do
    it 'registers an offense and corrects when using space between lvar receiver and left brackets' do
      expect_offense(<<~RUBY)
        collection = do_something
        collection [index_or_key]
                  ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        collection = do_something
        collection[index_or_key]
      RUBY
    end

    it 'registers an offense and corrects when using space between ivar receiver and left brackets' do
      expect_offense(<<~RUBY)
        @collection [index_or_key]
                   ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        @collection[index_or_key]
      RUBY
    end

    it 'registers an offense and corrects when using space between cvar receiver and left brackets' do
      expect_offense(<<~RUBY)
        @@collection [index_or_key]
                    ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        @@collection[index_or_key]
      RUBY
    end

    it 'registers an offense and corrects when using space between gvar receiver and left brackets' do
      expect_offense(<<~RUBY)
        $collection [index_or_key]
                   ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        $collection[index_or_key]
      RUBY
    end

    it 'does not register an offense when using space between method call and left brackets' do
      expect_no_offenses(<<~RUBY)
        do_something [item_of_array_literal]
      RUBY
    end

    it 'does not register an offense when not using space between variable receiver and left brackets' do
      expect_no_offenses(<<~RUBY)
        collection = do_something
        collection[index_or_key]
      RUBY
    end

    it 'does not register an offense when not using space between method call and left brackets' do
      expect_no_offenses(<<~RUBY)
        do_something[item_of_array_literal]
      RUBY
    end

    it 'does not register an offense when array literal argument is enclosed in parentheses' do
      expect_no_offenses(<<~RUBY)
        do_something([item_of_array_literal])
      RUBY
    end

    it 'does not register an offense when it is used as a method argument' do
      expect_no_offenses(<<~RUBY)
        expect(offenses).to eq []
      RUBY
    end

    it 'does not register an offense when using multiple arguments' do
      expect_no_offenses(<<~RUBY)
        do_something [foo], bar
      RUBY
    end

    it 'does not register an offense when without receiver' do
      expect_no_offenses(<<~RUBY)
        [index_or_key]
      RUBY
    end

    it 'does not register an offense when call desugared `Hash#[]` to lvar receiver' do
      expect_no_offenses(<<~RUBY)
        collection.[](index_or_key)
      RUBY
    end

    it 'does not register an offense when call desugared `Hash#[]` to ivar receiver' do
      expect_no_offenses(<<~RUBY)
        @collection.[](index_or_key)
      RUBY
    end

    it 'does not register an offense when call desugared `Hash#[]` to cvar receiver' do
      expect_no_offenses(<<~RUBY)
        @@collection.[](index_or_key)
      RUBY
    end
  end

  context 'when assigning' do
    it 'registers an offense and corrects when using space between receiver and left brackets' do
      expect_offense(<<~RUBY)
        @correction [index_or_key] = :value
                   ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        @correction[index_or_key] = :value
      RUBY
    end

    it 'does not register an offense when not using space between receiver and left brackets' do
      expect_no_offenses(<<~RUBY)
        @correction[index_or_key] = :value
      RUBY
    end

    it 'does not register an offense when space is used in left bracket' do
      expect_no_offenses(<<~RUBY)
        @collections[ index_or_key ] = :value
      RUBY
    end

    it 'does not register an offense when multiple spaces are inserted inside the left bracket' do
      expect_no_offenses(<<~RUBY)
        @collections[  index_or_key] = value
      RUBY
    end
  end

  it 'does not register an offense when assigning an array' do
    expect_no_offenses(<<~RUBY)
      task.options = ['--no-output']
    RUBY
  end

  it 'does not register an offense when using array literal argument without parentheses' do
    expect_no_offenses(<<~RUBY)
      before_validation { to_downcase ['email'] }
    RUBY
  end

  it 'does not register an offense when using percent array literal argument without parentheses' do
    expect_no_offenses(<<~RUBY)
      before_validation { to_downcase %w[email] }
    RUBY
  end
end
