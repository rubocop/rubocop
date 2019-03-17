# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DelegateAllowBlank do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects when using allow_blank' do
    expect_offense(<<-RUBY.strip_indent)
      delegate :foo, to: :bar, allow_blank: true
                               ^^^^^^^^^^^^^^^^^ `allow_blank` is not a valid option, use `allow_nil`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      delegate :foo, to: :bar, allow_nil: true
    RUBY
  end

  it 'does not register an offense when using allow_nil' do
    expect_no_offenses('delegate :foo, to: :bar, allow_nil: true')
  end

  it 'does not register an offense when no extra options given' do
    expect_no_offenses('delegate :foo, to: :bar')
  end
end
