# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassEqualityComparison, :config do
  let(:cop_config) { { 'AllowedMethods' => [] } }

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

  it 'registers an offense and corrects when comparing `Module#name` for equality' do
    expect_offense(<<~RUBY)
      var.class.name == Date.name
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `instance_of?(Date)` instead of comparing classes.
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

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'AllowedMethods' => ['=='] } }

    it 'does not register an offense when comparing class for equality' do
      expect_no_offenses(<<~RUBY)
        def ==(other)
          self.class == other.class &&
            name == other.name
        end
      RUBY
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'AllowedPatterns' => ['equal'] } }

    it 'does not register an offense when comparing class for equality' do
      expect_no_offenses(<<~RUBY)
        def equal?(other)
          self.class == other.class &&
            name == other.name
        end
      RUBY
    end
  end

  context 'with String comparison in module' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        module Foo
          def bar?(value)
            bar.class.name == 'Bar'
                ^^^^^^^^^^^^^^^^^^^ Use `instance_of?(::Bar)` instead of comparing classes.
          end

          class Bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          def bar?(value)
            bar.instance_of?(::Bar)
          end

          class Bar
          end
        end
      RUBY
    end
  end

  context 'with instance variable comparison in module' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        module Foo
          def bar?(value)
            bar.class.name == @class_name
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `instance_of?(@class_name)` instead of comparing classes.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          def bar?(value)
            bar.instance_of?(@class_name)
          end
        end
      RUBY
    end
  end
end
