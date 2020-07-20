# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TopLevelReturnWithArgument, :config do
  let (:cop_config) do
    { 'AllowComments' => true }
  end

  contextit 'Expect no offense from the top level return node' do
    expect_no_offenses(<<~RUBY)
      foo

      return

      bar
    RUBY
  end

  it 'Expect offense from the top level return node' do
    expect_offense(<<~RUBY)
      foo

      return 1, 2, 3 # Should raise a `top level return with argument detected` offense
      ^^^^^^^^^^^^^^ Top level return with argument detected.
      bar
    RUBY
  end

  it 'Expect no offense from the top level return node with block level return' do
    expect_no_offenses(<<~RUBY)
      foo

      [1, 2, 3, 4, 5].each { |n| return n }

      return # Should raise a `top level return with argument detected` offense

      bar
    RUBY
  end

  it 'Expect offense from the top level return node' do
    expect_offense(<<~RUBY)
      foo

      [1, 2, 3, 4, 5].each { |n| return n }

      return 1, 2, 3 # Should raise a `top level return with argument detected` offense
      ^^^^^^^^^^^^^^ Top level return with argument detected.
      bar
    RUBY
  end
end
