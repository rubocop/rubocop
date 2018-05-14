# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MissingRespondToMissing do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when respond_to_missing? is not implemented' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'registers an offense when method_missing is implemented ' \
    'as a class methods' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented ' \
    'as instance methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        def respond_to_missing?
        end

        def method_missing
        end
      end
    RUBY
  end

  it 'allows method_missing and respond_to_missing? implemented ' \
    'as class methods' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Test
        def self.respond_to_missing?
        end

        def self.method_missing
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
    'an instance method and method_missing is implemented as a class method' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def self.method_missing
        ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end

        def respond_to_missing?
        end
      end
    RUBY
  end

  it 'registers an offense respond_to_missing? is implemented as ' \
    'a class method and method_missing is implemented as an instance method' do
    expect_offense(<<-RUBY.strip_indent)
      class Test
        def self.respond_to_missing?
        end

        def method_missing
        ^^^^^^^^^^^^^^^^^^ When using `method_missing`, define `respond_to_missing?`.
        end
      end
    RUBY
  end
end
