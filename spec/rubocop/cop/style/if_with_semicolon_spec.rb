# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects for one line if/;/end' do
    expect_offense(<<~RUBY)
      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead or if else structure.
    RUBY

    expect_correction(<<~RUBY)
      cond ? run : dont
    RUBY
  end

  it 'accepts without `else` branch' do
    # This case is corrected to a modifier form by `Style/IfUnlessModifier` cop.
    # Therefore, this cop does not handle it.
    expect_no_offenses(<<~RUBY)
      if cond; run end
    RUBY
  end

  it 'can handle modifier conditionals' do
    expect_no_offenses(<<~RUBY)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    RUBY
  end

  context 'when elsif is present' do
    it 'accepts without `else` branch' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead or if else structure.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        end
      RUBY
    end

    it 'accepts second elsif block' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 elsif cond3; run3 else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead or if else structure.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        elsif cond3
          run3
        else
          dont
        end
      RUBY
    end

    it 'accepts with `else` branch' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead or if else structure.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        else
          dont
        end
      RUBY
    end
  end
end
