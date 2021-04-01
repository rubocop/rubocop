# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DateTime, :config do
  let(:cop_config) { { 'AllowCoercion' => false } }

  it 'registers an offense when using DateTime for current time' do
    expect_offense(<<~RUBY)
      DateTime.now
      ^^^^^^^^^^^^ Prefer Time over DateTime.
    RUBY

    expect_correction(<<~RUBY)
      Time.now
    RUBY
  end

  it 'registers an offense when using ::DateTime for current time' do
    expect_offense(<<~RUBY)
      ::DateTime.now
      ^^^^^^^^^^^^^^ Prefer Time over DateTime.
    RUBY

    expect_correction(<<~RUBY)
      ::Time.now
    RUBY
  end

  it 'registers an offense when using DateTime for modern date' do
    expect_offense(<<~RUBY)
      DateTime.iso8601('2016-06-29')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer Time over DateTime.
    RUBY

    expect_correction(<<~RUBY)
      Time.iso8601('2016-06-29')
    RUBY
  end

  it 'does not register an offense when using Time for current time' do
    expect_no_offenses('Time.now')
  end

  it 'does not register an offense when using Date for modern date' do
    expect_no_offenses("Date.iso8601('2016-06-29')")
  end

  it 'does not register an offense when using DateTime for historic date' do
    expect_no_offenses("DateTime.iso8601('2016-06-29', Date::ENGLAND)")
  end

  it 'does not register an offense when using ::DateTime for historic date' do
    expect_no_offenses("::DateTime.iso8601('2016-06-29', ::Date::ITALY)")
  end

  it 'does not register an offense when using DateTime in another namespace' do
    expect_no_offenses('Icalendar::Values::DateTime.new(start_at)')
  end

  describe 'when configured to not allow #to_datetime' do
    before { cop_config['AllowCoercion'] = false }

    it 'registers an offense' do
      expect_offense(<<~RUBY)
        thing.to_datetime
        ^^^^^^^^^^^^^^^^^ Do not use #to_datetime.
      RUBY
    end
  end

  describe 'when configured to allow #to_datetime' do
    before { cop_config['AllowCoercion'] = true }

    it 'does not register an offense' do
      expect_no_offenses('thing.to_datetime')
    end
  end
end
