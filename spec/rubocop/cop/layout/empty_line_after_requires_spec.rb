# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterRequires, :config do
  context 'when EnforcedStyle is beginning_of_file_only' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'beginning_of_file_only' }
    end

    context 'when empty line is put after requires at the beginning of the file' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          require 'a'
          require 'b'

          foo
        RUBY
      end
    end

    context 'when empty line is not put after requires at the beginning of the file' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          require 'a'
          require 'b'
          ^^^^^^^^^^^ Add an empty line after requires.
          foo
        RUBY

        expect_correction(<<~RUBY)
          require 'a'
          require 'b'

          foo
        RUBY
      end
    end

    context 'when empty line is put after requires not at the beginning of the file' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          foo

          require 'a'
          require 'b'
          bar
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is all' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'all' }
    end

    context 'when empty line is put after requires not at the beginning of the file' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          foo
          require 'a'
          require 'b'
          ^^^^^^^^^^^ Add an empty line after requires.
          bar
        RUBY

        expect_correction(<<~RUBY)
          foo
          require 'a'
          require 'b'

          bar
        RUBY
      end
    end
  end

  context 'when RequireMethodNames includes require_dependency' do
    let(:cop_config) do
      { 'RequireMethodNames' => %w[require require_relative require_dependency] }
    end

    context 'when empty line is not put after require_dependency' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          require_dependency 'a'
          require_dependency 'b'
          ^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after requires.
          foo
        RUBY

        expect_correction(<<~RUBY)
          require_dependency 'a'
          require_dependency 'b'

          foo
        RUBY
      end
    end
  end
end
