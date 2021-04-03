# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::AsciiIdentifiers, :config do
  shared_examples 'checks identifiers' do
    it 'registers an offense for a variable name with non-ascii chars' do
      expect_offense(<<~RUBY)
        älg = 1
        ^ Use only ascii symbols in identifiers.
      RUBY
    end

    it 'registers an offense for a variable name with mixed chars' do
      expect_offense(<<~RUBY)
        foo∂∂bar = baz
           ^^ Use only ascii symbols in identifiers.
      RUBY
    end

    it 'accepts identifiers with only ascii chars' do
      expect_no_offenses('x.empty?')
    end

    it 'does not get confused by a byte order mark' do
      expect_no_offenses(<<~RUBY)
        ﻿
        puts 'foo'
      RUBY
    end

    it 'does not get confused by an empty file' do
      expect_no_offenses('')
    end
  end

  context 'when AsciiConstants is true' do
    let(:cop_config) { { 'AsciiConstants' => true } }

    include_examples 'checks identifiers'

    it 'registers an offense for a constant name with non-ascii chars' do
      expect_offense(<<~RUBY)
        class Foö
                ^ Use only ascii symbols in constants.
        end
      RUBY
    end
  end

  context 'when AsciiConstants is false' do
    let(:cop_config) { { 'AsciiConstants' => false } }

    include_examples 'checks identifiers'

    it 'accepts constants with only ascii chars' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end
      RUBY
    end
  end
end
