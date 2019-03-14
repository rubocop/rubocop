# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ActiveSupportAliases do
  subject(:cop) { described_class.new }

  describe 'String' do
    describe '#starts_with?' do
      it 'registers as an offense and corrects' do
        expect_offense(<<-RUBY.strip_indent)
          'some_string'.starts_with?('prefix')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `start_with?` instead of `starts_with?`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          'some_string'.start_with?('prefix')
        RUBY
      end
    end

    describe '#start_with?' do
      it 'is not registered as an offense' do
        expect_no_offenses("'some_string'.start_with?('prefix')")
      end
    end

    describe '#ends_with?' do
      it 'registers as an offense and corrects' do
        expect_offense(<<-RUBY.strip_indent)
          'some_string'.ends_with?('prefix')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `end_with?` instead of `ends_with?`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          'some_string'.end_with?('prefix')
        RUBY
      end
    end

    describe '#end_with?' do
      it 'is not registered as an offense' do
        expect_no_offenses("'some_string'.end_with?('prefix')")
      end
    end
  end

  describe 'Array' do
    describe '#append' do
      it 'registers as an offense and does not correct' do
        expect_offense(<<-RUBY.strip_indent)
          [1, 'a', 3].append('element')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `<<` instead of `append`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          [1, 'a', 3].append('element')
        RUBY
      end
    end

    describe '#<<' do
      it 'is not registered as an offense' do
        expect_no_offenses("[1, 'a', 3] << 'element'")
      end
    end

    describe '#prepend' do
      it 'registers as an offense and corrects' do
        expect_offense(<<-RUBY.strip_indent)
          [1, 'a', 3].prepend('element')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `unshift` instead of `prepend`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          [1, 'a', 3].unshift('element')
        RUBY
      end
    end

    describe '#unshift' do
      it 'is not registered as an offense' do
        expect_no_offenses("[1, 'a', 3].unshift('element')")
      end
    end
  end
end
