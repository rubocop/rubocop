# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DateTime do
  subject(:cop) { described_class.new }

  it 'registers an offense when using DateTime for current time' do
    expect_offense(<<-RUBY.strip_indent)
      DateTime.now
      ^^^^^^^^^^^^ Prefer Date or Time over DateTime.
    RUBY
  end

  it 'registers an offense when using ::DateTime for current time' do
    expect_offense(<<-RUBY.strip_indent)
      ::DateTime.now
      ^^^^^^^^^^^^^^ Prefer Date or Time over DateTime.
    RUBY
  end

  it 'registers an offense when using DateTime for modern date' do
    expect_offense(<<-RUBY.strip_indent)
      DateTime.iso8601('2016-06-29')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer Date or Time over DateTime.
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

  it 'does not register an offense when using DateTime in another namespace' do
    expect_no_offenses('Icalendar::Values::DateTime.new(start_at)')
  end
end
