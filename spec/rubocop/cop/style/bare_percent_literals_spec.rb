# frozen_string_literal: true

describe RuboCop::Cop::Style::BarePercentLiterals, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'accepts other delimiters' do
    it 'accepts __FILE__' do
      inspect_source(cop, '__FILE__')
      expect(cop.offenses).to be_empty
    end

    it 'accepts regular expressions' do
      inspect_source(cop, '/%Q?/')
      expect(cop.offenses).to be_empty
    end

    it 'accepts ""' do
      inspect_source(cop, '""')
      expect(cop.offenses).to be_empty
    end

    it 'accepts "" string with interpolation' do
      inspect_source(cop, '"#{file}hi"')
      expect(cop.offenses).to be_empty
    end

    it "accepts ''" do
      inspect_source(cop, "'hi'")
      expect(cop.offenses).to be_empty
    end

    it 'accepts %q' do
      inspect_source(cop, '%q(hi)')
      expect(cop.offenses).to be_empty
    end

    it 'accepts heredoc' do
      inspect_source(cop, <<-END.strip_indent)
        func <<HEREDOC
        hi
        HEREDOC
      END
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is percent_q' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent_q' } }

    context 'and strings are static' do
      it 'registers an offense for %()' do
        inspect_source(cop, '%(hi)')
        expect(cop.messages).to eq(['Use `%Q` instead of `%`.'])
        expect(cop.highlights).to eq(['%('])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%(hi)')
        expect(new_source).to eq('%Q(hi)')
      end

      it 'accepts %Q()' do
        inspect_source(cop, '%Q(hi)')
        expect(cop.offenses).to be_empty
      end

      include_examples 'accepts other delimiters'
    end

    context 'and strings are dynamic' do
      it 'registers an offense for %()' do
        inspect_source(cop, '%(#{x})')
        expect(cop.messages).to eq(['Use `%Q` instead of `%`.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%(#{x})')
        expect(new_source).to eq('%Q(#{x})')
      end

      it 'accepts %Q()' do
        inspect_source(cop, '%Q(#{x})')
        expect(cop.offenses).to be_empty
      end

      include_examples 'accepts other delimiters'
    end
  end

  context 'when EnforcedStyle is bare_percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'bare_percent' } }

    context 'and strings are static' do
      it 'registers an offense for %Q()' do
        inspect_source(cop, '%Q(hi)')
        expect(cop.messages).to eq(['Use `%` instead of `%Q`.'])
        expect(cop.highlights).to eq(['%Q('])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%Q(hi)')
        expect(new_source).to eq('%(hi)')
      end

      it 'accepts %()' do
        inspect_source(cop, '%(hi)')
        expect(cop.offenses).to be_empty
      end

      include_examples 'accepts other delimiters'
    end

    context 'and strings are dynamic' do
      it 'registers an offense for %Q()' do
        inspect_source(cop, '%Q(#{x})')
        expect(cop.messages).to eq(['Use `%` instead of `%Q`.'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, '%Q(#{x})')
        expect(new_source).to eq('%(#{x})')
      end

      it 'accepts %()' do
        inspect_source(cop, '%(#{x})')
        expect(cop.offenses).to be_empty
      end

      include_examples 'accepts other delimiters'
    end
  end
end
