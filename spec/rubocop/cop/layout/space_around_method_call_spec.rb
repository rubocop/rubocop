# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundMethodCall do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using a space after the . in a method call' do
    expect_offense(<<~RUBY)
      'a'. to_s
          ^ Avoid using space after dot in method call.
    RUBY
  end

  it 'registers an offense when using a space before the . in a method call' do
    expect_offense(<<~RUBY)
      'a' .to_s
         ^ Avoid using space before dot in method call.
    RUBY
  end

  it 'does not register an offense when the method call is done on the next ' \
      'line and there is no space after the dot' do
    expect_no_offenses(<<~RUBY)
      'a'
       .to_s
    RUBY
  end

  it 'registers an offense when the method call is done on the next line and ' \
      'there is a space after the dot' do
    expect_offense(<<~RUBY)
      'a'
       . to_s
        ^ Avoid using space after dot in method call.
    RUBY
  end

  it 'registers an offense when there is 2 calls on the next line and a ' \
      'space around the dot' do
    expect_offense(<<~RUBY)
      'a'
      .to_s .to_i
           ^ Avoid using space before dot in method call.
    RUBY
  end

  it 'does not register an offense when there is no space around a .' do
    expect_no_offenses(<<~RUBY)
      'a'.to_s
    RUBY
  end
end
