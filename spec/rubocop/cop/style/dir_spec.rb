# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Dir, :config do
  shared_examples 'auto-correct' do |original, expected|
    it 'auto-corrects' do
      new_source = autocorrect_source(original)

      expect(new_source).to eq(expected)
    end
  end

  context 'when using `#expand_path` and `#dirname`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        File.expand_path(File.dirname(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY
    end

    it 'registers an offense with ::File' do
      expect_offense(<<~RUBY)
        ::File.expand_path(::File.dirname(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY
    end

    it_behaves_like 'auto-correct',
                    'File.expand_path(File.dirname(__FILE__))',
                    '__dir__'

    it_behaves_like 'auto-correct',
                    '::File.expand_path(::File.dirname(__FILE__))',
                    '__dir__'
  end

  context 'when using `#dirname` and `#realpath`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        File.dirname(File.realpath(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY
    end

    it 'registers an offense with ::File' do
      expect_offense(<<~RUBY)
        ::File.dirname(::File.realpath(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY
    end

    it_behaves_like 'auto-correct',
                    'File.dirname(File.realpath(__FILE__))',
                    '__dir__'

    it_behaves_like 'auto-correct',
                    '::File.dirname(::File.realpath(__FILE__))',
                    '__dir__'
  end
end
