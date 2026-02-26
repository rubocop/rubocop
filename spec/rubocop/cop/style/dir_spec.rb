# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Dir, :config do
  context 'when using `#expand_path` and `#dirname`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        File.expand_path(File.dirname(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY

      expect_correction(<<~RUBY)
        __dir__
      RUBY
    end

    it 'registers an offense with ::File' do
      expect_offense(<<~RUBY)
        ::File.expand_path(::File.dirname(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY

      expect_correction(<<~RUBY)
        __dir__
      RUBY
    end
  end

  context 'when using `#dirname` and `#realpath`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        File.dirname(File.realpath(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY

      expect_correction(<<~RUBY)
        __dir__
      RUBY
    end

    it 'registers an offense with ::File' do
      expect_offense(<<~RUBY)
        ::File.dirname(::File.realpath(__FILE__))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `__dir__` to get an absolute path to the current file's directory.
      RUBY

      expect_correction(<<~RUBY)
        __dir__
      RUBY
    end
  end
end
