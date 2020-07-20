# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringConcatenation do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects for string concatenation' do
    expect_offense(<<~RUBY)
      email_with_name = user.name + ' <' + user.email + '>'
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation instead of string concatenation.
    RUBY

    expect_correction(<<~RUBY)
      email_with_name = "\#{user.name} <\#{user.email}>"
    RUBY
  end

  it 'registers an offense and corrects for string concatenation as part of other expression' do
    expect_offense(<<~RUBY)
      users = (user.name + ' ' + user.email) * 5
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation instead of string concatenation.
    RUBY

    expect_correction(<<~RUBY)
      users = ("\#{user.name} \#{user.email}") * 5
    RUBY
  end

  it 'correctly handles strings with special characters' do
    expect_offense(<<-RUBY)
      email_with_name = "\\n" + user.name + ' ' + user.email + '\\n'
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation instead of string concatenation.
    RUBY

    expect_correction(<<-RUBY)
      email_with_name = "\\n\#{user.name} \#{user.email}\\\\n"
    RUBY
  end

  it 'does not register an offense when using `+` with all non string arguments' do
    expect_no_offenses(<<~RUBY)
      user.name + user.email
    RUBY
  end
end
