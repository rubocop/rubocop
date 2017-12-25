# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FloatOutOfRange do
  subject(:cop) { described_class.new }

  it 'does not register an offense for 0.0' do
    expect_no_offenses('0.0')
  end

  it 'does not register an offense for tiny little itty bitty floats' do
    expect_no_offenses('1.1e-100')
  end

  it 'does not register an offense for respectably sized floats' do
    expect_no_offenses('55.7e89')
  end

  context 'on whopping big floats which tip the scales' do
    let(:source) { '9.9999e999' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        9.9999e999
        ^^^^^^^^^^ Float out of range.
      RUBY
    end
  end

  context 'on floats so close to zero that nobody can tell the difference' do
    let(:source) { '1.0e-400' }

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        1.0e-400
        ^^^^^^^^ Float out of range.
      RUBY
    end
  end
end
