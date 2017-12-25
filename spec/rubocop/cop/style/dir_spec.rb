# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Dir, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'auto-correct' do |original, expected|
    it 'auto-corrects' do
      new_source = autocorrect_source(original)

      expect(new_source).to eq(expected)
    end
  end

  it 'registers an offense when using `#expand_path` and `#dirname`' do
    expect_offense(<<-RUBY.strip_indent)
      File.expand_path(File.dirname(__FILE__))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
    RUBY
  end

  it_behaves_like 'auto-correct',
                  'File.expand_path(File.dirname(__FILE__))',
                  '__dir__'

  it 'registers an offense when using `#dirname` and `#realpath`' do
    expect_offense(<<-RUBY.strip_indent)
      File.dirname(File.realpath(__FILE__))
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
    RUBY
  end

  it_behaves_like 'auto-correct',
                  'File.dirname(File.realpath(__FILE__))',
                  '__dir__'
end
