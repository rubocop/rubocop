# frozen_string_literal: true

describe RuboCop::Cop::Metrics::PerceivedComplexity, :config do
  subject(:cop) { described_class.new(config) }

  context 'when Max is 1' do
    let(:cop_config) { { 'Max' => 1 } }

    it 'accepts a method with no decision points' do
      inspect_source(cop, ['def method_name',
                           '  call_foo',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts complex code outside of methods' do
      inspect_source(cop,
                     ['def method_name',
                      '  call_foo',
                      'end',
                      '',
                      'if first_condition then',
                      '  call_foo if second_condition && third_condition',
                      '  call_bar if fourth_condition || fifth_condition',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for an if modifier' do
      inspect_source(cop, ['def self.method_name',
                           '  call_foo if some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
      expect(cop.highlights).to eq(['def'])
      expect(cop.config_to_allow_offenses).to eq('Max' => 2)
    end

    it 'registers an offense for an unless modifier' do
      inspect_source(cop, ['def method_name',
                           '  call_foo unless some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for elsif and else blocks' do
      inspect_source(cop, ['def method_name',
                           '  if first_condition then',
                           '    call_foo',
                           '  elsif second_condition then',
                           '    call_bar',
                           '  else',
                           '    call_bam',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [4/1]'])
    end

    it 'registers an offense for a ternary operator' do
      inspect_source(cop, ['def method_name',
                           '  value = some_condition ? 1 : 2',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for a while block' do
      inspect_source(cop, ['def method_name',
                           '  while some_condition do',
                           '    call_foo',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for an until block' do
      inspect_source(cop, ['def method_name',
                           '  until some_condition do',
                           '    call_foo',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for a for block' do
      inspect_source(cop, ['def method_name',
                           '  for i in 1..2 do',
                           '    call_method',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for a rescue block' do
      inspect_source(cop, ['def method_name',
                           '  begin',
                           '    call_foo',
                           '  rescue Exception',
                           '    call_bar',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for a case/when block' do
      inspect_source(cop, ['def method_name',
                           '  case value',
                           '  when 1 then call_foo_1',
                           '  when 2 then call_foo_2',
                           '  when 3 then call_foo_3',
                           '  when 4 then call_foo_4',
                           '  end',
                           'end'])
      # The `case` node plus the first `when` score one complexity point
      # together. The other `when` nodes get 0.2 complexity points.
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [3/1]'])
    end

    it 'registers an offense for a case/when block without an expression ' \
       'after case' do
      inspect_source(cop, ['def method_name',
                           '  case',
                           '  when value == 1',
                           '    call_foo',
                           '  when value == 2',
                           '    call_bar',
                           '  end',
                           'end'])
      # Here, the `case` node doesn't count, but each when scores one
      # complexity point.
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [3/1]'])
    end

    it 'registers an offense for &&' do
      inspect_source(cop, ['def method_name',
                           '  call_foo && call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for and' do
      inspect_source(cop, ['def method_name',
                           '  call_foo and call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for ||' do
      inspect_source(cop, ['def method_name',
                           '  call_foo || call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offense for or' do
      inspect_source(cop, ['def method_name',
                           '  call_foo or call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [2/1]'])
    end

    it 'deals with nested if blocks containing && and ||' do
      inspect_source(cop,
                     ['def method_name',
                      '  if first_condition then',
                      '    call_foo if second_condition && third_condition',
                      '    call_bar if fourth_condition || fifth_condition',
                      '  end',
                      'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [6/1]'])
    end

    it 'counts only a single method' do
      inspect_source(cop, ['def method_name_1',
                           '  call_foo if some_condition',
                           'end',
                           '',
                           'def method_name_2',
                           '  call_foo if some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name_1 is too high. [2/1]',
                'Perceived complexity for method_name_2 is too high. [2/1]'])
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'counts stupid nested if and else blocks' do
      inspect_source(cop, ['def method_name',                   # 1
                           '  if first_condition then',         # 2
                           '    call_foo',
                           '  else',                            # 3
                           '    if second_condition then',      # 4
                           '      call_bar',
                           '    else',                          # 5
                           '      call_bam if third_condition', # 6
                           '    end',
                           '    call_baz if fourth_condition',  # 7
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Perceived complexity for method_name is too high. [7/2]'])
    end
  end
end
