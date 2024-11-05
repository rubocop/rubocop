# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelfAssignment, :config do
  %i[+ - * ** / % ^ << >> | & || &&].product(['x', '@x', '@@x']).each do |op, var|
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

  %i[+ - * ** / % ^ << >> | &].product(['x', '@x', '@@x']).each do |op, var|
    it 'registers an offense and corrects for a method call with parentheses' do
      expect_offense(<<~RUBY, op: op, var: var)
        %{var} = %{var}.%{op}(y)
        ^{var}^^^^{var}^^{op}^^^ Use self-assignment shorthand `#{op}=`.
      RUBY

      expect_correction(<<~RUBY)
        #{var} #{op}= y
      RUBY
    end

    it 'does not register an offense for a method call with multiple parameters' do
      expect_no_offenses(<<~RUBY)
        #{var} = #{var}.#{op}(y, z)
      RUBY
    end
  end
end
