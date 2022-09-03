# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StaticClass, :config do
  it 'registers an offense when class has only class method' do
    expect_offense(<<~RUBY)
      class C
      ^^^^^^^ Prefer modules to classes with only class methods.
        def self.class_method; end
      end
    RUBY

    expect_correction(<<~RUBY)
      module C
      module_function

        def class_method; end
      end
    RUBY
  end

  it 'registers an offense when class has `class << self` with class methods' do
    expect_offense(<<~RUBY)
      class C
      ^^^^^^^ Prefer modules to classes with only class methods.
        def self.class_method; end

        class << self
          def other_class_method; end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module C
      module_function

        def class_method; end

       #{trailing_whitespace}
          def other_class_method; end
       #{trailing_whitespace}
      end
    RUBY
  end

  it 'does not register an offense when class has `class << self` with macro calls' do
    expect_no_offenses(<<~RUBY)
      class C
        def self.class_method; end

        class << self
          macro_method
        end
      end
    RUBY
  end

  it 'registers an offense when class has assignments along with class methods' do
    expect_offense(<<~RUBY)
      class C
      ^^^^^^^ Prefer modules to classes with only class methods.
        CONST = 1

        def self.class_method; end
      end
    RUBY

    expect_correction(<<~RUBY)
      module C
      module_function

        CONST = 1

        def class_method; end
      end
    RUBY
  end

  it 'does not register an offense when class has instance method' do
    expect_no_offenses(<<~RUBY)
      class C
        def self.class_method; end

        def instance_method; end
      end
    RUBY
  end

  it 'does not register an offense when class has macro-like method' do
    expect_no_offenses(<<~RUBY)
      class C
        def self.class_method; end

        macro_method
      end
    RUBY
  end

  it 'does not register an offense when class is empty' do
    expect_no_offenses(<<~RUBY)
      class C
      end
    RUBY
  end

  it 'does not register an offense when class has a parent' do
    expect_no_offenses(<<~RUBY)
      class C < B
        def self.class_method; end
      end
    RUBY
  end

  it 'does not register an offense when class includes/prepends a module' do
    expect_no_offenses(<<~RUBY)
      class C
        include M
        def self.class_method; end
      end

      class C
        prepend M
        def self.class_method; end
      end
    RUBY
  end

  it 'registers an offense when class extends a module' do
    expect_offense(<<~RUBY)
      class C
      ^^^^^^^ Prefer modules to classes with only class methods.
        extend M
        def self.class_method; end
      end
    RUBY

    expect_correction(<<~RUBY)
      module C
      module_function

        extend M
        def class_method; end
      end
    RUBY
  end

  it 'does not register an offense for modules' do
    expect_no_offenses(<<~RUBY)
      module C
        def self.class_method; end
      end
    RUBY
  end
end
