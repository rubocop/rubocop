# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::TrailingCommaInLiteral, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'single line lists' do |extra_info|
    it 'registers an offense for trailing comma in an Array literal' do
      inspect_source(cop, 'VALUES = [1001, 2020, 3333, ]')
      expect(cop.messages)
        .to eq(["Avoid comma after the last item of an array#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offense for trailing comma in a Hash literal' do
      inspect_source(cop, 'MAP = { a: 1001, b: 2020, c: 3333, }')
      expect(cop.messages)
        .to eq(["Avoid comma after the last item of a hash#{extra_info}."])
      expect(cop.highlights).to eq([','])
    end

    it 'accepts Array literal without trailing comma' do
      inspect_source(cop, 'VALUES = [1001, 2020, 3333]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts single element Array literal without trailing comma' do
      inspect_source(cop, 'VALUES = [1001]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts empty Array literal' do
      inspect_source(cop, 'VALUES = []')
      expect(cop.offenses).to be_empty
    end

    it 'accepts rescue clause' do
      # The list of rescued classes is an array.
      inspect_source(cop, ['begin',
                           '  do_something',
                           'rescue RuntimeError',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts Hash literal without trailing comma' do
      inspect_source(cop, 'MAP = { a: 1001, b: 2020, c: 3333 }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts single element Hash literal without trailing comma' do
      inspect_source(cop, 'MAP = { a: 10001 }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts empty Hash literal' do
      inspect_source(cop, 'MAP = {}')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects unwanted comma in an Array literal' do
      new_source = autocorrect_source(cop, 'VALUES = [1001, 2020, 3333, ]')
      expect(new_source).to eq('VALUES = [1001, 2020, 3333 ]')
    end

    it 'auto-corrects unwanted comma in a Hash literal' do
      new_source = autocorrect_source(cop,
                                      'MAP = { a: 1001, b: 2020, c: 3333, }')
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
        inspect_source(cop, ['VALUES = [',
                             '           1001,',
                             '           2020,',
                             '           3333,',
                             '         ]'])
        expect(cop.highlights).to eq([','])
      end

      it 'registers an offense for trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333,',
                             '      }'])
        expect(cop.highlights).to eq([','])
      end

      it 'accepts an Array literal with no trailing comma' do
        inspect_source(cop, ['VALUES = [ 1001,',
                             '           2020,',
                             '           3333 ]'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a Hash literal with no trailing comma' do
        inspect_source(cop, ['MAP = {',
                             '        a: 1001,',
                             '        b: 2020,',
                             '        c: 3333',
                             '      }'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts comma inside a heredoc parameters at the end' do
        inspect_source(cop, ['route(help: {',
                             "  'auth' => <<-HELP.chomp",
                             ',',
                             'HELP',
                             '})'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts comma in comment after last value item' do
        inspect_source(cop, ['{ ',
                             "  foo: 'foo',",
                             "  bar: 'bar'.delete(',')#,",
                             '}'])
        expect(cop.offenses).to be_empty
      end

      it 'auto-corrects unwanted comma in an Array literal' do
        new_source = autocorrect_source(cop, ['VALUES = [',
                                              '           1001,',
                                              '           2020,',
                                              '           3333,',
                                              '         ]'])
        expect(new_source).to eq(['VALUES = [',
                                  '           1001,',
                                  '           2020,',
                                  '           3333',
                                  '         ]'].join("\n"))
      end

      it 'auto-corrects unwanted comma in a Hash literal' do
        new_source = autocorrect_source(cop, ['MAP = { a: 1001,',
                                              '        b: 2020,',
                                              '        c: 3333,',
                                              '      }'])
        expect(new_source).to eq(['MAP = { a: 1001,',
                                  '        b: 2020,',
                                  '        c: 3333',
                                  '      }'].join("\n"))
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'accepts Array literal with no trailing comma' do
          inspect_source(cop, ['VALUES = [',
                               '           1001,',
                               '           2020,',
                               '           3333]'])
          expect(cop.offenses).to be_empty
        end

        it 'accepts a Hash literal with no trailing comma' do
          inspect_source(cop, ['VALUES = {',
                               '           a: "b",',
                               '           c: "d",',
                               '           e: "f"}'])
          expect(cop.offenses).to be_empty
        end
      end

      it 'accepts Array literal with two of the values on the same line' do
        inspect_source(cop, ['VALUES = [',
                             '           1001, 2020,',
                             '           3333',
                             '         ]'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for an Array literal with two of the values ' \
         'on the same line and a trailing comma' do
        inspect_source(cop, ['VALUES = [',
                             '           1001, 2020,',
                             '           3333,',
                             '         ]'])
        expect(cop.messages)
          .to eq(['Avoid comma after the last item of an array, unless each ' \
                  'item is on its own line.'])
      end

      it 'registers an offense for no trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333',
                             '}'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline hash.'])
        expect(cop.highlights).to eq(['c: 3333'])
      end

      it 'registers an offense for trailing comma in a comment in Hash' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333 # ,',
                             '}'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline hash.'])
        expect(cop.highlights).to eq(['c: 3333'])
      end

      it 'accepts trailing comma in an Array literal' do
        inspect_source(cop, ['VALUES = [1001,',
                             '          2020,',
                             '          3333,',
                             '         ]'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = {',
                             '        a: 1001,',
                             '        b: 2020,',
                             '        c: 3333,',
                             '      }'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multiline word array' do
        inspect_source(cop, ['ingredients = %w(',
                             '  sausage',
                             '  anchovies',
                             '  olives',
                             ')'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        inspect_source(cop, ['route(help: {',
                             "  'auth' => <<-HELP.chomp",
                             '...',
                             'HELP',
                             '})'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty hash being passed as a method argument' do
        inspect_source(cop, 'Foo.new({})')
        inspect_source(cop, ['Foo.new({',
                             '         })'])
        inspect_source(cop, ['Foo.new([',
                             '         ])'])
        expect(cop.offenses).to be_empty
      end

      it 'auto-corrects an Array literal with two of the values on the same' \
         ' line and a trailing comma' do
        new_source = autocorrect_source(cop, ['VALUES = [',
                                              '           1001, 2020,',
                                              '           3333',
                                              '         ]'])
        expect(new_source).to eq(['VALUES = [',
                                  '           1001, 2020,',
                                  '           3333',
                                  '         ]'].join("\n"))
      end

      it 'auto-corrects missing comma in a Hash literal' do
        new_source = autocorrect_source(cop, ['MAP = { a: 1001,',
                                              '        b: 2020,',
                                              '        c: 3333',
                                              '}'])
        expect(new_source).to eq(['MAP = { a: 1001,',
                                  '        b: 2020,',
                                  '        c: 3333,',
                                  '}'].join("\n"))
      end

      it 'accepts a multiline array with a single item and trailing comma' do
        inspect_source(cop, ['foo = [',
                             '  1,',
                             ']'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multiline hash with a single pair and trailing comma' do
        inspect_source(cop, ['bar = {',
                             '  a: 123,',
                             '}'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'when EnforcedStyleForMultiline is consistent_comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'consistent_comma' } }

      context 'when closing bracket is on same line as last value' do
        it 'registers an offense for an Array literal with no trailing comma' do
          inspect_source(cop, ['VALUES = [',
                               '           1001,',
                               '           2020,',
                               '           3333]'])
          expect(cop.messages)
            .to eq(['Put a comma after the last item of a multiline array.'])
        end

        it 'registers an offense for a Hash literal with no trailing comma' do
          inspect_source(cop, ['VALUES = {',
                               '           a: "b",',
                               '           b: "c",',
                               '           d: "e"}'])
          expect(cop.messages)
            .to eq(['Put a comma after the last item of a multiline hash.'])
        end

        it 'auto-corrects a missing comma in a Hash literal' do
          new_source = autocorrect_source(cop, ['MAP = { a: 1001,',
                                                '        b: 2020,',
                                                '        c: 3333}'])
          expect(new_source).to eq(['MAP = { a: 1001,',
                                    '        b: 2020,',
                                    '        c: 3333,}'].join("\n"))
        end
      end

      it 'accepts Array literal with two of the values on the same line' do
        inspect_source(cop, ['VALUES = [',
                             '           1001, 2020,',
                             '           3333,',
                             '         ]'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for an Array literal with two of the values ' \
         'on the same line and no trailing comma' do
        inspect_source(cop, ['VALUES = [',
                             '           1001, 2020,',
                             '           3333',
                             '         ]'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline array.'])
      end

      it 'registers an offense for no trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333',
                             '}'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline hash.'])
        expect(cop.highlights).to eq(['c: 3333'])
      end

      it 'accepts trailing comma in an Array literal' do
        inspect_source(cop, ['VALUES = [1001,',
                             '          2020,',
                             '          3333,',
                             '         ]'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = {',
                             '        a: 1001,',
                             '        b: 2020,',
                             '        c: 3333,',
                             '      }'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multiline word array' do
        inspect_source(cop, ['ingredients = %w(',
                             '  sausage',
                             '  anchovies',
                             '  olives',
                             ')'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        inspect_source(cop, ['route(help: {',
                             "  'auth' => <<-HELP.chomp",
                             '...',
                             'HELP',
                             '})'])
        expect(cop.offenses).to be_empty
      end

      it 'auto-corrects an Array literal with two of the values on the same' \
         ' line and a trailing comma' do
        new_source = autocorrect_source(cop, ['VALUES = [',
                                              '           1001, 2020,',
                                              '           3333',
                                              '         ]'])
        expect(new_source).to eq(['VALUES = [',
                                  '           1001, 2020,',
                                  '           3333,',
                                  '         ]'].join("\n"))
      end

      it 'auto-corrects missing comma in a Hash literal' do
        new_source = autocorrect_source(cop, ['MAP = { a: 1001,',
                                              '        b: 2020,',
                                              '        c: 3333',
                                              '}'])
        expect(new_source).to eq(['MAP = { a: 1001,',
                                  '        b: 2020,',
                                  '        c: 3333,',
                                  '}'].join("\n"))
      end

      it 'accepts a multiline array with a single item and trailing comma' do
        inspect_source(cop, ['foo = [',
                             '  1,',
                             ']'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a multiline hash with a single pair and trailing comma' do
        inspect_source(cop, ['bar = {',
                             '  a: 123,',
                             '}'])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
