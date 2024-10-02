# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AmbiguousEndlessMethodDefinition, :config do
  context 'Ruby >= 3.0', :ruby30 do
    it 'does not register an offense for a non endless method' do
      expect_no_offenses(<<~RUBY)
        def foo
        end
      RUBY
    end

    %i[and or if unless while until].each do |operator|
      context "with #{operator}" do
        it "does not register an offense for a non endless method followed by `#{operator}`" do
          expect_no_offenses(<<~RUBY)
            def foo
            end #{operator} bar
          RUBY
        end

        it 'does not register an offense when the operator is already wrapped in parens' do
          expect_no_offenses(<<~RUBY)
            def foo = (true #{operator} bar)
          RUBY
        end

        it 'does not register an offense when the method definition is already wrapped in parens' do
          expect_no_offenses(<<~RUBY)
            (def foo = true) #{operator} bar
          RUBY
        end

        unless %i[and or].include?(operator)
          it "does not register an offense for non-modifier `#{operator}`" do
            expect_no_offenses(<<~RUBY)
              #{operator} bar
                def foo = true
              end
            RUBY
          end
        end

        it "registers and offense and corrects an endless method followed by `#{operator}`" do
          expect_offense(<<~RUBY, operator: operator)
            def foo = true #{operator} bar
            ^^^^^^^^^^^^^^^^{operator}^^^^ Avoid using `#{operator}` statements with endless methods.
          RUBY

          expect_correction(<<~RUBY)
            def foo
              true
            end #{operator} bar
          RUBY
        end
      end
    end

    it 'does not register an offense for `&&`' do
      expect_no_offenses(<<~RUBY)
        def foo = true && bar
      RUBY
    end

    it 'does not register an offense for `||`' do
      expect_no_offenses(<<~RUBY)
        def foo = true || bar
      RUBY
    end
  end
end
