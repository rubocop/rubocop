# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::HashCompareByIdentity, :config do
  it 'registers an offense when using hash methods with `object_id` on receiver as a key' do
    expect_offense(<<~RUBY)
      hash.key?(foo.object_id)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
      hash.has_key?(foo.object_id)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
      hash[foo.object_id] = bar
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
      hash[foo.object_id]
      ^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
      hash.fetch(foo.object_id, 42)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
    RUBY
  end

  it 'registers an offense when using hash method with `object_id` as a key' do
    expect_offense(<<~RUBY)
      hash.key?(object_id)
      ^^^^^^^^^^^^^^^^^^^^ Use `Hash#compare_by_identity` instead of using `object_id` for keys.
    RUBY
  end

  it 'does not register an offense for hash methods without `object_id` as key' do
    expect_no_offenses(<<~RUBY)
      hash.key?(foo)
    RUBY
  end
end
