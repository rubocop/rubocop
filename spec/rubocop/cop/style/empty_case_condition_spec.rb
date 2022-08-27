# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyCaseCondition, :config do
  shared_examples 'detect/correct empty case, accept non-empty case' do
    it 'registers an offense and autocorrects' do
      expect_offense(source)

      expect_correction(corrected_source)
    end

    let(:source_with_case) { source.sub(/case/, 'case :a').sub(/^\s*\^.*\n/, '') }

    it 'accepts the source with case' do
      expect_no_offenses(source_with_case)
    end
  end

  context 'given a case statement with an empty case' do
    context 'with multiple when branches and an else' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when 1 == 2
            foo
          when 1 == 1
            bar
          else
            baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if 1 == 2
            foo
          elsif 1 == 1
            bar
          else
            baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with multiple when branches and an `else` with code comments' do
      let(:source) do
        <<~RUBY
          def example
            # Comment before everything
            case # first comment
            ^^^^ Do not use empty `case` condition, instead use an `if` expression.
            # condition a
            # This is a multi-line comment
            when 1 == 2
              foo
            # condition b
            when 1 == 1
              bar
            # condition c
            else
              baz
            end
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          def example
            # Comment before everything
            # first comment
            # condition a
            # This is a multi-line comment
            if 1 == 2
              foo
            # condition b
            elsif 1 == 1
              bar
            # condition c
            else
              baz
            end
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with multiple when branches and no else' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when 1 == 2
            foo
          when 1 == 1
            bar
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if 1 == 2
            foo
          elsif 1 == 1
            bar
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and an else' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when 1 == 2
            foo
          else
            bar
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if 1 == 2
            foo
          else
            bar
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and no else' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when 1 == 2
            foo
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if 1 == 2
            foo
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a when branch including comma-delimited alternatives' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when false
            foo
          when nil, false, 1
            bar
          when false, 1
            baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if false
            foo
          elsif nil || false || 1
            bar
          elsif false || 1
            baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with when branches using then' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when false then foo
          when nil, false, 1 then bar
          when false, 1 then baz
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if false then foo
          elsif nil || false || 1 then bar
          elsif false || 1 then baz
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with first when branch including comma-delimited alternatives' do
      let(:source) do
        <<~RUBY
          case
          ^^^^ Do not use empty `case` condition, instead use an `if` expression.
          when my.foo?, my.bar?
            something
          when my.baz?
            something_else
          end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          if my.foo? || my.bar?
            something
          elsif my.baz?
            something_else
          end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'when used as an argument of a method without comment' do
      let(:source) do
        <<~RUBY
          do_some_work case
                       ^^^^ Do not use empty `case` condition, instead use an `if` expression.
                       when object.nil?
                         Object.new
                       else
                         object
                       end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          do_some_work if object.nil?
                         Object.new
                       else
                         object
                       end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'when used as an argument of a method with comment' do
      let(:source) do
        <<~RUBY
          # example.rb
          do_some_work case
                       ^^^^ Do not use empty `case` condition, instead use an `if` expression.
                       when object.nil?
                         Object.new
                       else
                         object
                       end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          # example.rb
          do_some_work if object.nil?
                         Object.new
                       else
                         object
                       end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'when using `when ... then` in `case` in `return`' do
      let(:source) do
        <<~RUBY
          return case
                 ^^^^ Do not use empty `case` condition, instead use an `if` expression.
                 when object.nil? then Object.new
                 else object
                 end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          return if object.nil?
           Object.new
                 else object
                 end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'when using `when ... then` in `case` in a method call' do
      let(:source) do
        <<~RUBY
          do_some_work case
                       ^^^^ Do not use empty `case` condition, instead use an `if` expression.
                       when object.nil? then Object.new
                       else object
                       end
        RUBY
      end
      let(:corrected_source) do
        <<~RUBY
          do_some_work if object.nil?
           Object.new
                       else object
                       end
        RUBY
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'when using `return` in `when` clause and assigning the return value of `case`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          v = case
              when x.a
                1
              when x.b
                return 2
              end
        RUBY
      end
    end

    context 'when using `return ... if` in `when` clause and ' \
            'assigning the return value of `case`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          v = case
              when x.a
                1
              when x.b
                return 2 if foo
              end
        RUBY
      end
    end

    context 'when using `return` in `else` clause and assigning the return value of `case`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          v = case
              when x.a
                1
              else
                return 2
              end
        RUBY
      end
    end

    context 'when using `return ... if` in `else` clause and ' \
            'assigning the return value of `case`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          v = case
              when x.a
                1
              else
                return 2 if foo
              end
        RUBY
      end
    end
  end
end
