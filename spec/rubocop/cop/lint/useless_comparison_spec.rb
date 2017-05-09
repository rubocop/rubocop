# frozen_string_literal: true

describe RuboCop::Cop::Lint::UselessComparison do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offense for a simple comparison with #{op}" do
      inspect_source(cop, <<-END.strip_indent)
        5 #{op} 5
        a #{op} a
      END
      expect(cop.offenses.size).to eq(2)
    end

    it "registers an offense for a complex comparison with #{op}" do
      inspect_source(cop, <<-END.strip_indent)
        5 + 10 * 30 #{op} 5 + 10 * 30
        a.top(x) #{op} a.top(x)
      END
      expect(cop.offenses.size).to eq(2)
    end
  end

  it 'works with lambda.()' do
    expect_offense(<<-RUBY.strip_indent)
      a.(x) > a.(x)
            ^ Comparison of something with itself detected.
    RUBY
  end
end
