# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterRequires, :config do
  context 'when EnforcedStyle is top_level' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'top_level' }
    end

    context 'when empty line is put after requires at top level' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          require 'a'
          require 'b'

          foo
        RUBY
      end
    end

    context 'when empty line is not put after requires at top level' do
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

    context 'when empty line is not put after requires not at top level' do
      it 'registers no offense' do
        expect_no_offenses(<<~RUBY)
          if condition
            require 'a'
            require 'b'
            bar
          end
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is always' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'always' }
    end

    context 'when empty line is put after requires not at top level' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          if condition
            require 'a'
            require 'b'
            ^^^^^^^^^^^ Add an empty line after requires.
            bar
          end
        RUBY

        expect_correction(<<~RUBY)
          if condition
            require 'a'
            require 'b'

            bar
          end
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
