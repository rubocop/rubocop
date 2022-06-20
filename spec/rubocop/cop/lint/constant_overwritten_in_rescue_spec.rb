# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ConstantOverwrittenInRescue, :config do
  it 'registers an offense when overriding an exception with an exception result' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue => StandardError
             ^^ `StandardError` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
      rescue StandardError
      end
    RUBY
  end

  it 'does not register an offense when not overriding an exception with an exception result' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      rescue StandardError
      end
    RUBY
  end

  it 'does not register an offense when using `=>` but correctly assigning to variables' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      rescue StandardError => e
      end
    RUBY
  end
end
