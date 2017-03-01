# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceBeforeSemicolon do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/SpaceInsideBlockBraces' => brace_config)
  end
  let(:brace_config) { {} }

  it 'registers an offense for space before semicolon' do
    inspect_source(cop, 'x = 1 ; y = 2')
    expect(cop.messages).to eq(
      ['Space found before semicolon.']
    )
  end

  it 'does not register an offense for no space before semicolons' do
    inspect_source(cop, 'x = 1; y = 2')
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects space before semicolon' do
    new_source = autocorrect_source(cop, 'x = 1 ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  it 'handles more than one space before a semicolon' do
    new_source = autocorrect_source(cop, 'x = 1  ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  context 'inside block braces' do
    shared_examples 'common behavior' do
      it 'accepts no space between an opening brace and a semicolon' do
        inspect_source(cop, 'test {; }')
        expect(cop.messages).to be_empty
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'space' }
      end

      it_behaves_like 'common behavior'

      it 'accepts a space between an opening brace and a semicolon' do
        inspect_source(cop, 'test { ; }')
        expect(cop.messages).to be_empty
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'no_space' }
      end

      it_behaves_like 'common behavior'

      it 'registers an offense for a space between an opening brace and a ' \
         'semicolon' do
        inspect_source(cop, 'test { ; }')
        expect(cop.messages).to eq(['Space found before semicolon.'])
      end
    end
  end
end
