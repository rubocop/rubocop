# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ConditionalAssignment, :config do
  shared_examples 'all variable types' do |variable|
    it 'registers an offense assigning any variable type to ternary' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = foo? ? 1 : 2
        ^{variable}^^^^^^^^^^^^^^^ Assign variables inside of conditionals
      RUBY

      expect_correction(<<~RUBY)
        foo? ? #{variable} = 1 : #{variable} = 2
      RUBY
    end

    it 'registers an offense assigning any variable type to if else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = if foo
        ^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        1
                      else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          #{variable} = 1
        else
          #{variable} = 2
        end
      RUBY
    end

    it 'registers an offense assigning any variable type to if elsif else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = if foo
        ^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        1
                      elsif baz
                        2
                      else
                        3
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          #{variable} = 1
        elsif baz
          #{variable} = 2
        else
          #{variable} = 3
        end
      RUBY
    end

    it 'registers an offense assigning any variable type to if else with multiple assignment' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable}, %{variable} = if foo
        ^{variable}^^^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        something
                      else
                        something_else
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          #{variable}, #{variable} = something
        else
          #{variable}, #{variable} = something_else
        end
      RUBY
    end

    it 'allows assignment to if without else' do
      expect_no_offenses(<<~RUBY)
        #{variable} = if foo
                        1
                      end
      RUBY
    end

    it 'registers an offense assigning any variable type to unless else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = unless foo
        ^{variable}^^^^^^^^^^^^^ Assign variables inside of conditionals
                        1
                      else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          #{variable} = 1
        else
          #{variable} = 2
        end
      RUBY
    end

    it 'registers an offense for assigning any variable type to case when' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = case foo
        ^{variable}^^^^^^^^^^^ Assign variables inside of conditionals
                      when "a"
                        1
                      when "b"
                        2
                      else
                        3
                      end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when "a"
          #{variable} = 1
        when "b"
          #{variable} = 2
        else
          #{variable} = 3
        end
      RUBY
    end

    context '>= Ruby 2.7', :ruby27 do
      it 'registers an offense for assigning any variable type to case in' do
        expect_offense(<<~RUBY, variable: variable)
          %{variable} = case foo
          ^{variable}^^^^^^^^^^^ Assign variables inside of conditionals
                        in "a"
                          1
                        in "b"
                          2
                        else
                          3
                        end
        RUBY

        expect_correction(<<~RUBY)
          case foo
          in "a"
            #{variable} = 1
          in "b"
            #{variable} = 2
          else
            #{variable} = 3
          end
        RUBY
      end
    end

    it 'does not crash for rescue assignment' do
      expect_no_offenses(<<~RUBY)
        begin
          foo
        rescue => #{variable}
          bar
        end
      RUBY
    end
  end

  shared_examples 'all assignment types' do |assignment|
    it 'registers an offense for any assignment to ternary' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} (foo? ? 1 : 2)
        ^^^^^{assignment}^^^^^^^^^^^^^^^ Assign variables inside of conditionals
      RUBY

      expect_correction(<<~RUBY)
        foo? ? bar #{assignment} 1 : bar #{assignment} 2
      RUBY
    end

    it 'registers an offense any assignment to if else' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} if foo
        ^^^^^{assignment}^^^^^^^ Assign variables inside of conditionals
                        1
                      else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          bar #{assignment} 1
        else
          bar #{assignment} 2
        end
      RUBY
    end

    it 'allows any assignment to if without else' do
      expect_no_offenses(<<~RUBY)
        bar #{assignment} if foo
                        1
                      end
      RUBY
    end

    it 'registers an offense for any assignment to unless else' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} unless foo
        ^^^^^{assignment}^^^^^^^^^^^ Assign variables inside of conditionals
                        1
                      else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          bar #{assignment} 1
        else
          bar #{assignment} 2
        end
      RUBY
    end

    it 'registers an offense any assignment to case when' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} case foo
        ^^^^^{assignment}^^^^^^^^^ Assign variables inside of conditionals
                      when "a"
                        1
                      else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when "a"
          bar #{assignment} 1
        else
          bar #{assignment} 2
        end
      RUBY
    end

    it 'does not crash when used inside rescue' do
      expect_no_offenses(<<~RUBY)
        begin
          bar #{assignment} 2
        rescue
          bar #{assignment} 1
        end
      RUBY
    end
  end

  shared_examples 'multiline all variable types offense' do |variable|
    it 'assigning any variable type to a multiline if else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = if foo
        ^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          #{variable} = 1
        else
          something_else
          #{variable} = 2
        end
      RUBY
    end

    it 'assigning any variable type to an if else with multiline in one branch' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = if foo
        ^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          #{variable} = 1
        else
          something_else
          #{variable} = 2
        end
      RUBY
    end

    it 'assigning any variable type to a multiline if elsif else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = if foo
        ^{variable}^^^^^^^^^ Assign variables inside of conditionals
                        something
                        1
                      elsif bar
                        something_other
                        2
                      elsif baz
                        something_other_again
                        3
                      else
                        something_else
                        4
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          #{variable} = 1
        elsif bar
          something_other
          #{variable} = 2
        elsif baz
          something_other_again
          #{variable} = 3
        else
          something_else
          #{variable} = 4
        end
      RUBY
    end

    it 'assigning any variable type to a multiline unless else' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = unless foo
        ^{variable}^^^^^^^^^^^^^ Assign variables inside of conditionals
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          something
          #{variable} = 1
        else
          something_else
          #{variable} = 2
        end
      RUBY
    end

    it 'assigning any variable type to a multiline case when' do
      expect_offense(<<~RUBY, variable: variable)
        %{variable} = case foo
        ^{variable}^^^^^^^^^^^ Assign variables inside of conditionals
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when "a"
          something
          #{variable} = 1
        else
          something_else
          #{variable} = 2
        end
      RUBY
    end
  end

  shared_examples 'multiline all variable types allow' do |variable|
    it 'assigning any variable type to a multiline if else' do
      expect_no_offenses(<<~RUBY)
        #{variable} = if foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end

    it 'assigning any variable type to an if else with multiline in one branch' do
      expect_no_offenses(<<~RUBY)
        #{variable} = if foo
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end

    it 'assigning any variable type to a multiline if elsif else' do
      expect_no_offenses(<<~RUBY)
        #{variable} = if foo
                        something
                        1
                      elsif
                        something_other
                        2
                      elsif
                        something_other_again
                        3
                      else
                        something_else
                        4
                      end
      RUBY
    end

    it 'assigning any variable type to a multiline unless else' do
      expect_no_offenses(<<~RUBY)
        #{variable} = unless foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end

    it 'assigning any variable type to a multiline case when' do
      expect_no_offenses(<<~RUBY)
        #{variable} = case foo
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end
  end

  shared_examples 'multiline all assignment types offense' do |assignment|
    it 'any assignment to a multiline if else' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} if foo
        ^^^^^{assignment}^^^^^^^ Assign variables inside of conditionals
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          bar #{assignment} 1
        else
          something_else
          bar #{assignment} 2
        end
      RUBY
    end

    it 'any assignment to a multiline unless else' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} unless foo
        ^^^^^{assignment}^^^^^^^^^^^ Assign variables inside of conditionals
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          something
          bar #{assignment} 1
        else
          something_else
          bar #{assignment} 2
        end
      RUBY
    end

    it 'any assignment to a multiline case when' do
      expect_offense(<<~RUBY, assignment: assignment)
        bar %{assignment} case foo
        ^^^^^{assignment}^^^^^^^^^ Assign variables inside of conditionals
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when "a"
          something
          bar #{assignment} 1
        else
          something_else
          bar #{assignment} 2
        end
      RUBY
    end
  end

  shared_examples 'multiline all assignment types allow' do |assignment|
    it 'any assignment to a multiline if else' do
      expect_no_offenses(<<~RUBY)
        bar #{assignment} if foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end

    it 'any assignment to a multiline unless else' do
      expect_no_offenses(<<~RUBY)
        bar #{assignment} unless foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end

    it 'any assignment to a multiline case when' do
      expect_no_offenses(<<~RUBY)
        bar #{assignment} case foo
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
    end
  end

  shared_examples 'single line condition autocorrect' do
    it 'corrects assignment to an if else condition' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                1
              else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to an if elsif else condition' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                1
              elsif foobar
                2
              else
                3
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          bar = 1
        elsif foobar
          bar = 2
        else
          bar = 3
        end
      RUBY
    end

    it 'corrects assignment to an if elsif else with multiple elsifs' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                1
              elsif foobar
                2
              elsif baz
                3
              else
                4
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          bar = 1
        elsif foobar
          bar = 2
        elsif baz
          bar = 3
        else
          bar = 4
        end
      RUBY
    end

    it 'corrects assignment to an unless else condition' do
      expect_offense(<<~RUBY)
        bar = unless foo
        ^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
                1
              else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else condition' do
      expect_offense(<<~RUBY)
        bar = case foo
        ^^^^^^^^^^^^^^ Assign variables inside of conditionals
              when foobar
                1
              else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when foobar
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else with multiple whens' do
      expect_offense(<<~RUBY)
        bar = case foo
        ^^^^^^^^^^^^^^ Assign variables inside of conditionals
              when foobar
                1
              when baz
                2
              else
                3
              end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when foobar
          bar = 1
        when baz
          bar = 2
        else
          bar = 3
        end
      RUBY
    end

    it 'corrects assignment to a ternary operator' do
      expect_offense(<<~RUBY)
        bar = foo? ? 1 : 2
        ^^^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
      RUBY

      expect_correction(<<~RUBY)
        foo? ? bar = 1 : bar = 2
      RUBY
    end
  end

  context 'SingleLineConditionsOnly true' do
    let(:config) do
      RuboCop::Config.new('Style/ConditionalAssignment' => {
                            'Enabled' => true,
                            'SingleLineConditionsOnly' => true,
                            'IncludeTernaryExpressions' => true,
                            'EnforcedStyle' => 'assign_inside_condition',
                            'SupportedStyles' => %w[assign_to_condition
                                                    assign_inside_condition]
                          },
                          'Layout/EndAlignment' => {
                            'EnforcedStyleAlignWith' => 'keyword',
                            'Enabled' => true
                          },
                          'Layout/LineLength' => {
                            'Max' => 80,
                            'Enabled' => true
                          })
    end

    it_behaves_like('all variable types', 'bar')
    it_behaves_like('all variable types', 'BAR')
    it_behaves_like('all variable types', 'FOO::BAR')
    it_behaves_like('all variable types', '@bar')
    it_behaves_like('all variable types', '@@bar')
    it_behaves_like('all variable types', '$BAR')
    it_behaves_like('all variable types', 'foo.bar')

    it_behaves_like('multiline all variable types allow', 'bar')
    it_behaves_like('multiline all variable types allow', 'BAR')
    it_behaves_like('multiline all variable types allow', 'FOO::BAR')
    it_behaves_like('multiline all variable types allow', '@bar')
    it_behaves_like('multiline all variable types allow', '@@bar')
    it_behaves_like('multiline all variable types allow', '$BAR')
    it_behaves_like('multiline all variable types allow', 'foo.bar')

    it_behaves_like('all assignment types', '=')
    it_behaves_like('all assignment types', '==')
    it_behaves_like('all assignment types', '===')
    it_behaves_like('all assignment types', '+=')
    it_behaves_like('all assignment types', '-=')
    it_behaves_like('all assignment types', '*=')
    it_behaves_like('all assignment types', '**=')
    it_behaves_like('all assignment types', '/=')
    it_behaves_like('all assignment types', '%=')
    it_behaves_like('all assignment types', '^=')
    it_behaves_like('all assignment types', '&=')
    it_behaves_like('all assignment types', '|=')
    it_behaves_like('all assignment types', '<=')
    it_behaves_like('all assignment types', '>=')
    it_behaves_like('all assignment types', '<<=')
    it_behaves_like('all assignment types', '>>=')
    it_behaves_like('all assignment types', '||=')
    it_behaves_like('all assignment types', '&&=')
    it_behaves_like('all assignment types', '<<')

    it_behaves_like('multiline all assignment types allow', '=')
    it_behaves_like('multiline all assignment types allow', '==')
    it_behaves_like('multiline all assignment types allow', '===')
    it_behaves_like('multiline all assignment types allow', '+=')
    it_behaves_like('multiline all assignment types allow', '-=')
    it_behaves_like('multiline all assignment types allow', '*=')
    it_behaves_like('multiline all assignment types allow', '**=')
    it_behaves_like('multiline all assignment types allow', '/=')
    it_behaves_like('multiline all assignment types allow', '%=')
    it_behaves_like('multiline all assignment types allow', '^=')
    it_behaves_like('multiline all assignment types allow', '&=')
    it_behaves_like('multiline all assignment types allow', '|=')
    it_behaves_like('multiline all assignment types allow', '<=')
    it_behaves_like('multiline all assignment types allow', '>=')
    it_behaves_like('multiline all assignment types allow', '<<=')
    it_behaves_like('multiline all assignment types allow', '>>=')
    it_behaves_like('multiline all assignment types allow', '||=')
    it_behaves_like('multiline all assignment types allow', '&&=')
    it_behaves_like('multiline all assignment types allow', '<<')

    it 'allows a method call in the subject of a ternary operator' do
      expect_no_offenses('bar << foo? ? 1 : 2')
    end

    it 'registers an offense for assignment using a method that ends with an equal sign' do
      expect_offense(<<~RUBY)
        self.attributes = foo? ? 1 : 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
      RUBY

      expect_correction(<<~RUBY)
        foo? ? self.attributes = 1 : self.attributes = 2
      RUBY
    end

    it 'registers an offense for assignment using []=' do
      expect_offense(<<~RUBY)
        foo[:a] = if bar?
        ^^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
                    1
                  else
                    2
                  end
      RUBY

      expect_correction(<<~RUBY)
        if bar?
          foo[:a] = 1
        else
          foo[:a] = 2
        end
      RUBY
    end

    it 'registers an offense for assignment to an if then else' do
      expect_offense(<<~RUBY)
        bar = if foo then 1
        ^^^^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
              else 2
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo then bar = 1
        else bar = 2
        end
      RUBY
    end

    it 'registers an offense for assignment to case when then else' do
      expect_offense(<<~RUBY)
        baz = case foo
        ^^^^^^^^^^^^^^ Assign variables inside of conditionals
              when bar then 1
              else 2
              end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when bar then baz = 1
        else baz = 2
        end
      RUBY
    end

    it 'registers an offense when empty `case` condition' do
      expect_offense(<<~RUBY)
        var = case
        ^^^^^^^^^^ Assign variables inside of conditionals
        when foo
          bar
        else
          baz
        end
      RUBY

      expect_correction(<<~RUBY)
        case
        when foo
          var = bar
        else
          var = baz
        end
      RUBY
    end

    context 'for loop' do
      it 'ignores pseudo assignments in a for loop' do
        expect_no_offenses('for i in [1, 2, 3]; puts i; end')
      end
    end

    it_behaves_like('single line condition autocorrect')

    it 'corrects assignment to a namespaced constant' do
      expect_offense(<<~RUBY)
        FOO::BAR = if baz?
        ^^^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
                      1
                    else
                      2
                    end
      RUBY

      expect_correction(<<~RUBY)
        if baz?
          FOO::BAR = 1
        else
          FOO::BAR = 2
        end
      RUBY
    end

    it 'corrects assignment when without `else` branch' do
      expect_offense(<<~RUBY)
        var = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
          bar
        elsif baz
          qux
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          var = bar
        elsif baz
          var = qux
        end
      RUBY
    end
  end

  context 'SingleLineConditionsOnly false' do
    let(:config) do
      RuboCop::Config.new('Style/ConditionalAssignment' => {
                            'Enabled' => true,
                            'SingleLineConditionsOnly' => false,
                            'IncludeTernaryExpressions' => true,
                            'EnforcedStyle' => 'assign_inside_condition',
                            'SupportedStyles' => %w[assign_to_condition
                                                    assign_inside_condition]
                          },
                          'Layout/EndAlignment' => {
                            'EnforcedStyleAlignWith' => 'keyword',
                            'Enabled' => true
                          },
                          'Layout/LineLength' => {
                            'Max' => 80,
                            'Enabled' => true
                          })
    end

    it_behaves_like('all variable types', 'bar')
    it_behaves_like('all variable types', 'BAR')
    it_behaves_like('all variable types', 'FOO::BAR')
    it_behaves_like('all variable types', '@bar')
    it_behaves_like('all variable types', '@@bar')
    it_behaves_like('all variable types', '$BAR')
    it_behaves_like('all variable types', 'foo.bar')

    it_behaves_like('multiline all variable types offense', 'bar')
    it_behaves_like('multiline all variable types offense', 'BAR')
    it_behaves_like('multiline all variable types offense', 'FOO::BAR')
    it_behaves_like('multiline all variable types offense', '@bar')
    it_behaves_like('multiline all variable types offense', '@@bar')
    it_behaves_like('multiline all variable types offense', '$BAR')
    it_behaves_like('multiline all variable types offense', 'foo.bar')

    it_behaves_like('all assignment types', '=')
    it_behaves_like('all assignment types', '==')
    it_behaves_like('all assignment types', '===')
    it_behaves_like('all assignment types', '+=')
    it_behaves_like('all assignment types', '-=')
    it_behaves_like('all assignment types', '*=')
    it_behaves_like('all assignment types', '**=')
    it_behaves_like('all assignment types', '/=')
    it_behaves_like('all assignment types', '%=')
    it_behaves_like('all assignment types', '^=')
    it_behaves_like('all assignment types', '&=')
    it_behaves_like('all assignment types', '|=')
    it_behaves_like('all assignment types', '<=')
    it_behaves_like('all assignment types', '>=')
    it_behaves_like('all assignment types', '<<=')
    it_behaves_like('all assignment types', '>>=')
    it_behaves_like('all assignment types', '||=')
    it_behaves_like('all assignment types', '&&=')
    it_behaves_like('all assignment types', '<<')

    it_behaves_like('multiline all assignment types offense', '=')
    it_behaves_like('multiline all assignment types offense', '==')
    it_behaves_like('multiline all assignment types offense', '===')
    it_behaves_like('multiline all assignment types offense', '+=')
    it_behaves_like('multiline all assignment types offense', '-=')
    it_behaves_like('multiline all assignment types offense', '*=')
    it_behaves_like('multiline all assignment types offense', '**=')
    it_behaves_like('multiline all assignment types offense', '/=')
    it_behaves_like('multiline all assignment types offense', '%=')
    it_behaves_like('multiline all assignment types offense', '^=')
    it_behaves_like('multiline all assignment types offense', '&=')
    it_behaves_like('multiline all assignment types offense', '|=')
    it_behaves_like('multiline all assignment types offense', '<=')
    it_behaves_like('multiline all assignment types offense', '>=')
    it_behaves_like('multiline all assignment types offense', '<<=')
    it_behaves_like('multiline all assignment types offense', '>>=')
    it_behaves_like('multiline all assignment types offense', '||=')
    it_behaves_like('multiline all assignment types offense', '&&=')
    it_behaves_like('multiline all assignment types offense', '<<')

    it_behaves_like('single line condition autocorrect')

    it 'corrects assignment to a multiline if else condition' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                something
                1
              else
                something_else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          bar = 1
        else
          something_else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a multiline if elsif else condition' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                something
                1
              elsif foobar
                something_elsif
                2
              else
                something_else
                3
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          bar = 1
        elsif foobar
          something_elsif
          bar = 2
        else
          something_else
          bar = 3
        end
      RUBY
    end

    it 'corrects assignment to an if elsif else with multiple elsifs' do
      expect_offense(<<~RUBY)
        bar = if foo
        ^^^^^^^^^^^^ Assign variables inside of conditionals
                something
                1
              elsif foobar
                something_elsif1
                2
              elsif baz
                something_elsif2
                3
              else
                something_else
                4
              end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          something
          bar = 1
        elsif foobar
          something_elsif1
          bar = 2
        elsif baz
          something_elsif2
          bar = 3
        else
          something_else
          bar = 4
        end
      RUBY
    end

    it 'corrects assignment to an unless else condition' do
      expect_offense(<<~RUBY)
        bar = unless foo
        ^^^^^^^^^^^^^^^^ Assign variables inside of conditionals
                something
                1
              else
                something_else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
          something
          bar = 1
        else
          something_else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else condition' do
      expect_offense(<<~RUBY)
        bar = case foo
        ^^^^^^^^^^^^^^ Assign variables inside of conditionals
              when foobar
                something
                1
              else
                something_else
                2
              end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when foobar
          something
          bar = 1
        else
          something_else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else with multiple whens' do
      expect_offense(<<~RUBY)
        bar = case foo
        ^^^^^^^^^^^^^^ Assign variables inside of conditionals
              when foobar
                something
                1
              when baz
                something_other
                2
              else
                something_else
                3
              end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when foobar
          something
          bar = 1
        when baz
          something_other
          bar = 2
        else
          something_else
          bar = 3
        end
      RUBY
    end
  end

  context 'IncludeTernaryExpressions false' do
    let(:config) do
      RuboCop::Config.new('Style/ConditionalAssignment' => {
                            'Enabled' => true,
                            'SingleLineConditionsOnly' => true,
                            'IncludeTernaryExpressions' => false,
                            'EnforcedStyle' => 'assign_inside_condition',
                            'SupportedStyles' => %w[assign_to_condition
                                                    assign_inside_condition]
                          },
                          'Layout/EndAlignment' => {
                            'EnforcedStyleAlignWith' => 'keyword',
                            'Enabled' => true
                          },
                          'Layout/LineLength' => {
                            'Max' => 80,
                            'Enabled' => true
                          })
    end

    it 'allows assigning any variable type to ternary' do
      expect_no_offenses('bar = foo? ? 1 : 2')
    end
  end
end
