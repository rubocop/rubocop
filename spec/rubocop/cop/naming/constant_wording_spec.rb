# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ConstantWording do
  subject(:cop) { described_class.new }

  it 'report const names not clear' do
    expect_offense(<<-RUBY.strip_indent)
      ::Whitelist = 42
        ^^^^^^^^^ Please use clearer names for constants.
      WhiteList = 42
      ^^^^^^^^^ Please use clearer names for constants.
      Whitelisted = 42
      ^^^^^^^^^^^ Please use clearer names for constants.
      Blacklist = 42
      ^^^^^^^^^ Please use clearer names for constants.
      Blacklisted = 42
      ^^^^^^^^^^^ Please use clearer names for constants.
    RUBY
  end
end
