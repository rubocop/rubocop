# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::PredicateName, :config do
  context 'with restricted prefixes' do
    let(:cop_config) { { 'NamePrefix' => %w[has_ is_], 'ForbiddenPrefixes' => %w[has_ is_] } }

    it 'registers an offense when method name starts with "is"' do
      expect_offense(<<~RUBY)
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `attr?`.
      RUBY
    end

    it 'registers an offense when method name starts with "has"' do
      expect_offense(<<~RUBY)
        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `attr?`.
      RUBY
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<~RUBY)
        def have_attr; end
      RUBY
    end

    it 'accepts method name that is an assignment' do
      expect_no_offenses(<<~RUBY)
        def is_hello=; end
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<~RUBY)
        def is_2d?; end
      RUBY
    end
  end

  context 'without restricted prefixes' do
    let(:cop_config) { { 'NamePrefix' => %w[has_ is_], 'ForbiddenPrefixes' => [] } }

    it 'registers an offense when method name starts with "is"' do
      expect_offense(<<~RUBY)
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY
    end

    it 'registers an offense when method name starts with "has"' do
      expect_offense(<<~RUBY)
        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `has_attr?`.
      RUBY
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<~RUBY)
        def have_attr; end
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<~RUBY)
        def is_2d?; end
      RUBY
    end
  end

  context 'with permitted predicate names' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'ForbiddenPrefixes' => %w[is_],
        'AllowedMethods' => %w[is_a?] }
    end

    it 'accepts method name which is in permitted list' do
      expect_no_offenses(<<~RUBY)
        def is_a?; end
      RUBY
    end
  end

  context 'with method definition macros' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'ForbiddenPrefixes' => %w[is_],
        'MethodDefinitionMacros' => %w[define_method def_node_matcher] }
    end

    it 'registers an offense when using `define_method`' do
      expect_offense(<<~RUBY)
        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
      RUBY
    end

    it 'registers an offense when using an internal affair macro' do
      expect_offense(<<~RUBY)
        def_node_matcher :is_hello, <<~PATTERN
                         ^^^^^^^^^ Rename `is_hello` to `hello?`.
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<~RUBY)
        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
      RUBY
    end
  end

  context 'without method definition macros' do
    let(:cop_config) { { 'NamePrefix' => %w[is_], 'ForbiddenPrefixes' => %w[is_] } }

    it 'registers an offense when using `define_method`' do
      expect_offense(<<~RUBY)
        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
      RUBY
    end

    it 'does not register any offenses when using an internal affair macro' do
      expect_no_offenses(<<~RUBY)
        def_node_matcher :is_hello, <<~PATTERN
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<~RUBY)
        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
      RUBY
    end
  end

  context 'using Sorbet sigs' do
    let(:cop_config) do
      {
        'NamePrefix' => %w[is_ has_],
        'ForbiddenPrefixes' => [],
        'UseSorbetSigs' => 'true'
      }
    end

    it 'registers an offense if no ? when `sig { returns(T::Boolean) }` and variants' do
      expect_offense(<<~RUBY)
        sig { returns(T::Boolean) }
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY

      expect_offense(<<~RUBY)
        sig { returns(T::Boolean) }
        # Comment here.
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY

      expect_offense(<<~RUBY)
        sig { returns(T::Boolean) }


        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY

      expect_offense(<<~RUBY)
        sig do
          returns(T::Boolean)
        end
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY
    end

    it 'does not register an offense if no ? when `sig { returns(T::Array[String]) }`' do
      expect_no_offenses(<<~RUBY)
        sig { returns(T::Array[String]) }
        def has_caused_error
          errors.add(:base, 'This has caused an error')
        end
      RUBY
    end

    it 'picks the correct sig when there are multiple' do
      expect_no_offenses(<<~RUBY)
        sig { returns(T::Boolean) }
        def is_attr?; end

        sig { returns(String) }
        def has_caused_error
          errors.add(:base, 'This has caused an error')
        end
      RUBY
    end

    it 'works correctly when returns is chained on params' do
      expect_offense(<<~RUBY)
        sig { params(x: Integer).returns(T::Boolean) }
        def is_even(x); end
            ^^^^^^^ Rename `is_even` to `is_even?`.
      RUBY
    end

    it 'does not register an offense if no ? when no sigs but the config is enabled' do
      expect_no_offenses(<<~RUBY)
        def is_attr; end
      RUBY
    end
  end
end
