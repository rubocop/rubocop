# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FlipFlop, :config do
  it 'registers an offense for inclusive flip-flops' do
    expect_offense(<<~RUBY)
      DATA.each_line do |line|
      print line if (line =~ /begin/)..(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip-flop operators.
      end
    RUBY
  end

  it 'registers an offense for exclusive flip-flops' do
    expect_offense(<<~RUBY)
      DATA.each_line do |line|
      print line if (line =~ /begin/)...(line =~ /end/)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid the use of flip-flop operators.
      end
    RUBY
  end
end
