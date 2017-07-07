# frozen_string_literal: true

# rubocop:disable Style/FormatStringToken
describe RuboCop::Cop::Lint::FormatParameterMismatch do
  subject(:cop) { described_class.new }

  shared_examples 'variables' do |variable|
    it 'does not register an offense for % called on a variable' do
      inspect_source(<<-RUBY.strip_indent)
        #{variable} = '%s'
        #{variable} % [foo]
      RUBY

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for format called on a variable' do
      inspect_source(<<-RUBY.strip_indent)
        #{variable} = '%s'
        format(#{variable}, foo)
      RUBY

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense for format called on a variable' do
      inspect_source(<<-RUBY.strip_indent)
        #{variable} = '%s'
        sprintf(#{variable}, foo)
      RUBY

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
    inspect_source('Kernel.format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `format` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when calling Kernel.sprintf ' \
     'and the fields do not match' do
    inspect_source('Kernel.sprintf("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `sprintf` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when there are less arguments than expected' do
    inspect_source('format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (1) to `format` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'registers an offense when there are more arguments than expected' do
    inspect_source('format("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `format` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'does not register an offense when arguments and fields match' do
    expect_no_offenses('format("%s %d %i", 1, 2, 3)')
  end

  it 'correctly ignores double percent' do
    expect_no_offenses("format('%s %s %% %s %%%% %%%%%%', 1, 2, 3)")
  end

  it 'constants do not register offenses' do
    expect_no_offenses('format(A_CONST, 1, 2, 3)')
  end

  it 'registers offense with sprintf' do
    inspect_source('sprintf("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `sprintf` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'correctly parses different sprintf formats' do
    expect_no_offenses('sprintf("%020x%+g:% g %%%#20.8x %#.0e", 1, 2, 3, 4, 5)')
  end

  it 'registers an offense for String#%' do
    inspect_source('"%s %s" % [1, 2, 3]')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ["Number of arguments (3) to `String#%` doesn't match the number of " \
       'fields (2).']
    )
  end

  it 'does not register offense for `String#%` when arguments, fields match' do
    expect_no_offenses('"%s %s" % [1, 2]')
  end

  it 'does not register an offense when single argument is a hash' do
    expect_no_offenses('puts "%s" % {"a" => 1}')
  end

  it 'does not register an offense when single argument is not an array' do
    expect_no_offenses('puts "%s" % CONST')
  end

  context 'when splat argument is present' do
    it 'does not register an offense when args count is less than expected' do
      expect_no_offenses('sprintf("%s, %s, %s", 1, *arr)')
    end

    it 'does register an offense when args count is more than expected' do
      inspect_source('puts "%s, %s, %s" % [1, 2, 3, 4, *arr]')
      expect(cop.offenses).not_to be_empty
      inspect_source('format("%s, %s, %s", 1, 2, 3, 4, *arr)')
      expect(cop.offenses).not_to be_empty
      inspect_source('sprintf("%s, %s, %s", 1, 2, 3, 4, *arr)')
      expect(cop.offenses).not_to be_empty
    end
  end

  context 'when multiple arguments are called for' do
    context 'and a single variable argument is passed' do
      it 'does not register an offense' do
        # the variable could evaluate to an array
        expect_no_offenses('puts "%s %s" % var')
      end
    end

    context 'and a single send node is passed' do
      it 'does not register an offense' do
        expect_no_offenses('puts "%s %s" % ("ab".chars)')
      end
    end
  end

  context 'when format is not a string literal' do
    it 'does not register an offense' do
      expect_no_offenses('puts str % [1, 2]')
    end
  end

  # Regression: https://github.com/bbatsov/rubocop/issues/3869
  context 'when passed an empty array' do
    it 'does not register an offense' do
      expect_no_offenses("'%' % []")
    end
  end

  it 'ignores percent right next to format string' do
    expect_no_offenses('format("%0.1f%% percent", 22.5)')
  end

  it 'accepts an extra argument for dynamic width' do
    expect_no_offenses('format("%*d", max_width, id)')
  end

  it 'registers an offense if extra argument for dynamic width not given' do
    inspect_source('format("%*d", id)')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(["Number of arguments (1) to `format` doesn't " \
                                'match the number of fields (2).'])
  end

  it 'accepts an extra arg for dynamic width with other preceding flags' do
    expect_no_offenses('format("%0*x", max_width, id)')
  end

  it 'accepts an extra arg for dynamic width with other following flags' do
    expect_no_offenses('format("%*0x", max_width, id)')
  end

  it 'does not register an offense argument is the result of a message send' do
    expect_no_offenses('format("%s", "a b c".gsub(" ", "_"))')
  end

  it 'does not register an offense when using named parameters' do
    expect_no_offenses('"foo %{bar} baz" % { bar: 42 }')
  end

  it 'identifies correctly digits for spacing in format' do
    expect_no_offenses('"duration: %10.fms" % 42')
  end

  it 'finds faults even when the string looks like a HEREDOC' do
    # heredocs are ignored at the moment
    inspect_source('format("<< %s bleh", 1, 2)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for sprintf with splat argument' do
    expect_no_offenses('sprintf("%d%d", *test)')
  end

  it 'does not register an offense for format with splat argument' do
    expect_no_offenses('format("%d%d", *test)')
  end

  context 'on format with %{} interpolations' do
    context 'and 1 argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%{y}-%{m}-%{d}', params)
        RUBY
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%{y}-%{m}-%{d}', 2015, 1, 1)
               ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (1).
        RUBY
      end
    end
  end

  context 'on format with %<> interpolations' do
    context 'and 1 argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', params)
        RUBY
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', 2015, 1, 1)
               ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (1).
        RUBY
      end
    end
  end

  context 'with wildcard' do
    it 'does not register an offence for width' do
      expect_no_offenses('format("%*d", 10, 3)')
    end

    it 'does not register an offence for precision' do
      expect_no_offenses('format("%.*f", 2, 20.19)')
    end

    it 'does not register an offense for width and precision' do
      expect_no_offenses('format("%*.*f", 10, 3, 20.19)')
    end

    it 'does not register an offense for multiple wildcards' do
      expect_no_offenses('format("%*.*f %*.*f", 10, 2, 20.19, 5, 1, 11.22)')
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
