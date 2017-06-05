# frozen_string_literal: true

describe RuboCop::Cop::Lint::EndInMethod do
  subject(:cop) { described_class.new }

  it 'reports an offense for def with an RUBY inside' do
    src = <<-RUBY.strip_indent
      def test
        END { something }
      end
    RUBY
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs with an RUBY inside' do
    src = <<-RUBY.strip_indent
      def self.test
        END { something }
      end
    RUBY
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts END outside of def(s)' do
    expect_no_offenses('END { something }')
  end
end
