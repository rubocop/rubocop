# frozen_string_literal: true

describe RuboCop::Cop::Style::DefWithParentheses do
  subject(:cop) { described_class.new }

  it 'reports an offense for def with empty parens' do
    src = <<-END.strip_indent
      def func()
      end
    END
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for class def with empty parens' do
    src = <<-END.strip_indent
      def Test.func()
      end
    END
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts def with arg and parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func(a)
      end
    RUBY
  end

  it 'accepts empty parentheses in one liners' do
    expect_no_offenses("def to_s() join '/' end")
  end

  it 'auto-removes unneeded parens' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def test();
      something
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def test;
      something
      end
    END
  end
end
