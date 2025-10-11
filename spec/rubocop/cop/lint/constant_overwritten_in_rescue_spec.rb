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

  it 'registers an offense when overriding a fully-qualified constant' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue => ::StandardError
             ^^ `::StandardError` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
      rescue ::StandardError
      end
    RUBY
  end

  it 'registers an offense when overriding a constant with a method call receiver' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue => foo.class::RESCUABLE_EXCEPTIONS
             ^^ `foo.class::RESCUABLE_EXCEPTIONS` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
      rescue foo.class::RESCUABLE_EXCEPTIONS
      end
    RUBY
  end

  it 'registers an offense when overriding a constant with a variable receiver' do
    expect_offense(<<~RUBY)
      var = Object
      begin
        something
      rescue => var::StandardError
             ^^ `var::StandardError` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      var = Object
      begin
        something
      rescue var::StandardError
      end
    RUBY
  end

  it 'registers an offense when overriding a nested constant' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue => MyNamespace::MyException
             ^^ `MyNamespace::MyException` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
      rescue MyNamespace::MyException
      end
    RUBY
  end

  it 'registers an offense when overriding a fully qualified nested constant' do
    expect_offense(<<~RUBY)
      begin
        something
      rescue => ::MyNamespace::MyException
             ^^ `::MyNamespace::MyException` is overwritten by `rescue =>`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        something
      rescue ::MyNamespace::MyException
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
