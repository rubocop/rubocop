# frozen_string_literal: true

describe RuboCop::Cop::Style::PercentQLiterals, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'accepts quote characters' do
    it 'accepts single quotes' do
      inspect_source(cop, "'hi'")
      expect(cop.offenses).to be_empty
    end

    it 'accepts double quotes' do
      inspect_source(cop, '"hi"')
      expect(cop.offenses).to be_empty
    end
  end

  shared_examples 'accepts any q string with backslash t' do
    context 'with special characters' do
      it 'accepts %q' do
        inspect_source(cop, '%q(\t)')
        expect(cop.offenses).to be_empty
      end

      it 'accepts %Q' do
        inspect_source(cop, '%Q(\t)')
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when EnforcedStyle is lower_case_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'lower_case_q' } }

    context 'without interpolation' do
      it 'accepts %q' do
        inspect_source(cop, '%q(hi)')
        expect(cop.offenses).to be_empty
      end

      it 'registers offense for %Q' do
        inspect_source(cop, '%Q(hi)')
        expect(cop.messages)
          .to eq(['Do not use `%Q` unless interpolation is needed.  Use `%q`.'])
        expect(cop.highlights).to eq(['%Q('])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%Q(hi)')
        expect(new_source).to eq('%q(hi)')
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
    end

    context 'with interpolation' do
      it 'accepts %Q' do
        inspect_source(cop, '%Q(#{1 + 2})')
        expect(cop.offenses).to be_empty
      end

      it 'accepts %q' do
        # This is most probably a mistake, but not this cop's responsibility.
        inspect_source(cop, '%q(#{1 + 2})')
        expect(cop.offenses).to be_empty
      end

      include_examples 'accepts quote characters'
    end
  end

  context 'when EnforcedStyle is upper_case_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'upper_case_q' } }

    context 'without interpolation' do
      it 'registers offense for %q' do
        inspect_source(cop, '%q(hi)')
        expect(cop.messages).to eq(['Use `%Q` instead of `%q`.'])
        expect(cop.highlights).to eq(['%q('])
      end

      it 'accepts %Q' do
        inspect_source(cop, '%Q(hi)')
        expect(cop.offenses).to be_empty
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%q[hi]')
        expect(new_source).to eq('%Q[hi]')
      end

      include_examples 'accepts quote characters'
      include_examples 'accepts any q string with backslash t'
    end

    context 'with interpolation' do
      it 'accepts %Q' do
        inspect_source(cop, '%Q(#{1 + 2})')
        expect(cop.offenses).to be_empty
      end

      it 'accepts %q' do
        # It's strange if interpolation syntax appears inside a static string,
        # but we can't be sure if it's a mistake or not. Changing it to %Q
        # would alter semantics, so we leave it as it is.
        inspect_source(cop, '%q(#{1 + 2})')
        expect(cop.offenses).to be_empty
      end

      it 'does not auto-correct' do
        source = '%q(#{1 + 2})'
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(source)
      end

      include_examples 'accepts quote characters'
    end
  end
end
