# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantNestedInterpolation do
  subject(:cop) { described_class.new }

  it 'accepts single interpolation' do
    expect_no_offenses('"dear #{user.name}"')
  end

  it 'accepts two single interpolation' do
    expect_no_offenses('"Hello #{user1.name} and #{user2.name}"')
  end

  it 'accepts interpolation with or logic' do
    expect_no_offenses(<<~'RUBY')
      "\n#{(lines.join("\n").split(node.source).first || '')}"
    RUBY
  end

  it 'registers an offense for "Hello, #{nested interpolation}"' do
    expect_offense(<<~'RUBY')
      "Hello, #{user.blank? ? 'guest' : "dear #{user.name}"}"
                                              ^^^^^^^^^^^^ Redundant nested interpolation.
    RUBY
  end

  it 'registers an offense for %|Hello, #{nested interpolation"|' do
    expect_offense(<<~'RUBY')
      %|Hello, #{user.blank? ? 'guest' : "dear #{user.name}"}|
                                               ^^^^^^^^^^^^ Redundant nested interpolation.
    RUBY
  end

  it 'registers an offense for %Q(Hello, #{nested interpolation}")' do
    expect_offense(<<~'RUBY')
      %Q(Hello, #{user.blank? ? 'guest' : "dear #{user.name}"})
                                                ^^^^^^^^^^^^ Redundant nested interpolation.
    RUBY
  end

  it 'registers an offense for ["Hello, #{nested interpolation}"}"]' do
    expect_offense(<<~'RUBY')
      ["Hello, #{user.blank? ? 'guest' : "dear #{user.name}"}", 'foo']
                                               ^^^^^^^^^^^^ Redundant nested interpolation.
    RUBY
  end

  it 'registers interpolation into business block' do
    expect_offense(<<~'RUBY')
      "#{assignment.join("\n#{indentation(node)}")}"
                            ^^^^^^^^^^^^^^^^^^^^ Redundant nested interpolation.
    RUBY
  end
end
