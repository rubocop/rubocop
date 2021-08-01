# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::InheritDeprecatedCopClass, :config do
  it 'registers an offense when using `Cop`' do
    expect_offense(<<~RUBY)
      class Foo < Cop
                  ^^^ Use `Base` instead of `Cop`.
      end
    RUBY
  end

  it 'registers an offense when using `RuboCop::Cop::Cop`' do
    expect_offense(<<~RUBY)
      class Foo < RuboCop::Cop::Cop
                  ^^^^^^^^^^^^^^^^^ Use `Base` instead of `Cop`.
      end
    RUBY
  end

  it 'does not register an offense when using `Base`' do
    expect_no_offenses(<<~RUBY)
      class Foo < Base
      end
    RUBY
  end

  it 'does not register an offense when not inherited super class' do
    expect_no_offenses(<<~RUBY)
      class Foo
      end
    RUBY
  end
end
