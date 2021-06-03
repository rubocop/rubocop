# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OneLineConditional, :config do
  let(:config) { RuboCop::Config.new(config_data) }
  let(:config_data) { cop_config_data }
  let(:cop_config_data) do
    {
      'Style/OneLineConditional' => {
        'AlwaysCorrectToMultiline' => always_correct_to_multiline
      }
    }
  end
  let(:if_offense_message) do
    'Favor the ternary operator (`?:`) or multi-line constructs over single-line ' \
      '`if/then/else/end` constructs.'
  end
  let(:unless_offense_message) do
    'Favor the ternary operator (`?:`) or multi-line constructs over single-line ' \
      '`unless/then/else/end` constructs.'
  end

  context 'when AlwaysCorrectToMultiline is false' do
    let(:always_correct_to_multiline) { false }

    it 'registers and corrects an offense with ternary operator for if/then/else/end' do
      expect_offense(<<~RUBY)
        if cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        cond ? run : dont
      RUBY
    end

    it 'does not register an offense for if/then/else/end with empty else' do
      expect_no_offenses('if cond then run else end')
    end

    it 'registers and corrects an offense with ternary operator for if/then/else/end when ' \
       '`then` without body' do
      expect_offense(<<~RUBY)
        if cond then else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        cond ? nil : dont
      RUBY
    end

    it 'does not register an offense for if/then/end' do
      expect_no_offenses('if cond then run end')
    end

    it 'registers and corrects an offense with ternary operator for unless/then/else/end' do
      expect_offense(<<~RUBY)
        unless cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{unless_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        cond ? dont : run
      RUBY
    end

    it 'does not register an offense for unless/then/else/end with empty else' do
      expect_no_offenses('unless cond then run else end')
    end

    it 'does not register an offense for unless/then/end' do
      expect_no_offenses('unless cond then run end')
    end

    %w[| ^ & <=> == === =~ > >= < <= << >> + - * / % ** ~ ! != !~ && ||].each do |operator|
      it 'registers and corrects an offense with ternary operator and adding parentheses ' \
         'when if/then/else/end is preceded by an operator' do
        expect_offense(<<~RUBY, operator: operator)
          a %{operator} if cond then run else dont end
            _{operator} ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          a #{operator} (cond ? run : dont)
        RUBY
      end
    end

    shared_examples 'if/then/else/end with constructs changing precedence' do |expr|
      it 'registers and corrects an offense with ternary operator and adding parentheses inside ' \
         "for if/then/else/end with `#{expr}` constructs inside inner branches" do
        expect_offense(<<~RUBY, expr: expr)
          if %{expr} then %{expr} else %{expr} end
          ^^^^{expr}^^^^^^^{expr}^^^^^^^{expr}^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          (#{expr}) ? (#{expr}) : (#{expr})
        RUBY
      end
    end

    it_behaves_like 'if/then/else/end with constructs changing precedence', 'puts 1'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'defined? :A'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'yield a'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'super b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'not a'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a and b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a or b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a = b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a ? b : c'

    it 'registers and corrects an offense with ternary operator and adding parentheses for ' \
       'if/then/else/end that contains method calls with unparenthesized arguments' do
      expect_offense(<<~RUBY)
        if check 1 then run 2 else dont_run 3 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        (check 1) ? (run 2) : (dont_run 3)
      RUBY
    end

    it 'registers and corrects an offense with ternary operator without adding parentheses for ' \
       'if/then/else/end that contains method calls with parenthesized arguments' do
      expect_offense(<<~RUBY)
        if a(0) then puts(1) else yield(2) end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        a(0) ? puts(1) : yield(2)
      RUBY
    end

    it 'registers and corrects an offense with ternary operator without adding parentheses for ' \
       'if/then/else/end that contains unparenthesized operator method calls' do
      expect_offense(<<~RUBY)
        if 0 + 0 then 1 + 1 else 2 + 2 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        0 + 0 ? 1 + 1 : 2 + 2
      RUBY
    end

    shared_examples 'if/then/else/end with keyword' do |keyword|
      it 'registers and corrects an offense with ternary operator when one of the branches of ' \
         "if/then/else/end contains `#{keyword}` keyword" do
        expect_offense(<<~RUBY, keyword: keyword)
          if true then %{keyword} else 7 end
          ^^^^^^^^^^^^^^{keyword}^^^^^^^^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          true ? #{keyword} : 7
        RUBY
      end
    end

    it_behaves_like 'if/then/else/end with keyword', 'retry'
    it_behaves_like 'if/then/else/end with keyword', 'break'
    it_behaves_like 'if/then/else/end with keyword', 'self'
    it_behaves_like 'if/then/else/end with keyword', 'raise'

    it 'registers and corrects an offense with ternary operator when one of the branches of ' \
       'if/then/else/end contains `next` keyword' do
      expect_offense(<<~RUBY)
        map { |line| if line.match(/^\s*#/) || line.strip.empty? then next else line end }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        map { |line| (line.match(/^\s*#/) || line.strip.empty?) ? next : line }
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct for if-then-elsif-then-end' do
      expect_offense(<<~RUBY)
        if cond1 then run elsif cond2 then maybe end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond1
          run
        elsif cond2
          maybe
        end
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct for ' \
       'if-then-elsif-then-else-end' do
      expect_offense(<<~RUBY)
        if cond1 then run elsif cond2 then maybe else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond1
          run
        elsif cond2
          maybe
        else
          dont
        end
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct for ' \
       'if-then-elsif-then-elsif-then-else-end' do
      expect_offense(<<~RUBY)
        if cond1 then run elsif cond2 then maybe elsif cond3 then perhaps else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond1
          run
        elsif cond2
          maybe
        elsif cond3
          perhaps
        else
          dont
        end
      RUBY
    end
  end

  context 'when AlwaysCorrectToMultiline is true' do
    let(:always_correct_to_multiline) { true }

    it 'registers and corrects an offense with multi-line construct for if/then/else/end' do
      expect_offense(<<~RUBY)
        if cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        else
          dont
        end
      RUBY
    end

    it 'does not register an offense for if/then/else/end with empty else' do
      expect_no_offenses('if cond then run else end')
    end

    it 'registers and corrects an offense with multi-line construct for if/then/else/end when ' \
       '`then` without body' do
      expect_offense(<<~RUBY)
        if cond then else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond
          nil
        else
          dont
        end
      RUBY
    end

    it 'does not register an offense for if/then/end' do
      expect_no_offenses('if cond then run end')
    end

    it 'registers and corrects an offense with multi-line construct for unless/then/else/end' do
      expect_offense(<<~RUBY)
        unless cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{unless_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        unless cond
          run
        else
          dont
        end
      RUBY
    end

    it 'does not register an offense for unless/then/else/end with empty else' do
      expect_no_offenses('unless cond then run else end')
    end

    it 'does not register an offense for unless/then/end' do
      expect_no_offenses('unless cond then run end')
    end

    %w[| ^ & <=> == === =~ > >= < <= << >> + - * / % ** ~ ! != !~ && ||].each do |operator|
      it 'registers and corrects an offense with multi-line construct without adding parentheses ' \
         'when if/then/else/end is preceded by an operator' do
        expect_offense(<<~RUBY, operator: operator)
          a %{operator} if cond then run else dont end
            _{operator} ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          a #{operator} if cond
            #{' ' * operator.length}   run
            #{' ' * operator.length} else
            #{' ' * operator.length}   dont
            #{' ' * operator.length} end
        RUBY
      end
    end

    shared_examples 'if/then/else/end with constructs changing precedence' do |expr|
      it 'registers and corrects an offense with multi-line construct without adding ' \
         "parentheses for if/then/else/end with `#{expr}` constructs inside inner branches" do
        expect_offense(<<~RUBY, expr: expr)
          if %{expr} then %{expr} else %{expr} end
          ^^^^{expr}^^^^^^^{expr}^^^^^^^{expr}^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          if #{expr}
            #{expr}
          else
            #{expr}
          end
        RUBY
      end
    end

    it_behaves_like 'if/then/else/end with constructs changing precedence', 'puts 1'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'defined? :A'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'yield a'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'super b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'not a'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a and b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a or b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a = b'
    it_behaves_like 'if/then/else/end with constructs changing precedence', 'a ? b : c'

    it 'registers and corrects an offense with multi-line construct without adding parentheses ' \
       'for if/then/else/end that contains method calls with unparenthesized arguments' do
      expect_offense(<<~RUBY)
        if check 1 then run 2 else dont_run 3 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if check 1
          run 2
        else
          dont_run 3
        end
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct without adding parentheses for ' \
       'if/then/else/end that contains method calls with parenthesized arguments' do
      expect_offense(<<~RUBY)
        if a(0) then puts(1) else yield(2) end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if a(0)
          puts(1)
        else
          yield(2)
        end
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct without adding parentheses for ' \
       'if/then/else/end that contains unparenthesized operator method calls' do
      expect_offense(<<~RUBY)
        if 0 + 0 then 1 + 1 else 2 + 2 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if 0 + 0
          1 + 1
        else
          2 + 2
        end
      RUBY
    end

    shared_examples 'if/then/else/end with keyword' do |keyword|
      it 'registers and corrects an offense with multi-line construct when one of the branches ' \
         "of if/then/else/end contains `#{keyword}` keyword" do
        expect_offense(<<~RUBY, keyword: keyword)
          if true then %{keyword} else 7 end
          ^^^^^^^^^^^^^^{keyword}^^^^^^^^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          if true
            #{keyword}
          else
            7
          end
        RUBY
      end
    end

    it_behaves_like 'if/then/else/end with keyword', 'retry'
    it_behaves_like 'if/then/else/end with keyword', 'break'
    it_behaves_like 'if/then/else/end with keyword', 'self'
    it_behaves_like 'if/then/else/end with keyword', 'raise'

    it 'registers and corrects an offense with multi-line construct when one of the branches of ' \
       'if/then/else/end contains `next` keyword' do
      expect_offense(<<~RUBY)
        map { |line| if line.match(/^\s*#/) || line.strip.empty? then next else line end }
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        map { |line| if line.match(/^\s*#/) || line.strip.empty?
                       next
                     else
                       line
                     end }
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct for ' \
       'if-then-elsif-then-else-end' do
      expect_offense(<<~RUBY)
        if cond1 then run elsif cond2 then maybe else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond1
          run
        elsif cond2
          maybe
        else
          dont
        end
      RUBY
    end

    it 'registers and corrects an offense with multi-line construct for ' \
       'if-then-elsif-then-elsif-then-else-end' do
      expect_offense(<<~RUBY)
        if cond1 then run elsif cond2 then maybe elsif cond3 then perhaps else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
      RUBY

      expect_correction(<<~RUBY)
        if cond1
          run
        elsif cond2
          maybe
        elsif cond3
          perhaps
        else
          dont
        end
      RUBY
    end

    context 'when IndentationWidth differs from default' do
      let(:config_data) { cop_config_data.merge('Layout/IndentationWidth' => { 'Width' => 4 }) }

      it 'registers and corrects an offense with multi-line construct for if/then/else/end' do
        expect_offense(<<~RUBY)
          if cond then run else dont end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{if_offense_message}
        RUBY

        expect_correction(<<~RUBY)
          if cond
              run
          else
              dont
          end
        RUBY
      end
    end
  end
end
