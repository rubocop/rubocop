# frozen_string_literal: true

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
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `format` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when calling Kernel.sprintf ' \
     'and the fields do not match' do
    inspect_source(cop, 'Kernel.sprintf("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `sprintf` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when there are less arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `format` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when there are more arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `format` doesn't match the number of " \
       'fields (2).']
    )
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
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `sprintf` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'correctly parses different sprintf formats' do
    inspect_source(cop,
                   'sprintf("%020x%+g:% g %%%#20.8x %#.0e", 1, 2, 3, 4, 5)')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for String#%' do
    inspect_source(cop, '"%s %s" % [1, 2, 3]')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `String#%` doesn't match the number of " \
       'fields (2).']
    )
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

  context 'when multiple arguments are called for' do
    context 'and a single variable argument is passed' do
      it 'does not register an offense' do
        # the variable could evaluate to an array
        inspect_source(cop, 'puts "%s %s" % var')
        expect(cop.offenses).to be_empty
      end
    end

    context 'and a single send node is passed' do
      it 'does not register an offense' do
        inspect_source(cop, 'puts "%s %s" % ("ab".chars)')
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when format is not a string literal' do
    it 'does not register an offense' do
      inspect_source(cop, 'puts str % [1, 2]')
      expect(cop.offenses).to be_empty
    end
  end

  it 'ignores percent right next to format string' do
    inspect_source(cop, 'format("%0.1f%% percent", 22.5)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts an extra argument for dynamic width' do
    inspect_source(cop, 'format("%*d", max_width, id)')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense if extra argument for dynamic width not given' do
    inspect_source(cop, 'format("%*d", id)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(["Number of arguments (1) to `format` doesn't " \
                                'match the number of fields (2).'])
  end

  it 'accepts an extra arg for dynamic width with other preceding flags' do
    inspect_source(cop, 'format("%0*x", max_width, id)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts an extra arg for dynamic width with other following flags' do
    inspect_source(cop, 'format("%*0x", max_width, id)')
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

  it 'does not register an offense for sprintf with splat argument' do
    inspect_source(cop, 'sprintf("%d%d", *test)')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for format with splat argument' do
    inspect_source(cop, 'format("%d%d", *test)')
    expect(cop.offenses).to be_empty
  end

  context 'on format with %{} interpolations' do
    context 'and 1 argument' do
      it 'does not register an offense' do
        inspect_source(cop, ["params = { y: '2015', m: '01', d: '01' }",
                             "puts format('%{y}-%{m}-%{d}', params)"])
        expect(cop.offenses).to be_empty
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        inspect_source(cop, ["params = { y: '2015', m: '01', d: '01' }",
                             "puts format('%{y}-%{m}-%{d}', 2015, 1, 1)"])
        expect(cop.messages).to eq(['Number of arguments (3) to `format` ' \
                                    "doesn't match the number of fields (1)."])
      end
    end
  end

  context 'on format with %<> interpolations' do
    context 'and 1 argument' do
      it 'does not register an offense' do
        inspect_source(cop, ["params = { y: '2015', m: '01', d: '01' }",
                             "puts format('%<y>d-%<m>d-%<d>d', params)"])
        expect(cop.offenses).to be_empty
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        inspect_source(cop, ["params = { y: '2015', m: '01', d: '01' }",
                             "puts format('%<y>d-%<m>d-%<d>d', 2015, 1, 1)"])
        expect(cop.messages).to eq(['Number of arguments (3) to `format` ' \
                                    "doesn't match the number of fields (1)."])
      end
    end
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
    expect('%+-d'.scan(described_class::FIELD_REGEX).size) # multiple flags
      .to eq(1)
  end
end
