# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ConstantWording do
  subject(:cop) { described_class.new }

  it 'report const names not clear' do
    expect_offense(<<-RUBY.strip_indent)
      Whitelist = 42
      ^^^^^^^^^ Please use clearer concepts, such as allow, permitted, approved.
    RUBY
  end
end
