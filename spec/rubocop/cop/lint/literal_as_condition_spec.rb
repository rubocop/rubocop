# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralAsCondition do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {} :sym :"#{a}").each do |lit|
    it "registers an offense for literal #{lit} in if" do
      inspect_source(<<-RUBY.strip_indent)
        if #{lit}
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in while" do
      inspect_source(<<-RUBY.strip_indent)
        while #{lit}
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in post-loop while" do
      inspect_source(<<-RUBY.strip_indent)
        begin
          top
        end while(#{lit})
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in until" do
      inspect_source(<<-RUBY.strip_indent)
        until #{lit}
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in post-loop until" do
      inspect_source(<<-RUBY.strip_indent)
        begin
          top
        end until #{lit}
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in case" do
      inspect_source(<<-RUBY.strip_indent)
        case #{lit}
        when x then top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in a when " \
       'of a case without anything after case keyword' do
      inspect_source(<<-RUBY.strip_indent)
        case
        when #{lit} then top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "accepts literal #{lit} in a when of a case with " \
       'something after case keyword' do
      inspect_source(<<-RUBY.strip_indent)
        case x
        when #{lit} then top
        end
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it "registers an offense for literal #{lit} in &&" do
      inspect_source(<<-RUBY.strip_indent)
        if x && #{lit}
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in complex cond" do
      inspect_source(<<-RUBY.strip_indent)
        if x && !(a && #{lit}) && y && z
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in !" do
      inspect_source(<<-RUBY.strip_indent)
        if !#{lit}
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in complex !" do
      inspect_source(<<-RUBY.strip_indent)
        if !(x && (y && #{lit}))
          top
        end
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "accepts literal #{lit} if it's not an and/or operand" do
      inspect_source(<<-RUBY.strip_indent)
        if test(#{lit})
          top
        end
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it "accepts literal #{lit} in non-toplevel and/or" do
      inspect_source(<<-RUBY.strip_indent)
        if (a || #{lit}).something
          top
        end
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it "registers an offense for `!#{lit}`" do
      inspect_source(<<-RUBY.strip_indent)
        !#{lit}
      RUBY
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for `not #{lit}`" do
      inspect_source(<<-RUBY.strip_indent)
        not(#{lit})
      RUBY
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts array literal in case, if it has non-literal elements' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case [1, 2, x]
      when [1, 2, 5] then top
      end
    RUBY
  end

  it 'accepts array literal in case, if it has nested non-literal element' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case [1, 2, [x, 1]]
      when [1, 2, 5] then top
      end
    RUBY
  end

  it 'registers an offense for case with a primitive array condition' do
    expect_offense(<<-RUBY.strip_indent)
      case [1, 2, [3, 4]]
           ^^^^^^^^^^^^^^ Literal `[1, 2, [3, 4]]` appeared as a condition.
      when [1, 2, 5] then top
      end
    RUBY
  end

  it 'accepts dstr literal in case' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      case "#{x}"
      when [1, 2, 5] then top
      end
    RUBY
  end
end
