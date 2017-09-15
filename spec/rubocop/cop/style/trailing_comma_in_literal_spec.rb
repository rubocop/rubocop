# frozen_string_literal: true

describe RuboCop::Cop::Style::TrailingCommaInLiteral, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'single line lists' do |extra_info|
    it 'registers an offense for trailing comma in an Array literal' do
      inspect_source('VALUES = [1001, 2020, 3333, ]')
      expect(cop.messages)
        .to eq(["Avoid comma after the last item of an array#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offense for trailing comma in a Hash literal' do
      inspect_source('MAP = { a: 1001, b: 2020, c: 3333, }')
      expect(cop.messages)
        .to eq(["Avoid comma after the last item of a hash#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'accepts Array literal without trailing comma' do
      expect_no_offenses('VALUES = [1001, 2020, 3333]')
    end

    it 'accepts single element Array literal without trailing comma' do
      expect_no_offenses('VALUES = [1001]')
    end

    it 'accepts empty Array literal' do
      expect_no_offenses('VALUES = []')
    end

    it 'accepts rescue clause' do
      # The list of rescued classes is an array.
      expect_no_offenses(<<-RUBY.strip_indent)
        begin
          do_something
        rescue RuntimeError
        end
      RUBY
    end

    it 'accepts Hash literal without trailing comma' do
      expect_no_offenses('MAP = { a: 1001, b: 2020, c: 3333 }')
    end

    it 'accepts single element Hash literal without trailing comma' do
      expect_no_offenses('MAP = { a: 10001 }')
    end

    it 'accepts empty Hash literal' do
      expect_no_offenses('MAP = {}')
    end

    it 'auto-corrects unwanted comma in an Array literal' do
      new_source = autocorrect_source('VALUES = [1001, 2020, 3333, ]')
      expect(new_source).to eq('VALUES = [1001, 2020, 3333 ]')
    end

    it 'auto-corrects unwanted comma in a Hash literal' do
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

      it 'registers an offense for trailing comma in an Array literal' do
        expect_offense(<<-RUBY.strip_indent)
          VALUES = [
                     1001,
                     2020,
                     3333,
                         ^ Avoid comma after the last item of an array.
                   ]
        RUBY
      end

      it 'registers an offense for trailing comma in a Hash literal' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
                         ^ Avoid comma after the last item of a hash.
                }
        RUBY
      end

      it 'accepts an Array literal with no trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          VALUES = [ 1001,
                     2020,
                     3333 ]
        RUBY
      end

      it 'accepts a Hash literal with no trailing comma' do
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

      it 'auto-corrects unwanted comma in an Array literal' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          VALUES = [
                     1001,
                     2020,
                     3333,
                   ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          VALUES = [
                     1001,
                     2020,
                     3333
                   ]
        RUBY
      end

      it 'auto-corrects unwanted comma in a Hash literal' do
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
        it 'accepts Array literal with no trailing comma' do
          expect_no_offenses(<<-RUBY.strip_indent)
            VALUES = [
                       1001,
                       2020,
                       3333]
          RUBY
        end

        it 'accepts a Hash literal with no trailing comma' do
          expect_no_offenses(<<-RUBY.strip_indent)
            VALUES = {
                       a: "b",
                       c: "d",
                       e: "f"}
          RUBY
        end
      end

      it 'accepts Array literal with two of the values on the same line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333
                   ]
        RUBY
      end

      it 'registers an offense for an Array literal with two of the values ' \
         'on the same line and a trailing comma' do
        inspect_source(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333,
                   ]
        RUBY
        expect(cop.messages)
          .to eq(['Avoid comma after the last item of an array, unless each ' \
                  'item is on its own line.'])
      end

      it 'registers an offense for no trailing comma in a Hash literal' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'registers an offense for trailing comma in a comment in Hash' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333 # ,
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'accepts trailing comma in an Array literal' do
        expect_no_offenses(<<-RUBY.strip_indent)
          VALUES = [1001,
                    2020,
                    3333,
                   ]
        RUBY
      end

      it 'accepts trailing comma in a Hash literal' do
        expect_no_offenses(<<-RUBY.strip_indent)
          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
        RUBY
      end

      it 'accepts a multiline word array' do
        expect_no_offenses(<<-RUBY.strip_indent)
          ingredients = %w(
            sausage
            anchovies
            olives
          )
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

      it 'accepts an empty hash being passed as a method argument' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Foo.new([
                   ])
        RUBY
      end

      it 'auto-corrects an Array literal with two of the values on the same' \
         ' line and a trailing comma' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333
                   ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333
                   ]
        RUBY
      end

      it 'auto-corrects missing comma in a Hash literal' do
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

      it 'accepts a multiline array with a single item and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = [
            1,
          ]
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
        it 'registers an offense for an Array literal with no trailing comma' do
          expect_offense(<<-RUBY.strip_indent)
            VALUES = [
                       1001,
                       2020,
                       3333]
                       ^^^^ Put a comma after the last item of a multiline array.
          RUBY
        end

        it 'registers an offense for a Hash literal with no trailing comma' do
          expect_offense(<<-RUBY.strip_indent)
            VALUES = {
                       a: "b",
                       b: "c",
                       d: "e"}
                       ^^^^^^ Put a comma after the last item of a multiline hash.
          RUBY
        end

        it 'auto-corrects a missing comma in a Hash literal' do
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

      it 'accepts Array literal with two of the values on the same line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333,
                   ]
        RUBY
      end

      it 'registers an offense for an Array literal with two of the values ' \
         'on the same line and no trailing comma' do
        inspect_source(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333
                   ]
        RUBY
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline array.'])
      end

      it 'registers an offense for no trailing comma in a Hash literal' do
        expect_offense(<<-RUBY.strip_indent)
          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
        RUBY
      end

      it 'accepts trailing comma in an Array literal' do
        expect_no_offenses(<<-RUBY.strip_indent)
          VALUES = [1001,
                    2020,
                    3333,
                   ]
        RUBY
      end

      it 'accepts trailing comma in a Hash literal' do
        expect_no_offenses(<<-RUBY.strip_indent)
          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
        RUBY
      end

      it 'accepts a multiline word array' do
        expect_no_offenses(<<-RUBY.strip_indent)
          ingredients = %w(
            sausage
            anchovies
            olives
          )
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

      it 'auto-corrects an Array literal with two of the values on the same' \
         ' line and a trailing comma' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333
                   ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          VALUES = [
                     1001, 2020,
                     3333,
                   ]
        RUBY
      end

      it 'auto-corrects missing comma in a Hash literal' do
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

      it 'accepts a multiline array with a single item and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = [
            1,
          ]
        RUBY
      end

      it 'accepts a multiline hash with a single pair and trailing comma' do
        expect_no_offenses(<<-RUBY.strip_indent)
          bar = {
            a: 123,
          }
        RUBY
      end

      it 'accepts a multiline array with items on a single line and' \
         'trailing comma' do
        inspect_source(<<-RUBY.strip_indent)
          foo = [
            1, 2,
          ]
        RUBY
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multiline hash with pairs on a single line and' \
         'trailing comma' do
        inspect_source(<<-RUBY.strip_indent)
          bar = {
            a: 1001, b: 2020,
          }
        RUBY
        expect(cop.offenses).to be_empty
      end
    end
  end
end
