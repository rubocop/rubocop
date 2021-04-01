# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyEnsure, :config do
  it 'registers an offense and corrects empty ensure' do
    expect_offense(<<~RUBY)
      begin
        something
      ensure # hello
      ^^^^^^ Empty `ensure` block detected.
        # world
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
       # hello
        # world
      end
    RUBY
  end

  it 'does not register an offense for non-empty ensure' do
    expect_no_offenses(<<~RUBY)
      begin
        something
        return
      ensure
        file.close
      end
    RUBY
  end
end
