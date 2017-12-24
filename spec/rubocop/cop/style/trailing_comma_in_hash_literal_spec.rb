# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrailingCommaInHashLiteral, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'single line lists' do |extra_info|
    it 'registers an offense for trailing comma in a literal' do
      inspect_source('MAP = { a: 1001, b: 2020, c: 3333, }')
      expect(cop.messages)
        .to eq(["Avoid comma after the last item of a hash#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'accepts literal without trailing comma' do
      expect_no_offenses('MAP = { a: 1001, b: 2020, c: 3333 }')
    end

    it 'accepts single element literal without trailing comma' do
      expect_no_offenses('MAP = { a: 10001 }')
    end

    it 'accepts empty literal' do
      expect_no_offenses('MAP = {}')
    end

    it 'auto-corrects unwanted comma in literal' do
      new_source = autocorrect_source('MAP = { a: 1001, b: 2020, c: 3333, }')
      expect(new_source).to eq('MAP = { a: 1001, b: 2020, c: 3333 }')
    end
  end

  context 'with single line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      include_examples 'single line lists', ''
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      include_examples 'single line lists',
                       ', unless each item is on its own line'
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      include_examples 'single line lists',
                       ', unless items are split onto multiple lines'
    end
  end

  context 'with multi-line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

      it 'registers an offense for trailing comma in literal' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
                         ^ Avoid comma after the last item of a hash.
                }
        RUBY
      end

      it 'accepts literal with no trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333
                }
        RUBY
      end

      it 'accepts comma inside a heredoc parameters at the end' do
        expect_no_offenses(<<-RUBY.strip_indent)
          route(help: {
            'auth' => <<-HELP.chomp
          ,
          HELP
          })
        RUBY
      end

      it 'accepts comma in comment after last value item' do
        expect_no_offenses(<<-RUBY.strip_indent)
          {
            foo: 'foo',
            bar: 'bar'.delete(',')#,
          }
        RUBY
      end

      it 'auto-corrects unwanted comma in literal' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
                }
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                }
        RUBY
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'accepts literal with no trailing comma' do
          expect_no_offenses(<<-RUBY.strip_indent)
            VALUES = {
                       a: "b",
                       c: "d",
                       e: "f"}
          RUBY
        end
      end

      it 'registers an offense for no trailing comma' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'registers an offense for trailing comma in a comment' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333 # ,
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'accepts trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
        RUBY
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        expect_no_offenses(<<-RUBY.strip_indent)
          route(help: {
            'auth' => <<-HELP.chomp
          ...
          HELP
          })
        RUBY
      end

      it 'auto-corrects missing comma' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
          }
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
          }
        RUBY
      end

      it 'accepts a multiline hash with a single pair and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = {
            a: 123,
          }
        RUBY
      end
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'registers an offense for literal with no trailing comma' do
          expect_offense(<<-RUBY.strip_indent)
            VALUES = {
                       a: "b",
                       b: "c",
                       d: "e"}
                       ^^^^^^ Put a comma after the last item of a multiline hash.
          RUBY
        end

        it 'auto-corrects a missing comma' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            MAP = { a: 1001,
                    b: 2020,
                    c: 3333}
          RUBY
          expect(new_source).to eq(<<-RUBY.strip_indent)
            MAP = { a: 1001,
                    b: 2020,
                    c: 3333,}
          RUBY
        end
      end

      it 'registers an offense for no trailing comma' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'accepts trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
        RUBY
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        expect_no_offenses(<<-RUBY.strip_indent)
          route(help: {
            'auth' => <<-HELP.chomp
          ...
          HELP
          })
        RUBY
      end

      it 'auto-corrects missing comma' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
          }
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
          }
        RUBY
      end

      it 'accepts a multiline hash with a single pair and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = {
            a: 123,
          }
        RUBY
      end

      it 'accepts a multiline hash with pairs on a single line and' \
         'trailing comma' do
        inspect_source(<<-RUBY.strip_indent)
          bar = {
            a: 1001, b: 2020,
          }
        RUBY
        expect(cop.offenses.empty?).to be(true)
      end
    end
  end
end
