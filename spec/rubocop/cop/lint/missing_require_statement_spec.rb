# frozen_string_literal: true

describe RuboCop::Cop::Lint::MissingRequireStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  # TODO: Write test code
  #
  # For example
  it 'registers an offense when missing a require' do
    expect_offense(<<-RUBY.strip_indent)
      Abbrev.abbrev(["test"])
      ^^^^^^ `Abbrev` not found, you're probably missing a require statement
    RUBY
  end

  it 'does not register an offense when require is present' do
    expect_no_offenses(<<-RUBY.strip_indent)
      require 'abbrev'
      Abbrev.abbrev([ "test" ])
    RUBY
  end
  
  it 'does not register an offense for modules/classes defined in the same file' do
    expect_no_offenses(<<-RUBY.strip_indent)
      module A
        module B
          class C
            def test
            end
          end
        end
      end
      A::B::C.new.test
    RUBY
  end
end
