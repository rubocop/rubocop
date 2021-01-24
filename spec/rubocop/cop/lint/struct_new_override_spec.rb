# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::StructNewOverride, :config do
  it 'registers an offense using `Struct.new(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = Struct.new(:members)
                       ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `::Struct.new(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = ::Struct.new(:members)
                         ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Struct.new(string, ...symbols)`' do
    expect_offense(<<~RUBY)
      Struct.new('Bad', :members, :name)
                        ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Struct.new(...symbols)`' do
    expect_offense(<<~RUBY)
      Bad = Struct.new(:name, :members, :address)
                              ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Struct.new(symbol, string)`' do
    expect_offense(<<~RUBY)
      Bad = Struct.new(:name, "members")
                              ^^^^^^^^^ `"members"` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with a block' do
    expect_offense(<<~RUBY)
      Struct.new(:members) do
                 ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
        def members?
          !members.empty?
        end
      end
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with multiple overrides' do
    expect_offense(<<~RUBY)
      Struct.new(:members, :clone, :zip)
                                   ^^^^ `:zip` member overrides `Struct#zip` and it may be unexpected.
                           ^^^^^^ `:clone` member overrides `Struct#clone` and it may be unexpected.
                 ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Struct.new(...)` with an option argument' do
    expect_offense(<<~RUBY)
      Struct.new(:members, keyword_init: true)
                 ^^^^^^^^ `:members` member overrides `Struct#members` and it may be unexpected.
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
