# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBlockBody, :config do
  let(:beginning_offense_annotation) { '^{} Extra empty line detected at block body beginning.' }

  # Test blocks using both {} and do..end
  [%w[{ }], %w[do end]].each do |open, close|
    context "when EnforcedStyle is no_empty_lines for #{open} #{close} block" do
      let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

      it 'registers an offense for block body starting with a blank' do
        expect_offense(<<~RUBY)
          some_method #{open}

          #{beginning_offense_annotation}
            do_something
          #{close}
        RUBY

        expect_correction(<<~RUBY)
          some_method #{open}
            do_something
          #{close}
        RUBY
      end

      it 'registers an offense for block body ending with a blank' do
        expect_offense(<<~RUBY)
          some_method #{open}
            do_something

          ^{} Extra empty line detected at block body end.
            #{close}
        RUBY

        expect_correction(<<~RUBY)
          some_method #{open}
            do_something
            #{close}
        RUBY
      end

      context 'Ruby 2.7', :ruby27 do
        it 'registers an offense for block body ending with a blank' do
          expect_offense(<<~RUBY)
            some_method #{open}
              _1

            ^{} Extra empty line detected at block body end.
              #{close}
          RUBY

          expect_correction(<<~RUBY)
            some_method #{open}
              _1
              #{close}
          RUBY
        end
      end

      it 'accepts block body starting with a line with spaces' do
        expect_no_offenses(<<~RUBY)
          some_method #{open}
           #{trailing_whitespace}
            do_something
          #{close}
        RUBY
      end

      it 'registers an offense for block body starting with a blank passed to ' \
         'a multi-line method call' do
        expect_offense(<<~RUBY)
          some_method arg,
            another_arg #{open}

          #{beginning_offense_annotation}
            do_something
          #{close}
        RUBY
      end

      it 'is not fooled by single line blocks' do
        expect_no_offenses(<<~RUBY)
          some_method #{open} do_something #{close}

          something_else
        RUBY
      end
    end

    context "when EnforcedStyle is empty_lines for #{open} #{close} block" do
      let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

      it 'registers an offense for block body not starting or ending with a blank' do
        expect_offense(<<~RUBY)
          some_method #{open}
            do_something
          ^ Empty line missing at block body beginning.
          #{close}
          ^ Empty line missing at block body end.
        RUBY

        expect_correction(<<~RUBY)
          some_method #{open}

            do_something

          #{close}
        RUBY
      end

      it 'ignores block with an empty body' do
        expect_no_offenses("some_method #{open}\n#{close}")
      end

      it 'is not fooled by single line blocks' do
        expect_no_offenses(<<~RUBY)
          some_method #{open} do_something #{close}
          something_else
        RUBY
      end
    end
  end
end
