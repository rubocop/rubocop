# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassEqualityComparison, :config do
  let(:cop_config) do
    { 'IgnoredMethods' => [] }
  end

  it 'registers an offense and corrects when comparing class using `==` for equality' do
    expect_offense(<<~RUBY)
      var.class == Date
          ^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
    RUBY

    expect_correction(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  it 'registers an offense and corrects when comparing class using `equal?` for equality' do
    expect_offense(<<~RUBY)
      var.class.equal?(Date)
          ^^^^^^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
    RUBY

    expect_correction(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  it 'registers an offense and corrects when comparing class using `eql?` for equality' do
    expect_offense(<<~RUBY)
      var.class.eql?(Date)
          ^^^^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
    RUBY

    expect_correction(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  it 'registers an offense and corrects when comparing single quoted class name for equality' do
    expect_offense(<<~RUBY)
      var.class.name == 'Date'
          ^^^^^^^^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
    RUBY

    expect_correction(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  it 'registers an offense and corrects when comparing double quoted class name for equality' do
    expect_offense(<<~RUBY)
      var.class.name == "Date"
          ^^^^^^^^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
    RUBY

    expect_correction(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  it 'does not register an offense when using `instance_of?`' do
    expect_no_offenses(<<~RUBY)
      var.instance_of?(Date)
    RUBY
  end

  context 'when IgnoredMethods is specified' do
    let(:cop_config) do
      { 'IgnoredMethods' => ['=='] }
    end

    it 'does not register an offense when comparing class for equality' do
      expect_no_offenses(<<~RUBY)
        def ==(other)
          self.class == other.class &&
            name == other.name
        end
      RUBY
    end
  end
end
