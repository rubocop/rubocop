# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::PossibleAssignmentToNil, :config do
  ['a&.value', '@a&.value', '@@a&.value'].each do |lhs|
    highlighter = '^' * lhs.length
    ['=', '||=', '&&=', '+=', '-=', '*=', '/=', '&='].each do |operator|
      it "registers an offense for `#{lhs}` on the left hand side of an assignment with `#{operator}`" do
        expect_offense(<<~RUBY)
          #{lhs} #{operator} 2
          #{highlighter} The target of the assignment can evaluate to `nil` due to the `&.` operator.
        RUBY
      end
    end
  end

  it 'does not register an offense for an assignment without `&.`' do
    expect_no_offenses(<<~RUBY)
      a.value = 0
    RUBY
  end
end
