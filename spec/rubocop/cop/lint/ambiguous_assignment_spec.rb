# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousAssignment, :config do
  assignment_targets = %w[x @x @@x $x X obj.foo arr[0] hash[:key] self.foo obj&.foo h[k]].freeze

  described_class::MISTAKES.each_key do |mistake|
    operator = mistake[1]

    assignment_targets.each do |lhs|
      it "registers an offense when using `#{operator}` with `#{lhs}`" do
        expect_offense(<<~RUBY, operator: operator, lhs: lhs)
          %{lhs} =%{operator} y
          _{lhs} ^^{operator} Suspicious assignment detected. Did you mean `%{operator}=`?
        RUBY
      end

      it "does not register an offense when using `#{operator}` correctly with `#{lhs}`" do
        expect_no_offenses(<<~RUBY)
          #{lhs} #{operator}= y
          #{lhs} = #{operator}y
        RUBY
      end
    end
  end
end
