# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::SharedExamples, :config do
  it 'registers an offense and corrects for `shared_examples_for`' do
    expect_offense(<<~RUBY)
      shared_examples_for 'desc' do |var|
      ^^^^^^^^^^^^^^^^^^^ Use `shared_examples` instead of `shared_examples_for`.
      end
    RUBY

    expect_correction(<<~RUBY)
      shared_examples 'desc' do |var|
      end
    RUBY
  end

  it 'registers an offense and corrects for `RSpec.shared_examples_for`' do
    expect_offense(<<~RUBY)
      RSpec.shared_examples_for 'desc' do |var|
            ^^^^^^^^^^^^^^^^^^^ Use `shared_examples` instead of `shared_examples_for`.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.shared_examples 'desc' do |var|
      end
    RUBY
  end

  it 'registers an offense and corrects for `::RSpec.shared_examples_for`' do
    expect_offense(<<~RUBY)
      ::RSpec.shared_examples_for 'desc' do |var|
              ^^^^^^^^^^^^^^^^^^^ Use `shared_examples` instead of `shared_examples_for`.
      end
    RUBY

    expect_correction(<<~RUBY)
      ::RSpec.shared_examples 'desc' do |var|
      end
    RUBY
  end

  it 'does not register an offense for `shared_examples_for` with another receiver' do
    expect_no_offenses(<<~RUBY)
      foo.shared_examples_for
    RUBY
  end
end
