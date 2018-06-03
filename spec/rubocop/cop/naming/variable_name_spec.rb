# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::VariableName, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'always accepted' do
    it 'accepts screaming snake case globals' do
      expect_no_offenses('$MY_GLOBAL = 0')
    end

    it 'accepts screaming snake case constants' do
      expect_no_offenses('MY_CONSTANT = 0')
    end

    it 'accepts assigning to camel case constant' do
      expect_no_offenses('Paren = Struct.new :left, :right, :kind')
    end

    it 'accepts assignment with indexing of self' do
      expect_no_offenses('self[:a] = b')
    end
  end

  context 'when configured for snake_case' do
    let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

    it 'registers an offense for camel case in local variable name' do
      expect_offense(<<-RUBY.strip_indent)
        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        my_local = 1
        myLocal = 1
        ^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for camel case in instance variable name' do
      expect_offense(<<-RUBY.strip_indent)
        @myAttribute = 3
        ^^^^^^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for camel case in class variable name' do
      expect_offense(<<-RUBY.strip_indent)
        @@myAttr = 2
        ^^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for camel case local variables marked as unused' do
      expect_offense(<<-RUBY.strip_indent)
    _myLocal = 1
    ^^^^^^^^ Use snake_case for variable names.
    RUBY
    end

    it 'registers an offense for method arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def method(funnyArg); end
                   ^^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for default method arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(optArg = 1); end
                ^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for rest arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(*restArg); end
                 ^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for keyword arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(kwArg: 1); end
                ^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for keyword rest arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(**kwRest); end
                  ^^^^^^ Use snake_case for variable names.
      RUBY
    end

    it 'registers an offense for block arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(&blockArg); end
                 ^^^^^^^^ Use snake_case for variable names.
      RUBY
    end

    include_examples 'always accepted'
  end

  context 'when configured for camelCase' do
    let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

    it 'registers an offense for snake case in local variable name' do
      expect_offense(<<-RUBY.strip_indent)
        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<-RUBY.strip_indent)
        my_local = 1
        ^^^^^^^^ Use camelCase for variable names.
        myLocal = 1
      RUBY
    end

    it 'accepts camel case in local variable name' do
      expect_no_offenses('myLocal = 1')
    end

    it 'accepts camel case in instance variable name' do
      expect_no_offenses('@myAttribute = 3')
    end

    it 'accepts camel case in class variable name' do
      expect_no_offenses('@@myAttr = 2')
    end

    it 'registers an offense for snake case in method parameter' do
      expect_offense(<<-RUBY.strip_indent)
        def method(funny_arg); end
                   ^^^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'accepts camel case local variables marked as unused' do
      expect_no_offenses('_myLocal = 1')
    end

    it 'registers an offense for default method arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(opt_arg = 1); end
                ^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'registers an offense for rest arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(*rest_arg); end
                 ^^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'registers an offense for keyword arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(kw_arg: 1); end
                ^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'registers an offense for keyword rest arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(**kw_rest); end
                  ^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    it 'registers an offense for block arguments' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(&block_arg); end
                 ^^^^^^^^^ Use camelCase for variable names.
      RUBY
    end

    include_examples 'always accepted'
  end
end
