# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::InconsistentSafeNavigation, :config do
  it 'registers an offense when a receiver is used with both safe and regular navigation' do
    expect_offense(<<~RUBY)
      user.address&.street
      user.address.city
      ^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end

  it 'registers an offense when a receiver is used with both safe and regular navigation in reverse order' do
    expect_offense(<<~RUBY)
      user.address.city
      ^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
      user.address&.street
    RUBY
  end

  it 'does not register an offense when a receiver is used consistently with safe navigation' do
    expect_no_offenses(<<~RUBY)
      user.address&.street
      user.address&.city
    RUBY
  end

  it 'does not register an offense when a receiver is used consistently without safe navigation' do
    expect_no_offenses(<<~RUBY)
      user.address.street
      user.address.city
    RUBY
  end

  it 'does not register an offense when different receivers are used' do
    expect_no_offenses(<<~RUBY)
      user.address&.street
      user.contact.phone
    RUBY
  end

  it 'handles complex expressions as receivers' do
    expect_offense(<<~RUBY)
      (user.find(id)).address&.street
      (user.find(id)).address.city
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end

  it 'handles multi-dot method calls' do
    expect_offense(<<~RUBY)
      user.contact.address&.street
      user.contact.address.city
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end

  it 'handles safe navigation in multiple places' do
    expect_offense(<<~RUBY)
      user&.address&.street
      user&.address.city
      ^^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end

  it 'handles safe navigation in different statements' do
    expect_offense(<<~RUBY)
      def foo
        user.address&.street
        puts "test"
        user.address.city
        ^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
      end
    RUBY
  end

  it 'handles method calls with arguments' do
    expect_offense(<<~RUBY)
      user.find(1)&.address
      user.find(1).address
      ^^^^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end

  it 'handles methods with special characters' do
    expect_offense(<<~RUBY)
      user.address&.[](:street)
      user.address[:city]
      ^^^^^^^^^^^^^^^^^^^ Inconsistent use of safe navigation operator. This receiver is accessed elsewhere with safe navigation operator.
    RUBY
  end
end
