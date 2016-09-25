# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Metrics::BlockNesting, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 2 } }

  shared_examples 'too deep' do |source, lines, max_to_allow = 3|
    it "registers #{lines.length} offense(s)" do
      inspect_source(cop, source)
      expect(cop.offenses.map(&:line)).to eq(lines)
      expect(cop.messages).to eq(
        ['Avoid more than 2 levels of block nesting.'] * lines.length
      )
    end

    it 'sets `Max` value correctly' do
      inspect_source(cop, source)
      expect(cop.config_to_allow_offenses['Max']).to eq(max_to_allow)
    end
  end

  it 'accepts `Max` levels of nesting' do
    inspect_source(cop, ['if a',
                         '  if b',
                         '    puts b',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  context '`Max + 1` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      puts c',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context '`Max + 2` levels of `if` nesting' do
    source = ['if a',
              '  if b',
              '    if c',
              '      if d',
              '        puts d',
              '      end',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3], 4
  end

  context 'Multiple nested `ifs` at same level' do
    source = ['if a',
              '  if b',
              '    if c',
              '      puts c',
              '    end',
              '  end',
              '  if d',
              '    if e',
              '      puts e',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3, 8]
  end

  context 'nested `case`' do
    source = ['if a',
              '  if b',
              '    case c',
              '      when C',
              '        puts C',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `while`' do
    source = ['if a',
              '  if b',
              '    while c',
              '      puts c',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested modifier `while`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end while c',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `until`' do
    source = ['if a',
              '  if b',
              '    until c',
              '      puts c',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested modifier `until`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    end until c',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `for`' do
    source = ['if a',
              '  if b',
              '    for c in [1,2] do',
              '      puts c',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [3]
  end

  context 'nested `rescue`' do
    source = ['if a',
              '  if b',
              '    begin',
              '      puts c',
              '    rescue',
              '      puts x',
              '    end',
              '  end',
              'end']
    it_behaves_like 'too deep', source, [5]
  end

  it 'accepts if/elsif' do
    inspect_source(cop, ['if a',
                         'elsif b',
                         'elsif c',
                         'elsif d',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
