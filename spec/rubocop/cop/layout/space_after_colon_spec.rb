# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceAfterColon do
  subject(:cop) { described_class.new }

  it 'registers an offense for colon without space after it' do
    expect_offense(<<-RUBY.strip_indent)
      {a:3}
        ^ Space missing after colon.
    RUBY
  end

  it 'accepts colons in symbols' do
    expect_no_offenses('x = :a')
  end

  it 'accepts colon in ternary followed by space' do
    expect_no_offenses('x = w ? a : b')
  end

  it 'accepts hashes with a space after colons' do
    expect_no_offenses('{a: 3}')
  end

  it 'accepts hash rockets' do
    expect_no_offenses('x = {"a"=>1}')
  end

  it 'accepts if' do
    expect_no_offenses(<<-RUBY.strip_indent)
      x = if w
            a
          end
    RUBY
  end

  it 'accepts colons in strings' do
    expect_no_offenses("str << ':'")
  end

  it 'accepts required keyword arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def f(x:, y:)
      end
    RUBY
  end

  if RUBY_VERSION >= '2.1'
    it 'accepts colons denoting required keyword argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def initialize(table:, nodes:)
        end
      RUBY
    end

    it 'registers an offence if an keyword optional argument has no space' do
      expect_offense(<<-RUBY.strip_indent)
        def m(var:1, other_var: 2)
                 ^ Space missing after colon.
        end
      RUBY
    end
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source('def f(a:, b:2); {a:3}; end')
    expect(new_source).to eq('def f(a:, b: 2); {a: 3}; end')
  end
end
