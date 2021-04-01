# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelfAssignment, :config do
  %i[+ - * ** / | & || &&].product(['x', '@x', '@@x']).each do |op, var|
    it "registers an offense for non-shorthand assignment #{op} and #{var}" do
      expect_offense(<<~RUBY, op: op, var: var)
        %{var} = %{var} %{op} y
        ^{var}^^^^{var}^^{op}^^ Use self-assignment shorthand `#{op}=`.
      RUBY

      expect_correction(<<~RUBY)
        #{var} #{op}= y
      RUBY
    end
  end
end
