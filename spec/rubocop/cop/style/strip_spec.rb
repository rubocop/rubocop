# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Strip, :config do
  it 'registers an offense for str.lstrip.rstrip' do
    expect_offense(<<~RUBY)
      str.lstrip.rstrip
          ^^^^^^^^^^^^^ Use `strip` instead of `lstrip.rstrip`.
    RUBY

    expect_correction(<<~RUBY)
      str.strip
    RUBY
  end

  it 'registers an offense for str.rstrip.lstrip' do
    expect_offense(<<~RUBY)
      str.rstrip.lstrip
          ^^^^^^^^^^^^^ Use `strip` instead of `rstrip.lstrip`.
    RUBY

    expect_correction(<<~RUBY)
      str.strip
    RUBY
  end
end
