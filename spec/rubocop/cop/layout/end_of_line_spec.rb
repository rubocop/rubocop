# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EndOfLine, :config do
  shared_examples 'all configurations' do
    it 'accepts an empty file' do
      expect_no_offenses('')
    end
  end

  shared_examples 'iso-8859-15' do |eol|
    it 'can inspect non-UTF-8 encoded source with proper encoding comment' do
      # Weird place to have a test on working with non-utf-8 encodings.
      # Encodings are not specific to the EndOfLine cop, so the test is better
      # be moved somewhere more general?
      # Also working with encodings is actually the responsibility of
      # 'whitequark/parser' gem, not RuboCop itself so these test really belongs there(?)

      encoding = 'iso-8859-15'
      input = (+<<~RUBY).force_encoding(encoding)
        # coding: ISO-8859-15#{eol}
        # Euro symbol: \xa4#{eol}
      RUBY

      expect do
        Tempfile.open('tmp', encoding: encoding) { |f| expect_no_offenses(input, f) }
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Carriage return character (detected|missing)./
      )
    end
  end

  context 'when EnforcedStyle is native' do
    let(:cop_config) { { 'EnforcedStyle' => 'native' } }

    it 'registers an offense for an incorrect EOL' do
      if RuboCop::Platform.windows?
        expect_offense(<<~RUBY)
          x=0
          ^^^ Carriage return character missing.

          y=1\r
        RUBY
      else
        expect_offense(<<~RUBY)
          x=0

          y=1\r
          ^^^ Carriage return character detected.
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is crlf' do
    let(:cop_config) { { 'EnforcedStyle' => 'crlf' } }

    include_examples 'all configurations'

    it 'registers an offense for CR+LF' do
      expect_offense(<<~RUBY)
        x=0
        ^^^ Carriage return character missing.

        y=1\r
      RUBY
    end

    it 'does not register offense for no CR at end of file' do
      expect_no_offenses('x=0')
    end

    it 'does not register offenses after __END__' do
      expect_no_offenses(<<~RUBY)
        x=0\r
        __END__
        x=0
      RUBY
    end

    context 'and there are many lines ending with LF' do
      it 'registers only one offense' do
        expect_offense(<<~RUBY)
          x=0
          ^^^ Carriage return character missing.

          y=1
        RUBY
      end

      include_examples 'iso-8859-15', ''
    end

    context 'and the default external encoding is US_ASCII' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'does not crash on UTF-8 encoded non-ascii characters' do
        expect_no_offenses(<<~RUBY)
          class Epd::ReportsController < EpdAreaController\r
            'terecht bij uw ROM-coördinator.'\r
          end\r
        RUBY
      end

      include_examples 'iso-8859-15', ''
    end
  end

  context 'when EnforcedStyle is lf' do
    let(:cop_config) { { 'EnforcedStyle' => 'lf' } }

    include_examples 'all configurations'

    it 'registers an offense for CR+LF' do
      expect_offense(<<~RUBY)
        x=0

        y=1\r
        ^^^ Carriage return character detected.
      RUBY
    end

    it 'registers an offense for CR at end of file' do
      expect_offense(<<~RUBY)
        x=0\r
        ^^^ Carriage return character detected.
      RUBY
    end

    it 'does not register offenses after __END__' do
      expect_no_offenses(<<~RUBY)
        x=0
        __END__
        x=0\r
      RUBY
    end

    context 'and there are many lines ending with CR+LF' do
      it 'registers only one offense' do
        expect_offense(<<~RUBY)
          x=0\r
          ^^^ Carriage return character detected.
          \r
          y=1
        RUBY
      end

      include_examples 'iso-8859-15', "\r"
    end

    context 'and the default external encoding is US_ASCII' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'does not crash on UTF-8 encoded non-ascii characters' do
        expect_no_offenses(<<~RUBY)
          class Epd::ReportsController < EpdAreaController
            'terecht bij uw ROM-coördinator.'
          end
        RUBY
      end

      include_examples 'iso-8859-15', "\r"
    end
  end
end
