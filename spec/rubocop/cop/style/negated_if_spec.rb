# frozen_string_literal: true

describe RuboCop::Cop::Style::NegatedIf do
  subject(:cop) do
    config = RuboCop::Config.new(
      'Style/NegatedIf' => {
        'SupportedStyles' => %w[both prefix postfix],
        'EnforcedStyle' => 'both'
      }
    )
    described_class.new(config)
  end

  describe 'with “both” style' do
    it 'registers an offense for if with exclamation point condition' do
      inspect_source(cop, <<-END.strip_indent)
        if !a_condition
          some_method
        end
        some_method if !a_condition
      END
      expect(cop.messages).to eq(
        ['Favor `unless` over `if` for negative ' \
         'conditions.'] * 2
      )
    end

    it 'registers an offense for unless with exclamation point condition' do
      inspect_source(cop, <<-END.strip_indent)
        unless !a_condition
          some_method
        end
        some_method unless !a_condition
      END
      expect(cop.messages).to eq(['Favor `if` over `unless` for negative ' \
                                  'conditions.'] * 2)
    end

    it 'registers an offense for if with "not" condition' do
      inspect_source(cop, <<-END.strip_indent)
        if not a_condition
          some_method
        end
        some_method if not a_condition
      END
      expect(cop.messages).to eq(
        ['Favor `unless` over `if` for negative ' \
         'conditions.'] * 2
      )
      expect(cop.offenses.map(&:line)).to eq([1, 4])
    end

    it 'accepts an if/else with negative condition' do
      expect_no_offenses(<<-END.strip_indent)
        if !a_condition
          some_method
        else
          something_else
        end
        if not a_condition
          some_method
        elsif other_condition
          something_else
        end
      END
    end

    it 'accepts an if where only part of the condition is negated' do
      expect_no_offenses(<<-END.strip_indent)
        if !condition && another_condition
          some_method
        end
        if not condition or another_condition
          some_method
        end
        some_method if not condition or another_condition
      END
    end

    it 'accepts an if where the condition is doubly negated' do
      expect_no_offenses(<<-END.strip_indent)
        if !!condition
          some_method
        end
        some_method if !!condition
      END
    end

    it 'is not confused by negated elsif' do
      expect_no_offenses(<<-END.strip_indent)
        if test.is_a?(String)
          3
        elsif test.is_a?(Array)
          2
        elsif !test.nil?
          1
        end
      END
    end

    it 'autocorrects for postfix' do
      corrected = autocorrect_source(cop, 'bar if !foo')

      expect(corrected).to eq 'bar unless foo'
    end

    it 'autocorrects by replacing if not with unless' do
      corrected = autocorrect_source(cop, 'something if !x.even?')
      expect(corrected).to eq 'something unless x.even?'
    end

    it 'autocorrects by replacing parenthesized if not with unless' do
      corrected = autocorrect_source(cop, 'something if (!x.even?)')
      expect(corrected).to eq 'something unless (x.even?)'
    end

    it 'autocorrects by replacing unless not with if' do
      corrected = autocorrect_source(cop, 'something unless !x.even?')
      expect(corrected).to eq 'something if x.even?'
    end

    it 'autocorrects for prefix' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        if !foo
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        unless foo
        end
      END
    end
  end

  describe 'with “prefix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedIf' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'prefix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offence for prefix' do
      inspect_source(cop, <<-END.strip_indent)
        if !foo
        end
      END

      expect(cop.messages).to eq(
        ['Favor `unless` over `if` for negative conditions.']
      )
    end

    it 'does not register an offence for postfix' do
      expect_no_offenses('foo if !bar')
    end

    it 'autocorrects for prefix' do
      corrected = autocorrect_source(cop, <<-END.strip_indent)
        if !foo
        end
      END

      expect(corrected).to eq <<-END.strip_indent
        unless foo
        end
      END
    end
  end

  describe 'with “postfix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedIf' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'postfix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offence for postfix' do
      expect_offense(<<-RUBY.strip_indent)
        foo if !bar
        ^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
      RUBY
    end

    it 'does not register an offence for prefix' do
      expect_no_offenses(<<-END.strip_indent)
        if !foo
        end
      END
    end

    it 'autocorrects for postfix' do
      corrected = autocorrect_source(cop, 'bar if !foo')

      expect(corrected).to eq 'bar unless foo'
    end
  end

  it 'does not blow up for ternary ops' do
    expect_no_offenses('a ? b : c')
  end

  it 'does not blow up on a negated ternary operator' do
    expect_no_offenses('!foo.empty? ? :bar : :baz')
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<-END.strip_indent)
      if ()
      end
    END
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<-END.strip_indent)
      unless ()
      end
    END
  end
end
