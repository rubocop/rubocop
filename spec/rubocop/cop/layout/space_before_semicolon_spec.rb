# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceBeforeSemicolon do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/SpaceInsideBlockBraces' => brace_config)
  end
  let(:brace_config) { {} }

  it 'registers an offense for space before semicolon' do
    expect_offense(<<-RUBY.strip_indent)
      x = 1 ; y = 2
           ^ Space found before semicolon.
    RUBY
  end

  it 'does not register an offense for no space before semicolons' do
    expect_no_offenses('x = 1; y = 2')
  end

  it 'auto-corrects space before semicolon' do
    new_source = autocorrect_source('x = 1 ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  it 'handles more than one space before a semicolon' do
    new_source = autocorrect_source('x = 1  ; y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  context 'inside block braces' do
    shared_examples 'common behavior' do
      it 'accepts no space between an opening brace and a semicolon' do
        inspect_source('test {; }')
        expect(cop.messages).to be_empty
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'space' }
      end

      it_behaves_like 'common behavior'

      it 'accepts a space between an opening brace and a semicolon' do
        expect_no_offenses('test { ; }')
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'no_space' }
      end

      it_behaves_like 'common behavior'

      it 'registers an offense for a space between an opening brace and a ' \
         'semicolon' do
        inspect_source('test { ; }')
        expect(cop.messages).to eq(['Space found before semicolon.'])
      end
    end
  end
end
