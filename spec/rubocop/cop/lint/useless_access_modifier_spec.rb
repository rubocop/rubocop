# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessAccessModifier, :config do
  context 'when an access modifier has no effect' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          def some_method
            puts 10
          end
          private
          ^^^^^^^ Useless `private` access modifier.
          def self.some_method
            puts 10
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def some_method
            puts 10
          end
          def self.some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when an access modifier has no methods' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          def some_method
            puts 10
          end
          protected
          ^^^^^^^^^ Useless `protected` access modifier.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when an access modifier is followed by attr_*' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          protected
          attr_accessor :some_property
          public
          attr_reader :another_one
          private
          attr :yet_again, true
          protected
          attr_writer :just_for_good_measure
        end
      RUBY
    end
  end

  context 'when an access modifier is followed by a class method defined on constant' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          protected
          ^^^^^^^^^ Useless `protected` access modifier.
          def SomeClass.some_method
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          def SomeClass.some_method
          end
        end
      RUBY
    end
  end

  context 'when there are consecutive access modifiers' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
         private
         private
         ^^^^^^^ Useless `private` access modifier.
          def some_method
            puts 10
          end
          def some_other_method
            puts 10
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
         private
          def some_method
            puts 10
          end
          def some_other_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when passing method as symbol' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          def some_method
            puts 10
          end
          private :some_method
        end
      RUBY
    end
  end

  context 'when class is empty save modifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          private
          ^^^^^^^ Useless `private` access modifier.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
        end
      RUBY
    end
  end

  context 'when multiple class definitions in file but only one has offense' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          private
          ^^^^^^^ Useless `private` access modifier.
        end
        class SomeOtherClass
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
        end
        class SomeOtherClass
        end
      RUBY
    end
  end

  context 'when using inline modifiers' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          private def some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when only a constant or local variable is defined after the modifier' do
    %w[CONSTANT some_var].each do |binding_name|
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          class SomeClass
            private
            ^^^^^^^ Useless `private` access modifier.
            #{binding_name} = 1
          end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            #{binding_name} = 1
          end
        RUBY
      end
    end
  end

  context 'when a def is an argument to a method call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          private
          helper_method def some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when private_class_method is used without arguments' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        class SomeClass
          private_class_method
          ^^^^^^^^^^^^^^^^^^^^ Useless `private_class_method` access modifier.

          def self.some_method
            puts 10
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass

          def self.some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context 'when private_class_method is used with arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          private_class_method def self.some_method
            puts 10
          end
        end
      RUBY
    end
  end

  context "when using ActiveSupport's `concerning` method" do
    let(:config) do
      RuboCop::Config.new(
        'Lint/UselessAccessModifier' => {
          'ContextCreatingMethods' => ['concerning']
        }
      )
    end

    it 'is aware that this creates a new scope' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          concerning :FirstThing do
            def foo
            end
            private

            def method
            end
          end

          concerning :SecondThing do
            def omg
            end
            private
            def method
            end
          end
         end
      RUBY
    end

    it 'still points out redundant uses within the block' do
      expect_offense(<<~RUBY)
        class SomeClass
          concerning :FirstThing do
            def foo
            end
            private

            def method
            end
          end

          concerning :SecondThing do
            def omg
            end
            private
            def method
            end
            private
            ^^^^^^^ Useless `private` access modifier.
            def another_method
            end
          end
         end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          concerning :FirstThing do
            def foo
            end
            private

            def method
            end
          end

          concerning :SecondThing do
            def omg
            end
            private
            def method
            end
            def another_method
            end
          end
         end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'still points out redundant uses within the block' do
        expect_offense(<<~RUBY)
          class SomeClass
            concerning :SecondThing do
              p _1
              def omg
              end
              private
              def method
              end
              private
              ^^^^^^^ Useless `private` access modifier.
              def another_method
              end
            end
           end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            concerning :SecondThing do
              p _1
              def omg
              end
              private
              def method
              end
              def another_method
              end
            end
           end
        RUBY
      end
    end
  end

  context 'when using ActiveSupport behavior when Rails is not enabled' do
    it 'reports offenses and corrects' do
      expect_offense(<<~RUBY)
        module SomeModule
          extend ActiveSupport::Concern
          class_methods do
            def some_public_class_method
            end
            private
            def some_private_class_method
            end
          end
          def some_public_instance_method
          end
          private
          ^^^^^^^ Useless `private` access modifier.
          def some_private_instance_method
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module SomeModule
          extend ActiveSupport::Concern
          class_methods do
            def some_public_class_method
            end
            private
            def some_private_class_method
            end
          end
          def some_public_instance_method
          end
          def some_private_instance_method
          end
        end
      RUBY
    end
  end

  context 'when using the class_methods method from ActiveSupport::Concern' do
    let(:config) do
      RuboCop::Config.new(
        'Lint/UselessAccessModifier' => {
          'ContextCreatingMethods' => ['class_methods']
        }
      )
    end

    it 'is aware that this creates a new scope' do
      expect_no_offenses(<<~RUBY)
        module SomeModule
          extend ActiveSupport::Concern
          class_methods do
            def some_public_class_method
            end
            private
            def some_private_class_method
            end
          end
          def some_public_instance_method
          end
          private
          def some_private_instance_method
          end
        end
      RUBY
    end
  end

  context 'when using a known method-creating method' do
    let(:config) do
      RuboCop::Config.new(
        'Lint/UselessAccessModifier' => {
          'MethodCreatingMethods' => ['delegate']
        }
      )
    end

    it 'is aware that this creates a new method' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          private

          delegate :foo, to: :bar
        end
      RUBY
    end

    it 'still points out redundant uses within the module' do
      expect_offense(<<~RUBY)
        class SomeClass
          delegate :foo, to: :bar

          private
          ^^^^^^^ Useless `private` access modifier.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          delegate :foo, to: :bar

        end
      RUBY
    end
  end

  shared_examples 'at the top of the body' do |keyword|
    it 'registers an offense and corrects for `public`' do
      expect_offense(<<~RUBY)
        #{keyword} A
          public
          ^^^^^^ Useless `public` access modifier.
          def method
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} A
          def method
          end
        end
      RUBY
    end

    it "doesn't register an offense for `protected`" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          protected
          def method
          end
        end
      RUBY
    end

    it "doesn't register an offense for `private`" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          private
          def method
          end
        end
      RUBY
    end
  end

  shared_examples 'repeated visibility modifiers' do |keyword, modifier|
    it "registers an offense when `#{modifier}` is repeated" do
      expect_offense(<<~RUBY, modifier: modifier)
        #{keyword} A
          #{modifier == 'private' ? 'protected' : 'private'}
          def method1
          end
          %{modifier}
          %{modifier}
          ^{modifier} Useless `#{modifier}` access modifier.
          def method2
          end
        end
      RUBY
    end
  end

  shared_examples 'non-repeated visibility modifiers' do |keyword|
    it 'registers an offense and corrects even when `public` is not repeated' do
      expect_offense(<<~RUBY)
        #{keyword} A
          def method1
          end
          public
          ^^^^^^ Useless `public` access modifier.
          def method2
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} A
          def method1
          end
          def method2
          end
        end
      RUBY
    end

    it "doesn't register an offense when `protected` is not repeated" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          def method1
          end
          protected
          def method2
          end
        end
      RUBY
    end

    it "doesn't register an offense when `private` is not repeated" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          def method1
          end
          private
          def method2
          end
        end
      RUBY
    end
  end

  shared_examples 'at the end of the body' do |keyword, modifier|
    it "registers an offense for trailing `#{modifier}`" do
      expect_offense(<<~RUBY, modifier: modifier)
        #{keyword} A
          def method1
          end
          def method2
          end
          %{modifier}
          ^{modifier} Useless `#{modifier}` access modifier.
        end
      RUBY
    end
  end

  shared_examples 'nested in a begin..end block' do |keyword, modifier|
    it "still flags repeated `#{modifier}`" do
      expect_offense(<<~RUBY, modifier: modifier)
        #{keyword} A
          #{modifier == 'private' ? 'protected' : 'private'}
          def blah
          end
          begin
            def method1
            end
            %{modifier}
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            def method2
            end
          end
        end
      RUBY
    end

    unless modifier == 'public'
      it "doesn't flag an access modifier from surrounding scope" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            #{modifier}
            begin
              def method1
              end
            end
          end
        RUBY
      end
    end
  end

  shared_examples 'method named by access modifier name' do |keyword, modifier|
    it "does not register an offense for `#{modifier}`" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          def foo
          end

          do_something do
            { #{modifier}: #{modifier} }
          end
        end
      RUBY
    end
  end

  shared_examples 'unused visibility modifiers' do |keyword|
    it 'registers an offense and corrects when visibility is ' \
       'immediately changed without any intervening defs' do
      expect_offense(<<~RUBY)
        #{keyword} A
          private
          def method1
          end
          public
          ^^^^^^ Useless `public` access modifier.
          private
          def method2
          end
        end
      RUBY

      expect_correction(<<~RUBY, loop: false)
        #{keyword} A
          private
          def method1
          end
          private
          def method2
          end
        end
      RUBY
    end
  end

  shared_examples 'conditionally defined method' do |keyword, modifier|
    %w[if unless].each do |conditional_type|
      it "doesn't register an offense for #{conditional_type}" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            #{modifier}
            #{conditional_type} x
              def method1
              end
            end
          end
        RUBY
      end
    end
  end

  shared_examples 'methods defined in an iteration' do |keyword, modifier|
    %w[each map].each do |iteration_method|
      it "doesn't register an offense for #{iteration_method}" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            #{modifier}
            [1, 2].#{iteration_method} do |i|
              define_method("method\#{i}") do
                i
              end
            end
          end
        RUBY
      end
    end
  end

  shared_examples 'method defined with define_method' do |keyword, modifier|
    it "doesn't register an offense if a block is passed" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          #{modifier}
          define_method(:method1) do
          end
        end
      RUBY
    end

    %w[lambda proc ->].each do |proc_type|
      it "doesn't register an offense if a #{proc_type} is passed" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            #{modifier}
            define_method(:method1, #{proc_type} { })
          end
        RUBY
      end
    end
  end

  shared_examples 'method defined on a singleton class' do |keyword, modifier|
    context 'inside a class' do
      it "doesn't register an offense if a method is defined" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            class << self
              #{modifier}
              define_method(:method1) do
              end
            end
          end
        RUBY
      end

      it "doesn't register an offense if the modifier is the same as outside the meta-class" do
        expect_no_offenses(<<~RUBY)
          #{keyword} A
            #{modifier}
            def method1
            end
            class << self
              #{modifier}
              def method2
              end
            end
          end
        RUBY
      end

      it 'registers an offense if no method is defined' do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            class << self
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end

      it 'registers an offense if no method is defined after the modifier' do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            class << self
              def method1
              end
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end

      it 'registers an offense even if a non-singleton-class method is defined' do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            def method1
            end
            class << self
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end
    end

    context 'outside a class' do
      it "doesn't register an offense if a method is defined" do
        expect_no_offenses(<<~RUBY)
          class << A
            #{modifier}
            define_method(:method1) do
            end
          end
        RUBY
      end

      it 'registers an offense if no method is defined' do
        expect_offense(<<~RUBY, modifier: modifier)
          class << A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
          end
        RUBY
      end

      it 'registers an offense if no method is defined after the modifier' do
        expect_offense(<<~RUBY, modifier: modifier)
          class << A
            def method1
            end
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
          end
        RUBY
      end
    end
  end

  shared_examples 'method defined using class_eval' do |modifier|
    it "doesn't register an offense if a method is defined" do
      expect_no_offenses(<<~RUBY)
        A.class_eval do
          #{modifier}
          define_method(:method1) do
          end
        end
      RUBY
    end

    it 'registers an offense if no method is defined' do
      expect_offense(<<~RUBY, modifier: modifier)
        A.class_eval do
          %{modifier}
          ^{modifier} Useless `#{modifier}` access modifier.
        end
      RUBY
    end

    context 'inside a class' do
      it 'registers an offense when a modifier is outside the block and a method is defined only inside the block' do
        expect_offense(<<~RUBY, modifier: modifier)
          class A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            A.class_eval do
              def method1
              end
            end
          end
        RUBY
      end

      it 'registers two offenses when a modifier is inside and outside the block and no method is defined' do
        expect_offense(<<~RUBY, modifier: modifier)
          class A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            A.class_eval do
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end
    end
  end

  shared_examples 'def in new block' do |klass, modifier|
    it "doesn't register an offense if a method is defined in #{klass}.new" do
      expect_no_offenses(<<~RUBY)
        #{klass}.new do
          #{modifier}
          def foo
          end
        end
      RUBY
    end

    it "registers an offense if no method is defined in #{klass}.new" do
      expect_offense(<<~RUBY, modifier: modifier)
        #{klass}.new do
          %{modifier}
          ^{modifier} Useless `#{modifier}` access modifier.
        end
      RUBY
    end
  end

  shared_examples 'method defined using instance_eval' do |modifier|
    it "doesn't register an offense if a method is defined" do
      expect_no_offenses(<<~RUBY)
        A.instance_eval do
          #{modifier}
          define_method(:method1) do
          end
        end
      RUBY
    end

    it 'registers an offense if no method is defined' do
      expect_offense(<<~RUBY, modifier: modifier)
        A.instance_eval do
          %{modifier}
          ^{modifier} Useless `#{modifier}` access modifier.
        end
      RUBY
    end

    context 'inside a class' do
      it 'registers an offense when a modifier is outside the block and a ' \
         'method is defined only inside the block' do
        expect_offense(<<~RUBY, modifier: modifier)
          class A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            self.instance_eval do
              def method1
              end
            end
          end
        RUBY
      end

      it 'registers two offenses when a modifier is inside and outside the and no method is defined' do
        expect_offense(<<~RUBY, modifier: modifier)
          class A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            self.instance_eval do
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end
    end
  end

  shared_examples 'nested modules' do |keyword, modifier|
    it "doesn't register an offense for nested #{keyword}s" do
      expect_no_offenses(<<~RUBY)
        #{keyword} A
          #{modifier}
          def method1
          end
          #{keyword} B
            def method2
            end
            #{modifier}
            def method3
            end
          end
        end
      RUBY
    end

    context 'unused modifiers' do
      it "registers an offense with a nested #{keyword}" do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            #{keyword} B
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end

      it "registers an offense when outside a nested #{keyword}" do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            #{keyword} B
              def method1
              end
            end
          end
        RUBY
      end

      it "registers an offense when inside a nested #{keyword}" do
        expect_offense(<<~RUBY, modifier: modifier)
          #{keyword} A
            #{keyword} B
              %{modifier}
              ^{modifier} Useless `#{modifier}` access modifier.
            end
          end
        RUBY
      end
    end
  end

  %w[protected private].each do |modifier|
    it_behaves_like('method defined using class_eval', modifier)
    it_behaves_like('method defined using instance_eval', modifier)
  end

  %w[Class ::Class Module ::Module Struct ::Struct].each do |klass|
    %w[protected private].each do |modifier|
      it_behaves_like('def in new block', klass, modifier)
    end
  end

  context '`def` in `Data.define` block', :ruby32 do
    %w[protected private].each do |modifier|
      it "doesn't register an offense if a method is defined in `Data.define` with block" do
        expect_no_offenses(<<~RUBY)
          Data.define do
            #{modifier}
            def foo
            end
          end
        RUBY
      end

      it 'registers an offense if no method is defined in `Data.define` with block' do
        expect_offense(<<~RUBY, modifier: modifier)
          Data.define do
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
          end
        RUBY
      end

      it 'registers an offense if no method is defined in `::Data.define` with block' do
        expect_offense(<<~RUBY, modifier: modifier)
          ::Data.define do
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
          end
        RUBY
      end

      it 'registers an offense if no method is defined in `Data.define` with numblock' do
        expect_offense(<<~RUBY, modifier: modifier)
          Data.define do
            %{modifier}
            ^{modifier} Useless `#{modifier}` access modifier.
            do_something(_1)
          end
        RUBY
      end
    end
  end

  %w[module class].each do |keyword|
    it_behaves_like('at the top of the body', keyword)
    it_behaves_like('non-repeated visibility modifiers', keyword)
    it_behaves_like('unused visibility modifiers', keyword)

    %w[public protected private].each do |modifier|
      it_behaves_like('repeated visibility modifiers', keyword, modifier)
      it_behaves_like('at the end of the body', keyword, modifier)
      it_behaves_like('nested in a begin..end block', keyword, modifier)
      it_behaves_like('method named by access modifier name', keyword, modifier)

      next if modifier == 'public'

      it_behaves_like('conditionally defined method', keyword, modifier)
      it_behaves_like('methods defined in an iteration', keyword, modifier)
      it_behaves_like('method defined with define_method', keyword, modifier)
      it_behaves_like('method defined on a singleton class', keyword, modifier)
      it_behaves_like('nested modules', keyword, modifier)
    end
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => true })
    end

    context 'when using same access modifier inside and outside the included block' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          class SomeClass
            included do
              private
              def foo; end
            end
            private
            def bar; end
          end
        RUBY
      end

      it 'registers an offense when using repeated access modifier inside/outside the included block' do
        expect_offense(<<~RUBY)
          class SomeClass
            included do
              private
              private
              ^^^^^^^ Useless `private` access modifier.
              def foo; end
            end
            private
            private
            ^^^^^^^ Useless `private` access modifier.
            def bar; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            included do
              private
              def foo; end
            end
            private
            def bar; end
          end
        RUBY
      end
    end
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: false`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => false })
    end

    context 'when using same access modifier inside and outside the `included` block' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class SomeClass
            included do
              private
              def foo; end
            end
            private
            ^^^^^^^ Useless `private` access modifier.
            def bar; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            included do
              private
              def foo; end
            end
            def bar; end
          end
        RUBY
      end

      it 'registers an offense when using repeated access modifier inside/outside the `included` block' do
        expect_offense(<<~RUBY)
          class SomeClass
            included do
              private
              private
              ^^^^^^^ Useless `private` access modifier.
              def foo; end
            end
            private
            ^^^^^^^ Useless `private` access modifier.
            private
            ^^^^^^^ Useless `private` access modifier.
            def bar; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            included do
              private
              def foo; end
            end
            def bar; end
          end
        RUBY
      end
    end
  end
end
