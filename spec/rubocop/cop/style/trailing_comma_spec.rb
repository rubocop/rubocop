# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrailingComma, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyleForMultiline' => 'no_comma' } }

  context 'with single line list of values' do
    it 'registers an offence for trailing comma in an Array literal' do
      inspect_source(cop, 'VALUES = [1001, 2020, 3333, ]')
      expect(cop.messages)
        .to eq(['Avoid comma after the last item of an array.'])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offence for trailing comma in a Hash literal' do
      inspect_source(cop, 'MAP = { a: 1001, b: 2020, c: 3333, }')
      expect(cop.messages)
        .to eq(['Avoid comma after the last item of a hash.'])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offence for trailing comma in a method call' do
      inspect_source(cop, 'some_method(a, b, c, )')
      expect(cop.messages)
        .to eq(['Avoid comma after the last parameter of a method call.'])
      expect(cop.highlights).to eq([','])
    end

    it 'registers an offence for trailing comma in a method call with hash' \
      ' parameters at the end' do
      inspect_source(cop, 'some_method(a, b, c: 0, d: 1, )')
      expect(cop.messages)
        .to eq(['Avoid comma after the last parameter of a method call.'])
      expect(cop.highlights).to eq([','])
    end

    it 'accepts Array literal without trailing comma' do
      inspect_source(cop, 'VALUES = [1001, 2020, 3333]')
      expect(cop.offences).to be_empty
    end

    it 'accepts empty Array literal' do
      inspect_source(cop, 'VALUES = []')
      expect(cop.offences).to be_empty
    end

    it 'accepts rescue clause' do
      # The list of rescued classes is an array.
      inspect_source(cop, ['begin',
                           '  do_something',
                           'rescue RuntimeError',
                           'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts Hash literal without trailing comma' do
      inspect_source(cop, 'MAP = { a: 1001, b: 2020, c: 3333 }')
      expect(cop.offences).to be_empty
    end

    it 'accepts empty Hash literal' do
      inspect_source(cop, 'MAP = {}')
      expect(cop.offences).to be_empty
    end

    it 'accepts method call without trailing comma' do
      inspect_source(cop, 'some_method(a, b, c)')
      expect(cop.offences).to be_empty
    end

    it 'accepts method call without parameters' do
      inspect_source(cop, 'some_method')
      expect(cop.offences).to be_empty
    end
  end

  context 'with multi-line list of values' do
    context 'when EnforcedStyleForMultiline is no_comma' do
      it 'registers an offence for trailing comma in an Array literal' do
        inspect_source(cop, ['VALUES = [',
                             '           1001,',
                             '           2020,',
                             '           3333,',
                             '         ]'])
        expect(cop.highlights).to eq([','])
      end

      it 'registers an offence for trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333,',
                             '      }'])
        expect(cop.highlights).to eq([','])
      end

      it 'registers an offence for trailing comma in a method call with ' \
        'hash parameters at the end' do
        inspect_source(cop, ['some_method(',
                             '              a,',
                             '              b,',
                             '              c: 0,',
                             '              d: 1,)'])
        expect(cop.highlights).to eq([','])
      end

      it 'accepts an Array literal with no trailing comma' do
        inspect_source(cop, ['VALUES = [ 1001,',
                             '           2020,',
                             '           3333 ]'])
        expect(cop.offences).to be_empty
      end

      it 'accepts a Hash literal with no trailing comma' do
        inspect_source(cop, ['MAP = {',
                             '        a: 1001,',
                             '        b: 2020,',
                             '        c: 3333',
                             '      }'])
        expect(cop.offences).to be_empty
      end

      it 'accepts a method call with ' \
        'hash parameters at the end and no trailing comma' do
        inspect_source(cop, ['some_method(a,',
                             '            b,',
                             '            c: 0,',
                             '            d: 1',
                             '           )'])
        expect(cop.offences).to be_empty
      end

      it 'accepts comma inside a heredoc' \
        ' parameters at the end' do
        inspect_source(cop, ['route(help: {',
                             "  'auth' => <<-HELP.chomp",
                             ',',
                             'HELP',
                             '})'])
        expect(cop.offences).to be_empty
      end
    end

    context 'when EnforcedStyleForMultiline is comma' do
      let(:cop_config) { { 'EnforcedStyleForMultiline' => 'comma' } }

      it 'registers an offence for no trailing comma in an Array literal' do
        inspect_source(cop, ['VALUES = [',
                             '           1001,',
                             '           2020,',
                             '           3333]'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline array.'])
        expect(cop.highlights).to eq(['3333'])
      end

      it 'registers an offence for no trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = { a: 1001,',
                             '        b: 2020,',
                             '        c: 3333 }'])
        expect(cop.messages)
          .to eq(['Put a comma after the last item of a multiline hash.'])
        expect(cop.highlights).to eq(['c: 3333'])
      end

      it 'registers an offence for no trailing comma in a method call with' \
        ' hash parameters at the end' do
        inspect_source(cop, ['some_method(',
                             '              a,',
                             '              b,',
                             '              c: 0,',
                             '              d: 1',
                             '           )'])
        expect(cop.messages)
          .to eq(['Put a comma after the last parameter of a multiline ' \
                  'method call.'])
        expect(cop.highlights).to eq(['d: 1'])
      end

      it 'accepts trailing comma in an Array literal' do
        inspect_source(cop, ['VALUES = [1001,',
                             '          2020,',
                             '          3333,',
                             '         ]'])
        expect(cop.offences).to be_empty
      end

      it 'accepts trailing comma in a Hash literal' do
        inspect_source(cop, ['MAP = {',
                             '        a: 1001,',
                             '        b: 2020,',
                             '        c: 3333,',
                             '      }'])
        expect(cop.offences).to be_empty
      end

      it 'accepts trailing comma in a method call with hash' \
        ' parameters at the end' do
        inspect_source(cop, ['some_method(',
                             '              a,',
                             '              b,',
                             '              c: 0,',
                             '              d: 1,',
                             '           )'])
        expect(cop.offences).to be_empty
      end

      it 'accepts a multiline word array' do
        inspect_source(cop, ['ingredients = %w(',
                             '  sausage',
                             '  anchovies',
                             '  olives',
                             ')'])
        expect(cop.offences).to be_empty
      end

      it 'accepts missing comma after a heredoc' do
        # A heredoc that's the last item in a literal or parameter list can not
        # have a trailing comma. It's a syntax error.
        inspect_source(cop, ['route(help: {',
                             "  'auth' => <<-HELP.chomp",
                             '...',
                             'HELP',
                             '},)']) # We still need a comma after the hash.
        expect(cop.offences).to be_empty
      end
    end
  end
end
