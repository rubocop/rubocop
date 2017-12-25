# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::BinaryOperatorParameterName do
  subject(:cop) { described_class.new }

  %i[+ eql? equal?].each do |op|
    it "registers an offense for #{op} with arg not named other" do
      inspect_source(<<-RUBY.strip_indent)
        def #{op}(another)
          another
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["When defining the `#{op}` operator, " \
                'name its argument `other`.'])
    end
  end

  it 'works properly even if the argument not surrounded with braces' do
    expect_offense(<<-RUBY.strip_indent)
      def + another
            ^^^^^^^ When defining the `+` operator, name its argument `other`.
        another
      end
    RUBY
  end

  it 'does not register an offense for arg named other' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def +(other)
        other
      end
    RUBY
  end

  it 'does not register an offense for arg named _other' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def <=>(_other)
        0
      end
    RUBY
  end

  it 'does not register an offense for []' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def [](index)
        other
      end
    RUBY
  end

  it 'does not register an offense for []=' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def []=(index, value)
        other
      end
    RUBY
  end

  it 'does not register an offense for <<' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def <<(cop)
        other
      end
    RUBY
  end

  it 'does not register an offense for non binary operators' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def -@; end
                    # This + is not a unary operator. It can only be
                    # called with dot notation.
      def +; end
      def *(a, b); end # Quite strange, but legal ruby.
      def `(cmd); end
    RUBY
  end
end
