# frozen_string_literal: true

describe RuboCop::Cop::Style::SelfAssignment do
  subject(:cop) { described_class.new }

  %i[+ - * ** / | &].product(['x', '@x', '@@x']).each do |op, var|
    it "registers an offense for non-shorthand assignment #{op} and #{var}" do
      inspect_source("#{var} = #{var} #{op} y")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Use self-assignment shorthand `#{op}=`."])
    end

    it "accepts shorthand assignment for #{op} and #{var}" do
      inspect_source("#{var} #{op}= y")
      expect(cop.offenses).to be_empty
    end

    it "auto-corrects a non-shorthand assignment #{op} and #{var}" do
      new_source = autocorrect_source("#{var} = #{var} #{op} y")
      expect(new_source).to eq("#{var} #{op}= y")
    end
  end

  ['||', '&&'].product(['x', '@x', '@@x']).each do |op, var|
    it "registers an offense for non-shorthand assignment #{op} and #{var}" do
      inspect_source("#{var} = #{var} #{op} y")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Use self-assignment shorthand `#{op}=`."])
    end

    it "accepts shorthand assignment for #{op} and #{var}" do
      inspect_source("#{var} #{op}= y")
      expect(cop.offenses).to be_empty
    end

    it "auto-corrects a non-shorthand assignment #{op} and #{var}" do
      new_source = autocorrect_source("#{var} = #{var} #{op} y")
      expect(new_source).to eq("#{var} #{op}= y")
    end
  end
end
