# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ToJSON do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `#to_json` without arguments' do
    expect_offense(<<-RUBY.strip_indent)
      def to_json
      ^^^^^^^^^^^  `#to_json` requires an optional argument to be parsable via JSON.generate(obj).
      end
    RUBY
  end

  it 'does not register an offense when using `#to_json` with arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def to_json(opts)
      end
    RUBY
  end

  it 'autocorrects' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      def to_json
      end
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      def to_json(_opts)
      end
    RUBY
  end
end
