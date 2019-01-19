# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::PredicateName, :config do
  subject(:cop) { described_class.new(config) }

  context 'with blacklisted prefixes' do
    let(:cop_config) do
      { 'NamePrefix' => %w[has_ is_],
        'NamePrefixBlacklist' => %w[has_ is_] }
    end

    it 'registers an offense when method name starts with "is"' do
      expect_offense(<<-RUBY.strip_indent)
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `attr?`.
      RUBY
    end

    it 'registers an offense when method name starts with "has"' do
      expect_offense(<<-RUBY.strip_indent)
        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `attr?`.
      RUBY
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def have_attr; end
      RUBY
    end

    it 'accepts method name that is an assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def is_hello=; end
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def is_2d?; end
      RUBY
    end
  end

  context 'without blacklisted prefixes' do
    let(:cop_config) do
      { 'NamePrefix' => %w[has_ is_], 'NamePrefixBlacklist' => [] }
    end

    it 'registers an offense when method name starts with "is"' do
      expect_offense(<<-RUBY.strip_indent)
        def is_attr; end
            ^^^^^^^ Rename `is_attr` to `is_attr?`.
      RUBY
    end

    it 'registers an offense when method name starts with "has"' do
      expect_offense(<<-RUBY.strip_indent)
        def has_attr; end
            ^^^^^^^^ Rename `has_attr` to `has_attr?`.
      RUBY
    end

    it 'accepts method name that starts with unknown prefix' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def have_attr; end
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def is_2d?; end
      RUBY
    end
  end

  context 'with whitelisted predicate names' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'NamePrefixBlacklist' => %w[is_],
        'NameWhitelist' => %w[is_a?] }
    end

    it 'accepts method name which is in whitelist' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def is_a?; end
      RUBY
    end
  end

  context 'with method definition macros' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'NamePrefixBlacklist' => %w[is_],
        'MethodDefinitionMacros' => %w[define_method def_node_matcher] }
    end

    it 'registers an offense when using `define_method`' do
      expect_offense(<<-RUBY.strip_indent)
        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
      RUBY
    end

    it 'registers an offense when using an internal affair macro' do
      expect_offense(<<-RUBY.strip_indent)
        def_node_matcher :is_hello, <<-PATTERN
                         ^^^^^^^^^ Rename `is_hello` to `hello?`.
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
      RUBY
    end
  end

  context 'without method definition macros' do
    let(:cop_config) do
      { 'NamePrefix' => %w[is_], 'NamePrefixBlacklist' => %w[is_] }
    end

    it 'registers an offense when using `define_method`' do
      expect_offense(<<-RUBY.strip_indent)
        define_method(:is_hello) do |method_name|
                      ^^^^^^^^^ Rename `is_hello` to `hello?`.
          method_name == 'hello'
        end
      RUBY
    end

    it 'does not register any offenses when using an internal affair macro' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def_node_matcher :is_hello, <<-PATTERN
                         ^^^^^^^^^ Rename `is_hello` to `hello?`.
          (send
            (send nil? :method_name) :==
            (str 'hello'))
        PATTERN
      RUBY
    end

    it 'accepts method name when corrected name is invalid identifier' do
      expect_no_offenses(<<-RUBY.strip_indent)
        define_method(:is_2d?) do |method_name|
          method_name == 'hello'
        end
      RUBY
    end
  end
end
