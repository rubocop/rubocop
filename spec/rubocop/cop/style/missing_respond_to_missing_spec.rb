# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MissingRespondToMissing, :config do
  it 'registers an offense when respond_to_missing? is not implemented' do
    expect_offense(<<~RUBY)
      class Test
        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'registers an offense when method_missing is implemented as a class methods' do
    expect_offense(<<~RUBY)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented as instance methods' do
    expect_no_offenses(<<~RUBY)
      class Test
        def respond_to_missing?
        end

        def method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented as class methods' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.respond_to_missing?
        end

        def self.method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? when defined with inline access modifier' do
    expect_no_offenses(<<~RUBY)
      class Test
        private def respond_to_missing?
        end

        private def method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? when defined with inline access modifier and ' \
     'method_missing is not qualified by inline access modifier' do
    expect_no_offenses(<<~RUBY)
      class Test
        private def respond_to_missing?
        end

        def method_missing
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
     'an instance method and method_missing is implemented as a class method' do
    expect_offense(<<~RUBY)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end

        def respond_to_missing?
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
     'a class method and method_missing is implemented as an instance method' do
    expect_offense(<<~RUBY)
      class Test
        def self.respond_to_missing?
        end

        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end
end
