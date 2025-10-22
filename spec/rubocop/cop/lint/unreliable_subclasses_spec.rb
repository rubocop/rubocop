# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnreliableSubclasses, :config do
  it 'registers an offense when using `subclasses`' do
    expect_offense(<<~RUBY)
      MyBaseClass.subclasses
                  ^^^^^^^^^^ Avoid using `subclasses` as it is unreliable with autoloading and non-deterministic with garbage collection.
    RUBY
  end
end
