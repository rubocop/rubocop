# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassEqualityComparison, :config do
  let(:cop_config) do
    { 'IgnoredMethods' => [] }
  end

  it 'registers an offense and corrects when comparing class for equality' do
    expect_offense(<<~RUBY)
      var.class == Date
          ^^^^^^^^^^^^^ Use `Object.instance_of?` instead of comparing classes.
      var.class.equal?(Date)
          ^^^^^^^^^^^^^^^^^^ Use `Object.instance_of?` instead of comparing classes.
      var.class.eql?(Date)
          ^^^^^^^^^^^^^^^^ Use `Object.instance_of?` instead of comparing classes.
    RUBY
  end

  it 'registers an offense and corrects when comparing class name for equality' do
    expect_offense(<<~RUBY)
      var.class.name == "Date"
          ^^^^^^^^^^^^^^^^^^^^ Use `Object.instance_of?` instead of comparing classes.
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
