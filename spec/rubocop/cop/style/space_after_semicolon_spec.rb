# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterSemicolon do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/SpaceInsideBlockBraces' => brace_config)
  end
  let(:brace_config) { {} }

  it 'registers an offense for semicolon without space after it' do
    inspect_source(cop, 'x = 1;y = 2')
    expect(cop.messages).to eq(
      ['Space missing after semicolon.']
    )
  end

  it 'does not crash if semicolon is the last character of the file' do
    inspect_source(cop, 'x = 1;')
    expect(cop.messages).to be_empty
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
        inspect_source(cop, 'test { ;}')
        expect(cop.messages).to be_empty
      end
    end
  end
end
