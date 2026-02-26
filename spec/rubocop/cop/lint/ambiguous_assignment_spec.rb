# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousAssignment, :config do
  RuboCop::Cop::Lint::AmbiguousAssignment::MISTAKES.each_key do |mistake|
    operator = mistake[1]

    %i[x @x @@x $x X].each do |lhs|
      it "registers an offense when using `#{operator}` with `#{lhs}`" do
        expect_offense(<<~RUBY, operator: operator, lhs: lhs)
          %{lhs} =%{operator} y
          _{lhs} ^^{operator} Suspicious assignment detected. Did you mean `%{operator}=`?
        RUBY
      end

      it 'does not register an offense when no mistype assignments' do
        expect_no_offenses(<<~RUBY)
          x #{operator}= y
          x = #{operator}y
        RUBY
      end
    end
  end
end
