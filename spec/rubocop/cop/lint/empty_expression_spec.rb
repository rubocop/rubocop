# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyExpression do
  subject(:cop) { described_class.new }

  context 'when used as a standalone expression' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        ()
        ^^ Avoid empty expressions.
      RUBY
    end

    context 'with nested empty expressions' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          (())
           ^^ Avoid empty expressions.
        RUBY
      end
    end
  end

  context 'when used in a condition' do
    it 'registers an offense inside `if`' do
      expect_offense(<<-RUBY.strip_indent)
        if (); end
           ^^ Avoid empty expressions.
      RUBY
    end

    it 'registers an offense inside `elseif`' do
      expect_offense(<<-RUBY.strip_indent)
        if foo
          1
        elsif ()
              ^^ Avoid empty expressions.
          2
        end
      RUBY
    end

    it 'registers an offense inside `case`' do
      expect_offense(<<-RUBY.strip_indent)
        case ()
             ^^ Avoid empty expressions.
        when :foo then 1
        end
      RUBY
    end

    it 'registers an offense inside `when`' do
      expect_offense(<<-RUBY.strip_indent)
        case foo
        when () then 1
             ^^ Avoid empty expressions.
        end
      RUBY
    end

    it 'registers an offense in the condition of a ternary operator' do
      expect_offense(<<-RUBY.strip_indent)
        () ? true : false
        ^^ Avoid empty expressions.
      RUBY
    end

    it 'registers an offense in the return value of a ternary operator' do
      expect_offense(<<-RUBY.strip_indent)
        foo ? () : bar
              ^^ Avoid empty expressions.
      RUBY
    end
  end

  context 'when used as a return value' do
    it 'registers an offense in the return value of a method' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          ()
          ^^ Avoid empty expressions.
        end
      RUBY
    end

    it 'registers an offense in the return value of a condition' do
      expect_offense(<<-RUBY.strip_indent)
        if foo
          ()
          ^^ Avoid empty expressions.
        end
      RUBY
    end

    it 'registers an offense in the return value of a case statement' do
      expect_offense(<<-RUBY.strip_indent)
        case foo
        when :bar then ()
                       ^^ Avoid empty expressions.
        end
      RUBY
    end
  end

  context 'when used as an assignment' do
    it 'registers an offense for the assigned value' do
      expect_offense(<<-RUBY.strip_indent)
        foo = ()
              ^^ Avoid empty expressions.
      RUBY
    end
  end
end
