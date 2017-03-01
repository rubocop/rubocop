# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceAfterComma do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/SpaceInsideHashLiteralBraces' => brace_config)
  end
  let(:brace_config) { {} }

  shared_examples 'ends with an item' do |items, correct_items|
    it 'registers an offense' do
      inspect_source(cop, source.call(items))
      expect(cop.messages).to eq(
        ['Space missing after comma.']
      )
    end

    it 'does auto-correction' do
      new_source = autocorrect_source(cop, source.call(items))
      expect(new_source).to eq source.call(correct_items)
    end
  end

  shared_examples 'trailing comma' do |items|
    it 'accepts the last comma' do
      inspect_source(cop, source.call(items))
      expect(cop.messages).to be_empty
    end
  end

  context 'block argument commas without space' do
    let(:source) { ->(args) { "each { |#{args}| }" } }

    it_behaves_like 'ends with an item', 's,t', 's, t'
    it_behaves_like 'trailing comma', 's, t,'
  end

  context 'array index commas without space' do
    let(:source) { ->(items) { "formats[#{items}]" } }

    it_behaves_like 'ends with an item', '0,1', '0, 1'
    it_behaves_like 'trailing comma', '0,'
  end

  context 'method call arg commas without space' do
    let(:source) { ->(args) { "a(#{args})" } }

    it_behaves_like 'ends with an item', '1,2', '1, 2'
  end

  context 'inside hash braces' do
    shared_examples 'common behavior' do
      it 'accepts a space between a comma and a closing brace' do
        inspect_source(cop, '{ foo:bar, }')
        expect(cop.messages).to be_empty
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'space' }
      end

      it_behaves_like 'common behavior'

      it 'registers an offense for no space between a comma and a ' \
         'closing brace' do
        inspect_source(cop, '{ foo:bar,}')
        expect(cop.messages).to eq(['Space missing after comma.'])
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) do
        { 'Enabled' => true, 'EnforcedStyle' => 'no_space' }
      end

      it_behaves_like 'common behavior'

      it 'accepts no space between a comma and a closing brace' do
        inspect_source(cop, '{foo:bar,}')
        expect(cop.messages).to be_empty
      end
    end
  end
end
