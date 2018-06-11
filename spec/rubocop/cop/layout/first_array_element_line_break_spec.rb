# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstArrayElementLineBreak do
  subject(:cop) { described_class.new }

  context 'elements listed on the first line' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        a = [:a,
             ^^ Add a line break before the first element of a multi-line array.
             :b]
      RUBY
    end

    it 'autocorrects the offense' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a = [:a,
             :b]
      RUBY
      # Alignment for the first element is set by IndentationWidth cop,
      # the rest of the elements should be aligned using the AlignArray cop.
      expect(corrected).to eq(<<-RUBY.strip_indent)
        a = [
        :a,
             :b]
      RUBY
    end
  end

  context 'word arrays' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        %w(a b
           ^ Add a line break before the first element of a multi-line array.
           c d)
      RUBY
    end

    it 'autocorrects the offense' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        %w(a b
           c d)
      RUBY

      expect(corrected).to eq(<<-RUBY.strip_indent)
        %w(
        a b
           c d)
      RUBY
    end
  end

  context 'array nested in a method call' do
    it 'registers ans offense' do
      expect_offense(<<-RUBY.strip_indent)
        method([:foo,
                ^^^^ Add a line break before the first element of a multi-line array.
                :bar])
      RUBY
    end

    it 'autocorrects the offense' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        method([:foo,
                :bar])
      RUBY

      expect(corrected).to eq(<<-RUBY.strip_indent)
        method([
        :foo,
                :bar])
      RUBY
    end
  end

  context 'masgn implicit arrays' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        a, b,
        c = 1,
            ^ Add a line break before the first element of a multi-line array.
        2, 3
      RUBY
    end

    it 'autocorrects the offense' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
        a, b,
        c = 1,
        2, 3
      RUBY

      expect(corrected).to eq(<<-RUBY.strip_indent)
        a, b,
        c = 
        1,
        2, 3
      RUBY
    end
  end

  context 'send implicit arrays' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        a
        .c = 1,
             ^ Add a line break before the first element of a multi-line array.
        2, 3
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        a
        .c = 1,
        2, 3
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        a
        .c = 
        1,
        2, 3
      RUBY
    end
  end

  it 'ignores properly formatted implicit arrays' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a, b,
      c =
      1, 2,
      3
    RUBY
  end

  it 'ignores elements listed on a single line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      b = [
        :a,
        :b]
    RUBY
  end
end
