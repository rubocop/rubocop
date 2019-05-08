# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EnsureReturn do
  subject(:cop) { described_class.new }

  it 'registers an offense for return in ensure' do
    expect_offense(<<~RUBY)
      begin
        something
      ensure
        file.close
        return
        ^^^^^^ Do not return from an `ensure` block.
      end
    RUBY
  end

  it 'does not register an offense for return outside ensure' do
    expect_no_offenses(<<~RUBY)
      begin
        something
        return
      ensure
        file.close
      end
    RUBY
  end

  it 'does not check when ensure block has no body' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      ensure
      end
    RUBY
  end
end
