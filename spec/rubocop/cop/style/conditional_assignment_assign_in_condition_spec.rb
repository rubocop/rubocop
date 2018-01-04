# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ConditionalAssignment do
  subject(:cop) { described_class.new(config) }

  shared_examples 'all variable types' do |variable|
    it 'registers an offense assigning any variable type to ternary' do
      inspect_source("#{variable} = foo? ? 1 : 2")

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'allows assigning any variable type inside ternary' do
      inspect_source("foo? ? #{variable} = 1 : #{variable} = 2")

      expect(cop.offenses.empty?).to be(true)
    end

    it 'registers an offense assigning any variable type to if else' do
      source = <<-RUBY.strip_indent
        #{variable} = if foo
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense assigning any variable type to if elsif else' do
      source = <<-RUBY.strip_indent
        #{variable} = if foo
                        1
                      elsif baz
                        2
                      else
                        3
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense assigning any variable type to if else' \
      'with multiple assignment' do
      source = <<-RUBY.strip_indent
        #{variable}, #{variable} = if foo
                        something
                      else
                        something_else
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'allows assigning any variable type inside if else' \
      'with multiple assignment' do
      source = <<-RUBY.strip_indent
        if foo
          #{variable}, #{variable} = something
        else
          #{variable}, #{variable} = something_else
        end
      RUBY
      inspect_source(source)

      expect(cop.messages.empty?).to be(true)
    end

    it 'allows assigning any variable type inside if else' do
      source = <<-RUBY.strip_indent
        if foo
          #{variable} = 1
        else
          #{variable} = 2
        end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    it 'allows assignment to if without else' do
      source = <<-RUBY.strip_indent
        #{variable} = if foo
                        1
                      end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    it 'registers an offense assigning any variable type to unless else' do
      source = <<-RUBY.strip_indent
        #{variable} = unless foo
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'allows assigning any variable type inside unless else' do
      source = <<-RUBY.strip_indent
        unless foo
          #{variable} = 1
        else
          #{variable} = 2
        end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    it 'registers an offense for assigning any variable type to case when' do
      source = <<-RUBY.strip_indent
        #{variable} = case foo
                      when "a"
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'allows assigning any variable type inside case when' do
      source = <<-RUBY.strip_indent
        case foo
        when "a"
          #{variable} = 1
        else
          #{variable} = 2
        end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    it 'does not crash for rescue assignment' do
      source = <<-RUBY.strip_indent
        begin
          foo
        rescue => #{variable}
          bar
        end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    context 'auto-correct' do
      it 'corrects assigning any variable type to ternary' do
        new_source = autocorrect_source("#{variable} = foo? ? 1 : 2")

        expect(new_source).to eq("foo? ? #{variable} = 1 : #{variable} = 2")
      end

      it 'corrects assigning any variable type to if elsif else' do
        source = <<-RUBY.strip_indent
          #{variable} = if foo
                          1
                        elsif baz
                          2
                        else
                          3
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          if foo
            #{variable} = 1
          elsif baz
            #{variable} = 2
          else
            #{variable} = 3
          end
        RUBY
      end

      it 'corrects assigning any variable type to unless else' do
        source = <<-RUBY.strip_indent
          #{variable} = unless foo
                          1
                        else
                          2
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          unless foo
            #{variable} = 1
          else
            #{variable} = 2
          end
        RUBY
      end

      it 'corrects assigning any variable type to case when' do
        source = <<-RUBY.strip_indent
          #{variable} = case foo
                        when "a"
                          1
                        when "b"
                          2
                        else
                          3
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
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
    end
  end

  shared_examples 'all assignment types' do |assignment|
    it 'registers an offense for any assignment to ternary' do
      inspect_source("bar #{assignment} (foo? ? 1 : 2)")

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense any assignment to if else' do
      source = <<-RUBY.strip_indent
        bar #{assignment} if foo
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'allows any assignment to if without else' do
      source = <<-RUBY.strip_indent
        bar #{assignment} if foo
                        1
                      end
      RUBY
      inspect_source(source)

      expect(cop.offenses.empty?).to be(true)
    end

    it 'registers an offense for any assignment to unless else' do
      source = <<-RUBY.strip_indent
        bar #{assignment} unless foo
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense any assignment to case when' do
      source = <<-RUBY.strip_indent
        bar #{assignment} case foo
                      when "a"
                        1
                      else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    context 'auto-correct' do
      it 'corrects any assignment to ternary' do
        new_source = autocorrect_source("bar #{assignment} (foo? ? 1 : 2)")

        expect(new_source)
          .to eq("foo? ? bar #{assignment} 1 : bar #{assignment} 2")
      end

      it 'corrects any assignment to if else' do
        source = <<-RUBY.strip_indent
          bar #{assignment} if foo
                          1
                        else
                          2
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          if foo
            bar #{assignment} 1
          else
            bar #{assignment} 2
          end
        RUBY
      end

      it 'corrects any assignment to unless else' do
        source = <<-RUBY.strip_indent
          bar #{assignment} unless foo
                          1
                        else
                          2
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          unless foo
            bar #{assignment} 1
          else
            bar #{assignment} 2
          end
        RUBY
      end

      it 'corrects any assignment to case when' do
        source = <<-RUBY.strip_indent
          bar #{assignment} case foo
                        when "a"
                          1
                        else
                          2
                        end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          case foo
          when "a"
            bar #{assignment} 1
          else
            bar #{assignment} 2
          end
        RUBY
      end
    end
  end

  shared_examples 'multiline all variable types' do |variable, expected|
    it 'assigning any variable type to a multiline if else' do
      source = <<-RUBY.strip_indent
        #{variable} = if foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'assigning any variable type to an if else with multiline ' \
       'in one branch' do
      source = <<-RUBY.strip_indent
        #{variable} = if foo
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'assigning any variable type to a multiline if elsif else' do
      source = <<-RUBY.strip_indent
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
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'assigning any variable type to a multiline unless else' do
      source = <<-RUBY.strip_indent
        #{variable} = unless foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'assigning any variable type to a multiline case when' do
      source = <<-RUBY.strip_indent
        #{variable} = case foo
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end
  end

  shared_examples 'multiline all assignment types' do |assignment, expected|
    it 'any assignment to a multiline if else' do
      source = <<-RUBY.strip_indent
        bar #{assignment} if foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'any assignment to a multiline unless else' do
      source = <<-RUBY.strip_indent
        bar #{assignment} unless foo
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end

    it 'any assignment to a multiline case when' do
      source = <<-RUBY.strip_indent
        bar #{assignment} case foo
                      when "a"
                        something
                        1
                      else
                        something_else
                        2
                      end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq(expected)
    end
  end

  shared_examples 'single line condition auto-correct' do
    it 'corrects assignment to an if else condition' do
      source = <<-RUBY.strip_indent
        bar = if foo
                1
              else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        if foo
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to an if elsif else condition' do
      source = <<-RUBY.strip_indent
        bar = if foo
                1
              elsif foobar
                2
              else
                3
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = if foo
                1
              elsif foobar
                2
              elsif baz
                3
              else
                4
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = unless foo
                1
              else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        unless foo
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else condition' do
      source = <<-RUBY.strip_indent
        bar = case foo
              when foobar
                1
              else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
        case foo
        when foobar
          bar = 1
        else
          bar = 2
        end
      RUBY
    end

    it 'corrects assignment to a case when else with multiple whens' do
      source = <<-RUBY.strip_indent
        bar = case foo
              when foobar
                1
              when baz
                2
              else
                3
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      new_source = autocorrect_source('bar = foo? ? 1 : 2')

      expect(new_source).to eq('foo? ? bar = 1 : bar = 2')
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
                          'Metrics/LineLength' => {
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

    it_behaves_like('multiline all variable types', 'bar', [])
    it_behaves_like('multiline all variable types', 'BAR', [])
    it_behaves_like('multiline all variable types', 'FOO::BAR', [])
    it_behaves_like('multiline all variable types', '@bar', [])
    it_behaves_like('multiline all variable types', '@@bar', [])
    it_behaves_like('multiline all variable types', '$BAR', [])
    it_behaves_like('multiline all variable types', 'foo.bar', [])

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
    it_behaves_like('all assignment types', '+=')
    it_behaves_like('all assignment types', '-=')
    it_behaves_like('all assignment types', '<<')

    it_behaves_like('multiline all assignment types', '=', [])
    it_behaves_like('multiline all assignment types', '==', [])
    it_behaves_like('multiline all assignment types', '===', [])
    it_behaves_like('multiline all assignment types', '+=', [])
    it_behaves_like('multiline all assignment types', '-=', [])
    it_behaves_like('multiline all assignment types', '*=', [])
    it_behaves_like('multiline all assignment types', '**=', [])
    it_behaves_like('multiline all assignment types', '/=', [])
    it_behaves_like('multiline all assignment types', '%=', [])
    it_behaves_like('multiline all assignment types', '^=', [])
    it_behaves_like('multiline all assignment types', '&=', [])
    it_behaves_like('multiline all assignment types', '|=', [])
    it_behaves_like('multiline all assignment types', '<=', [])
    it_behaves_like('multiline all assignment types', '>=', [])
    it_behaves_like('multiline all assignment types', '<<=', [])
    it_behaves_like('multiline all assignment types', '>>=', [])
    it_behaves_like('multiline all assignment types', '||=', [])
    it_behaves_like('multiline all assignment types', '&&=', [])
    it_behaves_like('multiline all assignment types', '+=', [])
    it_behaves_like('multiline all assignment types', '-=', [])
    it_behaves_like('multiline all assignment types', '<<', [])

    it 'allows a method call in the subject of a ternary operator' do
      expect_no_offenses('bar << foo? ? 1 : 2')
    end

    it 'registers an offense for assignment using a method that ends with ' \
       'an equal sign' do
      inspect_source('self.attributes = foo? ? 1 : 2')

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense for assignment using []=' do
      source = <<-RUBY.strip_indent
        foo[:a] = if bar?
                    1
                  else
                    2
                  end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense for assignment to an if then else' do
      source = <<-RUBY.strip_indent
        bar = if foo then 1
              else 2
              end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    it 'registers an offense for assignment to case when then else' do
      source = <<-RUBY.strip_indent
        baz = case foo
              when bar then 1
              else 2
              end
      RUBY
      inspect_source(source)

      expect(cop.messages).to eq([described_class::ASSIGN_TO_CONDITION_MSG])
    end

    context 'for loop' do
      it 'ignores pseudo assignments in a for loop' do
        expect_no_offenses('for i in [1, 2, 3]; puts i; end')
      end
    end

    context 'auto-correct' do
      it_behaves_like('single line condition auto-correct')

      it 'corrects assignment to an if then else' do
        source = <<-RUBY.strip_indent
          bar = if foo then 1
                else 2
                end
        RUBY

        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          if foo then bar = 1
          else bar = 2
          end
        RUBY
      end

      it 'corrects assignment to case when then else' do
        source = <<-RUBY.strip_indent
          baz = case foo
                when bar then 1
                else 2
                end
        RUBY

        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          case foo
          when bar then baz = 1
          else baz = 2
          end
        RUBY
      end

      it 'corrects assignment using a method that ends with an equal sign' do
        new_source = autocorrect_source('self.attributes = foo? ? 1 : 2')

        expect(new_source)
          .to eq('foo? ? self.attributes = 1 : self.attributes = 2')
      end

      it 'corrects assignment using []=' do
        source = <<-RUBY.strip_indent
          foo[:a] = if bar?
                      1
                    else
                      2
                    end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          if bar?
            foo[:a] = 1
          else
            foo[:a] = 2
          end
        RUBY
      end

      it 'corrects assignment to a namespaced constant' do
        source = <<-RUBY.strip_indent
          FOO::BAR = if baz?
                       1
                     else
                       2
                     end
        RUBY
        new_source = autocorrect_source(source)

        expect(new_source).to eq(<<-RUBY.strip_indent)
          if baz?
            FOO::BAR = 1
          else
            FOO::BAR = 2
          end
        RUBY
      end
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
                          'Metrics/LineLength' => {
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

    it_behaves_like('multiline all variable types', 'bar',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', 'BAR',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', 'FOO::BAR',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', '@bar',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', '@@bar',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', '$BAR',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all variable types', 'foo.bar',
                    [described_class::ASSIGN_TO_CONDITION_MSG])

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
    it_behaves_like('all assignment types', '+=')
    it_behaves_like('all assignment types', '-=')
    it_behaves_like('all assignment types', '<<')

    it_behaves_like('multiline all assignment types', '=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '==',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '===',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '+=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '-=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '*=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '**=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '/=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '%=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '^=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '&=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '|=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '<=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '>=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '<<=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '>>=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '||=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '&&=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '+=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '-=',
                    [described_class::ASSIGN_TO_CONDITION_MSG])
    it_behaves_like('multiline all assignment types', '<<',
                    [described_class::ASSIGN_TO_CONDITION_MSG])

    it_behaves_like('single line condition auto-correct')

    it 'corrects assignment to a multiline if else condition' do
      source = <<-RUBY.strip_indent
        bar = if foo
                something
                1
              else
                something_else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = if foo
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
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = if foo
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
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = unless foo
                something
                1
              else
                something_else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = case foo
              when foobar
                something
                1
              else
                something_else
                2
              end
      RUBY
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
      source = <<-RUBY.strip_indent
        bar = case foo
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
      new_source = autocorrect_source(source)

      expect(new_source).to eq(<<-RUBY.strip_indent)
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
                          'Metrics/LineLength' => {
                            'Max' => 80,
                            'Enabled' => true
                          })
    end

    it 'allows assigning any variable type to ternary' do
      expect_no_offenses('bar = foo? ? 1 : 2')
    end
  end
end
