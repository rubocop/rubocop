# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::VariableBindInAlternativePattern, :config, :ruby27 do
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      case foo
      in {a: } | Array
         ^^^^^^^^^^^^^ Do not bind variables in alternative patterns.
        do_something
      end
    RUBY
  end

  it 'does not register an offense when not assigning variables' do
    expect_no_offenses(<<~RUBY)
      foo = 1
      case x
      in ^foo | Array
        do_something
      end
    RUBY
  end

  it 'does not register an offense when not alternative pattern' do
    expect_no_offenses(<<~RUBY)
      case x
      in { foo: }
        first_method
      in { bar: }
        second_method
      end
    RUBY
  end
end
