# frozen_string_literal: true

RSpec.describe(
  RuboCop::Cop::Lint::DisjunctiveAssignmentInConstructor,
  :config
) do
  subject(:cop) { described_class.new(config) }

  context 'empty constructor' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Banana
          def initialize
          end
        end
      RUBY
    end
  end

  context 'constructor does not have disjunctive assignment' do
    it 'accepts' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Banana
          def initialize
            @delicious = true
          end
        end
      RUBY
    end
  end

  context 'constructor has disjunctive assignment' do
    context 'LHS is lvar' do
      it 'accepts' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Banana
            def initialize
              delicious ||= true
            end
          end
        RUBY
      end
    end

    context 'LHS is ivar' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          class Banana
            def initialize
              @delicious ||= true
                         ^^^ Unnecessary disjunctive assignment. Use plain assignment.
            end
          end
        RUBY
      end

      context 'constructor calls super after assignment' do
        it 'registers an offense' do
          expect_offense(<<-RUBY.strip_indent)
            class Banana
              def initialize
                @delicious ||= true
                           ^^^ Unnecessary disjunctive assignment. Use plain assignment.
                super
              end
            end
          RUBY
        end
      end

      context 'constructor calls super before disjunctive assignment' do
        it 'accepts' do
          expect_no_offenses(<<-RUBY.strip_indent)
            class Banana
              def initialize
                super
                @delicious ||= true
              end
            end
          RUBY
        end
      end

      context 'constructor calls any method before disjunctive assignment' do
        it 'accepts' do
          expect_no_offenses(<<-RUBY.strip_indent)
            class Banana
              def initialize
                # With the limitations of static analysis, it's very difficult
                # to determine, after this method call, whether the disjunctive
                # assignment is necessary or not.
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
