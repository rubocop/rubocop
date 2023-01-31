# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FormatParameterMismatch, :config do
  shared_examples 'variables' do |variable|
    it 'does not register an offense for % called on a variable' do
      expect_no_offenses(<<~RUBY)
        #{variable} = '%s'
        #{variable} % [foo]
      RUBY
    end

    it 'does not register an offense for format called on a variable' do
      expect_no_offenses(<<~RUBY)
        #{variable} = '%s'
        format(#{variable}, foo)
      RUBY
    end

    it 'does not register an offense for format called on a variable' do
      expect_no_offenses(<<~RUBY)
        #{variable} = '%s'
        sprintf(#{variable}, foo)
      RUBY
    end
  end

  it_behaves_like 'variables', 'CONST'
  it_behaves_like 'variables', 'var'
  it_behaves_like 'variables', '@var'
  it_behaves_like 'variables', '@@var'
  it_behaves_like 'variables', '$var'

  it 'registers an offense when calling Kernel.format and the fields do not match' do
    expect_offense(<<~RUBY)
      Kernel.format("%s %s", 1)
             ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
    RUBY
  end

  it 'registers an offense when calling Kernel.sprintf and the fields do not match' do
    expect_offense(<<~RUBY)
      Kernel.sprintf("%s %s", 1)
             ^^^^^^^ Number of arguments (1) to `sprintf` doesn't match the number of fields (2).
    RUBY
  end

  it 'registers an offense when there are less arguments than expected' do
    expect_offense(<<~RUBY)
      format("%s %s", 1)
      ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
    RUBY
  end

  it 'registers an offense when there are no expected format string' do
    expect_offense(<<~RUBY)
      format("something", 1)
      ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (0).
    RUBY
  end

  it 'registers an offense when there are more arguments than expected' do
    expect_offense(<<~RUBY)
      format("%s %s", 1, 2, 3)
      ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (2).
    RUBY
  end

  it 'does not register an offense when arguments and fields match' do
    expect_no_offenses('format("%s %d %i", 1, 2, 3)')
  end

  it 'correctly ignores double percent' do
    expect_no_offenses("format('%s %s %% %s %%%% %%%%%% %%5B', 1, 2, 3)")
  end

  it 'constants do not register offenses' do
    expect_no_offenses('format(A_CONST, 1, 2, 3)')
  end

  it 'registers offense with sprintf' do
    expect_offense(<<~RUBY)
      sprintf("%s %s", 1, 2, 3)
      ^^^^^^^ Number of arguments (3) to `sprintf` doesn't match the number of fields (2).
    RUBY
  end

  it 'correctly parses different sprintf formats' do
    expect_no_offenses('sprintf("%020x%+g:% g %%%#20.8x %#.0e", 1, 2, 3, 4, 5)')
  end

  it 'registers an offense for String#%' do
    expect_offense(<<~RUBY)
      "%s %s" % [1, 2, 3]
              ^ Number of arguments (3) to `String#%` doesn't match the number of fields (2).
    RUBY
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

    context 'when args count is more than expected' do
      it 'registers an offense for `#%`' do
        expect_offense(<<~RUBY)
          puts "%s, %s, %s" % [1, 2, 3, 4, *arr]
                            ^ Number of arguments (5) to `String#%` doesn't match the number of fields (3).
        RUBY
      end

      it 'does not register an offense for `#format`' do
        expect_no_offenses(<<~RUBY)
          puts format("%s, %s, %s", 1, 2, 3, 4, *arr)
        RUBY
      end

      it 'does not register an offense for `#sprintf`' do
        expect_no_offenses(<<~RUBY)
          puts sprintf("%s, %s, %s", 1, 2, 3, 4, *arr)
        RUBY
      end
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

  context 'when using (digit)$ flag' do
    it 'does not register an offense' do
      expect_no_offenses("format('%1$s %2$s', 'foo', 'bar')")
    end

    it 'does not register an offense when match between the maximum value ' \
       'specified by (digit)$ flag and the number of arguments' do
      expect_no_offenses("format('%1$s %1$s', 'foo')")
    end

    it 'registers an offense when mismatch between the maximum value ' \
       'specified by (digit)$ flag and the number of arguments' do
      expect_offense(<<~RUBY)
        format('%1$s %2$s', 'foo', 'bar', 'baz')
        ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (2).
      RUBY
    end
  end

  context 'when format is not a string literal' do
    it 'does not register an offense' do
      expect_no_offenses('puts str % [1, 2]')
    end
  end

  context 'when format is invalid' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        format('%s %2$s', 'foo', 'bar')
        ^^^^^^ Format string is invalid because formatting sequence types (numbered, named or unnumbered) are mixed.
      RUBY
    end
  end

  # Regression: https://github.com/rubocop/rubocop/issues/3869
  context 'when passed an empty array' do
    it 'does not register an offense' do
      expect_no_offenses("'%' % []")
    end
  end

  # Regression: https://github.com/rubocop/rubocop/issues/8115
  context 'when argument itself contains format characters and ' \
          'formats in format string and argument are not equal' do
    it 'ignores argument formatting' do
      expect_no_offenses(%{format('%<t>s', t: '%d')})
    end
  end

  it 'ignores percent right next to format string' do
    expect_no_offenses('format("%0.1f%% percent", 22.5)')
  end

  it 'accepts an extra argument for dynamic width' do
    expect_no_offenses('format("%*d", max_width, id)')
  end

  it 'registers an offense if extra argument for dynamic width not given' do
    expect_offense(<<~RUBY)
      format("%*d", id)
      ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
    RUBY
  end

  it 'accepts an extra arg for dynamic width with other preceding flags' do
    expect_no_offenses('format("%0*x", max_width, id)')
  end

  it 'does not register an offense argument is the result of a message send' do
    expect_no_offenses('format("%s", "a b c".gsub(" ", "_"))')
  end

  it 'does not register an offense when using named parameters' do
    expect_no_offenses('"foo %{bar} baz" % { bar: 42 }')
  end

  it 'does not register an offense when using named parameters with escaped `%`' do
    expect_no_offenses('format("%%%<hex>02X", hex: 10)')
  end

  it 'identifies correctly digits for spacing in format' do
    expect_no_offenses('"duration: %10.fms" % 42')
  end

  it 'finds faults even when the string looks like a HEREDOC' do
    # heredocs are ignored at the moment
    expect_offense(<<~RUBY)
      format("<< %s bleh", 1, 2)
      ^^^^^^ Number of arguments (2) to `format` doesn't match the number of fields (1).
    RUBY
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
        expect_no_offenses(<<~RUBY)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%{y}-%{m}-%{d}', params)
        RUBY
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
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
        expect_no_offenses(<<~RUBY)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', params)
        RUBY
      end
    end

    context 'and multiple arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', 2015, 1, 1)
               ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (1).
        RUBY
      end
    end
  end

  context 'with wildcard' do
    it 'does not register an offense for width' do
      expect_no_offenses('format("%*d", 10, 3)')
    end

    it 'does not register an offense for precision' do
      expect_no_offenses('format("%.*f", 2, 20.19)')
    end

    it 'does not register an offense for width and precision' do
      expect_no_offenses('format("%*.*f", 10, 3, 20.19)')
    end

    it 'does not register an offense for multiple wildcards' do
      expect_no_offenses('format("%*.*f %*.*f", 10, 2, 20.19, 5, 1, 11.22)')
    end
  end

  context 'with interpolated string in format string' do
    it 'registers an offense when the fields do not match' do
      expect_offense(<<~'RUBY')
        format("#{foo} %s %s", "bar")
        ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
      RUBY
    end

    it 'does not register an offense when the fields match' do
      expect_no_offenses('format("#{foo} %s", "bar")')
    end

    it 'does not register an offense when only interpolated string' do
      expect_no_offenses('format("#{foo}", "bar", "baz")')
    end

    it 'does not register an offense when using `Kernel.format` with the interpolated number of decimal places fields match' do
      expect_no_offenses('Kernel.format("%.#{number_of_decimal_places}f", num)')
    end

    it 'registers an offense for String#% when the fields do not match' do
      expect_offense(<<~'RUBY')
        "%s %s" % ["#{foo}", 1, 2]
                ^ Number of arguments (3) to `String#%` doesn't match the number of fields (2).
      RUBY
    end

    it 'does not register an offense for String#% when the fields match' do
      expect_no_offenses('"%s %s" % ["#{foo}", 1]')
    end

    it 'does not register an offense for String#% when only interpolated string' do
      expect_no_offenses('"#{foo}" % [1, 2]')
    end
  end

  context 'with interpolated string in argument' do
    it 'registers an offense when the fields do not match' do
      expect_offense(<<~'RUBY')
        format("%s %s", "#{foo}")
        ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
      RUBY
    end

    it 'does not register an offense when the fields match' do
      expect_no_offenses('format("%s", "#{foo}")')
    end

    it 'registers an offense for String#% when the fields do not match' do
      expect_offense(<<~'RUBY')
        "#{foo} %s %s" % [1, 2, 3]
                       ^ Number of arguments (3) to `String#%` doesn't match the number of fields (2).
      RUBY
    end

    it 'does not register an offense for String#% when the fields match' do
      expect_no_offenses('"#{foo} %s %s" % [1, 2]')
    end
  end
end
