# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ConstantVisibility do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when defining a constant in a class' do
    it 'registers an offense when not using a visibility declaration' do
      expect_offense(<<-RUBY.strip_indent)
        class Foo
          BAR = 42
          ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
        end
      RUBY
    end

    it 'does not register an offense when using a visibility declaration' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Foo
          BAR = 42
          private_constant :BAR
        end
      RUBY
    end
  end

  context 'when defining a constant in a module' do
    it 'registers an offense when not using a visibility declaration' do
      expect_offense(<<-RUBY.strip_indent)
        module Foo
          BAR = 42
          ^^^^^^^^ Explicitly make `BAR` public or private using either `#public_constant` or `#private_constant`.
        end
      RUBY
    end

    it 'does not register an offense when using a visibility declaration' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Foo
          BAR = 42
          public_constant :BAR
        end
      RUBY
    end
  end

  it 'does not register an offense when passing a string to the ' \
     'visibility declaration' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo
        BAR = 42
        private_constant "BAR"
      end
    RUBY
  end

  it 'does not register an offense in the top level scope' do
    expect_no_offenses(<<-RUBY.strip_indent)
      BAR = 42
    RUBY
  end
end
