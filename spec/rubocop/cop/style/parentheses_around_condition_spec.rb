# frozen_string_literal: true

describe RuboCop::Cop::Style::ParenthesesAroundCondition, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offense for parentheses around condition' do
    inspect_source(<<-RUBY.strip_indent)
      if (x > 10)
      elsif (x < 3)
      end
      unless (x > 10)
      end
      while (x > 10)
      end
      until (x > 10)
      end
      x += 1 if (x < 10)
      x += 1 unless (x < 10)
      x += 1 until (x < 10)
      x += 1 while (x < 10)
    RUBY
    expect(cop.offenses.size).to eq(9)
    expect(cop.messages.first)
      .to eq("Don't use parentheses around the condition of an `if`.")
    expect(cop.messages.last)
      .to eq("Don't use parentheses around the condition of a `while`.")
  end

  it 'accepts parentheses if there is no space between the keyword and (.' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if(x > 5) then something end
      do_something until(x > 5)
    RUBY
  end

  it 'auto-corrects parentheses around condition' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      if (x > 10)
      elsif (x < 3)
      end
      unless (x > 10)
      end
      while (x > 10)
      end
      until (x > 10)
      end
      x += 1 if (x < 10)
      x += 1 unless (x < 10)
      x += 1 while (x < 10)
      x += 1 until (x < 10)
    RUBY
    expect(corrected).to eq <<-RUBY.strip_indent
      if x > 10
      elsif x < 3
      end
      unless x > 10
      end
      while x > 10
      end
      until x > 10
      end
      x += 1 if x < 10
      x += 1 unless x < 10
      x += 1 while x < 10
      x += 1 until x < 10
    RUBY
  end

  it 'accepts condition without parentheses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if x > 10
      end
      unless x > 10
      end
      while x > 10
      end
      until x > 10
      end
      x += 1 if x < 10
      x += 1 unless x < 10
      x += 1 while x < 10
      x += 1 until x < 10
    RUBY
  end

  it 'accepts parentheses around condition in a ternary' do
    expect_no_offenses('(a == 0) ? b : a')
  end

  it 'is not confused by leading parentheses in subexpression' do
    expect_no_offenses('(a > b) && other ? one : two')
  end

  it 'is not confused by unbalanced parentheses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if (a + b).c()
      end
    RUBY
  end

  %w[rescue if unless while until].each do |op|
    it "allows parens if the condition node is a modifier #{op} op" do
      inspect_source(<<-RUBY.strip_indent)
        if (something #{op} top)
        end
      RUBY
      expect(cop.offenses).to be_empty
    end
  end

  it 'does not blow up when the condition is a ternary op' do
    expect_offense(<<-RUBY.strip_indent)
      x if (a ? b : c)
           ^^^^^^^^^^^ Don't use parentheses around the condition of an `if`.
    RUBY
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if ()
      end
    RUBY
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      unless ()
      end
    RUBY
  end

  context 'safe assignment is allowed' do
    it 'accepts variable assignment in condition surrounded with parentheses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if (test = 10)
        end
      RUBY
    end

    it 'accepts element assignment in condition surrounded with parentheses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if (test[0] = 10)
        end
      RUBY
    end

    it 'accepts setter in condition surrounded with parentheses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if (self.test = 10)
        end
      RUBY
    end
  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accept variable assignment in condition surrounded with ' \
       'parentheses' do
      inspect_source(<<-RUBY.strip_indent)
        if (test = 10)
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not accept element assignment in condition surrounded with ' \
       'parentheses' do
      inspect_source(<<-RUBY.strip_indent)
        if (test[0] = 10)
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end
  end
end
