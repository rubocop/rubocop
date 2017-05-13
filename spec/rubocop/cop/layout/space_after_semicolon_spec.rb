# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceAfterSemicolon do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/SpaceInsideBlockBraces' => brace_config)
  end
  let(:brace_config) { {} }

  it 'registers an offense for semicolon without space after it' do
    expect_offense(<<-RUBY.strip_indent)
      x = 1;y = 2
           ^ Space missing after semicolon.
    RUBY
  end

  it 'does not crash if semicolon is the last character of the file' do
    expect_no_offenses('x = 1;')
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'x = 1;y = 2')
    expect(new_source).to eq('x = 1; y = 2')
  end

  context 'inside block braces' do
    shared_examples 'common behavior' do
      it 'accepts a space between a semicolon and a closing brace' do
        inspect_source(cop, 'test { ; }')
        expect(cop.messages).to be_empty
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'space' }
      end

      it_behaves_like 'common behavior'

      it 'registers an offense for no space between a semicolon and a ' \
         'closing brace' do
        inspect_source(cop, 'test { ;}')
        expect(cop.messages).to eq(['Space missing after semicolon.'])
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'no_space' }
      end

      it_behaves_like 'common behavior'

      it 'accepts no space between a semicolon and a closing brace' do
        expect_no_offenses('test { ;}')
      end
    end
  end
end
