# frozen_string_literal: true

RSpec.describe(
  RuboCop::Cop::Lint::OrAssignmentInConstructor,
  :config
) do
  context 'empty constructor' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class Banana
          def initialize
          end
        end
      RUBY
    end
  end

  context 'constructor does not have or-assignment' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class Banana
          def initialize
            @delicious = true
          end
        end
      RUBY
    end
  end

  context 'constructor has or-assignment' do
    context 'LHS is lvar' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          class Banana
            def initialize
              delicious ||= true
            end
          end
        RUBY
      end
    end

    context 'LHS is ivar' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          class Banana
            def initialize
              @delicious ||= true
                         ^^^ Unnecessary or-assignment. Use plain assignment.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Banana
            def initialize
              @delicious = true
            end
          end
        RUBY
      end

      context 'constructor calls super after assignment' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            class Banana
              def initialize
                @delicious ||= true
                           ^^^ Unnecessary or-assignment. Use plain assignment.
                super
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class Banana
              def initialize
                @delicious = true
                super
              end
            end
          RUBY
        end
      end

      context 'constructor calls super before or-assignment' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            class Banana
              def initialize
                super
                @delicious ||= true
              end
            end
          RUBY
        end
      end

      context 'constructor calls any method before or-assignment' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            class Banana
              def initialize
                # With the limitations of static analysis, it's very difficult
                # to determine, after this method call, whether the or-assignment
                # is necessary or not.
                absolutely_any_method
                @delicious ||= true
              end
            end
          RUBY
        end
      end
    end
  end
end
