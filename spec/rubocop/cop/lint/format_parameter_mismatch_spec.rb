# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::FormatParameterMismatch do
  subject(:cop) { described_class.new }

  shared_examples 'variables' do |variable|
    it 'does not register an offense for % called on a variable' do
      inspect_source(cop, ["#{variable} = '%s'",
                           "#{variable} % [foo]"])

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for format called on a variable' do
      inspect_source(cop, ["#{variable} = '%s'",
                           "format(#{variable}, foo)"])

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for format called on a variable' do
      inspect_source(cop, ["#{variable} = '%s'",
                           "sprintf(#{variable}, foo)"])

      expect(cop.messages).to be_empty
    end
  end

  it_behaves_like 'variables', 'CONST'
  it_behaves_like 'variables', 'var'
  it_behaves_like 'variables', '@var'
  it_behaves_like 'variables', '@@var'
  it_behaves_like 'variables', '$var'

  it 'registers an offense when calling Kernel.format ' \
     'and the fields do not match' do
    inspect_source(cop, 'Kernel.format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (1) to `format` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'registers an offense when calling Kernel.sprintf ' \
     'and the fields do not match' do
    inspect_source(cop, 'Kernel.sprintf("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (1) to `sprintf` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'registers an offense when there are less arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (1) to `format` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'registers an offense when there are more arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)

    msgs = ['Number arguments (3) to `format` mismatches expected fields (2).']
    expect(cop.messages)
      .to eq(msgs)
  end

  it 'does not register an offense when arguments and fields match' do
    inspect_source(cop, 'format("%s %d %i", 1, 2, 3)')
    expect(cop.offenses).to be_empty
  end

  it 'correctly ignores double percent' do
    inspect_source(cop, "format('%s %s %% %s %%%% %%%%%%', 1, 2, 3)")
    expect(cop.offenses).to be_empty
  end

  it 'constants do not register offenses' do
    inspect_source(cop, 'format(A_CONST, 1, 2, 3)')
    expect(cop.offenses).to be_empty
  end

  it 'registers offense with sprintf' do
    inspect_source(cop, 'sprintf("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (3) to `sprintf` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'correctly parses different sprintf formats' do
    inspect_source(cop,
                   'sprintf("%020x%+g:% g %%%#20.8x %#.0e", 1, 2, 3, 4, 5)')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for String#%' do
    inspect_source(cop, '"%s %s" % [1, 2, 3]')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (3) to `String#%` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'does not register offense for `String#%` when arguments, fields match' do
    inspect_source(cop, '"%s %s" % [1, 2]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense when single argument is a hash' do
    inspect_source(cop, 'puts "%s" % {"a" => 1}')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense when single argument is not an array' do
    inspect_source(cop, 'puts "%s" % 42')
    expect(cop.offenses).to be_empty

    inspect_source(cop, 'puts "%s" % "1"')
    expect(cop.offenses).to be_empty

    inspect_source(cop, 'puts "%s" % 1.2')
    expect(cop.offenses).to be_empty

    inspect_source(cop, 'puts "%s" % :a')
    expect(cop.offenses).to be_empty

    inspect_source(cop, 'puts "%s" % CONST')
    expect(cop.offenses).to be_empty
  end

  it 'ignores percent right next to format string' do
    inspect_source(cop, 'format("%0.1f%% percent", 22.5)')
    expect(cop.offenses).to be_empty
  end

  it 'ignores dynamic widths' do
    inspect_source(cop, 'format("%*d", max_width, id)')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense argument is the result of a message send' do
    inspect_source(cop, '"%s" % "a b c".gsub(" ", "_")')
    expect(cop.offenses).to be_empty

    inspect_source(cop, 'format("%s", "a b c".gsub(" ", "_"))')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense when using named parameters' do
    inspect_source(cop, '"foo %{bar} baz" % { bar: 42 }')
    expect(cop.offenses).to be_empty
  end

  it 'identifies correctly digits for spacing in format' do
    inspect_source(cop, '"duration: %10.fms" % 42')
    expect(cop.offenses).to be_empty
  end

  it 'finds faults even when the string looks like a HEREDOC' do
    # heredocs are ignored at the moment
    inspect_source(cop, 'format("<< %s bleh", 1, 2)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'finds the correct number of fields' do
    expect(''.scan(described_class::FIELD_REGEX).size)
      .to eq(0)
    expect('%s'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%s %s'.scan(described_class::FIELD_REGEX).size)
      .to eq(2)
    expect('%s %s %%'.scan(described_class::FIELD_REGEX).size)
      .to eq(3)
    expect('%s %s %%'.scan(described_class::FIELD_REGEX).size)
      .to eq(3)
    expect('% d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%+d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%+o'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%#o'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%.0e'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%#.0e'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('% 020d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%20d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%+20d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%020d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%+020d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('% 020d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%-20d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%-+20d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%- 20d'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%020x'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%#20.8x'.scan(described_class::FIELD_REGEX).size)
      .to eq(1)
    expect('%+g:% g:%-g'.scan(described_class::FIELD_REGEX).size)
      .to eq(3)
  end
end
