# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingRequireStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  describe 'require' do
    it 'registers an offense when missing' do
      expect_offense(<<-RUBY.strip_indent)
        Abbrev.abbrev(["test"])
        ^^^^^^ `Abbrev` not found, you're probably missing a require statement or there is a cycle in your dependencies.
      RUBY
    end

    it 'does not register an offense when present' do
      expect_no_offenses(<<-RUBY.strip_indent)
        require 'abbrev'
        Abbrev.abbrev([ "test" ])
      RUBY
    end

    it 'registers an offense when too late' do
      expect_offense(<<-RUBY.strip_indent)
        Abbrev.abbrev(["test"])
        ^^^^^^ `Abbrev` not found, you're probably missing a require statement or there is a cycle in your dependencies.
        require 'abbrev'
      RUBY
    end
  end

  describe 'modules/classes defined in file' do
    it 'does not register offenses for earlier definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module A
          module B
            class C
              def test
              end
            end
          end
        end
        A::B::C.new.test
      RUBY
    end

    it 'does not register an offense for later definitions' do
      # In a case where the `B::C.new.test` call would be top-level instead of in a method, ruby
      # would give a NameError, so it is a good approximation not to complain about a missing require 
      # in this case: There is no missing require - the order has to be changed to fix this instead
      expect_no_offenses(<<-RUBY.strip_indent)
        def test
          B::C.new.test
        end
        module B
          class C
            def test; end
          end
        end
      RUBY
    end
  end

  describe 'actual constants' do
    it 'does not register offenses for earlier definitions' do
      expect_no_offenses(<<-RUBY.strip_indent)
        MY_VERSION = 5
        MY_VERSION.to_i
      RUBY
    end

    it 'does not register offenses for later definitions' do
      # Ruby will NameError here as well
      expect_no_offenses(<<-RUBY.strip_indent)
        MY_VERSION.to_i
        MY_VERSION = 5
      RUBY
    end
  end

  describe 'inheritance' do
    it 'registers an offense when not available' do
      expect_offense(<<-RUBY.strip_indent)
      class A < B
      ^^^^^^^^^^^ `B` not found, you're probably missing a require statement or there is a cycle in your dependencies.
      end
      RUBY
    end

    it 'does not register an offense when defined in the same file' do
      expect_no_offenses(<<-RUBY.strip_indent)
        module B
          class C; end
        end
        class A < B::C; end
      RUBY
    end

    it 'does not register an offense for required files' do
      expect_no_offenses(<<-RUBY.strip_indent)
        require 'abbrev'
        class A < Abbrev; end
      RUBY
    end
  end
end
