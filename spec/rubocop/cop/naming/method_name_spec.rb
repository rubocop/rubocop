# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MethodName, :config do
  shared_examples 'never accepted' do |enforced_style|
    it 'registers an offense for mixed snake case and camel case in attr.' do
      expect_offense(<<~RUBY)
        attr :visit_Arel_Nodes_SelectStatement
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :visit_Arel_Nodes_SelectStatement
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_writer :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr 'visit_Arel_Nodes_SelectStatement'
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for mixed snake case and camel case in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :visit_Arel_Nodes_SelectStatement
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader 'visit_Arel_Nodes_SelectStatement'
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for mixed snake case and camel case' do
      expect_offense(<<~RUBY)
        def visit_Arel_Nodes_SelectStatement
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
        end
      RUBY
    end

    it 'registers an offense for capitalized camel case name in attr.' do
      expect_offense(<<~RUBY)
        attr :MyMethod
             ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :MyMethod
                    ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :MyMethod
                      ^^^^^^^^^ Use #{enforced_style} for method names.

        attr_writer :MyMethod
                    ^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end

    it 'registers an offense for capitalized camel case' do
      expect_offense(<<~RUBY)
        class MyClass
          def MyMethod
              ^^^^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for singleton upper case method without corresponding class' do
      expect_offense(<<~RUBY)
        module Sequel
          def self.Model(source)
                   ^^^^^ Use #{enforced_style} for method names.
          end
        end
      RUBY
    end
  end

  shared_examples 'always accepted' do |enforced_style|
    it 'accepts one line methods' do
      expect_no_offenses("def body; '' end")
    end

    it 'accepts operator definitions' do
      expect_no_offenses(<<~RUBY)
        def +(other)
          # ...
        end
      RUBY
    end

    it 'accepts unary operator definitions' do
      expect_no_offenses(<<~RUBY)
        def ~@; end
      RUBY

      expect_no_offenses(<<~RUBY)
        def !@; end
      RUBY
    end

    it 'accepts `alias_method` with non-intern first argument' do
      expect_no_offenses(<<~RUBY)
        alias_method foo, :bar
        alias_method fooBar, :bar
      RUBY
    end

    it 'accepts `alias_method` with array splat' do
      expect_no_offenses(<<~RUBY)
        alias_method *ary
      RUBY
    end

    it 'accepts `alias_method` with unexpected arity' do
      expect_no_offenses(<<~RUBY)
        alias_method :foo, :bar, :baz
        alias_method :fooBar, :bar, :baz
      RUBY
    end

    %w[class module].each do |kind|
      it "accepts class emitter method in a #{kind}" do
        expect_no_offenses(<<~RUBY)
          #{kind} Sequel
            def self.Model(source)
            end

            class Model
            end
          end
        RUBY
      end

      it "accepts class emitter method in a #{kind}, even when it is " \
         'defined inside another method' do
        expect_no_offenses(<<~RUBY)
          module DPN
            module Flow
              module BaseFlow
                class Start
                end
                def self.included(base)
                  def base.Start(aws_env, *args)
                  end
                end
              end
            end
          end
        RUBY
      end
    end

    %w[Struct ::Struct].each do |class_name|
      it "does not register an offense for member-less #{class_name}" do
        expect_no_offenses(<<~RUBY)
          #{class_name}.new()
        RUBY
      end
    end

    %i[define_method define_singleton_method].each do |name|
      %w[== >= <= > < =~ ! [] []= gärten].each do |method_name|
        it "does not register an offense when `#{name}` is called with a `#{method_name}` method name" do
          expect_no_offenses(<<~RUBY)
            #{name} :#{method_name} do
            end
          RUBY
        end
      end
    end

    context 'when specifying `AllowedPatterns`' do
      let(:cop_config) do
        {
          'EnforcedStyle' => enforced_style,
          'AllowedPatterns' => [
            '\AonSelectionBulkChange\z',
            '\Aon_selection_cleared\z'
          ]
        }
      end

      it 'does not register an offense for camel case method name in attr.' do
        expect_no_offenses(<<~RUBY)
          attr_reader :onSelectionBulkChange
          attr_accessor :onSelectionBulkChange
          attr_writer :onSelectionBulkChange
        RUBY
      end

      it 'does not register an offense for camel case method name matching `AllowedPatterns`' do
        expect_no_offenses(<<~RUBY)
          def onSelectionBulkChange(arg)
          end
        RUBY
      end

      it 'does not register an offense for snake case method name in attr.' do
        expect_no_offenses(<<~RUBY)
          attr_reader :on_selection_cleared
          attr_accessor :on_selection_cleared
          attr_writer :on_selection_cleared
        RUBY
      end

      it 'does not register an offense for snake case method name matching `AllowedPatterns`' do
        expect_no_offenses(<<~RUBY)
          def on_selection_cleared(arg)
          end
        RUBY
      end
    end
  end

  shared_examples 'multiple attr methods' do |enforced_style|
    it 'registers an offense for camel case methods names in attr.' do
      expect_offense(<<~RUBY)
        attr :my_method, :myMethod
             ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_reader :my_method, :myMethod
                    ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor :myMethod, :my_method
                      ^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.

        attr_accessor 'myMethod', 'my_method'
                      ^^^^^^^^^^^^^^^^^^^^^^^ Use #{enforced_style} for method names.
      RUBY
    end
  end

  shared_examples 'forbidden identifiers' do |identifier|
    context 'when ForbiddenIdentifiers is set' do
      let(:cop_config) { super().merge('ForbiddenIdentifiers' => [identifier]) }

      context 'for multi-line method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def %{identifier}
                ^{identifier} `%{identifier}` is forbidden, use another method name instead.
              true
            end
          RUBY

          expect_no_corrections
        end
      end

      context 'for single-line method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def %{identifier}; true; end
                ^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for class method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def self.%{identifier}
                     ^{identifier} `%{identifier}` is forbidden, use another method name instead.
            end
          RUBY

          expect_no_corrections
        end
      end

      context 'for singleton method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def foo.%{identifier}
                    ^{identifier} `%{identifier}` is forbidden, use another method name instead.
            end
          RUBY

          expect_no_corrections
        end
      end

      context 'for attr methods' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            attr_reader :#{identifier}
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
            attr_writer :#{identifier}
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
            attr_accessor :#{identifier}
                          ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for define_method' do
        it 'registers an offense when method with forbidden name is defined using `define_method`' do
          expect_offense(<<~RUBY, identifier: identifier)
            define_method :%{identifier}
                          ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY
        end

        it 'registers an offense when method with forbidden name is defined using `define_singleton_method`' do
          expect_offense(<<~RUBY, identifier: identifier)
            define_singleton_method :%{identifier}
                                    ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY
        end
      end

      context 'for `Struct` members' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            Struct.new(:%{identifier})
                       ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `Data` members' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            Data.define(:%{identifier})
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `alias` arguments' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            alias %{identifier} foo
                  ^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `alias_method` arguments' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            alias_method :%{identifier}, :foo
                         ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  shared_examples 'forbidden patterns' do |pattern, identifier|
    context 'when ForbiddenIdentifiers is set' do
      let(:cop_config) { super().merge('ForbiddenPatterns' => [pattern]) }

      context 'for multi-line method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def %{identifier}
                ^{identifier} `%{identifier}` is forbidden, use another method name instead.
              true
            end
          RUBY

          expect_no_corrections
        end
      end

      context 'for single-line method definition' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            def %{identifier}; true; end
                ^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for attr methods' do
        it 'registers an offense when method with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            attr_reader :#{identifier}
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
            attr_writer :#{identifier}
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
            attr_accessor :#{identifier}
                          ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for define_method' do
        it 'registers an offense when method with forbidden name is defined using `define_method`' do
          expect_offense(<<~RUBY, identifier: identifier)
            define_method :%{identifier}
                          ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY
        end

        it 'registers an offense when method with forbidden name is defined using `define_singleton_method`' do
          expect_offense(<<~RUBY, identifier: identifier)
            define_singleton_method :%{identifier}
                                    ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY
        end
      end

      context 'for `Struct` members' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            Struct.new(:%{identifier})
                       ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `Data` members' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            Data.define(:%{identifier})
                        ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `alias` arguments' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            alias %{identifier} foo
                  ^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end

      context 'for `alias_method` arguments' do
        it 'registers an offense when member with forbidden name is defined' do
          expect_offense(<<~RUBY, identifier: identifier)
            alias_method :%{identifier}, :foo
                         ^^{identifier} `%{identifier}` is forbidden, use another method name instead.
          RUBY

          expect_no_corrections
        end
      end
    end
  end

  shared_examples 'define_method method call' do |enforced_style, identifier|
    %i[define_method define_singleton_method].each do |name|
      it 'registers an offense when method name is passed as a symbol' do
        expect_offense(<<~RUBY, name: name, enforced_style: enforced_style, identifier: identifier)
          %{name} :%{identifier} do
          _{name} ^^{identifier} Use %{enforced_style} for method names.
          end
        RUBY
      end

      it 'registers an offense when method name is passed as a string' do
        expect_offense(<<~RUBY, name: name, enforced_style: enforced_style, identifier: identifier)
          %{name} '%{identifier}' do
          _{name} ^^{identifier}^ Use %{enforced_style} for method names.
          end
        RUBY
      end

      it 'does not register an offense when `define_method` is called without any arguments`' do
        expect_no_offenses(<<~RUBY)
          #{name} do
          end
        RUBY
      end

      it 'does not register an offense when `define_method` is called with a variable`' do
        expect_no_offenses(<<~RUBY)
          #{name} foo do
          end
        RUBY
      end

      it 'does not register an offense when an operator method is defined using a string' do
        expect_no_offenses(<<~RUBY)
          #{name} '`' do
          end
        RUBY
      end
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case method names in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :myMethod
                    ^^^^^^^^^ Use snake_case for method names.

        attr_accessor :myMethod
                      ^^^^^^^^^ Use snake_case for method names.

        attr_writer :myMethod
                    ^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for camel case in instance method name' do
      expect_offense(<<~RUBY)
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<~RUBY)
        def my_method
        end
        def myMethod
            ^^^^^^^^ Use snake_case for method names.
        end
      RUBY
    end

    it 'registers an offense for camel case in singleton method name' do
      expect_offense(<<~RUBY)
        def self.myMethod
                 ^^^^^^^^ Use snake_case for method names.
          # ...
        end
      RUBY
    end

    it 'accepts snake case in attr.' do
      expect_no_offenses(<<~RUBY)
        attr_reader :my_method
        attr_accessor :my_method
        attr_writer :my_method
      RUBY
    end

    it 'accepts snake case in names' do
      expect_no_offenses(<<~RUBY)
        def my_method
        end
      RUBY
    end

    it 'registers an offense for singleton camelCase method within class' do
      expect_offense(<<~RUBY)
        class Sequel
          def self.fooBar
                   ^^^^^^ Use snake_case for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for `Struct` camelCase member' do
      expect_offense(<<~RUBY)
        Struct.new("camelCase", :snake_case, var, *args, :camelCase, :snake_case_2, "camelCase2")
                                                         ^^^^^^^^^^ Use snake_case for method names.
                                                                                    ^^^^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for `::Struct` camelCase member' do
      expect_offense(<<~RUBY)
        ::Struct.new("camelCase", :snake_case, var, *args, :camelCase, :snake_case_2, "camelCase2")
                                                           ^^^^^^^^^^ Use snake_case for method names.
                                                                                      ^^^^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for `Data` camelCase member' do
      expect_offense(<<~RUBY)
        Data.define(:snake_case, var, *args, :camelCase, :snake_case_2, "camelCase2")
                                             ^^^^^^^^^^ Use snake_case for method names.
                                                                        ^^^^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for `::Data` camelCase member' do
      expect_offense(<<~RUBY)
        ::Data.define(:snake_case, var, *args, :camelCase, :snake_case_2, "camelCase2")
                                               ^^^^^^^^^^ Use snake_case for method names.
                                                                          ^^^^^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for `alias` camelCase argument' do
      expect_offense(<<~RUBY)
        alias fooBar foo
              ^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'registers an offense for `alias_method` camelCase argument' do
      expect_offense(<<~RUBY)
        alias_method :fooBar, :foo
                     ^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'accepts `alias` with interpolated symbol argument' do
      expect_no_offenses(<<~'RUBY')
        alias :"foo#{bar}" :baz
      RUBY
    end

    it 'registers an offense for `alias_method` snake_case string argument' do
      expect_offense(<<~RUBY)
        alias_method "fooBar", "foo"
                     ^^^^^^^^ Use snake_case for method names.
      RUBY
    end

    it 'accepts `alias_method` with interpolated string argument' do
      expect_no_offenses(<<~'RUBY')
        alias_method "foo#{bar}", "baz"
      RUBY
    end

    it_behaves_like 'never accepted',  'snake_case'
    it_behaves_like 'always accepted', 'snake_case'
    it_behaves_like 'multiple attr methods', 'snake_case'
    it_behaves_like 'forbidden identifiers', 'super'
    it_behaves_like 'forbidden patterns', '_v1\z', 'api_v1'
    it_behaves_like 'define_method method call', 'snake_case', 'fooBar'
    it_behaves_like 'define_method method call', 'snake_case', 'fooBar?'
    it_behaves_like 'define_method method call', 'snake_case', 'fooBar!'
    it_behaves_like 'define_method method call', 'snake_case', 'fooBar='
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'accepts camel case names in attr.' do
      expect_no_offenses(<<~RUBY)
        attr_reader :myMethod
        attr_accessor :myMethod
        attr_writer :myMethod
      RUBY
    end

    it 'accepts camel case in instance method name' do
      expect_no_offenses(<<~RUBY)
        def myMethod
          # ...
        end
      RUBY
    end

    it 'accepts camel case in singleton method name' do
      expect_no_offenses(<<~RUBY)
        def self.myMethod
          # ...
        end
      RUBY
    end

    it 'registers an offense for snake case name in attr.' do
      expect_offense(<<~RUBY)
        attr_reader :my_method
                    ^^^^^^^^^^ Use camelCase for method names.

        attr_accessor :my_method
                      ^^^^^^^^^^ Use camelCase for method names.

        attr_writer :my_method
                    ^^^^^^^^^^ Use camelCase for method names.

        attr_writer 'my_method'
                    ^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for snake case in names' do
      expect_offense(<<~RUBY)
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<~RUBY)
        def myMethod
        end
        def my_method
            ^^^^^^^^^ Use camelCase for method names.
        end
      RUBY
    end

    it 'registers an offense for singleton snake_case method within class' do
      expect_offense(<<~RUBY)
        class Sequel
          def self.foo_bar
                   ^^^^^^^ Use camelCase for method names.
          end
        end
      RUBY
    end

    it 'registers an offense for `Struct` snake_case member' do
      expect_offense(<<~RUBY)
        Struct.new("foo_bar", var, *args, :snake_case, :camelCase, :snake_case_2, "camelCase2")
                                          ^^^^^^^^^^^ Use camelCase for method names.
                                                                   ^^^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `::Struct` snake_case member' do
      expect_offense(<<~RUBY)
        ::Struct.new("foo_bar", var, *args, :snake_case, :camelCase, :snake_case_2, "camelCase2")
                                            ^^^^^^^^^^^ Use camelCase for method names.
                                                                     ^^^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `Data` snake_case member' do
      expect_offense(<<~RUBY)
        Data.define(var, *args, :snake_case, :camelCase, :snake_case_2, "camelCase2")
                                ^^^^^^^^^^^ Use camelCase for method names.
                                                         ^^^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `::Data` snake_case member' do
      expect_offense(<<~RUBY)
        ::Data.define(var, *args, :snake_case, :camelCase, :snake_case_2, "camelCase2")
                                  ^^^^^^^^^^^ Use camelCase for method names.
                                                           ^^^^^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `alias` snake_case argument' do
      expect_offense(<<~RUBY)
        alias foo_bar foo
              ^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `alias_method` snake_case symbol argument' do
      expect_offense(<<~RUBY)
        alias_method :foo_bar, :foo
                     ^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it 'registers an offense for `alias_method` snake_case string argument' do
      expect_offense(<<~RUBY)
        alias_method "foo_bar", "foo"
                     ^^^^^^^^^ Use camelCase for method names.
      RUBY
    end

    it_behaves_like 'always accepted', 'camelCase'
    it_behaves_like 'never accepted',  'camelCase'
    it_behaves_like 'multiple attr methods', 'camelCase'
    it_behaves_like 'forbidden identifiers', 'super'
    it_behaves_like 'forbidden patterns', '_gen\d+\z', 'user_gen1'
    it_behaves_like 'define_method method call', 'camelCase', 'foo_bar'
    it_behaves_like 'define_method method call', 'camelCase', 'foo_bar?'
    it_behaves_like 'define_method method call', 'camelCase', 'foo_bar!'
    it_behaves_like 'define_method method call', 'camelCase', 'foo_bar='
  end

  it 'accepts for non-ascii characters' do
    expect_no_offenses(<<~RUBY)
      def última_vista; end
    RUBY
  end
end
