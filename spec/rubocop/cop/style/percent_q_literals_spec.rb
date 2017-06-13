# frozen_string_literal: true

describe RuboCop::Cop::Style::PercentQLiterals, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'accepts quote characters' do
    it 'accepts single quotes' do
      expect_no_offenses("'hi'")
    end

    it 'accepts double quotes' do
      expect_no_offenses('"hi"')
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
        expect_offense(<<-RUBY.strip_indent)
          %Q(hi)
          ^^^ Do not use `%Q` unless interpolation is needed.  Use `%q`.
        RUBY
      end

      it 'auto-corrects' do
        new_source = autocorrect_source('%Q(hi)')
        expect(new_source).to eq('%q(hi)')
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
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
    end
  end

  context 'when EnforcedStyle is upper_case_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'upper_case_q' } }

    context 'without interpolation' do
      it 'registers offense for %q' do
        expect_offense(<<-RUBY.strip_indent)
          %q(hi)
          ^^^ Use `%Q` instead of `%q`.
        RUBY
      end

      it 'accepts %Q' do
        expect_no_offenses('%Q(hi)')
      end

      it 'auto-corrects' do
        new_source = autocorrect_source('%q[hi]')
        expect(new_source).to eq('%Q[hi]')
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
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

      it 'does not auto-correct' do
        source = '%q(#{1 + 2})'
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      include_examples 'accepts quote characters'
    end
  end
end
