# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateMagicComment, :config do
  it 'registers an offense when frozen magic comments are duplicated' do
    expect_offense(<<~RUBY)
      # frozen_string_literal: true
      # frozen_string_literal: true
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate magic comment detected.
    RUBY

    expect_correction(<<~RUBY)
      # frozen_string_literal: true
    RUBY
  end

  it 'registers an offense when same encoding magic comments are duplicated' do
    expect_offense(<<~RUBY)
      # encoding: ascii
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ Duplicate magic comment detected.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: ascii
    RUBY
  end

  it 'registers an offense when different encoding magic comments are duplicated' do
    expect_offense(<<~RUBY)
      # encoding: ascii
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Duplicate magic comment detected.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: ascii
    RUBY
  end

  it 'registers an offense when encoding and frozen magic comments are duplicated' do
    expect_offense(<<~RUBY)
      # encoding: ascii
      # frozen_string_literal: true
      # encoding: ascii
      ^^^^^^^^^^^^^^^^^ Duplicate magic comment detected.
      # frozen_string_literal: true
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate magic comment detected.
    RUBY

    expect_correction(<<~RUBY)
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when frozen magic comments are not duplicated' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when encoding magic comments are not duplicated' do
    expect_no_offenses(<<~RUBY)
      # encoding: ascii
    RUBY
  end

  it 'does not register an offense when encoding and frozen magic comments are not duplicated' do
    expect_no_offenses(<<~RUBY)
      # encoding: ascii
      # frozen_string_literal: true
    RUBY
  end
end
