# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PercentQLiterals, :config do
  shared_examples 'accepts quote characters' do
    it 'accepts single quotes' do
      expect_no_offenses("'hi'")
    end

    it 'accepts double quotes' do
      expect_no_offenses('"hi"')
    end
  end

  shared_examples 'with parser error' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        %q(\«)
      RUBY
    end
  end

  shared_examples 'accepts any q string with backslash t' do
    context 'with special characters' do
      it 'accepts %q' do
        expect_no_offenses('%q(\t)')
      end

      it 'accepts %Q' do
        expect_no_offenses('%Q(\t)')
      end
    end
  end

  context 'when EnforcedStyle is lower_case_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'lower_case_q' } }

    context 'without interpolation' do
      it 'accepts %q' do
        expect_no_offenses('%q(hi)')
      end

      it 'registers offense for %Q' do
        expect_offense(<<~RUBY)
          %Q(hi)
          ^^^ Do not use `%Q` unless interpolation is needed. Use `%q`.
        RUBY

        expect_correction(<<~RUBY)
          %q(hi)
        RUBY
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
      include_examples 'with parser error'
    end

    context 'with interpolation' do
      it 'accepts %Q' do
        expect_no_offenses('%Q(#{1 + 2})')
      end

      it 'accepts %q' do
        # This is most probably a mistake, but not this cop's responsibility.
        expect_no_offenses('%q(#{1 + 2})')
      end

      include_examples 'accepts quote characters'
      include_examples 'with parser error'
    end
  end

  context 'when EnforcedStyle is upper_case_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'upper_case_q' } }

    context 'without interpolation' do
      it 'registers offense for %q' do
        expect_offense(<<~RUBY)
          %q(hi)
          ^^^ Use `%Q` instead of `%q`.
        RUBY

        expect_correction(<<~RUBY)
          %Q(hi)
        RUBY
      end

      it 'accepts %Q' do
        expect_no_offenses('%Q(hi)')
      end

      it 'does not register an offense when correcting leads to a parsing error' do
        expect_no_offenses(<<~'RUBY')
          %q(\u)
        RUBY
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
      include_examples 'with parser error'
    end

    context 'with interpolation' do
      it 'accepts %Q' do
        expect_no_offenses('%Q(#{1 + 2})')
      end

      it 'accepts %q' do
        # It's strange if interpolation syntax appears inside a static string,
        # but we can't be sure if it's a mistake or not. Changing it to %Q
        # would alter semantics, so we leave it as it is.
        expect_no_offenses('%q(#{1 + 2})')
      end

      include_examples 'accepts quote characters'
      include_examples 'with parser error'
    end
  end
end
