# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedFileDirname, :config do
  context 'Ruby >= 3.1', :ruby31 do
    it 'registers and corrects an offense when using `File.dirname(path)` nested two times' do
      expect_offense(<<~RUBY)
        File.dirname(File.dirname(path))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dirname(path, 2)` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.dirname(path, 2)
      RUBY
    end

    it 'registers and corrects an offense when using `File.dirname(path)` nested three times' do
      expect_offense(<<~RUBY)
        File.dirname(File.dirname(File.dirname(path)))
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `dirname(path, 3)` instead.
      RUBY

      expect_correction(<<~RUBY)
        File.dirname(path, 3)
      RUBY
    end

    it 'does not register an offense when using non nested `File.dirname(path)`' do
      expect_no_offenses(<<~RUBY)
        File.dirname(path)
      RUBY
    end

    it 'does not register an offense when using `File.dirname(path, 2)`' do
      expect_no_offenses(<<~RUBY)
        File.dirname(path, 2)
      RUBY
    end
  end

  context 'Ruby <= 3.0', :ruby30 do
    it 'does not register an offense when using `File.dirname(path)` nested two times' do
      expect_no_offenses(<<~RUBY)
        File.dirname(File.dirname(path))
      RUBY
    end
  end
end
