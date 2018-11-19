# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::OpenStruct do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense for OpenStruct.new' do
    expect_offense(<<-RUBY.strip_indent)
      OpenStruct.new(key: "value")
                 ^^^ Consider using `Struct` over `OpenStruct` to optimize the performance.
    RUBY
  end

  it 'registers an offense for a fully qualified ::OpenStruct.new' do
    expect_offense(<<-RUBY.strip_indent)
      ::OpenStruct.new(key: "value")
                   ^^^ Consider using `Struct` over `OpenStruct` to optimize the performance.
    RUBY
  end

  it 'does not register offense for Struct' do
    expect_no_offenses(<<-RUBY.strip_indent)
      MyStruct = Struct.new(:key)
      MyStruct.new('value')
    RUBY
  end
end
