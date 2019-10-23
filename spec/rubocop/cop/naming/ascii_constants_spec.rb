# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::AsciiConstants do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for a class name with non-ascii chars' do
    expect_offense(<<~RUBY)
      class Foõ; end
              ^ Use only ascii symbols in constants.
    RUBY
  end

  it 'registers an offense for a module name with non-ascii chars' do
    expect_offense(<<~RUBY)
      module Foõ; end
               ^ Use only ascii symbols in constants.
    RUBY
  end

  it 'registers an offense for a constant name with non-ascii chars' do
    expect_offense(<<~RUBY)
      FOÕ = "bar"
        ^ Use only ascii symbols in constants.
    RUBY
  end

  it 'accepts identifiers with only ascii chars' do
    expect_no_offenses('FOO = "bar"')
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
