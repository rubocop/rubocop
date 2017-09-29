# frozen_string_literal: true

describe RuboCop::Cop::Style::StderrPuts do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it "registers an offense when using `$stderr.puts('hello')`" do
    expect_offense(<<-RUBY.strip_indent)
      $stderr.puts('hello')
      ^^^^^^^^^^^^ Use `warn` instead of `$stderr.puts`.
    RUBY
  end

  it "autocorrects `warn('hello')`" do
    new_source = autocorrect_source("$stderr.puts('hello')")

    expect(new_source).to eq "warn('hello')"
  end
end
