# frozen_string_literal: true

describe RuboCop::Cop::Style::FlipFlop do
  subject(:cop) { described_class.new }

  it 'registers an offense for inclusive flip flops' do
    expect_offense(<<-RUBY.strip_indent)
      DATA.each_line do |line|
      print line if (line =~ /begin/)..(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip flop operators.
      end
    RUBY
  end

  it 'registers an offense for exclusive flip flops' do
    expect_offense(<<-RUBY.strip_indent)
      DATA.each_line do |line|
      print line if (line =~ /begin/)...(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip flop operators.
      end
    RUBY
  end
end
