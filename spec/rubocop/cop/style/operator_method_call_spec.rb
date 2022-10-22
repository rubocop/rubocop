# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OperatorMethodCall, :config do
  described_class::RESTRICT_ON_SEND.each do |operator_method|
    it "registers an offense when using `foo.#{operator_method} bar`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method} bar
           ^ Redundant dot detected.
      RUBY

      expect_correction(<<~RUBY)
        foo #{operator_method} bar
      RUBY
    end

    it "does not register an offense when using `foo #{operator_method} bar`" do
      expect_no_offenses(<<~RUBY)
        foo #{operator_method} bar
      RUBY
    end

    it "registers an offense when using `foo.#{operator_method}(bar)`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method}(bar)
           ^ Redundant dot detected.
      RUBY

      # Redundant parentheses in `(bar)` are left to `Style/RedundantParentheses` to fix.
      expect_correction(<<~RUBY)
        foo #{operator_method}(bar)
      RUBY
    end
  end

  it 'does not register an offense when using `foo.+@bar.to_s`' do
    expect_no_offenses(<<~RUBY)
      foo.+ bar.to_s
    RUBY
  end

  it 'does not register an offense when using `foo.+@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.+@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.-@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.-@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.!@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.!@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.~@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.~@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.`bar`' do
    expect_no_offenses(<<~RUBY)
      foo.` bar
    RUBY
  end

  it 'does not register an offense when using `Foo.+(bar)`' do
    expect_no_offenses(<<~RUBY)
      Foo.+(bar)
    RUBY
  end
end
