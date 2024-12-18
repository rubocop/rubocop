# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RescueVariableWriter, :config do
  it 'does not register an offense without rescued exception variable' do
    expect_no_offenses(<<~RUBY)
      begin
        raise_error
      rescue
        puts "An error occurred"
      end
    RUBY
  end

  it 'does not register an offense when using local variable' do
    expect_no_offenses(<<~RUBY)
      begin
        raise_error
      rescue => e
        foo.bar = e
      end
    RUBY
  end

  it 'registers an offense when using writer method' do
    expect_offense(<<~RUBY)
      begin
        raise_error
      rescue => foo.bar
                ^^^^^^^ Do not use writer method for rescued exception.
      end
    RUBY
  end
end
