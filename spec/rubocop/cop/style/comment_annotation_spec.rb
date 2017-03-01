# frozen_string_literal: true

describe RuboCop::Cop::Style::CommentAnnotation, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'Keywords' => %w(TODO FIXME OPTIMIZE HACK REVIEW) }
  end

  context 'missing colon' do
    it 'registers an offense' do
      inspect_source(cop, '# TODO make better')
      expect(cop.messages).to eq([format(described_class::MSG, 'TODO')])
      expect(cop.highlights).to eq(['TODO '])
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, '# TODO make better')
      expect(corrected).to eq('# TODO: make better')
    end
  end

  context 'with configured keyword' do
    let(:cop_config) { { 'Keywords' => %w(ISSUE) } }

    it 'registers an offense for a missing colon after the word' do
      inspect_source(cop, '# ISSUE wrong order')
      expect(cop.messages).to eq([format(described_class::MSG, 'ISSUE')])
      expect(cop.highlights).to eq(['ISSUE '])
    end

    it 'autocorrects a missing colon after keyword' do
      corrected = autocorrect_source(cop, '# ISSUE wrong order')
      expect(corrected).to eq('# ISSUE: wrong order')
    end
  end

  context 'missing space after colon' do
    it 'registers an offense' do
      inspect_source(cop, '# TODO:make better')
      expect(cop.messages).to eq([format(described_class::MSG, 'TODO')])
      expect(cop.highlights).to eq(['TODO:'])
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, '# TODO:make better')
      expect(corrected).to eq('# TODO: make better')
    end
  end

  context 'lower case keyword' do
    it 'registers an offense' do
      inspect_source(cop, '# fixme: does not work')
      expect(cop.messages).to eq([format(described_class::MSG, 'fixme')])
      expect(cop.highlights).to eq(['fixme: '])
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, '# fixme: does not work')
      expect(corrected).to eq('# FIXME: does not work')
    end
  end

  context 'capitalized keyword' do
    it 'registers an offense' do
      inspect_source(cop, '# Optimize: does not work')
      expect(cop.messages).to eq([format(described_class::MSG, 'Optimize')])
      expect(cop.highlights).to eq(['Optimize: '])
    end

    it 'autocorrects' do
      corrected = autocorrect_source(cop, '# Optimize: does not work')
      expect(corrected).to eq('# OPTIMIZE: does not work')
    end
  end

  context 'upper case keyword with colon by no note' do
    it 'registers an offense' do
      inspect_source(cop, '# HACK:')
      expect(cop.messages)
        .to eq(['Annotation comment, with keyword `HACK`, is missing a note.'])
      expect(cop.highlights).to eq(['HACK:'])
    end

    it 'does not autocorrects' do
      source = '# HACK:'
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end
  end

  it 'accepts upper case keyword with colon, space and note' do
    inspect_source(cop, '# REVIEW: not sure about this')
    expect(cop.offenses).to be_empty
  end

  it 'accepts upper case keyword alone' do
    inspect_source(cop, '# OPTIMIZE')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a comment that is obviously a code example' do
    inspect_source(cop, '# Todo.destroy(1)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a keyword that is just the beginning of a sentence' do
    inspect_source(cop,
                   ["# Optimize if you want. I wouldn't recommend it.",
                    '# Hack is a fun game.'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts a keyword that is somewhere in a sentence' do
    src = ['# Example: There are three reviews, with ranks 1, 2, and 3. A new',
           '# review is saved with rank 2. The two reviews that originally had',
           '# ranks 2 and 3 will have their ranks increased to 3 and 4.']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  context 'when a keyword is not in the configuration' do
    let(:cop_config) do
      { 'Keywords' => %w(FIXME OPTIMIZE HACK REVIEW) }
    end

    it 'accepts the word without colon' do
      inspect_source(cop, '# TODO make better')
      expect(cop.offenses).to be_empty
    end
  end
end
