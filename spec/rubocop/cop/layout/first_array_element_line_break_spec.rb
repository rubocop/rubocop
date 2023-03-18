# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstArrayElementLineBreak, :config do
  context 'elements listed on the first line' do
    it 'registers and corrects the offense' do
      expect_offense(<<~RUBY)
        a = [:a,
             ^^ Add a line break before the first element of a multi-line array.
             :b]
      RUBY

      # Alignment for the first element is set by IndentationWidth cop,
      # the rest of the elements should be aligned using the ArrayAlignment cop.
      expect_correction(<<~RUBY)
        a = [
        :a,
             :b]
      RUBY
    end
  end

  context 'word arrays' do
    it 'registers and corrects the offense' do
      expect_offense(<<~RUBY)
        %w(a b
           ^ Add a line break before the first element of a multi-line array.
           c d)
      RUBY

      expect_correction(<<~RUBY)
        %w(
        a b
           c d)
      RUBY
    end
  end

  context 'array nested in a method call' do
    it 'registers an corrects the offense' do
      expect_offense(<<~RUBY)
        method([:foo,
                ^^^^ Add a line break before the first element of a multi-line array.
                :bar])
      RUBY

      expect_correction(<<~RUBY)
        method([
        :foo,
                :bar])
      RUBY
    end
  end

  context 'masgn implicit arrays' do
    it 'registers and corrects the offense' do
      expect_offense(<<~RUBY)
        a, b,
        c = 1,
            ^ Add a line break before the first element of a multi-line array.
        2, 3
      RUBY

      expect_correction(<<~RUBY)
        a, b,
        c =#{trailing_whitespace}
        1,
        2, 3
      RUBY
    end
  end

  context 'send implicit arrays' do
    it 'registers and corrects the offense' do
      expect_offense(<<~RUBY)
        a
        .c = 1,
             ^ Add a line break before the first element of a multi-line array.
        2, 3
      RUBY

      expect_correction(<<~RUBY)
        a
        .c =#{trailing_whitespace}
        1,
        2, 3
      RUBY
    end
  end

  it 'ignores properly formatted implicit arrays' do
    expect_no_offenses(<<~RUBY)
      a, b,
      c =
      1, 2,
      3
    RUBY
  end

  it 'ignores elements listed on a single line' do
    expect_no_offenses(<<~RUBY)
      b = [
        :a,
        :b]
    RUBY
  end

  context 'last element can be multiline' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last argument that is a multiline Hash' do
      expect_no_offenses(<<~RUBY)
        [a, b, {
          c: d
        }]
      RUBY
    end

    it 'ignores single value that is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        [{
          a: b
        }]
      RUBY
    end

    it 'registers and corrects values that are multiline hashes and not the last value' do
      expect_offense(<<~RUBY)
        [a, {
         ^ Add a line break before the first element of a multi-line array.
          b: c
        }, d]
      RUBY

      expect_correction(<<~RUBY)
        [
        a, {
          b: c
        }, d]
      RUBY
    end

    it 'registers and corrects last value that starts on another line' do
      expect_offense(<<~RUBY)
        [a, b,
         ^ Add a line break before the first element of a multi-line array.
        c]
      RUBY

      expect_correction(<<~RUBY)
        [
        a, b,
        c]
      RUBY
    end
  end
end
