# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineHashKeyLineBreaks, :config do
  context 'with line break after opening bracket' do
    context 'when on different lines than brackets but keys on one' do
      it 'does not add any offenses' do
        expect_no_offenses(<<~RUBY)
          {
            foo: 1, bar: "2"
          }
        RUBY
      end
    end

    context 'when on all keys on one line different than brackets' do
      it 'does not add any offenses' do
        expect_no_offenses(<<~RUBY)
          {
            foo => 1, bar => "2"
          }
        RUBY
      end
    end

    it 'registers an offense and corrects when key starts on same line as another' do
      expect_offense(<<~RUBY)
        {
          foo: 1,
          baz: 3, bar: "2"}
                  ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        {
          foo: 1,
          baz: 3,\s
        bar: "2"}
      RUBY
    end

    context 'when key starts on same line as another with rockets' do
      it 'adds an offense' do
        expect_offense(<<~RUBY)
          {
            foo => 1,
            baz => 3, bar: "2"}
                      ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
        RUBY

        expect_correction(<<~RUBY)
          {
            foo => 1,
            baz => 3,\s
          bar: "2"}
        RUBY
      end
    end
  end

  context 'without line break after opening bracket' do
    context 'when on same line' do
      it 'does not add any offenses' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: "2"}
        RUBY
      end
    end

    it 'registers an offense and corrects when key starts on same line as another' do
      expect_offense(<<~RUBY)
        {foo: 1,
          baz: 3, bar: "2"}
                  ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1,
          baz: 3,\s
        bar: "2"}
      RUBY
    end

    it 'registers an offense and corrects nested hashes' do
      expect_offense(<<~RUBY)
        {foo: 1,
          baz: {
            as: 12,
          }, bar: "2"}
             ^^^^^^^^ Each key in a multi-line hash must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 1,
          baz: {
            as: 12,
          },\s
        bar: "2"}
      RUBY
    end

    context 'ignore last element' do
      let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

      it 'ignores last value that is a multiline hash' do
        expect_no_offenses(<<~RUBY)
          {foo: 1, bar: {
            a: 1
          }}
        RUBY
      end

      it 'registers and corrects values that are multiline hashes and not the last value' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: {
                   ^^^^^^ Each key in a multi-line hash must start on a separate line.
            a: 1,
          }, baz: 3}
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1,#{trailing_whitespace}
          bar: {
            a: 1,
          },#{trailing_whitespace}
          baz: 3}
        RUBY
      end

      it 'registers and corrects last value that is on a new line' do
        expect_offense(<<~RUBY)
          {foo: 1, bar: 2,
                   ^^^^^^ Each key in a multi-line hash must start on a separate line.
            baz: 3}
        RUBY

        expect_correction(<<~RUBY)
          {foo: 1,#{trailing_whitespace}
          bar: 2,
            baz: 3}
        RUBY
      end
    end
  end
end
