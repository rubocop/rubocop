# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SubclassesMethod, :config do
  it 'registers an offense when using `.subclasses`' do
    expect_offense(<<~RUBY)
      subclasses
      ^^^^^^^^^^ `.subclasses` is deprecated in favor of explicitly registering classes.
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      good_method
    RUBY
  end
end
