# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::StructNewOverride do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense using `Struct.new(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = Struct.new(:members)
                       ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'registers an offense using `::Struct.new(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = ::Struct.new(:members)
                         ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'registers an offense using `Struct.new(string, ...symbols)`' do
    expect_offense(<<~RUBY)
      Struct.new('Bad', :members, :name)
                        ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'registers an offense using `Struct.new(...symbols)`' do
    expect_offense(<<~RUBY)
      Bad = Struct.new(:name, :members, :address)
                              ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with a block' do
    expect_offense(<<~RUBY)
      Struct.new(:members) do
                 ^^^^^^^^ Disallow overriding the `Struct#members` method.
        def members?
          !members.empty?
        end
      end
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with multiple overrides' do
    expect_offense(<<~RUBY)
      Struct.new(:members, :clone, :zip)
                                   ^^^^ Disallow overriding the `Struct#zip` method.
                           ^^^^^^ Disallow overriding the `Struct#clone` method.
                 ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with an option argument' do
    expect_offense(<<~RUBY)
      Struct.new(:members, keyword_init: true)
                 ^^^^^^^^ Disallow overriding the `Struct#members` method.
    RUBY
  end

  it 'does not register an offense with no overrides' do
    expect_no_offenses(<<~RUBY)
      Good = Struct.new(:id, :name)
    RUBY
  end

  it 'does not register an offense with an override within a given block' do
    expect_no_offenses(<<~RUBY)
      Good = Struct.new(:id, :name) do
        def members
          super.tap { |ret| pp "members: " + ret.to_s }
        end
      end
    RUBY
  end
end
